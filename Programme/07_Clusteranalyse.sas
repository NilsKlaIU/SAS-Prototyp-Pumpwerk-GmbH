/* ============================================================
   07_Clusteranalyse.sas

   Zweck:
   Gruppierung ähnlicher Produktionsbedingungen mithilfe
   einer K-Means-Clusteranalyse.

   Verwendete Clustermerkmale:
   - Bearbeitungstemperatur
   - Montagezeit
   - Drehmoment
   - Maschinenlaufzeit
   - Mitarbeitererfahrung

   Annahme:
   Für den Prototyp werden drei Cluster gebildet.
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Benutzerfreundliches Format für die Qualitätsvariable
   ============================================================ */

proc format;

    value qualfmt
        0 = "Nein"
        1 = "Ja";

    value clusterfmt
        1 = "Cluster 1"
        2 = "Cluster 2"
        3 = "Cluster 3";

run;

/* ============================================================
   2. Vollständige Beobachtungen auswählen

   Beobachtungen mit mindestens einem fehlenden Wert in den
   Clustermerkmalen werden nicht für die Clusterbildung
   verwendet.
   ============================================================ */

data work.cluster_basis;

    set qanal.analyse;

    if nmiss(

        Bearbeitungstemperatur_C,
        Montagezeit_Min,
        Drehmoment_Nm,
        Maschinenlaufzeit_Min,
        Mitarbeitererfahrung_Jahre

    ) = 0;

run;

/* ============================================================
   3. Anzahl verwendeter und ausgeschlossener Datensätze prüfen
   ============================================================ */

/* Anzahl der Datensätze in Makrovariablen speichern */

proc sql noprint;

    select count(*)
    into :anzahl_gesamt trimmed
    from qanal.analyse;

    select count(*)
    into :anzahl_verwendet trimmed
    from work.cluster_basis;

quit;


/* Kontrolltabelle erzeugen */

data work.cluster_datengrundlage;

    Anzahl_Gesamt =
        &anzahl_gesamt;

    Anzahl_Verwendet =
        &anzahl_verwendet;

    Anzahl_Ausgeschlossen =
        Anzahl_Gesamt - Anzahl_Verwendet;

    label
        Anzahl_Gesamt=
            "Gesamtdatensätze"

        Anzahl_Verwendet=
            "Verwendete Datensätze"

        Anzahl_Ausgeschlossen=
            "Ausgeschlossene Datensätze";

run;


/* Kontrolltabelle ausgeben */

title "Datengrundlage der Clusteranalyse";

proc print
    data=work.cluster_datengrundlage
    noobs
    label;
run;

title;

/* ============================================================
   4. Clustermerkmale standardisieren

   Die Standardisierung transformiert die verwendeten
   Variablen auf einen Mittelwert von 0 und eine
   Standardabweichung von 1.

   Dadurch können Variablen mit unterschiedlichen Einheiten
   gemeinsam in der Clusteranalyse verwendet werden.
   ============================================================ */

proc standard

    data=work.cluster_basis
    mean=0
    std=1
    out=work.cluster_standardisiert;

    var

        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Maschinenlaufzeit_Min
        Mitarbeitererfahrung_Jahre;

run;


/* ============================================================
   5. K-Means-Clusteranalyse

   MAXCLUSTERS=3:
   Es werden drei Cluster gebildet.

   MAXITER=100:
   Maximal 100 Iterationen.

   CONVERGE=0.001:
   Abbruch, sobald sich die Clusterzentren nur noch
   geringfügig verändern.
   ============================================================ */

title "Clusteranalyse der Produktionsbedingungen";

proc fastclus

    data=work.cluster_standardisiert
    maxclusters=3
    maxiter=100
    converge=0.001
    out=work.cluster_zuordnung
    outstat=qanal.cluster_statistik;

    var

        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Maschinenlaufzeit_Min
        Mitarbeitererfahrung_Jahre;

    id Pumpen_ID;

run;


/* ============================================================
   6. Clusterzuordnung mit den ursprünglichen Daten verbinden

   Die Cluster wurden mit standardisierten Werten berechnet.
   Für die Interpretation werden anschließend wieder die
   ursprünglichen Messwerte verwendet.
   ============================================================ */

proc sql;

    create table qanal.cluster_analyse as

    select

        a.*,
        b.Cluster

    from qanal.analyse as a

    inner join

        (
            select
                Pumpen_ID,
                Cluster

            from work.cluster_zuordnung
        )

        as b

    on a.Pumpen_ID = b.Pumpen_ID;

quit;


/* ============================================================
   7. Zusammenführung der Clusterzuordnung kontrollieren
   ============================================================ */

proc sql;

    title "Kontrolle der Clusterzuordnung";

    select

        count(*)
            as Anzahl_Beobachtungen,

        count(distinct Pumpen_ID)
            as Eindeutige_Pumpen,

        sum(missing(Cluster))
            as Fehlende_Clusterzuordnungen

    from qanal.cluster_analyse;

quit;


/* ============================================================
   8. Anzahl der Beobachtungen je Cluster
   ============================================================ */

title "Anzahl der Beobachtungen je Cluster";

proc freq data=qanal.cluster_analyse;

    tables
        Cluster
        / missing;

run;


/* ============================================================
   9. Produktionsbedingungen der Cluster beschreiben
   ============================================================ */

title "Produktionsbedingungen nach Cluster";

proc means

    data=qanal.cluster_analyse
    n
    mean
    std
    min
    max
    maxdec=2;

    class Cluster;

    var

        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Maschinenlaufzeit_Min
        Mitarbeitererfahrung_Jahre;

run;


/* ============================================================
   10. Qualitätskennzahlen der Cluster beschreiben

   Diese Variablen wurden nicht zur Clusterbildung verwendet.
   Sie dienen ausschließlich zur nachträglichen Beschreibung
   und Bewertung der Cluster.
   ============================================================ */

title "Qualitätskennzahlen nach Cluster";

proc means

    data=qanal.cluster_analyse
    n
    mean
    std
    min
    max
    maxdec=2;

    class Cluster;

    var

        Pruefdruck_bar
        Dichtheitsverlust_bar
        Vibration_mm_s
        Ausschusskosten_EUR
        Qualitaetsabweichung;

run;


/* ============================================================
   11. Qualitätsabweichung nach Cluster

   Nacharbeit und Ausschuss sind in der binären Variable
   Qualitaetsabweichung gemeinsam als Ja codiert.

   Dadurch entstehen größere Zellhäufigkeiten als bei einer
   Kreuztabelle mit den drei ursprünglichen Prüfergebnissen.
   ============================================================ */

title "Qualitätsabweichung nach Cluster";

proc freq data=qanal.cluster_analyse;

    format
        Cluster clusterfmt.
        Qualitaetsabweichung qualfmt.;

    tables
        Cluster * Qualitaetsabweichung
        / chisq
          expected
          norow;

run;


/* ============================================================
   12. Abweichungsquote je Cluster direkt berechnen
   ============================================================ */

proc sql;

    create table qanal.quote_cluster as

    select

        Cluster,

        count(*)
            as Anzahl_Pumpen,

        sum(Qualitaetsabweichung)
            as Anzahl_Abweichungen,

        calculated Anzahl_Abweichungen
        /
        calculated Anzahl_Pumpen
            as Abweichungsquote
            format=percent8.2

    from qanal.cluster_analyse

    where
        not missing(Qualitaetsabweichung)

    group by Cluster

    order by Cluster;

quit;


title "Qualitätsabweichungsquote nach Cluster";

proc print data=qanal.quote_cluster noobs;
run;


/* ============================================================
   13. Grafische Darstellung der Cluster

   Die Darstellung verwendet zwei der fünf Clustermerkmale:
   Bearbeitungstemperatur und Montagezeit.
   ============================================================ */

ods graphics
    / reset=index
      imagename="07_Cluster_Temperatur_Montagezeit"
      width=9in
      height=5.5in;


title "Cluster nach Bearbeitungstemperatur und Montagezeit";

proc sgplot data=qanal.cluster_analyse;

	format Cluster clusterfmt.;

    scatter

        x=Bearbeitungstemperatur_C
        y=Montagezeit_Min

        / group=Cluster
          transparency=0.10;

    xaxis
        label="Bearbeitungstemperatur in Grad Celsius"
        grid;

    yaxis
        label="Montagezeit in Minuten"
        grid;

    keylegend
        / title="Cluster"
          location=inside
          position=topright;

run;


/* ============================================================
   14. Qualitätsabweichungsquote nach Cluster visualisieren
   ============================================================ */

ods graphics
    / reset=index
      imagename="08_Abweichungsquote_Cluster"
      width=9in
      height=5.5in;

title "Qualitätsabweichungsquote nach Cluster";

proc sgplot data=qanal.quote_cluster;

    format Cluster clusterfmt.;

    vbarparm
        category=Cluster
        response=Abweichungsquote
        / datalabel;

    xaxis
        label="Cluster"
        discreteorder=data;

    yaxis
        label="Abweichungsquote"
        valuesformat=percent8.0
        grid;

run;


/* ============================================================
   15. Titel und Grafikeinstellungen zurücksetzen
   ============================================================ */

title;

ods graphics
    / reset=index;
/* ============================================================
   06_Visualisierungen.sas

   Zweck:
   Grafische Darstellung zentraler Ergebnisse des Prototyps.

   Eingabedatensatz:
   - QANAL.ANALYSE
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Benutzerfreundliches Format für die Analysevariable

   0 = keine Qualitätsabweichung
   1 = Qualitätsabweichung vorhanden
   ============================================================ */

proc format;

    value qualfmt
        0 = "Nein"
        1 = "Ja";

run;


ods graphics on;


/* ============================================================
   2. Verteilung der Prüfergebnisse
   ============================================================ */

proc sql;

    create table work.pruefergebnis_grafik as

    select

        case
            when Pruefergebnis = "Bestanden" then 1
            when Pruefergebnis = "Nacharbeit" then 2
            when Pruefergebnis = "Ausschuss" then 3
            else 4
        end
        as Reihenfolge,

        Pruefergebnis,

        count(*)
        as Anzahl

    from qanal.analyse

    group by
        calculated Reihenfolge,
        Pruefergebnis

    order by Reihenfolge;

quit;


ods graphics
    / reset=index
      imagename="01_Pruefergebnisse"
      width=9in
      height=5.5in;


title "Verteilung der Prüfergebnisse";

proc sgplot data=work.pruefergebnis_grafik;

    vbarparm
        category=Pruefergebnis
        response=Anzahl
        / datalabel;

    xaxis
        label="Prüfergebnis"
        discreteorder=data;

    yaxis
        label="Anzahl der Pumpen"
        grid;

run;

/* ============================================================
   3. Abweichungsquote nach Produktionslinie

   Zunächst wird eine separate Tabelle mit den
   Abweichungsquoten erstellt.
   ============================================================ */

proc sql;

    create table work.quote_linie_grafik as

    select

        Produktionslinie,

        count(*)
            as Anzahl_Pumpen,

        sum(Qualitaetsabweichung)
            as Anzahl_Abweichungen,

        calculated Anzahl_Abweichungen
        /
        calculated Anzahl_Pumpen
            as Abweichungsquote
            format=percent8.2

    from qanal.analyse

    where
        not missing(Produktionslinie)
        and
        not missing(Qualitaetsabweichung)

    group by Produktionslinie

    order by Abweichungsquote desc;

quit;


ods graphics
    / reset=index
      imagename="02_Abweichungsquote_Linie"
      width=9in
      height=5.5in;


title "Qualitätsabweichungsquote nach Produktionslinie";

proc sgplot data=work.quote_linie_grafik;

    vbarparm
    	category=Produktionslinie
    	response=Abweichungsquote
    	/ datalabel;

    xaxis
        label="Produktionslinie"
        discreteorder=data;

    yaxis
        label="Abweichungsquote"
        valuesformat=percent8.0
        grid;

run;


/* ============================================================
   4. Montagezeit nach Prüfergebnis

   Der Boxplot zeigt Median, Quartile und statistisch
   auffällige Montagezeiten.
   ============================================================ */

ods graphics
    / reset=index
      imagename="03_Boxplot_Montagezeit"
      width=9in
      height=5.5in;


title "Montagezeit nach Prüfergebnis";

proc sgplot data=qanal.analyse;

    vbox Montagezeit_Min
        / category=Pruefergebnis;

    xaxis
        label="Prüfergebnis";

    yaxis
        label="Montagezeit in Minuten"
        grid;

run;


/* ============================================================
   5. Zusammenhang zwischen Prüfdruck und Dichtheitsverlust
   ============================================================ */

ods graphics
    / reset=index
      imagename="04_Pruefdruck_Dichtheitsverlust"
      width=9in
      height=5.5in;


title "Zusammenhang zwischen Prüfdruck und Dichtheitsverlust";

proc sgplot data=qanal.analyse;

    scatter

        x=Pruefdruck_bar
        y=Dichtheitsverlust_bar

        / group=Pruefergebnis
          transparency=0.15;

    xaxis
        label="Prüfdruck in bar"
        grid;

    yaxis
        label="Dichtheitsverlust in bar"
        grid;

    keylegend
        / title="Prüfergebnis"
          location=inside
          position=topright;

run;


/* ============================================================
   6. Vibration nach Pumpentyp
   ============================================================ */

ods graphics
    / reset=index
      imagename="05_Vibration_Pumpentyp"
      width=9in
      height=5.5in;


title "Vibration nach Pumpentyp";

proc sgplot data=qanal.analyse;

    vbox Vibration_mm_s
        / category=Pumpentyp;

    xaxis
        label="Pumpentyp";

    yaxis
        label="Vibration in Millimeter pro Sekunde"
        grid;

run;


/* ============================================================
   7. Bearbeitungstemperatur und Montagezeit

   Die Gruppenvariable wird mit Nein und Ja statt mit
   den Werten 0 und 1 dargestellt.
   ============================================================ */

ods graphics
    / reset=index
      imagename="06_Temperatur_Montagezeit"
      width=9in
      height=5.5in;


title "Bearbeitungstemperatur und Montagezeit";

proc sgplot data=qanal.analyse;

    format
        Qualitaetsabweichung qualfmt.;

    scatter

        x=Bearbeitungstemperatur_C
        y=Montagezeit_Min

        / group=Qualitaetsabweichung
          transparency=0.15;

    xaxis
        label="Bearbeitungstemperatur in Grad Celsius"
        grid;

    yaxis
        label="Montagezeit in Minuten"
        grid;

    keylegend
        / title="Qualitätsabweichung"
          location=inside
          position=topright;

run;


/* ============================================================
   8. Titel und Grafikeinstellungen zurücksetzen
   ============================================================ */

title;

ods graphics
    / reset=index;
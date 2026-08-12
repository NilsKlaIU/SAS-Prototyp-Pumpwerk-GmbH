/* ============================================================
   08_Ergebnisexport.sas

   Zweck:
   Erstellung eines final formatierten PDF-Ergebnisberichts.

   Voraussetzungen:
   Die Programme 01 bis 07 wurden bereits ausgeführt.

   Ausgabe:
   Ergebnisse/Analysebericht_Pumpwerk.pdf
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Berichtseinstellungen
   ============================================================ */

%let berichtdatum=%sysfunc(today(),ddmmyy10.);

options
    orientation=portrait
    papersize=A4
    topmargin=1.4cm
    bottommargin=1.4cm
    leftmargin=1.5cm
    rightmargin=1.5cm;

ods escapechar='^';
ods noproctitle;


/* ============================================================
   2. Formate
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
   3. Hilfstabellen für den formatierten Bericht
   ============================================================ */

/* 3.1 Zentrale Qualitätskennzahlen */

proc sql;

    create table work.kpi_gesamt as

    select
        count(*) as Anzahl_Pumpen,

        sum(Pruefergebnis="Bestanden")
            as Bestanden,

        sum(Pruefergebnis="Nacharbeit")
            as Nacharbeit,

        sum(Pruefergebnis="Ausschuss")
            as Ausschuss,

        mean(Qualitaetsabweichung)
            as Abweichungsquote
            format=percent8.1

    from qanal.analyse;

quit;


/* 3.2 Geordnete Häufigkeiten der Prüfergebnisse */

proc sql;

    create table work.pruefergebnis_export as

    select

        case
            when Pruefergebnis="Bestanden" then 1
            when Pruefergebnis="Nacharbeit" then 2
            when Pruefergebnis="Ausschuss" then 3
            else 4
        end
        as Reihenfolge,

        Pruefergebnis,

        count(*)
            as Anzahl,

        count(*) /
        (
            select count(*)
            from qanal.analyse
        )
            as Anteil
            format=percent8.1

    from qanal.analyse

    group by
        calculated Reihenfolge,
        Pruefergebnis

    order by
        Reihenfolge;

quit;


/* 3.3 Kompakte Produktionskennzahlen */

proc sql;

    create table work.produktionskennzahlen as

    select

        case
            when Pruefergebnis="Bestanden" then 1
            when Pruefergebnis="Nacharbeit" then 2
            when Pruefergebnis="Ausschuss" then 3
            else 4
        end
        as Reihenfolge,

        Pruefergebnis,

        count(*)
            as Anzahl,

        mean(Bearbeitungstemperatur_C)
            as Temperatur
            format=8.2,

        mean(Montagezeit_Min)
            as Montagezeit
            format=8.2,

        mean(Drehmoment_Nm)
            as Drehmoment
            format=8.2,

        mean(Maschinenlaufzeit_Min)
            as Maschinenlaufzeit
            format=8.2,

        mean(Mitarbeitererfahrung_Jahre)
            as Erfahrung
            format=8.2

    from qanal.analyse

    group by
        calculated Reihenfolge,
        Pruefergebnis

    order by
        Reihenfolge;

quit;


/* 3.4 Kompakte Qualitätskennzahlen */

proc sql;

    create table work.qualitaetskennzahlen as

    select

        case
            when Pruefergebnis="Bestanden" then 1
            when Pruefergebnis="Nacharbeit" then 2
            when Pruefergebnis="Ausschuss" then 3
            else 4
        end
        as Reihenfolge,

        Pruefergebnis,

        mean(Pruefdruck_bar)
            as Pruefdruck
            format=8.2,

        mean(Dichtheitsverlust_bar)
            as Dichtheitsverlust
            format=8.2,

        mean(Vibration_mm_s)
            as Vibration
            format=8.2,

        mean(Ausschusskosten_EUR)
            as Kosten
            format=nlmny12.2

    from qanal.analyse

    group by
        calculated Reihenfolge,
        Pruefergebnis

    order by
        Reihenfolge;

quit;


/* 3.5 Ausreißerzahlen mit verständlichen Bezeichnungen */

proc sql;

    create table work.ausreisser_export as

    select
        1 as Reihenfolge,
        "Bearbeitungstemperatur" as Messgroesse length=40,
        sum(Ausreisser_Temperatur) as Anzahl,
        sum(Ausreisser_Temperatur) / count(*)
            as Anteil format=percent8.1
    from qanal.analyse_ausreisser

    union all

    select
        2,
        "Montagezeit",
        sum(Ausreisser_Montagezeit),
        sum(Ausreisser_Montagezeit) / count(*)
    from qanal.analyse_ausreisser

    union all

    select
        3,
        "Drehmoment",
        sum(Ausreisser_Drehmoment),
        sum(Ausreisser_Drehmoment) / count(*)
    from qanal.analyse_ausreisser

    union all

    select
        4,
        "Prüfdruck",
        sum(Ausreisser_Pruefdruck),
        sum(Ausreisser_Pruefdruck) / count(*)
    from qanal.analyse_ausreisser

    union all

    select
        5,
        "Dichtheitsverlust",
        sum(Ausreisser_Dichtheitsverlust),
        sum(Ausreisser_Dichtheitsverlust) / count(*)
    from qanal.analyse_ausreisser

    union all

    select
        6,
        "Vibration",
        sum(Ausreisser_Vibration),
        sum(Ausreisser_Vibration) / count(*)
    from qanal.analyse_ausreisser

    order by
        Reihenfolge;

quit;


/* 3.6 Kompakte Produktionskennzahlen der Cluster */

proc sql;

    create table work.cluster_produktion as

    select
        Cluster,

        count(*)
            as Anzahl,

        mean(Bearbeitungstemperatur_C)
            as Temperatur
            format=8.2,

        mean(Montagezeit_Min)
            as Montagezeit
            format=8.2,

        mean(Drehmoment_Nm)
            as Drehmoment
            format=8.2,

        mean(Maschinenlaufzeit_Min)
            as Maschinenlaufzeit
            format=8.2,

        mean(Mitarbeitererfahrung_Jahre)
            as Erfahrung
            format=8.2

    from qanal.cluster_analyse

    group by
        Cluster

    order by
        Cluster;

quit;


/* 3.7 Kompakte Qualitätskennzahlen der Cluster */

proc sql;

    create table work.cluster_qualitaet as

    select
        Cluster,

        count(*)
            as Anzahl,

        mean(Pruefdruck_bar)
            as Pruefdruck
            format=8.2,

        mean(Dichtheitsverlust_bar)
            as Dichtheitsverlust
            format=8.2,

        mean(Vibration_mm_s)
            as Vibration
            format=8.2,

        mean(Ausschusskosten_EUR)
            as Kosten
            format=nlmny12.2,

        mean(Qualitaetsabweichung)
            as Abweichungsquote
            format=percent8.2

    from qanal.cluster_analyse

    group by
        Cluster

    order by
        Cluster;

quit;


/* ============================================================
   4. PDF-Ausgabe öffnen
   ============================================================ */

ods pdf

    file=
    "&ergebnispfad/Analysebericht_Pumpwerk.pdf"

    style=journal
    notoc;

ods graphics
    / reset=index
      width=7.0in
      height=4.2in;


/* ============================================================
   5. Titelseite
   ============================================================ */

title;
footnote;

ods text=" ";
ods text=" ";
ods text=
    "^{style [just=center font_size=22pt font_weight=bold]
    Qualitätsanalyse in der Pumpenproduktion}";

ods text=" ";
ods text=
    "^{style [just=center font_size=15pt font_weight=bold]
    Ergebnisbericht des SAS-Prototyps}";

ods text=" ";
ods text=" ";
ods text=
    "^{style [just=center font_size=11pt]
    Pumpwerk GmbH}";

ods text=" ";
ods text=
    "^{style [just=center font_size=10pt]
    Forschungsfrage: Welche produktionsbezogenen Einflussfaktoren eines
    Pumpenherstellers stehen im Zusammenhang mit Qualitätsabweichungen,
    und welchen Beitrag kann SAS Studio zu deren Analyse leisten?}";

ods text=" ";
ods text=
    "^{style [just=center font_size=10pt]
    Datengrundlage: 600 synthetisch erzeugte Produktionsvorgänge}";

ods text=
    "^{style [just=center font_size=10pt]
    Analysesoftware: SAS Studio}";

ods text=
    "^{style [just=center font_size=10pt]
    Berichtsstand: &berichtdatum}";

ods text=" ";
ods text=" ";
ods text=
    "^{style [just=center font_size=9pt font_style=italic]
    Hinweis: Die Ergebnisse dienen der Demonstration des
    SAS-Prototyps und erlauben keine unmittelbaren Aussagen
    über reale Produktionsprozesse.}";


/* Fußzeile ab Seite 2 */

footnote1

    j=l
    height=7pt
    "Quelle: Eigene Berechnung auf Basis synthetisch erzeugter Daten."

    j=r
    height=7pt
    "Seite ^{thispage}";


/* ============================================================
   6. Managementübersicht und Prüfergebnisse
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "1. Managementübersicht";


proc report
    data=work.kpi_gesamt
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center];

    columns
        Anzahl_Pumpen
        Bestanden
        Nacharbeit
        Ausschuss
        Abweichungsquote;

    define Anzahl_Pumpen /
        display
        "Untersuchte|Pumpen";

    define Bestanden /
        display
        "Bestanden";

    define Nacharbeit /
        display
        "Nacharbeit";

    define Ausschuss /
        display
        "Ausschuss";

    define Abweichungsquote /
        display
        "Qualitäts-|abweichungsquote"
        format=percent8.1;

run;


ods pdf startpage=never;

ods graphics
    / width=7.0in
      height=3.6in;

title1
    j=l
    height=12pt
    bold
    "Verteilung der Prüfergebnisse";


proc sgplot
    data=work.pruefergebnis_export
    noborder;

    vbarparm
        category=Pruefergebnis
        response=Anzahl

        / datalabel
          datalabelattrs=(size=9pt);

    xaxis
        label="Prüfergebnis"
        discreteorder=data;

    yaxis
        label="Anzahl der Pumpen"
        grid;

run;


/* ============================================================
   7. Produktionslinien
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "2. Qualitätsabweichungen nach Produktionslinie";


proc report
    data=qanal.quote_linie
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center];

    columns
        Produktionslinie
        Anzahl_Pumpen
        Anzahl_Abweichungen
        Abweichungsquote;

    define Produktionslinie /
        display
        "Produktionslinie";

    define Anzahl_Pumpen /
        display
        "Produzierte|Pumpen";

    define Anzahl_Abweichungen /
        display
        "Qualitäts-|abweichungen";

    define Abweichungsquote /
        display
        "Abweichungs-|quote"
        format=percent8.2;

run;


ods pdf startpage=never;

ods graphics
    / width=7.0in
      height=3.5in;

title1
    j=l
    height=12pt
    bold
    "Abweichungsquote im Vergleich";


proc sgplot
    data=qanal.quote_linie
    noborder;

    vbarparm
        category=Produktionslinie
        response=Abweichungsquote

        / datalabel
          datalabelattrs=(size=9pt);

    xaxis
        label="Produktionslinie"
        discreteorder=data;

    yaxis
        label="Abweichungsquote"
        valuesformat=percent8.0
        grid;

run;


/* ============================================================
   8. Weitere Produktionsmerkmale
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "3. Abweichungsquoten nach weiteren Produktionsmerkmalen";


ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Arbeitsschicht}";


proc report
    data=qanal.quote_schicht
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center
         font_size=8pt];

    columns
        Schicht
        Anzahl_Pumpen
        Anzahl_Abweichungen
        Abweichungsquote;

    define Schicht /
        display
        "Schicht";

    define Anzahl_Pumpen /
        display
        "Pumpen";

    define Anzahl_Abweichungen /
        display
        "Abweichungen";

    define Abweichungsquote /
        display
        "Quote"
        format=percent8.2;

run;


ods pdf startpage=never;

ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Pumpentyp}";


proc report
    data=qanal.quote_pumpentyp
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center
         font_size=8pt];

    columns
        Pumpentyp
        Anzahl_Pumpen
        Anzahl_Abweichungen
        Abweichungsquote;

    define Pumpentyp /
        display
        "Pumpentyp";

    define Anzahl_Pumpen /
        display
        "Pumpen";

    define Anzahl_Abweichungen /
        display
        "Abweichungen";

    define Abweichungsquote /
        display
        "Quote"
        format=percent8.2;

run;


ods pdf startpage=never;

ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Lieferant}";


proc report
    data=qanal.quote_lieferant
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center
         font_size=8pt];

    columns
        Lieferant
        Anzahl_Pumpen
        Anzahl_Abweichungen
        Abweichungsquote;

    define Lieferant /
        display
        "Lieferant";

    define Anzahl_Pumpen /
        display
        "Pumpen";

    define Anzahl_Abweichungen /
        display
        "Abweichungen";

    define Abweichungsquote /
        display
        "Quote"
        format=percent8.2;

run;


/* ============================================================
   9. Kennzahlen nach Prüfergebnis
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "4. Kennzahlen nach Prüfergebnis";


ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Produktionskennzahlen: Mittelwerte}";


proc report
    data=work.produktionskennzahlen
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center
         font_size=7.5pt]

    style(column)=
        [just=center
         font_size=7.5pt];

    columns
        Pruefergebnis
        Anzahl
        Temperatur
        Montagezeit
        Drehmoment
        Maschinenlaufzeit
        Erfahrung;

    define Pruefergebnis /
        display
        "Prüfergebnis";

    define Anzahl /
        display
        "N";

    define Temperatur /
        display
        "Temperatur|°C";

    define Montagezeit /
        display
        "Montagezeit|Min.";

    define Drehmoment /
        display
        "Drehmoment|Nm";

    define Maschinenlaufzeit /
        display
        "Maschinenlaufzeit|Min.";

    define Erfahrung /
        display
        "Erfahrung|Jahre";

run;


ods pdf startpage=never;

ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Qualitätskennzahlen: Mittelwerte}";


proc report
    data=work.qualitaetskennzahlen
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center
         font_size=8pt]

    style(column)=
        [just=center
         font_size=8pt];

    columns
        Pruefergebnis
        Pruefdruck
        Dichtheitsverlust
        Vibration
        Kosten;

    define Pruefergebnis /
        display
        "Prüfergebnis";

    define Pruefdruck /
        display
        "Prüfdruck|bar";

    define Dichtheitsverlust /
        display
        "Dichtheitsverlust|bar";

    define Vibration /
        display
        "Vibration|mm/s";

    define Kosten /
        display
        "Mittlere Kosten"
        format=nlmny12.2;

run;


ods text=
    "^{style [just=left font_size=8pt font_style=italic]
    Mittelwerte werden auf Basis der jeweils verfügbaren
    Beobachtungen berechnet.}";


/* ============================================================
   10. Montagezeit
   ============================================================ */

ods pdf startpage=now;

ods graphics
    / width=7.0in
      height=4.6in;

title1
    j=l
    height=14pt
    bold
    "5. Montagezeit nach Prüfergebnis";


proc sgplot
    data=qanal.analyse
    noborder;

    vbox Montagezeit_Min
        / category=Pruefergebnis;

    xaxis
        label="Prüfergebnis";

    yaxis
        label="Montagezeit in Minuten"
        grid;

run;


/* ============================================================
   11. Prüfdruck und Dichtheitsverlust
   ============================================================ */

ods pdf startpage=now;

ods graphics
    / width=7.0in
      height=4.6in;

title1
    j=l
    height=14pt
    bold
    "6. Zusammenhang zwischen Prüfdruck und Dichtheitsverlust";


proc sgplot
    data=qanal.analyse
    noborder;

    scatter
        x=Pruefdruck_bar
        y=Dichtheitsverlust_bar

        / group=Pruefergebnis
          transparency=0.25
          markerattrs=(size=6);

    xaxis
        label="Prüfdruck in bar"
        grid;

    yaxis
        label="Dichtheitsverlust in bar"
        grid;

    keylegend
        / title="Prüfergebnis"
          position=topright
          location=inside;

run;


/* ============================================================
   12. Ausreißeranalyse
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "7. Statistisch auffällige Messwerte";


proc report
    data=work.ausreisser_export
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center];

    columns
        Messgroesse
        Anzahl
        Anteil;

    define Messgroesse /
        display
        "Messgröße"
        style(column)=[just=left];

    define Anzahl /
        display
        "Anzahl";

    define Anteil /
        display
        "Anteil an allen Pumpen"
        format=percent8.1;

run;


ods pdf startpage=never;

ods graphics
    / width=7.0in
      height=3.5in;

title1
    j=l
    height=12pt
    bold
    "Anzahl auffälliger Werte nach Messgröße";


proc sgplot
    data=work.ausreisser_export
    noborder;

    vbarparm
        category=Messgroesse
        response=Anzahl

        / datalabel
          datalabelattrs=(size=8pt);

    xaxis
        label="Messgröße"
        discreteorder=data
        fitpolicy=rotate;

    yaxis
        label="Anzahl auffälliger Werte"
        grid;

run;


ods text=
    "^{style [just=left font_size=8pt font_style=italic]
    Statistische Ausreißer sind nicht automatisch fehlerhafte
    Messungen. Sie kennzeichnen Beobachtungen außerhalb der
    Grenzen des Standard-Boxplots nach Tukey.}";


/* ============================================================
   13. Clusterübersicht
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "8. Clusterübersicht und Qualitätsabweichungsquoten";


proc report
    data=qanal.quote_cluster
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center]

    style(column)=
        [just=center];

    format
        Cluster clusterfmt.;

    columns
        Cluster
        Anzahl_Pumpen
        Anzahl_Abweichungen
        Abweichungsquote;

    define Cluster /
        display
        "Cluster";

    define Anzahl_Pumpen /
        display
        "Pumpen";

    define Anzahl_Abweichungen /
        display
        "Qualitäts-|abweichungen";

    define Abweichungsquote /
        display
        "Abweichungs-|quote"
        format=percent8.2;

run;


ods pdf startpage=never;

ods graphics
    / width=7.0in
      height=3.5in;

title1
    j=l
    height=12pt
    bold
    "Abweichungsquote nach Cluster";


proc sgplot
    data=qanal.quote_cluster
    noborder;

    format
        Cluster clusterfmt.;

    vbarparm
        category=Cluster
        response=Abweichungsquote

        / datalabel
          datalabelattrs=(size=9pt);

    xaxis
        label="Cluster"
        discreteorder=data;

    yaxis
        label="Abweichungsquote"
        valuesformat=percent8.0
        grid;

run;


ods text=
    "^{style [just=left font_size=8pt font_style=italic]
    Cluster 1 umfasst nur drei Beobachtungen. Die Gruppe ist
    deshalb nicht als stabile oder verallgemeinerbare
    Produktionsgruppe zu interpretieren.}";


/* ============================================================
   14. Clusterkennzahlen
   ============================================================ */

ods pdf startpage=now;

title1
    j=l
    height=14pt
    bold
    "9. Beschreibung der Cluster";


ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Produktionsbedingungen: Mittelwerte}";


proc report
    data=work.cluster_produktion
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center
         font_size=7.5pt]

    style(column)=
        [just=center
         font_size=7.5pt];

    format
        Cluster clusterfmt.;

    columns
        Cluster
        Anzahl
        Temperatur
        Montagezeit
        Drehmoment
        Maschinenlaufzeit
        Erfahrung;

    define Cluster /
        display
        "Cluster";

    define Anzahl /
        display
        "N";

    define Temperatur /
        display
        "Temperatur|°C";

    define Montagezeit /
        display
        "Montagezeit|Min.";

    define Drehmoment /
        display
        "Drehmoment|Nm";

    define Maschinenlaufzeit /
        display
        "Maschinenlaufzeit|Min.";

    define Erfahrung /
        display
        "Erfahrung|Jahre";

run;


ods pdf startpage=never;

ods text=
    "^{style [just=left font_size=10pt font_weight=bold]
    Qualitätskennzahlen: Mittelwerte}";


proc report
    data=work.cluster_qualitaet
    nowd
    split='|'

    style(header)=
        [background=cxE6E6E6
         font_weight=bold
         just=center
         font_size=8pt]

    style(column)=
        [just=center
         font_size=8pt];

    format
        Cluster clusterfmt.;

    columns
        Cluster
        Anzahl
        Pruefdruck
        Dichtheitsverlust
        Vibration
        Kosten
        Abweichungsquote;

    define Cluster /
        display
        "Cluster";

    define Anzahl /
        display
        "N";

    define Pruefdruck /
        display
        "Prüfdruck|bar";

    define Dichtheitsverlust /
        display
        "Dichtheitsverlust|bar";

    define Vibration /
        display
        "Vibration|mm/s";

    define Kosten /
        display
        "Mittlere|Kosten"
        format=nlmny12.2;

    define Abweichungsquote /
        display
        "Abweichungs-|quote"
        format=percent8.2;

run;


/* ============================================================
   15. Grafische Clusterdarstellung
   ============================================================ */

ods pdf startpage=now;

ods graphics
    / width=7.0in
      height=4.6in;

title1
    j=l
    height=14pt
    bold
    "10. Cluster nach Bearbeitungstemperatur und Montagezeit";


proc sgplot
    data=qanal.cluster_analyse
    noborder;

    format
        Cluster clusterfmt.;

    scatter
        x=Bearbeitungstemperatur_C
        y=Montagezeit_Min

        / group=Cluster
          transparency=0.20
          markerattrs=(size=6);

    xaxis
        label="Bearbeitungstemperatur in Grad Celsius"
        grid;

    yaxis
        label="Montagezeit in Minuten"
        grid;

    keylegend
        / title="Cluster"
          position=topright
          location=inside;

run;


/* ============================================================
   16. PDF-Ausgabe schließen
   ============================================================ */

title;
footnote;

ods pdf close;

ods proctitle;

ods graphics
    / reset=index;

%put NOTE: Der formatierte PDF-Ergebnisbericht wurde erfolgreich gespeichert.;

/* ============================================================
   04_Deskriptive_Analyse.sas

   Zweck:
   Beschreibung der Qualitätslage sowie Untersuchung von
   Qualitätsabweichungen nach Produktionsmerkmalen.
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Gesamtverteilung
   ============================================================ */

title "Verteilung der Prüfergebnisse";

proc freq data=qanal.analyse;
    tables Pruefergebnis / missing;
run;


title "Anteil der Qualitätsabweichungen";

proc freq data=qanal.analyse;
    tables Qualitaetsabweichung / missing;
run;


title "Verteilung der Fehlerarten";

proc freq data=qanal.analyse;
    tables Fehlerart / missing;
run;


/* ============================================================
   2. Deskriptive Kennzahlen nach Prüfergebnis
   ============================================================ */

title "Produktions- und Prüfkennzahlen nach Prüfergebnis";

proc means
    data=qanal.analyse
    n
    mean
    std
    min
    q1
    median
    q3
    max
    maxdec=2;

    class Pruefergebnis;

    var
        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Maschinenlaufzeit_Min
        Mitarbeitererfahrung_Jahre
        Pruefdruck_bar
        Dichtheitsverlust_bar
        Vibration_mm_s
        Ausschusskosten_EUR;

run;


/* ============================================================
   3. Abweichungsquote nach Produktionslinie
   ============================================================ */

proc sql;

    create table qanal.quote_linie as

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

    where not missing(Produktionslinie)

    group by Produktionslinie

    order by Abweichungsquote desc;

quit;


title "Abweichungsquote nach Produktionslinie";

proc print data=qanal.quote_linie noobs;
run;


/* ============================================================
   4. Abweichungsquote nach Arbeitsschicht
   ============================================================ */

proc sql;

    create table qanal.quote_schicht as

    select

        Schicht,

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

    where not missing(Schicht)

    group by Schicht

    order by Abweichungsquote desc;

quit;


title "Abweichungsquote nach Arbeitsschicht";

proc print data=qanal.quote_schicht noobs;
run;


/* ============================================================
   5. Abweichungsquote nach Pumpentyp
   ============================================================ */

proc sql;

    create table qanal.quote_pumpentyp as

    select

        Pumpentyp,

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

    where not missing(Pumpentyp)

    group by Pumpentyp

    order by Abweichungsquote desc;

quit;


title "Abweichungsquote nach Pumpentyp";

proc print data=qanal.quote_pumpentyp noobs;
run;


/* ============================================================
   6. Abweichungsquote nach Lieferant
   ============================================================ */

proc sql;

    create table qanal.quote_lieferant as

    select

        Lieferant,

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

    where not missing(Lieferant)

    group by Lieferant

    order by Abweichungsquote desc;

quit;


title "Abweichungsquote nach Lieferant";

proc print data=qanal.quote_lieferant noobs;
run;


/* ============================================================
   7. Explorative Zusammenhangsprüfungen

   Die Chi-Quadrat-Tests werden explorativ eingesetzt.
   Aufgrund der synthetischen Daten erlauben sie keine
   Aussage über reale Produktionsprozesse.
   ============================================================ */

title
    "Zusammenhang zwischen Produktionslinie und Qualitätsabweichung";

proc freq data=qanal.analyse;

    tables
        Produktionslinie * Qualitaetsabweichung
        / chisq expected;

run;


title
    "Zusammenhang zwischen Schicht und Qualitätsabweichung";

proc freq data=qanal.analyse;

    tables
        Schicht * Qualitaetsabweichung
        / chisq expected;

run;


title
    "Zusammenhang zwischen Pumpentyp und Qualitätsabweichung";

proc freq data=qanal.analyse;

    tables
        Pumpentyp * Qualitaetsabweichung
        / chisq expected;

run;


title
    "Zusammenhang zwischen Lieferant und Qualitätsabweichung";

proc freq data=qanal.analyse;

    tables
        Lieferant * Qualitaetsabweichung
        / chisq expected;

run;

title;
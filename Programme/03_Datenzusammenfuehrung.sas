/* ============================================================
   03_Datenzusammenfuehrung.sas

   Zweck:
   Zusammenführung der drei Datenquellen über Pumpen_ID und
   Erstellung des Analysedatensatzes.
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Datenquellen zusammenführen
   ============================================================ */

proc sql;

    create table qanal.gesamtdaten as

    select

        a.Pumpen_ID,
        a.Pumpentyp,
        a.Produktionsdatum,
        a.Produktionslinie,
        a.Schicht,
        a.Materialcharge,
        a.Lieferant,

        b.Bearbeitungstemperatur_C,
        b.Montagezeit_Min,
        b.Drehmoment_Nm,
        b.Maschinenlaufzeit_Min,
        b.Mitarbeitererfahrung_Jahre,
        b.Nacharbeit_vor_Pruefung,

        c.Pruefdruck_bar,
        c.Dichtheitsverlust_bar,
        c.Vibration_mm_s,
        c.Pruefergebnis,
        c.Fehlerart,
        c.Ausschusskosten_EUR

    from qanal.raw_stammdaten as a

    left join qanal.raw_produktionsdaten as b

        on a.Pumpen_ID = b.Pumpen_ID

    left join qanal.raw_qualitaetspruefung as c

        on a.Pumpen_ID = c.Pumpen_ID;

quit;


/* ============================================================
   2. Analysevariable erzeugen

   0 = Qualitätsprüfung bestanden
   1 = Nacharbeit oder Ausschuss
   ============================================================ */

data qanal.analyse;

    set qanal.gesamtdaten;

    if missing(Pruefergebnis) then
        Qualitaetsabweichung = .;

    else if Pruefergebnis = "Bestanden" then
        Qualitaetsabweichung = 0;

    else if Pruefergebnis in
        ("Nacharbeit", "Ausschuss") then
        Qualitaetsabweichung = 1;

    label
        Qualitaetsabweichung=
        "Qualitätsabweichung: 0=Nein, 1=Ja";

run;


/* ============================================================
   3. Zusammenführung kontrollieren
   ============================================================ */

proc sql;

    title "Kontrolle der Zusammenführung";

    select

        count(*) as Anzahl_Beobachtungen,

        count(distinct Pumpen_ID)
            as Eindeutige_Pumpen,

        sum(missing(Pumpentyp))
            as Fehlende_Stammdaten,

        sum(missing(Bearbeitungstemperatur_C))
    		as Fehlende_Temperaturwerte,

		sum(missing(Montagezeit_Min))
    		as Fehlende_Montagezeiten,

		sum(missing(Mitarbeitererfahrung_Jahre))
    		as Fehlende_Erfahrungswerte,

        sum(missing(Pruefergebnis))
            as Fehlende_Pruefergebnisse

    from qanal.analyse;

quit;


title "Kontrolle der Analysevariable";

proc freq data=qanal.analyse;

    tables
        Pruefergebnis * Qualitaetsabweichung
        / missing norow nocol nopercent;

run;

title;
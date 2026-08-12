/* ============================================================
   01_Datenimport.sas

   Zweck:
   Import der drei synthetischen CSV-Datenquellen.

   Eingaben:
   - produktionsdaten.csv
   - pumpen_stammdaten.csv
   - qualitaetspruefung.csv

   Ausgaben:
   - QANAL.RAW_PRODUKTIONSDATEN
   - QANAL.RAW_STAMMDATEN
   - QANAL.RAW_QUALITAETSPRUEFUNG
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Produktionsdaten
   ============================================================ */

data qanal.raw_produktionsdaten;

    infile "&quellpfad/produktionsdaten.csv"
        delimiter=';'
        dsd
        firstobs=2
        lrecl=32767
        truncover
        encoding='utf-8';

    length
        Pumpen_ID $5
        Nacharbeit_vor_Pruefung $4;

    input
        Pumpen_ID :$5.
        Bearbeitungstemperatur_C :best32.
        Montagezeit_Min :best32.
        Drehmoment_Nm :best32.
        Maschinenlaufzeit_Min :best32.
        Mitarbeitererfahrung_Jahre :best32.
        Nacharbeit_vor_Pruefung :$4.;

    label
        Pumpen_ID=
            "Pumpen-ID"

        Bearbeitungstemperatur_C=
            "Bearbeitungstemperatur in Grad Celsius"

        Montagezeit_Min=
            "Montagezeit in Minuten"

        Drehmoment_Nm=
            "Drehmoment in Newtonmeter"

        Maschinenlaufzeit_Min=
            "Maschinenlaufzeit in Minuten"

        Mitarbeitererfahrung_Jahre=
            "Mitarbeitererfahrung in Jahren"

        Nacharbeit_vor_Pruefung=
            "Nacharbeit vor der Qualitätsprüfung";

run;


/* ============================================================
   2. Pumpenstammdaten
   ============================================================ */

data qanal.raw_stammdaten;

    infile "&quellpfad/pumpen_stammdaten.csv"
        delimiter=';'
        dsd
        firstobs=2
        lrecl=32767
        truncover
        encoding='utf-8';

    length
        Pumpen_ID $5
        Pumpentyp $6
        Produktionslinie $7
        Schicht $8
        Materialcharge $6
        Lieferant $12;

    informat Produktionsdatum yymmdd10.;
    format Produktionsdatum ddmmyy10.;

    input
        Pumpen_ID :$5.
        Pumpentyp :$6.
        Produktionsdatum :yymmdd10.
        Produktionslinie :$7.
        Schicht :$8.
        Materialcharge :$6.
        Lieferant :$12.;

    label
        Pumpen_ID=
            "Pumpen-ID"

        Pumpentyp=
            "Pumpentyp"

        Produktionsdatum=
            "Produktionsdatum"

        Produktionslinie=
            "Produktionslinie"

        Schicht=
            "Arbeitsschicht"

        Materialcharge=
            "Materialcharge"

        Lieferant=
            "Lieferant";

run;


/* ============================================================
   3. Qualitätsprüfungen
   ============================================================ */

data qanal.raw_qualitaetspruefung;

    infile "&quellpfad/qualitaetspruefung.csv"
        delimiter=';'
        dsd
        firstobs=2
        lrecl=32767
        truncover
        encoding='utf-8';

    length
        Pumpen_ID $5
        Pruefergebnis $12
        Fehlerart $40;

    input
        Pumpen_ID :$5.
        Pruefdruck_bar :best32.
        Dichtheitsverlust_bar :best32.
        Vibration_mm_s :best32.
        Pruefergebnis :$12.
        Fehlerart :$40.
        Ausschusskosten_EUR :best32.;

    format Ausschusskosten_EUR nlmny12.2;

    label
        Pumpen_ID=
            "Pumpen-ID"

        Pruefdruck_bar=
            "Prüfdruck in bar"

        Dichtheitsverlust_bar=
            "Dichtheitsverlust in bar"

        Vibration_mm_s=
            "Vibration in Millimeter pro Sekunde"

        Pruefergebnis=
            "Ergebnis der Qualitätsprüfung"

        Fehlerart=
            "Fehlerart"

        Ausschusskosten_EUR=
            "Ausschuss- oder Nacharbeitskosten in Euro";

run;


/* ============================================================
   4. Kontrolle der importierten Datensatzgrößen
   ============================================================ */

proc sql;

    create table work.importkontrolle as

    select
        "Produktionsdaten" as Datenquelle length=30,
        count(*) as Anzahl_Beobachtungen

    from qanal.raw_produktionsdaten

    union all

    select
        "Pumpenstammdaten",
        count(*)

    from qanal.raw_stammdaten

    union all

    select
        "Qualitätsprüfungen",
        count(*)

    from qanal.raw_qualitaetspruefung;

quit;


title "Kontrolle des Datenimports";

proc print data=work.importkontrolle noobs;
run;

title;
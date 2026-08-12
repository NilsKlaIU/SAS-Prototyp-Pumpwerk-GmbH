/* ============================================================
   02_Datenpruefung.sas

   Zweck:
   Prüfung von Struktur, Vollständigkeit, Eindeutigkeit und
   Plausibilität der importierten Daten.
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Tabellenstruktur prüfen
   ============================================================ */

title "Struktur der Produktionsdaten";

proc contents data=qanal.raw_produktionsdaten;
run;


title "Struktur der Pumpenstammdaten";

proc contents data=qanal.raw_stammdaten;
run;


title "Struktur der Qualitätsprüfungen";

proc contents data=qanal.raw_qualitaetspruefung;
run;


/* ============================================================
   2. Erste Datensätze anzeigen
   ============================================================ */

title "Erste zehn Produktionsdatensätze";

proc print data=qanal.raw_produktionsdaten(obs=10);
run;


title "Erste zehn Pumpenstammdatensätze";

proc print data=qanal.raw_stammdaten(obs=10);
run;


title "Erste zehn Qualitätsprüfungen";

proc print data=qanal.raw_qualitaetspruefung(obs=10);
run;


/* ============================================================
   3. Doppelte Pumpen-IDs prüfen
   ============================================================ */

proc sql;

    title "Doppelte IDs in den Produktionsdaten";

    select
        Pumpen_ID,
        count(*) as Anzahl

    from qanal.raw_produktionsdaten

    group by Pumpen_ID

    having count(*) > 1;


    title "Doppelte IDs in den Pumpenstammdaten";

    select
        Pumpen_ID,
        count(*) as Anzahl

    from qanal.raw_stammdaten

    group by Pumpen_ID

    having count(*) > 1;


    title "Doppelte IDs in den Qualitätsprüfungen";

    select
        Pumpen_ID,
        count(*) as Anzahl

    from qanal.raw_qualitaetspruefung

    group by Pumpen_ID

    having count(*) > 1;

quit;


/* ============================================================
   4. Fehlende numerische Werte prüfen
   ============================================================ */

title "Fehlende Werte in den Produktionsdaten";

proc means data=qanal.raw_produktionsdaten n nmiss;

    var
        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Maschinenlaufzeit_Min
        Mitarbeitererfahrung_Jahre;

run;


title "Fehlende Werte in den Qualitätsprüfungen";

proc means data=qanal.raw_qualitaetspruefung n nmiss;

    var
        Pruefdruck_bar
        Dichtheitsverlust_bar
        Vibration_mm_s
        Ausschusskosten_EUR;

run;


/* ============================================================
   5. Häufigkeiten kategorialer Variablen prüfen
   ============================================================ */

title "Kategorien in den Pumpenstammdaten";

proc freq data=qanal.raw_stammdaten;

    tables
        Pumpentyp
        Produktionslinie
        Schicht
        Materialcharge
        Lieferant
        / missing;

run;


title "Kategorien in den Qualitätsprüfungen";

proc freq data=qanal.raw_qualitaetspruefung;

    tables
        Pruefergebnis
        Fehlerart
        / missing;

run;


/* ============================================================
   6. Einfache Plausibilitätsprüfungen

   Die verwendeten Grenzen sind Annahmen des Prototyps und
   stellen keine realen technischen Grenzwerte dar.
   ============================================================ */

title "Potenziell unplausible Produktionswerte";

proc print data=qanal.raw_produktionsdaten;

    where

        (
            not missing(Bearbeitungstemperatur_C)
            and
            (
                Bearbeitungstemperatur_C < 40
                or
                Bearbeitungstemperatur_C > 120
            )
        )

        or

        (
            not missing(Montagezeit_Min)
            and
            (
                Montagezeit_Min < 10
                or
                Montagezeit_Min > 120
            )
        )

        or

        (
            not missing(Drehmoment_Nm)
            and
            (
                Drehmoment_Nm < 20
                or
                Drehmoment_Nm > 90
            )
        )

        or

        (
            not missing(Maschinenlaufzeit_Min)
            and
            (
                Maschinenlaufzeit_Min < 15
                or
                Maschinenlaufzeit_Min > 140
            )
        )

        or

        (
            not missing(Mitarbeitererfahrung_Jahre)
            and
            (
                Mitarbeitererfahrung_Jahre < 0
                or
                Mitarbeitererfahrung_Jahre > 25
            )
        );

run;


title "Potenziell unplausible Prüfwerte";

proc print data=qanal.raw_qualitaetspruefung;

    where

        (
            not missing(Pruefdruck_bar)
            and
            (
                Pruefdruck_bar < 5
                or
                Pruefdruck_bar > 15
            )
        )

        or

        (
            not missing(Dichtheitsverlust_bar)
            and
            (
                Dichtheitsverlust_bar < 0
                or
                Dichtheitsverlust_bar > 2
            )
        )

        or

        (
            not missing(Vibration_mm_s)
            and
            (
                Vibration_mm_s < 0
                or
                Vibration_mm_s > 12
            )
        )

        or

        (
            not missing(Ausschusskosten_EUR)
            and
            Ausschusskosten_EUR < 0
        );

run;

title;
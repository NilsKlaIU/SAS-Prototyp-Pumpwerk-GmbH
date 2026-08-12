/* ============================================================
   05_Ausreisseranalyse.sas

   Zweck:
   Identifikation auffälliger numerischer Werte mithilfe der
   1,5-IQR-Regel.
   ============================================================ */

%include
    "/home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme/00_Konfiguration.sas";


/* ============================================================
   1. Erstes und drittes Quartil berechnen
   ============================================================ */

proc means data=qanal.analyse noprint;

    var
        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Pruefdruck_bar
        Dichtheitsverlust_bar
        Vibration_mm_s;

    output
        out=work.quartile
        (drop=_TYPE_ _FREQ_)

        q1=
        Q1_Temperatur
        Q1_Montagezeit
        Q1_Drehmoment
        Q1_Pruefdruck
        Q1_Dichtheitsverlust
        Q1_Vibration

        q3=
        Q3_Temperatur
        Q3_Montagezeit
        Q3_Drehmoment
        Q3_Pruefdruck
        Q3_Dichtheitsverlust
        Q3_Vibration;

run;


/* ============================================================
   2. Ausreißerkennzeichen erzeugen
   ============================================================ */

data qanal.analyse_ausreisser;

    if _n_=1 then
        set work.quartile;

    set qanal.analyse;


    IQR_Temperatur=
        Q3_Temperatur-Q1_Temperatur;

    IQR_Montagezeit=
        Q3_Montagezeit-Q1_Montagezeit;

    IQR_Drehmoment=
        Q3_Drehmoment-Q1_Drehmoment;

    IQR_Pruefdruck=
        Q3_Pruefdruck-Q1_Pruefdruck;

    IQR_Dichtheitsverlust=
        Q3_Dichtheitsverlust-Q1_Dichtheitsverlust;

    IQR_Vibration=
        Q3_Vibration-Q1_Vibration;


    Ausreisser_Temperatur =

        not missing(Bearbeitungstemperatur_C)

        and

        (
            Bearbeitungstemperatur_C
                <
            Q1_Temperatur-1.5*IQR_Temperatur

            or

            Bearbeitungstemperatur_C
                >
            Q3_Temperatur+1.5*IQR_Temperatur
        );


    Ausreisser_Montagezeit =

        not missing(Montagezeit_Min)

        and

        (
            Montagezeit_Min
                <
            Q1_Montagezeit-1.5*IQR_Montagezeit

            or

            Montagezeit_Min
                >
            Q3_Montagezeit+1.5*IQR_Montagezeit
        );


    Ausreisser_Drehmoment =

        not missing(Drehmoment_Nm)

        and

        (
            Drehmoment_Nm
                <
            Q1_Drehmoment-1.5*IQR_Drehmoment

            or

            Drehmoment_Nm
                >
            Q3_Drehmoment+1.5*IQR_Drehmoment
        );


    Ausreisser_Pruefdruck =

        not missing(Pruefdruck_bar)

        and

        (
            Pruefdruck_bar
                <
            Q1_Pruefdruck-1.5*IQR_Pruefdruck

            or

            Pruefdruck_bar
                >
            Q3_Pruefdruck+1.5*IQR_Pruefdruck
        );


    Ausreisser_Dichtheitsverlust =

        not missing(Dichtheitsverlust_bar)

        and

        (
            Dichtheitsverlust_bar
                <
            Q1_Dichtheitsverlust
                -1.5*IQR_Dichtheitsverlust

            or

            Dichtheitsverlust_bar
                >
            Q3_Dichtheitsverlust
                +1.5*IQR_Dichtheitsverlust
        );


    Ausreisser_Vibration =

        not missing(Vibration_mm_s)

        and

        (
            Vibration_mm_s
                <
            Q1_Vibration-1.5*IQR_Vibration

            or

            Vibration_mm_s
                >
            Q3_Vibration+1.5*IQR_Vibration
        );


    Anzahl_Ausreisser=sum(

        Ausreisser_Temperatur,
        Ausreisser_Montagezeit,
        Ausreisser_Drehmoment,
        Ausreisser_Pruefdruck,
        Ausreisser_Dichtheitsverlust,
        Ausreisser_Vibration

    );


    label
        Anzahl_Ausreisser=
        "Anzahl auffälliger Messgrößen";


    drop
        Q1_:
        Q3_:
        IQR_:;

run;


/* ============================================================
   3. Häufigkeit der Ausreißer ausgeben
   ============================================================ */

title "Anzahl der Ausreißer nach Messgröße";

proc means
    data=qanal.analyse_ausreisser
    sum
    maxdec=0;

    var
        Ausreisser_Temperatur
        Ausreisser_Montagezeit
        Ausreisser_Drehmoment
        Ausreisser_Pruefdruck
        Ausreisser_Dichtheitsverlust
        Ausreisser_Vibration;

run;


title "Beispiele auffälliger Produktions- und Prüfdatensätze";

proc print

    data=qanal.analyse_ausreisser
    (
        where=(Anzahl_Ausreisser>0)
        obs=30
    );

    var
        Pumpen_ID
        Pumpentyp
        Pruefergebnis
        Bearbeitungstemperatur_C
        Montagezeit_Min
        Drehmoment_Nm
        Pruefdruck_bar
        Dichtheitsverlust_bar
        Vibration_mm_s
        Anzahl_Ausreisser;

run;

title;
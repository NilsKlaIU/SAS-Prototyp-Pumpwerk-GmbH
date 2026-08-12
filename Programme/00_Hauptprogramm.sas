/* ============================================================
   00_Hauptprogramm.sas

   Führt den vollständigen Prototyp in der vorgesehenen
   Reihenfolge aus.
   ============================================================ */

%let programmepfad=
    /home/u64561142/sasuser.v94/Qualitaetsanalyse/Programme;

/* Zentrale Konfiguration */
%include "&programmepfad/00_Konfiguration.sas";

/* Verarbeitungsschritte */
%include "&programmepfad/01_Datenimport.sas";
%include "&programmepfad/02_Datenpruefung.sas";
%include "&programmepfad/03_Datenzusammenfuehrung.sas";
%include "&programmepfad/04_Deskriptive_Analyse.sas";
%include "&programmepfad/05_Ausreisseranalyse.sas";
%include "&programmepfad/06_Visualisierungen.sas";
%include "&programmepfad/07_Clusteranalyse.sas";
%include "&programmepfad/08_Ergebnisexport.sas";

%put NOTE: Das Hauptprogramm wurde vollständig ausgeführt.;
/* ============================================================
   00_Konfiguration.sas

   Zentrale Pfade und Grundeinstellungen des Projekts
   ============================================================ */

%let projektpfad=/home/u64561142/sasuser.v94/Qualitaetsanalyse;
%let programmepfad=&projektpfad/Programme;
%let quellpfad=&projektpfad/Quellen;
%let datenpfad=&projektpfad/Daten;
%let ergebnispfad=&projektpfad/Ergebnisse;

/* Dauerhafte Bibliothek für erzeugte SAS-Datensätze */
libname qanal "&datenpfad";

/* Grafikausgabe aktivieren */
ods graphics on;

/* Lesbare Standardausgabe */
options nodate nonumber;

/* Pfade im Log anzeigen */
%put NOTE: Projektpfad  = &projektpfad;
%put NOTE: Quellenpfad  = &quellpfad;
%put NOTE: Datenpfad    = &datenpfad;
%put NOTE: Ergebnispfad = &ergebnispfad;
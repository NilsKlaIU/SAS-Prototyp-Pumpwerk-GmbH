# SAS-Prototyp Pumpwerk GmbH

Dieses Repository enthält den im Rahmen einer Fallstudie entwickelten **SAS-Studio-Prototyp** zur Analyse von Produktions- und Qualitätsdaten der fiktiven Pumpwerk GmbH.

Ziel des Prototyps ist es, unterschiedliche Datenquellen zusammenzuführen, deren Qualität zu prüfen und anschließend statistische Analysen sowie Visualisierungen durchzuführen. Die Ergebnisse werden automatisiert in einem PDF-Bericht zusammengefasst.

## Datengrundlage

Für den Prototyp werden drei synthetisch erzeugte CSV-Dateien mit jeweils **600 Produktionsvorgängen** verwendet.

## Repository-Struktur

Programme/
- 00_Konfiguration.sas
- 00_Hauptprogramm.sas
- 01_Datenimport.sas
- 02_Datenpruefung.sas
- 03_Datenzusammenfuehrung.sas
- 04_Deskriptive_Analyse.sas
- 05_Ausreisseranalyse.sas
- 06_Visualisierungen.sas
- 07_Clusteranalyse.sas
- 08_Ergebnisexport.sas

Quellen/
- produktionsdaten.csv
- pumpen_stammdaten.csv
- qualitaetspruefung.csv

Ergebnisse/
- Analysebericht_Pumpwerk.pdf

## Ausführung in SAS Studio

1. Repository herunterladen.
2. Ordner und Dateien in SAS Studio übernehmen.
3. Projektpfade anpassen.
4. `00_Hauptprogramm.sas` ausführen.
5. Ergebnisbericht im Ordner `Ergebnisse` prüfen.

## Durchgeführte Analysen

- Datenprüfung und Datenaufbereitung
- Zusammenführung der drei Datenquellen
- deskriptive Analyse
- Chi-Quadrat-Tests
- Ausreißeranalyse
- Clusteranalyse
- Visualisierung zentraler Ergebnisse
- automatisierter PDF-Ergebnisexport

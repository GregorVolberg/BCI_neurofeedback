# Neurofeedback und BCI mit EEG

Installationsanleitung für OpenBCI "Cyton"

Stand: SoSe 2024

Das Cyton-Board hat einen Verstärker mit einer Abtastrate von 250 Hz und acht Steckplätzen für EEG-Elektroden. Das Board kommt mit einer grafischen Benutzeroberfläche ("OpenBCI GUI"). Alternativ können die EEG-Daten als stream in Echtzeit in andere Applikationen eingelesen werden.

##  Vorbereitung

Die Daten werden mit einem USB-Bluetooth-Dongle von Cyton zum Rechner übertragen. Das USB-Gerät erscheint im System als virtueller serieller Port ("COM-Port"). Auf älteren Systemen muss dazu ein FTDI-Treiber installiert werden, https://ftdichip.com/drivers/vcp-drivers/. 

Der FTDI-Treiber puffert die Daten am COM-Port per Voreinstellung für 16 ms. Für eine Echtzeitauswertung ist das zu lang, der Wert muss auf 1 ms reduziert werden. Eine Anleitung für Windows finden Sie unter https://docs.openbci.com/Troubleshooting/FTDI_Fix_Windows/ . Anleitungen für MacOS und Linux finden Sie dort ebenfalls.

Von der OpenBCI Webpage: "The FTDI driver is only necessary for Windows 8, Windows 10, and Mac OS X 10.9 through 10.15. If you are running a Mac that is mid 2015 or newer, you do not need to install the FTDI driver."

## OpenBCI GUI
Um die GUI zu installieren, laden Sie die passende Software von der OpenBCI webpage herunter (https://openbci.com/downloads) und folgen Sie der Anleitung, https://docs.openbci.com/Software/OpenBCISoftware/GUIDocs/ .

## Brainflow
Brainflow ist eine Bibliothek zur Aquise und Verarbeitung von Daten von Biosensoren. Die Bibliothek kann an verschiedene Programmiersprachen angebunden werden, darunter Matlab, Python und R. 
- Python: python 3.11 herunterladen und installieren, https://www.python.org/downloads/release/python-3110/ . Bei der Installation das Häkchen setzen bei "add to PATH", dann cosutum installatuion,  Dokumentation und tcl/tk können abgewählt werden. 
- Eingabeaufforderung öffnen und "python -m pip install brainflow" eingeben; installiert brainflow
- in R die Pakete reticulate und devtools von CRAN installieren.

[- Ein Paket "brainflow" erstellen mit R API bindings ('zzz.R')]

Mein Paket brainflow von Github installieren
https://ourcodingclub.github.io/tutorials/writing-r-package/


## Setup Elektroden
 (+ 2 für Referenz und Erde)

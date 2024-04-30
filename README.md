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
Brainflow ist eine Bibliothek zur Akquise und Verarbeitung von Daten von Biosensoren. Die Bibliothek kann an verschiedene Programmiersprachen angebunden werden, darunter Matlab und Python. Für brainflow gibt es kein eigenes R-Paket. Es ist aber möglich, von R aus die Python-Bibliothek anzusprechen. Dazu müssen zuerst Python und die Python-Bibliothek von brainflow installiert werden. 

### Python
Für die Installation von Python die Software python 3.11 herunterladen und installieren, https://www.python.org/downloads/release/python-3110/ . Bei der Installation das Häkchen setzen bei "add to PATH", dann die Costum installation wählen: Die optionalen Bestandteile "Dokumentation" und "tcl/tk" müssen nicht installiert werden. 

Für die Installation von brainflow unter Python die  Eingabeaufforderung öffnen und eingeben:

    python -m pip install brainflow
    

### R bindings
In R müssen Sie die Pakete reticulate und devtools von CRAN installieren. Reticulate sorgt für die Kommunikation mit Python, devtools ist für die nachfolgende Installation des brainflow-Pakets erforderlich.

    install.packages("devtools")
    install.packages("reticulate")
    
Das Paket brainflow soll auf dem eigenen System erstellt und dann installiert werden. Ich habe bereits ein Paket erstellt, Sie können es mit dem folgenden Code installieren.

    library(devtools)
    install_github("GregorVolberg/brainflow") 
    
## Starten von brainflow in R  
Wenn die Installation erfolgreich war, reicht es aus, zu Beginn eines Skripts in R die Bibliothek brainflow zu importieren.

    library("brainflow")

Möglicherweise nutzen Sie in Python verschiedene "Environments". Falls ja, binden Sie im R-Skript zuerst reticulate ein und wechseln in das Environment, in dem die python-bibliothek brainflow installiert ist. Zum Beispiel:

    library(reticulate)
    use_virtualenv("myEnvironment")
    library("brainflow")
    
oder mit der conda-Distribution:

    library(reticulate)
    use_condaenv("myEnvironment")
    library("brainflow")

Alternativ kann das Environment mit nachfolgendem Aufruf angegeben werden.

    Sys.env(RETICULATE_PYTHON_ENV = "Pfad/zu/Environment")

Als Test können Sie die folgenden Zeilen versuchen. Der erste Aufruf einer Funktion aus der Bibliothek dauert recht lange. Möglicherweise öffnet sich ein Fenster, in dem reticulate fragt, ob eine spezielles Environment voreingestellt werden soll. Wenn die Installation korrekt ist, sollte es keine Fehlermeldung geben.

    library(brainflow)
    params <- brainflow_python$BrainFlowInputParams()



# Nützliche Links (intern)

R-Paket erstellen:
https://ourcodingclub.github.io/tutorials/writing-r-package/

zzz.R - File
https://stackoverflow.com/questions/21448904/r-packages-what-is-the-file-zzz-r-used-for

R-Paket auf gibhub bereitstellen:
https://medium.com/@abertozz/turning-an-r-package-into-a-github-repo-aeaebacfe1c
    
    
<!--, in der conda-Installation  Sie zuerst in das    
Kommandos aufzurufen, sondern setzt auf der Python-Installation auf. 
[- Ein Paket "brainflow" erstellen mit R API bindings ('zzz.R')]

Mein Paket brainflow von Github installieren
https://ourcodingclub.github.io/tutorials/writing-r-package/-->


## Setup Elektroden
 (+ 2 für Referenz und Erde)

# VehicleExplorer for FS22 aka VeEx22
**This is a revamp of the good old VehicleSort from FS17**

For beginners: VehicleExplorer helps you organize your vehicles, by showing you a list which can be organized, well, sorted by you.
Besides that it has a couple of additional functionality. See below.

Feedback, this readme and additional information incl. source code can be find at: https://github.com/sperrgebiet/FS22_VehicleExplorer

**Please download the latest version directly from GitHub**
[Latest version](https://github.com/sperrgebiet/FS22_VehicleExplorer/blob/main/FS22_VehicleExplorer.zip?raw=true)

### Features
* List of all steerable vehicles (Specialization: Enterable)
* Set a customer order for your vehicles
  * Your order is saved in the default vehicles.xml, so no additional clutter
* Enter your vehicles directly with a click of a (mouse) button
  * This is meant literally, see known issues ;)
* EasyTab: Switch between the last two selected vehicles
* Park your vehicles, so that a switch of vehicles via Tab ignores them
* Repair vehicles and its implements
* Let your vehicle and implements get cleaned on a repair from your friendly VeEx staff ;)
* If Seasons is enabled, you can also let the vehicle and implements get repainted
* Displaying a store image next to the list
* Info box with additional informations
* Motor on/off, turned on/off (for e.g. harvester) and light status is saved and restored
* Different colors in the list if a vehicle is selected, or currently used by a helper/Courseplay
* Config Menu
  * Config is saved per savegame within modsSettings/VehicleExplorer/savegameX
  * Show/hide trains in the list
  * Show/hide station cranes in the list (No idea if that actually works, would need a map with a crane to test)
  * Show/hide steerable implements/trailers (e.g. forwarder trailer with crane)
  * Show/hide brand names in the list
  * Show/hide your own name when you enter a vehicle
  * Show/hide horse power in the list
  * Show/hide fill levels in the list
  * Show/hide implements in the list
  * Show/hide store images
  * Show/hide infobox
  * Move infobox up/down
  * Show/hide a background for the infobox/store image
  * Change text size
  * Change text alignment
  * Change list background transparency
  * Enable/disable saving of the additional vehicle status (motor, turnedOn, lights)
  * Show/hide keybindings in the game F1 help menu (needs a game restart to take affect)
  * Clean vehicle & implements on a repair
* Tardis integration
  * With Tardis (https://github.com/sperrgebiet/FS22_Tardis) you can teleport yourself AND your vehicles to any position on the map
  * With VehicleExplorer & Tardis you can select a vehicle on the list, and teleport that to any location without entering it. You can also configure
  if you want to enter the vehicle after teleportation or just drop the vehicle to another location
  * With Tardis Map Hotspots you can again, select a vehicle and quickly teleport that to one of those hotspots
  

### Known issues
* Although you can change all the keyboard bindings, the mouse actions are hardcoded for now
  * Left mouse click: Enter vehicle
  * Right mouse click: Select vehicle (to e.g. move it)
  * Right mouse click: Change value in the config menu
  * Mouse wheel: Selection up/down in list
* Max of three columns. If you've more vehicles (which would be insane anyways ;) , just disable the display of brand name etc


### Incompatible Mods
* ~~SpeedControl~~
  * ~~Actually both work fine side by side. There is just a keybinding overlap. So you've to set new keybindings through the game menu for Key 1, Key 2, Key NumPad Plus, Key NumPad Minus~~
  * Changed the default keybinding. So there is no overlap anymore.

## Default Keybinding
|Key Combi|Action|
|:---:|---|
|LAlt + v|Show/hide vehicle list|
|LAlt + KeyPad Minus|Show/hide config menu|
|KeyPad Enter|Enter vehicle|
|LAlt + p|Toggle parking|
|LAlt + KeyPad 5|Select item (for moving the vehicle) or to change values in the config|
|LAlt + KeyPad 8|Move up in the list/config|
|LAlt + KeyPad 2|Move down in the list/config|
|LAlt + 1|Move up fast in the list/config|
|LAlt + 2|Move down fast in the list/config|
|LAlt + R|Repair vehicle incl. implements|
|Tab|Next vehicle; VeEx own switch vehicle implementation (necessary to tab through vehicles in your own order)|
|Shift + Tab|Previous vehicle; VeEx own switch vehicle implementation (necessary to tab through vehicles in your own order)|
|LCtrl + Tab|easyTab; Easily tab between the last two vehicles you switched through VeEx|
|Mouse Left|Enter vehicle|
|Mouse Right|Select item/change values in config|
|Mouse Wheel|List up/down|

**_ If you want to use the 'sorted tabbing', make sure you drop the default key binding in the game menu. I didn't find a way to overwrite the default vehicle switching, and I think
it's better to let you, the user, this choice anyways. _**


## Meaning of colors used
|Color|Meaning|
|:---:|---|
|White|Standard|
|Green|Current player is controlling vehicle|
|Orange|Vehicle selected|
|Red|Vehicle locked (necessary to move it up/down in the list)|
|Grey|Vehicle is parked|
|Blue|Vehicle is controlled by AI (Helper or Courseplay)|
|Light Pink|Vehicle is controlled by FollowMe (not yet available)|
|Yellow|Engine is running|

## Note that the current version does NOT support multiplayer!
There were reports that VehicleExplorer does work in MP if you simply change the moddesc.xml. Although I assume not everything works then.
Anyways, I decided to work on a MP version. Just have no idea yet till when it will be available.

## Credits
Primarily to Dschonny & Slivicon. At least those are the names which were mentioned in the FS17 VehicleSort I used as a foundation. But the majority of code has changed anyways.
Also Kudos to the guys and gals from CoursePlay, VehicleInspector, VehicleFruitHud, EnhancedVehicle and many more for some inspiration and ideas.
Additionally Ifko[nator] for the RegisterSpecialization script.


## Latest Version
0.2.0.5 - I consider it as Beta. I tested it quite a lot myself, but hope for some helpful feedback from the community.

-----


# VehicleExplorer für LS22 aka VeEx22
**Dies ist eine Reinkarnation von VehicleSort aus LS17**

Für Neueinsteiger: VehicleExplorer hilft beim organisiere der Fahrzeuge. Es zeigt eine Liste welche dann selbst nach eigenen Wünschen sortiert werden kann.

Feedback, dieses ReadMe und weitere Informationen sowie der Quelltext findet sich unter: https://github.com/sperrgebiet/FS22_VehicleExplorer

**Bitte lade die letzte Version direkt von bei GitHub herunter**
[Letzte Version](https://github.com/sperrgebiet/FS22_VehicleExplorer/blob/main/FS22_VehicleExplorer.zip?raw=true)

### Funktionen
* Liste aller steuerbaren Fahrzeuge (Specialization: Enterable)
* Definition einer eigener Reihenfolge der Fahrzeuge
  * Die Reihenfolge wird in der Standard vehicles.xml gespeichert, also kein zusätzliches Wirrwar
* Fahrzeugwechsel einfach durch einen Mausklick
  * Dies meine ich wortwörtlich, siehe Bekannte Probleme ;)
* EasyTab: Zwischen den letzten beiden Fahrzeugen wechseln
* Parke die Fahrzeuge, sodass sie von einem Fahrzeugwechsel via Tab ignoriert werden
* Reparatur von Fahrzeugen und angehängten Geräten
* Mit Seasons ist es auch möglich das Fahrzeug und Geräte neu lackieren zu lassen
* Waschen von Fahrzeugen und Anbaugeräten nach einer Reparatur durch das freundliche VeEx Personal
* Anzeige eines Shop-Bildes neben der Fahrzeugliste
* Info Box neben der Fahrzeugliste mit weiteren Details
* Motor ein/aus, Gerätefunktionen ein/aus (für z.B. Drescher) und Licht-Status werden gespeichert und beim laden wieder hergestellt
* Unterschiedliche Farben in der Liste für selektiert, momentane Verwendung eines Helfers/CoursePlay
* Konfigurationsmenü
  * Die Konfiguration ist pro Speicherslot unter modsSettings-VehicleExplorer/savegameX zu finden
  * Anzeigen/verstecken von Zügen in der Liste
  * Anzeigen/verstecken von Stationskränen (kA ob das Funktioniert, bräuchte ne Map mit Kränen dafür)
  * Anzeigen/verstecken von Markennamen
  * Anzeigen/verstecken des eigenen Namens wenn man sich in einem Fahrzeug befindet
  * Anzeigen/verstecken der Leistung (PS) bei einem Fahrzeug
  * Anzeigen/verstecken der Füllmengen in der Liste
  * Anzeigen/verstecken von Anbaugeräten/Hängern in der Liste
  * Anzeigen/verstecken Shop Bild
  * Anzeigen/verstecken der Infobox
  * Rauf/runter verschieben der Infobox
  * Anzeigen/verstecken eines Hintergrundes für die Infobox/Shop Bild
  * Ändern der Schriftgröße
  * Textausrichtung ändern
  * Ändern der Hintergrundtransparenz
  * Aktivieren/deaktivieren des speicherns der zusätzlichen Fahrzeugstati (motor, turnedOn, lights)
  * Anzeigen/verstecken der Tastenbelegung im F1 Hilfemenü (benötigt einen Neustart des Spiels)
  * Aktivieren/deaktivieren des automatischen waschen von Fahrzeuge und Anbaugeräte beim Reparieren
* Tardis Integration
  * Mit Tardis (https://github.com/sperrgebiet/FS22_Tardis) kannst du dich selbst UND jedes Fahrzeug an jedgliche Position auf der Karte teleportieren
  * Mit VehicleExplorer & Tardis kannst du einfach ein Fahrzeug auf der Fahrzeugliste markieren, und dieses teleportieren ohne einzusteigen. Man kann konfigurieren ob
  man nach dem teleportieren einsteigen möchte oder nicht.
  * Mit Tardis Hotspots kann man einfach und schnell Fahrzeuge an eine vorher definierte Position teleportieren.


### Bekannte Probleme
* Wenn man auch die Tastaturbelegung verändern kann, so sind die Mausaktionen im Moment nicht veränderbar
  * Linke Maustaste: Ins Fahrzeug einsteigen
  * Rechte Maustaste: Fahrzeug auswählen (zum Verschieben)
  * Rechte Maustaste: Wert im Konfigurationsmenü ändern
  * Mausrad: Rauf/Runter in der Liste
* Maximal drei Spalten in der Liste. Wenn du mehr Fahrzeuge hast )was sowieso schon bedenklich ist ;), dann einfach die Markennamen oder Füllmengen deaktiveren um mehr Platz zu haben.

### Inkompatible Mods
* ~~SpeedControl~~
  * ~~Beide funktionieren einwandfrei nebeneinander. Es existiert nur eine Doppelbelegung der Tastaturbelegung. Im Spielmenü setze einfach neue Tasten für Taste 1, Taste 2, Taste NumPad Plus, Taste NumPad Minus~~
  * Habe die Standard Tastenbelegung verändert. Somit gibt es keinen Konflikt mehr.  

## Standard Tastenbelegung
|Key Kombi|Aktion|
|:---:|---|
|LAlt + v|Anzeigen/verstecken der Fahrzeugliste|
|LAlt + KeyPad Minus|Anzeigen/verstecken des Konfigurationsmenüs|
|LAlt + KeyPad Enter|Ins Fahrzeug wechseln|
|LAlt + p|Fahrzeug parken/ausparken|
|LAlt + KeyPad 5|Fahrzeug auswählen (zum Verschieben) und ändern eines Wertes in der Konfiguration|
|LAlt + KeyPad 8|Rauf in der Liste/Konfiguration|
|LAlt + KeyPad 2|Runter in der Liste/Konfiguration|
|LAlt + 1|Schnell rauf in der Liste/Konfiguration|
|LAlt + 2|Schnell runter in der Liste/Konfiguration|
|LAlt + R|Repariere Fahrzeug inkl. Anbaugeräte|
|Tab|Nächstes Fahrzeug; VeEx eigene Implementierung des Fahrzeugwechsels via Tabulator, damit man auch die eigene Sortierung verwendet wird|
|Shift + Tab|Vorheriges Fahrzeug; VeEx eigene Implementierung des Fahrzeugwechsels via Tabulator, damit man auch die eigene Sortierung verwendet wird|
|LCtrl + Tab|easyTab; Zwischen den beiden letzten Fahrzeugen wechseln welche in VeEx ausgewählt wurden|
|Linke Maustaste|Ins Fahrzeug wechseln|
|Rechte Maustaste|Fahrzeug auswählen/Eintrag im Konfigurationsmenü ändern|
|Mausrad|Liste rauf/runterscrollen|

**_ Wenn du das 'sortierte Tabbing' zum Wechseln der Fahrzeuge verwenden möchtest musst du die Standard Tastenbelegung dafür in den Spieleinstellungen verwerfen. Ich habe keine
Möglichkeit gefunden dies zu überschreiben, und finde auch das es besser ist diese Wahl dir, dem User, zu überlassen. _**


## Bedeutung der verwendeten Farben
|Farbe|Bedeutung|
|:---:|---|
|Weiss|Standard|
|Grün|Derzeitiger Spieler kontrolliert das Fahrzeug|
|Orange|Fahrzeug ist ausgewählt|
|Rot|Fahrzeug ist "gesperrt", notwendig um es in der Liste rauf/runter zu schieben|
|Grau|Fahrzeug ist geparkt|
|Blau|Fahrzeug wird von der KI kontrolliert (Helfer oder CoursePlay)|
|Helles Pink|Fahrzeug wird von FollowMe kontrolliert (noch nicht verfügbar)|
|Gelb|Motor is ein|

## Beachte, dass die jetzige Version kein Multiplayer unterstützt!
Es wurde bereits berichtet, dass VehicleExplorer sehr wohl in MP funktioniert wenn man jediglich die moddesc.xml ändert. Ob dies die gesamte Funktionalität betrifft glaube ich nicht.
Ich habe mich mittlerweile dazu entschlosse auch an einer MP Version zu arbeiten. Bis wann diese fertig ist kann ich jedoch nicht sagen.

## Credits
Primär an Dschonny & Slivicon. Zumindest waren das die Namen die in der LS17 VehicleSort Version genannt wurden welche als Basis diente. Aber der Grossteil des codes hat sich sowieso verändert.
Auch Kudos an die Jungs und Mädls von CoursePlay, VehicleInspector, VehicleFruitHud, EnhancedVehicle und vielen anderen für Inspirationen und Ideen.
Des weiteren noch Ifko[nator] für das RegisterSpecialization Skript.

## Letzte Version
0.2.0.5 - I würd mal sagen dies ist noch eine Beta. Ich hab zwar selbst recht viel getestet, hoffe aber auf hilfreiche Rückmeldungen von der Community.


# Screenshots
Vorstellung von Vehicle Explorer mit Tardis Integration auf YouTube: https://www.youtube.com/watch?v=w2LY9rmA4-g&t=7s

![FS19_VehicleExplorer_1](https://user-images.githubusercontent.com/20586786/53124444-ab13ac00-355b-11e9-8f84-cd976aed7729.png)
![FS19_VehicleExplorer_2](https://user-images.githubusercontent.com/20586786/53124445-abac4280-355b-11e9-91da-4ed4ab3367ed.png)
![FS19_VehicleExplorer_3](https://user-images.githubusercontent.com/20586786/53124447-ac44d900-355b-11e9-876f-c2b171ff227f.png)
![FS19_VehicleExplorer_4](https://user-images.githubusercontent.com/20586786/53124448-ac44d900-355b-11e9-8e9f-a9ba8840c3ff.png)
![FS19_VehicleExplorer_5](https://user-images.githubusercontent.com/20586786/53124449-acdd6f80-355b-11e9-8cdc-7e6c032097e7.png)
![FS19_VehicleExplorer_6](https://user-images.githubusercontent.com/20586786/53124450-acdd6f80-355b-11e9-8d57-5f4637bd4e1c.png)
![FS19_VehicleExplorer_7](https://user-images.githubusercontent.com/20586786/53124451-acdd6f80-355b-11e9-9d4d-f61fe3993dcd.png)
![FS19_VehicleExplorer_8](https://user-images.githubusercontent.com/20586786/53124452-ad760600-355b-11e9-86ce-41da3ae8a6f0.png)
![FS19_VehicleExplorer_9](https://user-images.githubusercontent.com/20586786/53124453-ad760600-355b-11e9-8dac-8a25d79b09b0.png)
![FS19_VehicleExplorer_10](https://user-images.githubusercontent.com/20586786/53124454-ae0e9c80-355b-11e9-80d1-7b363d3434b4.png)
![FS19_VehicleExplorer_11](https://user-images.githubusercontent.com/20586786/53124455-aea73300-355b-11e9-9db3-ba90bdcd71c3.png)


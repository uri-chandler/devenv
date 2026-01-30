# Light-Professional Theme

A comprehensive PlantUML design system for creating professional, visually consistent diagrams.

---

## Features

- Color System
- Typography System
- Specialty Message Functions
- Status Groups
- Architectural Layers
- Phases
- Theme System

---

@startuml Test

!$PDS = "pds/themes/light-professional"
!include $PDS/sequence.iuml

@enduml

## Examples

### Creating a Todo Item

A simple sequence diagram showing the creation of a Todo item through an API:

```plantuml
@startuml
!include skinparams.iuml


!include <material7.4.47/Arrow/ArrowDownBold>
!include <material7.4.47/DeveloperLanguages/CodeJson>
!include <material7.4.47/DeveloperLanguages/Identifier>
!include <material7.4.47/FilesFolders/FilePlus>
!include <material7.4.47/FilesFolders/FilePlusOutline>
!include <material7.4.47/FilesFolders/FileCheck>
!include <material7.4.47/FilesFolders/FileCheckOutline>
!include <material7.4.47/Database/all.puml>
!include <material7.4.47/Form/CheckCircle>
!include <material7.4.47/Form/CheckboxMultipleMarkedCircle>
!include <material7.4.47/Cloud/CloudUpload>

!unquoted function $Icon($name, $color = $Steel6, $scale = "0.3")
    !return "<color:" + $color + "><$mdi" + $name+ "{scale="+ $scale+ "}></color>"
!endfunction
scale 0.9

$PresentationSeqLayer("Client")
    actor User
    participant "$Icon(DatabaseCheck) API Gateway" as API
$SeqLayerEnd()

$ExternalSeqLayer("Business")
    participant "Todo Service" as Service
    participant "Database" as DB
$SeqLayerEnd()

activate User
$Phase("Create Todo")


User    -> API      :$Icon(CodeJson) POST /todos

    activate API

    API     -> Service  :$Icon(FilePlusOutline) Create todo

        activate Service
        Service -> DB       :$Icon(DatabasePlusOutline) INSERT INTO todos
        DB      -> Service  :$Icon(DatabaseCheck, $Steel6) Created
        Service -> API      :$Icon(FileCheck, $Steel6) Todo created
        deactivate Service
    
    API     -> User     :$Icon(CheckboxMultipleMarkedCircle, $Steel6) Todo created
    deactivate API

deactivate User
@enduml
```

---

## Usage

Include the design system in your PlantUML diagrams:

```plantuml
@startuml
!include skinparams.iuml

' Your diagram code here
@enduml
```

The `skinparams.iuml` file automatically includes:
- Color system
- Typography system
- Theme configuration
- Diagram styles (messages, sequence features)

---

## Next Steps

Detailed examples and usage patterns for each feature will be added in future updates.

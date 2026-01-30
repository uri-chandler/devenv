## Typography

```plantuml
@startuml

!include skinparams.iuml

' Assume your colors are included
!$Success = $Green4
!$Danger  = $Red3

$TITLE("Project Foo", "Starting Nov 22")

participant "User" as U
participant "API Gateway" as API

U -> API : GET /users
note right of U
  User requests access via
  $CODE("Authorization: Bearers")
  header token.
end note

API -> U : 200 OK
note left of API
  Response contains:
  * $B("Status"): $BADGE("Active", $Success)
  * $B("Role"): $TEXT_SM("Administrator")
  * $B("Error"): $BADGE("None", $Danger)
end note

@enduml
```
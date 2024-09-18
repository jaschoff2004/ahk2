

; SetupServer() {
;     ; This snippet disables flashing console windows
;     DllCall("AllocConsole")
;     WinHide("ahk_id " DllCall("GetConsoleWindow", "ptr"))

;     ; Starts the server using node js
;     Run("node `"`"files/dist/index.js`"`"")
; }

; RunClient() {
;     shell := ComObject("WScript.Shell")
;     server := "curl http://localhost:42800/subscribe -m 25"

;     allFunctions := GetAvailableFunctions()
;     sendListToServer := "curl http://localhost:42800/register/" . allFunctions
;     shell.Exec(A_ComSpec " /C " sendListToServer)

;     ; Go in subscriber mode and wait for commands.
;     ; You can trigger these commands by calling "localhost:42800/send/commandNameGoesHere"
;     Loop{
;         exec := shell.Exec(A_ComSpec " /C " server)
;         command := exec.StdOut.ReadAll()
        
;         ; Special case: kill. Reserved to terminate the script.
;         if(command == "kill") {
;             Run("curl `"`"http://localhost:42800/kill`"`"")
;             Exit()
;         } else {
;             CallCustomFunctionByName(command)
;         }
;     }
; }

; CallCustomFunctionByName(functionName) {
;     CustomFunctionsInstance := CustomFunctions()
;     if(IsFunctionAvailable(functionName, CustomFunctionsInstance)) {
;         CustomFunctionsInstance.%functionName%()
;     }
; }

; IsFunctionAvailable(functionName, obj := "") {
;     ; ; CustomFunctionsFunctionName := "CustomFunctions." . functionName
;     ; fn := obj.%functionName%
;     ; return (fn != 0)
;     return obj.base.HasOwnProp(functionName)
; }

; GetAvailableFunctions() {
;     CustomFunctionsInstance := CustomFunctions()
;     For key in CustomFunctionsInstance.Base.OwnProps()
;         if((key != "__Class") && (GetFunctionParameterCount(key, CustomFunctionsInstance) <= 1)) {
;             BaseMembers .= key ","	
;         }
;     return BaseMembers
; }

; GetFunctionParameterCount(functionName, obj := "") {
;     ; CustomFunctionsFunctionName := "CustomFunctions." . functionName
;     fn := obj.%functionName%
;     return fn.MinParams
; }
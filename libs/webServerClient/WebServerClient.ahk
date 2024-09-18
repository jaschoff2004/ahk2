#Requires AutoHotkey v2.0

#Include ../EventHandler.ahk
#Include ../Utils.ahk
#SingleInstance OFF 

; #SingleInstance OFF
; DetectHiddenWindows(0)
; instances := WinGetList(A_ScriptFullPath "ahk_class" "AutoHotkey")
; for instnace in instances {
;     if(instnace.hwnd != A_ScriptHwnd) {
;         WinClose(instnace.hwnd)
;     }
; }
; DetectHiddenWindows(1)
; #SingleInstance FORCE


; DetectHiddenWindows(On) 
; CurPID := DllCall("GetCurrentProcessId")
; WinGet   (List, List, %A_ScriptFullPath% ahk_class AutoHotkey) 
; Loop % List
; { 
;     WinGet, PID, PID, % "ahk_id" List%A_Index%
;     If (PID != CurPID)
;         Process, Close, %PID% 
; }

; OnExit(WebServerClient.OnExit) 
    
Class WebServerClient extends EventEmitter {

    shExec := ""
    endpoints := WebServerClient.Endpoints()
    running := false

    __New() {
        SendMode("Input")
        TraySetIcon("shell32.dll","147")
        this.Setup()
    }

    static OnExit(*) {
    }

    exit() {
        this.kill()
    }

    setup() {
        ; This snippet disables flashing console windows
        DllCall("AllocConsole")
        WinHide("ahk_id " DllCall("GetConsoleWindow", "ptr"))

        Run("node `"`"C:\Users\jaschoff\Desktop\ahk\libs\webServerClient\files\dist\index.js`"`"") ;,, "Hide UseErrorLevel")
    }

    run() {
        ; if(this.running) {            
        ;     this.emit("Ready")
        ;     return
        ; }
        this.running := true
        this.shell := ComObject("WScript.Shell")
        this.server := "curl http://localhost:42800/subscribe -m 1"   
        ; server := "curl http://localhost:42800/subscribe/default:v -m 3"    
        endpoints := "curl http://localhost:42800/register/" . this.endpoints.Get()        
        this.shExec := this.shell.Exec(A_ComSpec " /C " endpoints)
        ; strRegOut := this.shExec.StdOut.ReadAll()
        ; regOut := Utils.ToObject(strRegOut)
        
        listExec := this.shell.Exec(A_ComSpec " /C http://localhost:42800/list")
        list := listExec.StdOut.ReadAll()

        ; MsgBox("list: " list)
        
        ; paramsExec := this.shell.Exec(A_ComSpec " /C http://localhost:42800/params")
        ; params := paramsExec.StdOut.ReadAll()
        ; Go in subscriber mode and wait for commands.
        ; You can trigger these commands by calling "localhost:42800/send/commandNameGoesHere"        
        ; Loop {
           
            ; this.emit("Ready")
            this.startPolling()

            
            ; Special case: kill. Reserved to terminate the script.
            ; if(method == "kill") {
            ;     this.kill()
            ; } else if(method) {
            ;     this.endpoints.Route(method)
            ; }
        ; }
    }

    poll := false
    startPolling() {
        ; SetTimer(onTinck, 3000, 1)
        this.emit("Ready")
        this.poll := true
        ; onTinck() {
        While(this.poll) {
            this.shExec := this.shell.Exec(A_ComSpec " /C " this.server)    
            response := this.shExec.StdOut.ReadAll() 
            if(response) {
                if(response == "kill") {
                    this.kill()
                } 
                else {
                    this.poll := false
                    this.endpoints.Route(response)
                }
            }
        }
           
        ; }
    }

    kill(*) {
        this.poll := false
        if(this.shExec) {
            this.shExec.Terminate()
        }
        Run("curl `"`"http://localhost:42800/kill`"`"")
    }

    class Endpoints {

        endpoints := {name:["callback()"]} 

        __New() {
            this.endpoints := {}
            this.Register(default)
            default(v1, v2, v3) {
                MsgBox("default " v1.Length)
            }
        }

        get() {
            cmds := "commands/cmds:"
            params := "parameters/params:"
            For k, v in this.endpoints.OwnProps() {
                cmds .= k 
                cmds .= (A_Index < ObjOwnPropCount(this.endpoints) ? "," : "/" )	 
                Loop v[1].MaxParams {
                    params .= A_Index (A_Index < v[1].MaxParams ? "," : "")	  
                }      
            }            
             return cmds params 
        }

        register(callback) {
            if(!this.endpoints.HasOwnProp(callback.name)) {
                this.endpoints.DefineProp(callback.name, {value:[]})
            }
            this.endpoints.%callback.name%.Push(callback)            
        }

        route(strResponse) {
            obj := Utils.ToObject(strResponse)
            if(obj.HasOwnProp("cmd")) {
                if(this.endpoints.HasOwnProp(obj.cmd)) {
                    for cb in this.endpoints.%obj.cmd% {
                        cb()
                    }    
                }  
            }      
        }

        exits(name) {
            Return this.endpoints.Has("name")
        }
    }
}

; wsClient := WebServerClient()
; MsgBox("Endpoints: " wsClient.endpoints.get())
; wsClient.Run()
; test := "test"
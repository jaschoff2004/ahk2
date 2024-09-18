#Requires AutoHotkey v2.0
#Include utils.ahk
#Include whr.ahk
#Include EventHandler.ahk

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

; OnExit(ngrok.kill) 

class ngrok extends EventEmitter {

    
    whr := WinHttpRequest()

    api_key := "2k5sFYIFwoHrMkrZORMGJn8k1kM_6HLWC1BcV1zrj3Fco5Dws"
    shell := ""
    path := "c:\Users\jaschoff\Desktop\ngrok"
    tunnel := ""
    forwardTO := "http://localhost:42800"

    retryWait := 1000
    retryMax := 10
    retryCount := 0


    _tunnelSessions := ""
    tunnelSessions {
        get {
            if(!this._tunnelSessions || !this._tunnelSessions.Length) {
                _tunnelSessions := this.GET("tunnel_sessions")
                this._tunnelSessions := _tunnelSessions.tunnelSessions
            }
            return this._tunnelSessions
        }
    }

    _tunnels := ""
    tunnels {
        get {
            if(!this._tunnels || !this._tunnels.Length) {
                _tunnels := this.GET("tunnels")
                this._tunnels := _tunnels.tunnels
            }
            return this._tunnels
        }
    }

    _endpoints := ""
    endpoints {
        get {
            if(!this._endpoints || !this._endpoints.Length) {
                _endpoints := this.GET("endpoints")
                this._endpoints := _endpoints.endpoints
            }
            return this._endpoints
        }
    }

    ; static kill(*) {        
    ;     If(WinExist("ngrok.exe")) {
    ;         WinClose("ngrok.exe")
    ;     }
    ; }

    __New() {
    }

    exit() {
        this.PUT("tunnel_sessions", this.tunnels, "id", "stop")
        if(WinExist("ngrok.exe")) {
            WinClose("ngrok.exe")
        }
    }
    
    init() {         

        this._endpoints := ""
        this._tunnels := ""
        this.retryCount := 0
        
        ; if(!this.endpoints.Length) {

        ;     Run(this.path "\ngrok.exe http " this.forwardTO)
        ;     While(!this.endpoints.Length && this.retryCount <= this.retryMax) {
        ;         Sleep(this.retryWait)
        ;         this.retryCount += 1
        ;     }
        ;     this.retryCount := 0
        ; }
        
        if(!this.tunnels.Length) {    
            if(WinExist("ngrok.exe")) {
                WinClose("ngrok.exe")
            }
            Run(this.path "\ngrok.exe http " this.forwardTO)
            While(!this.tunnels.Length && this.retryCount <= this.retryMax) {
                Sleep(this.retryWait)
                this.retryCount += 1
            }
        }
        this.retryCount := 0

        this.emit("Init", this.tunnels.Length > 0)
    } 
    
    GET(api) {
        this.whr.Open("GET", "https://api.ngrok.com/" api, true)
        this.whr.SetRequestHeader("authorization", "Bearer " this.api_key)
        this.whr.SetRequestHeader("Ngrok-Version", "2")
        this.whr.Send()
        this.whr.WaitForResponse()
        return Utils.ToObject(this.whr.ResponseText) 
    }

    PUT(api, list, target, action) {
        for item in list {            
            this.whr.Open("PUT", "https://api.ngrok.com/" api "/" item.%target% "/" action, true)
            this.whr.SetRequestHeader("authorization", "Bearer " this.api_key)
            this.whr.SetRequestHeader("Ngrok-Version", "2")
            this.whr.Send()
            this.whr.WaitForResponse()
        }
        return Utils.ToObject(this.whr.ResponseText) 
    }   
}

; test := ngrok()
; MsgBox(test.endpoints[1].public_url)

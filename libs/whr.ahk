#Requires AutoHotkey v2.0

class WinHttpRequest {
    __New(url := "") {
        this.whr := ComObject("WinHttp.WinHttpRequest.5.1")

        if(url != "") {
            this.Open("Get", url, true)
            this.Send()
            this.WaitForResponse()
        }
    }

    ResponseText {
        get {
            try {

                return this.whr.ResponseText
            }
            catch Error as e {  
                throw(e)              
                ; MsgBox("An error was thrown!`nSpecifically: " e.Message)  
            }
        }
    } 

    Open(method, url, async := true) {
        this.whr.Open(method, url, async)
    }

    SetRequestHeader(header, value) {
        this.whr.setRequestHeader(header, value)
    }

    Send(data := "") {
        this.whr.Send(data)
    }

    WaitForResponse() {
        try {
            this.whr.WaitForResponse()
        }
        catch Error as e {
            throw(e)
            ; MsgBox("An error was thrown!`nSpecifically: " e.Message)            
        }        
    }
}
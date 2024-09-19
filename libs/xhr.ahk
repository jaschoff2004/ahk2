

class XmlHttpRequest {
    __New() {
        this.xmlhttp := ComObject("MSXML2.XMLHTTP.6.0")
    }

    Open(method, url, async := true) {
        this.xmlhttp.Open(method, url, async)
    }

    SetRequestHeader(header, value) {
        this.xmlhttp.setRequestHeader(header, value)
    }

    Send(data := "") {
        this.xmlhttp.Send(data)
    }

    WaitForResponse() {
        while (this.xmlhttp.readyState != 4) {
            Sleep(10)
        }
        return this.xmlhttp.responseText
    }
}
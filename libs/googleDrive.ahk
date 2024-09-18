#Requires AutoHotkey v2.0

class GoogleDrive {

    exe := "GoogleDriveFS.exe"
    exePath := "C:\Program Files\Google\Drive File Stream\94.0.1.0"
    driveLetter := 0
    driveLabel := "Google Drive"

    _connected := ""
    connected {
        get {
            if(this._connected == "") {
                this._connected := this.isConnected()
            }
            return this._connected
        }
        set {
            this._connected := value
        }
    }

    __New() {
        if(!this.connected) {
            this.connect()
        }
    }

    isConnected() {
        Loop Parse DriveGetList() {
            drive := A_LoopField
            if(DriveGetLabel(Drive ":") == this.driveLabel) {
                this.driveLetter := drive
            }        
        }
        return this.driveLetter
    }

    connect() {
        Run(this.exe, this.exePath)
       
        ready := Disk.DirExists("My Drive", "G:\")
        While(!ready) {
            Sleep(1000)
            ready := Disk.DirExists("My Drive", "G:\")
        }

    }

    disconnect() {

    }

}
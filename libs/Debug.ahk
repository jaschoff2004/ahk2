#Requires AutoHotkey v2.0

#Include EventHandler.ahk

class Debug extends EventEmitter { 

    
    Static defaultH := 21 ;

    parent := Gui("+AlwaysOnTop -Caption -ToolWindow -Border -Resize -MaximizeBox", 'defaultParent')
    layout := { 
        x: 0, 
        y: A_ScreenHeight * 0.7, 
        w: A_ScreenWidth, 
        h: A_ScreenHeight * 0.3 
    }
    font := "cfffffe s10"

    __New(parent := this.parent, layout := this.layout, font := this.font) { 
        this.parent := parent
        this.layout := layout       

        this.editDebug := this.parent.Add('Edit', 'xm y' Debug.defaultH ' w' this.layout.w-6 ' h' this.layout.h-Debug.defaultH ' -Border' )  ;+ReadOnly    
        ; this.editDebug.BackColor := "blue"
        ; this.editDebug := this.parent.Add('Edit', '' )  ;+ReadOnly    
        
        this.editDebug.SetFont(this.font)
        WinSetTransColor("white", this.editDebug)

        this.guiToolbar := Gui("+AlwaysOnTop -Caption -ToolWindow -border -Resize -MaximizeBox", 'toolBar01')
        this.guiToolbar.MarginX := 0
        this.guiToolbar.MarginY := 0
        ; this.guiToolbar.BackColor := 'black'

        this.guiToolbar.opt("+Parent" this.parent.Hwnd)
        this.guiToolbar.Show('x0 y0 w' this.layout.w ' h' Debug.defaultH)
        ; this.guiToolbar.Show()

        if(this.parent.Title := "defaultParent") {
            this.parent.MarginX := 3
            this.parent.MarginY := 0
            this.parent.BackColor := "black"
            ; this.parent.Show('x' this.layout.x ' y' this.layout.y ' w' this.layout.w ' h' this.layout.h)
            this.parent.Show('x' this.layout.x ' y' this.layout.y ' w' this.layout.w ' h' this.layout.h)
            
        }

        ; ; this.guiControls.Show('x0 y0 w300 h200')
        ; this.guiToolbar.Show("x" (A_ScreenWidth * 0.6) " y0 h" Debug.defaultH " w" (A_ScreenWidth * 0.4))

        this.btMax := this.guiToolbar.Add("Button", 'x' (A_ScreenWidth) - 17 ' y0 w17 h' Debug.defaultH, "1")
        this.btMax.SetFont('s12', 'Webdings')
        this.btMax.OnEvent('Click', (*) => this.consoleUp(true))

        this.btnMin := this.guiToolbar.Add("Button", 'x' (A_ScreenWidth) - 17 - 17 ' y0 w17 h' Debug.defaultH, "0")
        this.btnMin.SetFont('s12', 'Webdings')
        this.btnMin.OnEvent('Click', (*) => this.consoleDown(true))

        this.btnDown := this.guiToolbar.Add("Button", 'x' (A_ScreenWidth) - 17 - 34 ' y0' ' w17 h' Debug.defaultH, "6")
        this.btnDown.SetFont('s12', 'Webdings')
        this.btnDown.OnEvent('Click', (*) => this.consoleDown())

        this.btnUp := this.guiToolbar.Add("Button", 'x' (A_ScreenWidth) - 17 - 51 ' y0 w17 h' Debug.defaultH, "5")
        this.btnUp.SetFont('s12', 'Webdings')
        this.btnUp.OnEvent('Click', (*) => this.consoleUp())

        this.On("Resize", onResize)
        onResize(x, y, w, h) {    
            If (this.consoleXStep >= 0) {
                ControlMove(, , ,  h-Debug.defaultH, this.editDebug.hwnd)
            }    
            this.parent.Show('y' y ' h' h)    
            WinMoveTop(this.editDebug.hwnd)
            WinMoveTop(this.guiToolbar.hwnd)
        }


        this.print("Ready...")
    }

    print(input) {
        ControlSetText(this.editDebug.Text .= "`r`n" . input, this.editDebug)
    }

    consoleXStep := 0
    consoleXH := Debug.defaultH * 4
    stepY := this.layout.y
    stepH := this.layout.h
    consoleUp(max := false) {

        If (this.stepH + (this.consoleXH) > SysGet(17) || max) {
            nch := this.stepH := SysGet(17)
            ncy := this.stepY := 0
            nedH := SysGet(17) - Debug.defaultH
            nctH := SysGet(17) - Debug.defaultH
        }
        Else {
            this.consoleXStep += 1
            this.stepY -= (this.consoleXH)
            this.stepH += (this.consoleXH)

            nch := this.stepH
            ncy := this.stepY
            nedH := this.stepH - Debug.defaultH
            nctH := this.stepH - Debug.defaultH
        }

        ; If (this.consoleXStep >= 0) {
        ;     ControlMove(, , , nedH, this.editDebug.hwnd)
        ; }
        ; this.guiControls.Show(' h' ncth)
        ; this.that.wvGui.Show('h' SysGet(17) - nch)
        ; this._gui.Show('y' ncy ' h' nch)


        this.emit("Resize", this.layout.x, ncy, this.layout.w, nch)
    }

    ; consoleMin := false
    consoleDown(min := false) {

        If (this.stepH - (this.consoleXH) < Debug.defaultH || min) {
            nch := this.stepH := Debug.defaultH
            ncy := this.stepY := SysGet(17) - Debug.defaultH
            nedH := Debug.defaultH
            nctH := Debug.defaultH
        }
        Else {
            this.consoleXStep -= 1
            this.stepY += (this.consoleXH)
            this.stepH -= (this.consoleXH)

            nch := this.stepH
            ncy := this.stepY
            nedH := this.stepH - Debug.defaultH
            nctH := this.stepH - Debug.defaultH
        }

        ; If (this.consoleXStep >= 0) {
        ;     ControlMove(, , , nedH, this.editDebug.hwnd)
        ; }
        ; this.guiControls.Show(' h' ncth)
        ; this.that.wvGui.Show('h' SysGet(17) - nch)
        ; this._gui.Show('y' ncy ' h' nch)

        this.emit("Resize", this.layout.x, ncy, this.layout.w, nch)


        ; WinMoveTop(this.editDebug.hwnd)
        ; ; WinMoveTop(this.guiControls.hwnd)
        ; WinMoveTop(this.guiToolbar.hwnd)
    }
}
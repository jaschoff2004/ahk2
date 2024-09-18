#Requires AutoHotkey v2.0

#Include WinUserHeader.ahk
#Include Gdip_All_v2.ahk
#Include OCR.ahk
#Include EventHandler.ahk




Class Screen extends OCR {

    static stopWatches := false

    static clip(x , y, w, h) {
        If (!pToken := Gdip_Startup()) {
            MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

            Gdip_Shutdown(pToken)
            ExitApp()
        }
        Return Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
    }

    static save(clip, file := "") {
        if(!file) {
            file := FileSelect("Save", "clips/*.png", "Save As", "Save As")
        }
        If (!pToken := Gdip_Startup()) {
            MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

            Gdip_Shutdown(pToken)
            ExitApp()
        }
        Gdip_SaveBitmapToFile(clip, file)
        Gdip_DisposeImage(clip)
        Gdip_Shutdown(pToken)
    }

    static persist(_gui, clip, x, y, w, h) { ; place image onscreen in original position while still movable, with thin border for contrast

        ; Gdip_CreateBitmapFromFile

        if(Type(clip) == "string") {
            clip := Gdip_CreateBitmapFromFile(clip)
        }

        _gui.Show("x" x " y" y " w" w " h" h " NoActivate")
        _gui.color := "0x00FFFFFF"

        hbm := CreateDIBSection(w, h)
        hdc := CreateCompatibleDC()
        bm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        Gdip_SetInterpolationMode(G, 7)

        Gdip_DrawImage(G, clip, 0, 0, w, h, 0, 0, w, h)
        Gdip_DeleteGraphics(G)
        ; Gdip_DisposeImage(clip)
        UpdateLayeredWindow(_gui.hwnd, hdc, x, y, w, h, 255)
        SelectObject(hdc, bm)
        DeleteObject(hbm)
        DeleteDC(hdc)

    }

    static dispose(clip) {
        Gdip_DisposeImage(clip)
    }

    Class Area extends Win32API {
        event := EventEmitter()
        events := {select:"select", textOut: 'textOut', assign:'assign', update:'update', watch:'watch', watchStopped:'watchStopped', insideGuiControls:"insideGuiControls"}
        ; console := Console(this, {})

        defaultAlignment := "tl"
        alignment := this.defaultAlignment
        _x := 0
        x[a := this.alignment] {
            get => this.getAligment("x", a) ;this._x - this.oX
            set => this.setAlignent("x", a, value)  ;this._x := value +  this.oX
        }
        _y := 0
        y[a := this.alignment] {
            get => this.getAligment("y", a) ; this._y - this.oY
            set => this.setAlignent("y", a, value) ;this._y := value + this.oY
        }
        w := 50
        h := 50
        ; oX := 0
        ; oY := 0

        getAligment(axis, align) {

            align := StrSplit(align)[(axis != "x") + 1 ]
            offset := 0
            Switch align {
                Case "t" || "l" : offset := 0
                Case "c" : offset := 5
                Case "b" || "r" : offset := 10
                Default:
            }
            return this._%axis% + offset
        }

        setAlignent(axis, align, value) {

            align := StrSplit(align)[(axis != "x") + 1]
            offset := 0
            Switch align {
                Case "t" || "l" : offset := 0
                Case "c" : offset := 5
                Case "b" || "r" : offset := 10
                Default:
            }

            this._%axis% := value - offset
        }

        __New(x := 0, y := 0, w := 100, h := 100) {


            super.__New()
            ; this.Base.__New()
            this.x := x ? x : this.x
            this.y := y ? y : this.y
            this.w := w ? w : this.w
            this.h := h ? h : this.h

            ; this.console.log('area ready')
        }
    }

    Class Grid extends Screen.Area {
        ; guiGrid := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
        ; guiGrid.BackColor := "yellow"
        parent := ""
        color := "0xff1100ff"
        lineWidth := 1
        colNum := 16
        rowNum := 24

        colWidth {
            get {
                return this.w / this.colNum
            }
        }

        rowHeight {
            get {
                return this.h / this.rowNum
            }
        }


        cells := []

        __New(parent, x, y, w, h, colNem := this.colNum, rowNum := this.rowNum, lineW := this.lineWidth) {
            super.__New(x, y, w, h)
            this.parent := parent

            this.guiGrid := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs", "guiGrid")
            ; WinSetTransparent(1)
            this.guiGrid.Opt("+Parent" this.parent.hwnd)
            this.guiGrid.Show('x' this.x ' y' this.y ' w' this.w ' h' this.h)    
                
            this.draw()

            
            this.onLButtonDown(onLButtonDownHandler)
            onLButtonDownHandler(hwnd) {
                If (this.guiGrid.hwnd != hwnd) {
                    title := WinGetTitle(hwnd)
                    Return
                }
                MouseGetPos(&x, &y)

                col := 0
                Loop(this.colNum) {
                    xCellLeft :=  (A_Index * this.colWidth) - this.colWidth
                    xCellRight := A_Index * this.colWidth
                    col := x > xCellLeft && x <= xCellRight ? A_Index : -1
                }

                this.event.emit("cellClick", this)
                ; this.console.log('overlay LBUTTTON Down')
            }
        }

        draw() {
            If (!this.pToken := Gdip_Startup()) {
                MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

                Gdip_Shutdown(this.pToken)
                ExitApp()
            }

            hbm := CreateDIBSection(this.w, this.h)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc)
            Gdip_SetSmoothingMode(G, 4)
            pPen := Gdip_CreatePen(this.color, this.lineWidth)


            Loop(this.colNum) {
                lineX := A_Index * this.colWidth
                Gdip_DrawLine(G, pPen, Integer(lineX), Integer(this.y), Integer(lineX), Integer(this.y + this.h))
            }

            
            Loop(this.rowNum) {
                lineY := A_Index * this.rowHeight
                Gdip_DrawLine(G, pPen, Integer(this.x), Integer(lineY), Integer(this.x + this.w), Integer(lineY))
            }

            Gdip_DeletePen(pPen)


            ; DllCall("gdiplus.dll\GdipGraphicsClear", "Ptr", G, "UInt", 0x00FFFFFF) ; Delete old lines (to have just 1 updated line all the time)

            UpdateLayeredWindow(this.guiGrid.hwnd, hdc, 0, 0, this.w, this.h)

            SelectObject(hdc, obm)
            DeleteObject(hbm)
            Gdip_DeleteGraphics(G)

            Gdip_Shutdown(this.pToken)


            ; this.onLButtonDown(onLButtonDownHandler)
            ; onLButtonDownHandler(hwnd) {
            ;     If (this.guiGrid.hwnd != hwnd) {
            ;         Return
            ;     }
            ;     MouseGetPos(&x, &y)

            ;     col := 0
            ;     Loop(this.colNum) {
            ;         xCellLeft :=  (A_Index * this.colWidth) - this.colWidth
            ;         xCellRight := A_Index * this.colWidth
            ;         col := x > xCellLeft && x <= xCellRight ? A_Index : -1
            ;     }

            ;     this.event.emit("cellClick", this)
            ;     ; this.console.log('overlay LBUTTTON Down')
            ; }

            ; this.onMOVE(onMOVE_handler)
            ; onMOVE_handler(x, y, hwnd) {
            ;     If (this._overlay.hwnd = hwnd) {
            ;         WinMove(x-3, y-3,,, this._overlayHighlight.hwnd)
            ;         this.x := x
            ;         this.y := y
            ;         this.event.emit("move", this)
            ;     }
            ; }
        }

        class Cell {
            x := 0
            y := 0
            w := 0
            h := 0
            col := 0
            row := 0

            __New(parent) {

            }

        }
    }

    Class Overlay extends Screen.Area {
        parent := ""
        color := "0x0033f502"
        ; aX {
        ;     get => this.x - this.oX
        ;     set => this.x := value + this.oX
        ; }

        ; aY {
        ;     get => this.y - this.oY
        ;     set => this.y := value + this.oY
        ; }
        ; alignment := "cc"
        ; oX := 0
        ; oY := 0

        __New(x, y, w, h, parent := "", c := this.color, alignment := this.alignment) {
            super.__New(x, y, w, h)
            this.alignment := alignment
            this.parent := parent

            ; Switch this.alignment {
            ;     case "tl" : (
            ;         this.oX := 0,
            ;         this.oY := 0
            ;     )
            ;     Case "tc" : (
            ;         this.oX := this.w/2,
            ;         this.oY := 0
            ;     )
            ;     case "tr" : (
            ;         this.oX := this.w,
            ;         this.oY := 0
            ;     )
            ;     case "cl" :  (
            ;         this.oX := 0,
            ;         this.oY := this.h/2
            ;     )
            ;     Case "cc" : (
            ;         this.oX := this.w/2,
            ;         this.oY := this.h/2
            ;     )
            ;     case "cr" : (
            ;         this.oX := this.w,
            ;         this.oY := this.h/2
            ;     )
            ;     case "bl" : (
            ;         this.oX := 0,
            ;         this.oY := this.h
            ;     )
            ;     Case "bc" : (
            ;         this.oX := this.w/2,
            ;         this.oY := this.h
            ;     )
            ;     case "br" : (
            ;         this.oX := this.w,
            ;         this.oY := this.h
            ;     )

            ;     Default:

            ; }
            this.overlay(c)
        }

        overlay(c := this.color) {

            If (!this.pToken := Gdip_Startup()) {
                MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

                Gdip_Shutdown(this.pToken)
                ExitApp()
            }
            ; OnExit("ExitFunc")

            ; this.x := this.aX
            ; this.y := this.aY

            this._overlayHighlight := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
            this._overlayHighlight.BackColor := "0x000400ff"
            WinSetTransparent(125)
            if(this.parent) {
                this._overlayHighlight.opt("+Parent" this.parent.hwnd)
            }
            ; this._overlayHighlight.Show("x" this.x - 2 " y" this.y - 2 " w" this.w + 4 " h" this.h + 4 " NoActivate")  ;NoActivate

            hbm := CreateDIBSection(this.w + 6, this.h + 6)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc)
            Gdip_SetSmoothingMode(G, 4)
            pBrush := Gdip_BrushCreateSolid(c)
            Gdip_FillRectangle(G, pBrush, 0, 0, this.w + 6, this.h + 6)
            Gdip_DeleteBrush(pBrush)
            UpdateLayeredWindow(this._overlayHighlight.hwnd, hdc, this.x, this.y, this.w + 6, this.h + 6)

            this._overlay := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
            this._overlay.BackColor := C
            WinSetTransparent(125)
            if(this.parent) {
                this._overlay.opt("+Parent" this.parent.hwnd)
            }
            this._overlay.Show("x" this.x " y" this.y " w" this.w " h" this.h " NoActivate")  ;NoActivate

            hwnd1 := WinExist()

            hbm := CreateDIBSection(this.w, this.h)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc)
            Gdip_SetSmoothingMode(G, 4)
            pBrush := Gdip_BrushCreateSolid(c)
            Gdip_FillRectangle(G, pBrush, 0, 0, this.w, this.h)
            Gdip_DeleteBrush(pBrush)
            UpdateLayeredWindow(this._overlay.hwnd, hdc, this.x, this.y, this.w, this.h)


            this.onLButtonDown(onLbuttonDownOverlayHandler)
            onLbuttonDownOverlayHandler(hwnd) {
                If (this._overlay.hwnd != hwnd) {
                    Return
                }
                PostMessage(0xA1, 2,,this._overlay.hwnd)
                this.event.emit("click", this)
                ; this.console.log('overlay LBUTTTON Down')
            }

            this.onMOVE(onMOVE_handler)
            onMOVE_handler(x, y, hwnd) {
                If (this._overlay.hwnd = hwnd) {
                    WinMove(x-3, y-3,,, this._overlayHighlight.hwnd)
                    this.x := x
                    this.y := y
                    this.event.emit("move", this)
                }
            }

            SelectObject(hdc, obm)
            DeleteObject(hbm)
            Gdip_DeleteGraphics(G)


            Gdip_Shutdown(this.pToken)
        }

        highlight(state) {
            if(state) {
                this._overlayHighlight.Show("x" this.x - 3 " y" this.y - 3 " w" this.w + 6 " h" this.h + 6 " NoActivate")  ;NoActivate
            }
            else {
                this._overlayHighlight.hide()
            }
        }

        destroy() {
            this.release("LBUTTONDOWN")
            this.release("MOVE")
            this._overlayHighlight.destroy()
            this._overlay.destroy()
        }

        hide() {
            ; this._overlayHighlight.hide()
            this._overlay.hide()
        }

        show() {
            ; this._overlayHighlight.show()
            this._overlay.show()
        }
    }

    Class Outline extends Screen.Area {
        displayGui := ""
        parent := ""
        borderWidth := 4
        color := "0xFF008000"
        rectangle := ""
        watchEnabled := false
        guiSelectMode := ""
        ; G := ""

        modes := {
            new:{
                name : "new",
                actions: [
                    {name:'watch', display:'w', color:'0xFFA500', colorT:'0xFFFFA500' },
                    {name:'assign', display:'a', color:'0x008000', colorT:'0xFF008000' },
                    {name:'exit', display:'x', color:'0x000000', colorT:'0xFF000000' }
                ]

            },
            update:{
                name : "update",
                actions:[
                    {name:'watch', display:'w', color:'0xFFA500', colorT:'0xFFFFA500'},
                    {name:'update', display:'u', color:'0x008000', colorT:'0xFF008000'},
                    {name:'delete', display:'d', color:'0xFF0000', colorT:'0xFFFF0000'},
                    {name:'exit', display:'x', color:'0x000000', colorT:'0xFF000000' }
                ]
            } ,
            select: {
                name: "select",
                actions: [
                    {name:'select', display:'s', color:'0x0000FF', colorT:'0xFF0000FF' },
                    {name:'read', display:'r', color:'0x008000', colorT:'0xFF008000' },
                    {name:'exit', display:'x', color:'0x000000', colorT:'0xFF000000' }
                ]
            },
            clip: {
                name: "clip",
                actions: [
                    {name:'clip', display:'c', color:'0x0000FF', colorT:'0xFF0000FF' },
                    {name:'read', display:'r', color:'0x008000', colorT:'0xFF008000' },
                    {name:'exit', display:'x', color:'0x000000', colorT:'0xFF000000' }
                ]
            },
            read: {
                name: "read",
                actions: [
                    {name:'read', display:'r', color:'0x008000', colorT:'0xFF008000' },
                ]
            },
            passive: {
                name: "passive",
                actions: [
                    {name:'passive', display:'p', color:'0xFFA500', colorT:'0xFFFFA500' }
                ]
            }
        }

        ; selectModeIndex := 1
        ; selectMode := [
        ;     {name:'clip', display:'c', color:'0x0000FF', colorT:'0xFF0000FF' },
        ;     {name:'read', display:'r', color:'0x008000', colorT:'0xFF008000' },
        ;     {name:'exit', display:'x', color:'0xFF0000', colorT:'0xFFFF0000' }
        ; ]

        ; watchModeNewIndex := 1
        ; watchModeNew := [
        ;     {name:'watch', display:'w', color:'0xFFA500', colorT:'0xFFFFA500' },
        ;     {name:'assign', display:'a', color:'0x008000', colorT:'0xFF008000' }
        ; ]

        ; watchModeUpdateIndex := 1
        ; watchModUpdate := [
        ;     {name:'watch', display:'w', color:'0xFFA500', colorT:'0xFFFFA500' },
        ;     {name:'update', display:'u', color:'0x008000', colorT:'0xFF008000' }
        ; ]

        actionIndex := 1
        mode := ''

        __New(mode := 'new', parent := '', x := '', y := '', w := '', h := '') {

            super.__New(x, y, w, h)
            this.mode := this.modes.%mode%
            this.parent := parent

            ; if(x || y || w || h) {
            ;     this.x := x
            ;     this.y := y
            ;     this.w := w
            ;     this.h := h

                ; if(mode = 'new' || mode = 'update') {
                    ; this.actionIndex := this.watchModeNewIndex
                    ; this.mode := this.watchModeNew
                    this.rectangle := this.outline()
                    if(mode != "passive") {
                        this.handle()
                    }
                ; }
                ; else if(mode := "passive") {
                ;    this.rectangle :=  this.outlinePassive()
                ; }
            ; }
        }

        switchMode(mode) {
            this.mode := this.modes.%mode%

            Switch mode {
                Case "update" : this.show()
                Default:

            }
        }

        ; outlinePassive() {
        ;     If (!this.pToken := Gdip_Startup()) {
        ;         MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")
        ;         Gdip_Shutdown(this.pToken)
        ;         ExitApp()
        ;     }

        ;     If (!this.rectangle) {
        ;         this.rectangle := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs", 'guiRectangle')
        ;         if(this.parent) {
        ;             this.rectangle.opt("+Parent" this.parent.hwnd)
        ;         }
        ;         this.guiSelectMode := Gui("-Caption +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs", 'guiSelectMode')
        ;         this.guiSelectMode.BackColor := this.mode.actions[this.actionIndex].color
        ;         this.guiSelectMode.SetFont('s7 cwhite')
        ;         this.txtSelectMode := this.guiSelectMode.Add('Text', 'x4 y-2', this.mode.actions[this.actionIndex].display)
        ;         this.guiSelectMode.hide()
        ;     }

        ;     this.rectangle.Show("x" this.x " y" this.y " w" this.w " h" this.h " NoActivate")

        ;     hbm := CreateDIBSection(this.w, this.h)
        ;     hdc := CreateCompatibleDC()
        ;     obm := SelectObject(hdc, hbm)
        ;     G := Gdip_GraphicsFromHDC(hdc)
        ;     Gdip_SetSmoothingMode(G, 4)


        ;     ; CloseButton := 1.5 * this.borderWidth
        ;     pPen := Gdip_CreatePen(this.mode.actions[this.actionIndex].colorT, 3)
        ;     ; pPen2 := Gdip_CreatePen(this.mode.actions[this.actionIndex].colorT, THIS.borderWidth * 1.5)
        ;     ; Gdip_DrawRectangle(G, pPen2, this.w - CloseButton, this.h - CloseButton, CloseButton, CloseButton)
        ;     Gdip_DrawRectangle(G, pPen, 0, 0, this.w, this.h)
        ;     Gdip_DeletePen(pPen)
        ;     ; Gdip_DeletePen(pPen2)

        ;         ; Options := "x10p y30p w80p cbbffffff r4 s20 Underline Italic"
        ;         ; Font := "Arial"
        ;         ; Gdip_TextToGraphics(G, this.mode.actions[this.actionIndex], Options)

        ;     UpdateLayeredWindow(this.rectangle.hwnd, hdc, this.x, this.y, this.w, this.h)
        ;     ; this.guiSelectMode.Show('x' this.x ' y' this.y ' w12 h12')

        ;     SelectObject(hdc, obm)
        ;     DeleteObject(hbm)
        ;     DeleteDC(hdc)
        ;     ; Gdip_DeleteGraphics(G)

        ;     Gdip_Shutdown(this.pToken)

        ;     Return this.rectangle
        ; }

        outline(c := this.color, bw := this.borderWidth) {
            if (!this.pToken := Gdip_Startup()) {
                MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")
                Gdip_Shutdown(this.pToken)
                ExitApp()
            }

            if (!this.rectangle) {
                this.rectangle := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs", 'guiRectangle')
               
                if(this.parent) {
                    this.rectangle.opt("+Parent" this.parent.hwnd)
                }
                if(this.mode.name != "passive" && this.mode.name != "read") { 
                    this.guiSelectMode := Gui("-Caption +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs", 'guiSelectMode')
                    this.guiSelectMode.BackColor := this.mode.actions[1].color
                    this.guiSelectMode.SetFont('s7 cwhite')
                    this.txtSelectMode := this.guiSelectMode.Add('Text', 'x4 y-2', this.mode.actions[this.actionIndex].display)
                    this.guiSelectMode.Show('x' this.x ' y' this.y ' w12 h12')
                    if(this.parent) {
                        this.guiSelectMode.opt("+Parent" this.parent.hwnd)
                    }
                }
            }

            this.rectangle.Show("x" this.x " y" this.y " w" this.w " h" this.h " NoActivate")

            hbm := CreateDIBSection(this.w, this.h)
            hdc := CreateCompatibleDC()
            obm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc)
            Gdip_SetSmoothingMode(G, 4)

            pPen := Gdip_CreatePen(this.mode.actions[this.actionIndex].colorT, this.borderWidth)
            Gdip_DrawRectangle(G, pPen, 0, 0, this.w, this.h)
            Gdip_DeletePen(pPen)
            if(this.mode.name != "passive") {

                CloseButton := 1.5 * this.borderWidth
                pPen2 := Gdip_CreatePen(this.mode.actions[this.actionIndex].colorT, this.borderWidth * 1.5)
                Gdip_DrawRectangle(G, pPen2, this.w - CloseButton, this.h - CloseButton, CloseButton, CloseButton)
                Gdip_DeletePen(pPen2)
            }

                ; Options := "x10p y30p w80p cbbffffff r4 s20 Underline Italic"
                ; Font := "Arial"
                ; Gdip_TextToGraphics(G, this.mode.actions[this.actionIndex], Options)

            UpdateLayeredWindow(this.rectangle.hwnd, hdc, this.x, this.y, this.w, this.h)

            SelectObject(hdc, obm)
            DeleteObject(hbm)
            DeleteDC(hdc)
            ; Gdip_DeleteGraphics(G)

            Gdip_Shutdown(this.pToken)

            Return this.rectangle
        }

        handle() {
            this.onLButtonDown(onLbuttonutlineDown_handler)
            onLbuttonutlineDown_handler(hwnd) {
                if (this.rectangle.hwnd = hwnd) {
                    PostMessage(0xA1, 2,, this.rectangle.hwnd)
                }
            }

            this.onRButtonDown(onRButtonDown_handler)
            onRButtonDown_handler(hwnd) {
                if (this.rectangle.hwnd != hwnd) {
                    Return
                }
                this.resize()
            }

            this.onMOVE(onMOVE_handler)
            onMOVE_handler(x, y, hwnd) {
                If (this.rectangle.hwnd = hwnd) {
                    SetWinDelay(0)
                    if(this.mode.name != "passive" && this.mode.name != "read") {
                        WinMove(x, y,,, this.guiSelectMode.hwnd)
                    }
                    this.x := x
                    this.y := y
                    this.event.emit("move", this)
                }
            }

            this.onCAPTURECHANGED(onCAPTURECHANGED_handler)
            onCAPTURECHANGED_handler(hwnd) {
                If (this.rectangle.hwnd != hwnd) {
                    Return
                }
                ; WinActivate(this.rectangle.hwnd)
                ; WinGetPos(&x, &y, &w, &h, hwnd)  ;; REQUIRED to update the x, y on move end
                ; this.x := x
                ; this.y := y
                ; this.console.log("onCAPTURECHANGED_handler")
            }

            this.onMOUSEWHEEL(onMOUSEWHEEL_handler)
            onMOUSEWHEEL_handler(wParam, lParam, msg, hwnd) {
                if(this.rectangle.hwnd != hwnd) {
                    return
                }

                WHEEL_DELTA := (wParam << 32 >> 48)
                if(WHEEL_DELTA = 120) {
                    this.actionIndex := this.actionIndex = 1 ? this.mode.actions.Length : this.actionIndex - 1
                }
                else {
                    this.actionIndex := this.actionIndex = this.mode.actions.Length ? 1 : this.actionIndex + 1
                }
                this.txtSelectMode.Text := this.mode.actions[this.actionIndex].display
                this.color := this.mode.actions[this.actionIndex].colorT                
                if(this.mode.name != "passive" && this.mode.name != "read") {
                    this.guiSelectMode.BackColor := this.mode.actions[this.actionIndex].color
                }
                this.outline()
                ; this.console.log("onMOUSEWHEEL_handler")
            }

            this.onLBUTTONDBLCLK(onLBUTTONDBLCLK_handler)
            onLBUTTONDBLCLK_handler(hwnd) {
                if (this.rectangle.hwnd != hwnd) {
                    Return
                }

                this.islButtonDown := false

                if (this.mode.actions[this.actionIndex].name = 'read') {
                    this.watchCheck()
                }
                else if(this.mode.actions[this.actionIndex].name = 'select') {
                    this.event.emit(this.events.select, this)
                    this.destroy()
                }
                else if(this.mode.actions[this.actionIndex].name = 'watch') {
                    this.watchCheck()
                }
                else if(this.mode.actions[this.actionIndex].name = 'clip') {
                    this.clip()
                    this.persist()
                }
                else if(this.mode.actions[this.actionIndex].name = 'assign') {
                    this.event.emit(this.events.assign, this)
                    this.destroy()
                }
                else if(this.mode.actions[this.actionIndex].name = 'update') {
                    this.watchUpdate()
                }
                else if(this.mode.actions[this.actionIndex].name = 'exit') {
                    this.destroy()
                }
            }

        }

        resize() {
            CoordMode("Mouse", (this.parent?"client":"Screen"))
            MouseGetPos(&mX, &mY)
            xOff := this.w - mX
            yOff := this.h - mY

            this.loopstate := true
            this.loopStateCount := 0
            While GetKeyState("RButton", "p") {
                MouseGetPos(&mX, &mY)

                this.w := mX + xOff
                this.h := mY + yOff

                this.rectangle := this.outline()

                this.event.emit("resize", this)
            }
        }


        clip(x := this.x, y := this.y, w := this.w, h := this.y) {
            If (!pToken := Gdip_Startup()) {
                MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

                Gdip_Shutdown(pToken)
                ExitApp()
            }
            ; this.rectangle.hide()
            ; if(this.guiSelectMode) {
            ;     this.guiSelectMode.hide()
            ; }
            this.hide()
            this.clipBitmap := Gdip_BitmapFromScreen(x "|" y "|" w "|" h)
            this.show()
            ; this.rectangle.Show()
            ; if(this.guiSelectMode) {
            ;     this.guiSelectMode.show()
            ; }
            ; Gdip_SaveBitmapToFile(_pBitmapScreen, "clips/Gdip_BitmapFromScreen.png")
            ; Gdip_DisposeImage(_pBitmapScreen)
            ; Gdip_Shutdown(pToken)

            Return this.clipBitmap
        }

        persist(_gui := "", x := this.x, y := this.y, w := this.w, h := this.y) { ; place image onscreen in original position while still movable, with thin border for contrast


            boreder := 10
            color := "0xffffffff"
            if(!_gui) {
                _gui := this.displayGui := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
            }
            _gui.Show("x" x " y" y " w" w " h" h " NoActivate")
            _gui.color := "0x00FFFFFF"
            ; displayGui.outline()

            hbm := CreateDIBSection(w + boreder, h + boreder)
            hdc := CreateCompatibleDC()
            bm := SelectObject(hdc, hbm)
            G := Gdip_GraphicsFromHDC(hdc)
            Gdip_SetSmoothingMode(G, 4)
            Gdip_SetInterpolationMode(G, 7)


            ; pBitmap := Gdip_BitmapFromScreen(this.x "|" this.y "|" this.w "|" this.h)
            Gdip_DrawImage(G, this.clipBitmap, 0, 0, w, h, 0, 0, w, h)


            ; pPen := Gdip_CreatePen(color, this.borderWidth)
            ; Gdip_DrawRectangle(G, pPen, 0, 0, w, h)
            ; Gdip_DeletePen(pPen)


            Gdip_DeleteGraphics(G)
            ; Gdip_DisposeImage(this.clipBitmap)
            UpdateLayeredWindow(_gui.hwnd, hdc, x, y, w, h, 255)
            SelectObject(hdc, bm)
            DeleteObject(hbm)
            DeleteDC(hdc)

            ; this.islButtonDown := false
            ; this.onLButtonDown(onLbuttonDownOverlayHandler)
            ; onLbuttonDownOverlayHandler(hwnd) {
            ;     If (_gui.hwnd != hwnd) {
            ;         Return
            ;     }
            ;     this.islButtonDown := true
            ;     ; this.console.log('onLButtonDown persist')
            ;     PostMessage(0xA1, 2)
            ;     ; this.saveTempClip()
            ; }

            ; this.onLButtonUp(onLButtonUp_handler)
            ; onLButtonUp_handler(hwnd) {
            ;     If (_gui.hwnd != hwnd) {
            ;         Return
            ;     }
            ;     ; this.console.log('onLButtonUp persist')
            ; }

            ; this.onCaptureChanged(onCaptureChanged_handler)
            ; onCaptureChanged_handler(hwnd) {
            ;     If (_gui.hwnd != hwnd) {
            ;         Return
            ;     }
            ;     ; this.console.log('onCaptureChanged persist')

            ;     if(this.islButtonDown) {
            ;         ; this.console.log('lButton_DOWN persist')
            ;         this.islButtonDown := false

            ;     }
            ;     else {
            ;         ; this.console.log('lButton_UP persist')


            ;         ; WinGetPos(&wX, &wY,,, this.console.guiControls.hwnd)
            ;         ; MouseGetPos(&mX, &mY)
            ;         ; if(mX > wX && mY > wY) {
            ;         ;     ; this.console.log('INSIDE guiControls')

            ;         ;     this.event.emit(this.events.insideGuiControls, "")
            ;         ; }
            ;         ; else {

            ;         ;     ; this.console.log('OUTSIDE guiControls')
            ;         ; }
            ;     }
            ; }
        }

        update(x, y, w, h) {
            this.x := x
            this.y := y
            this.w := w
            this.h := h
            return this.rectangle := this.outline()
        }

        save(file := "") {
            if(!file) {
                file := FileSelect("Save", "clips/*.png", "Save As", "Save As")
            }
            If (!pToken := Gdip_Startup()) {
                MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

                Gdip_Shutdown(pToken)
                ExitApp()
            }
            ; _pBitmapScreen := Gdip_BitmapFromScreen(this.x "|" this.y "|" this.w "|" this.h)
            Gdip_SaveBitmapToFile(this.clipBitmap, file)
            Gdip_DisposeImage(this.clipBitmap)
            Gdip_Shutdown(pToken)
            if(this.displayGui) {
                this.displayGui.hide()
            }
        }

        saveTempClip(fileName := "tmp.jpg") {
            ; selectedFile := FileSelect("Save", "clips/*.png", "Save As", "Save As")
            ; If (selectedFile) {
                If (!pToken := Gdip_Startup()) {
                    MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")

                    Gdip_Shutdown(pToken)
                    ExitApp()
                }
                ; _pBitmapScreen := Gdip_BitmapFromScreen(this.x "|" this.y "|" this.w "|" this.h)
                result := Gdip_SaveBitmapToFile(this.clipBitmap, A_InitialWorkingDir '/clips/' fileName)
                Gdip_DisposeImage(this.clipBitmap)
                Gdip_Shutdown(pToken)
            ; }
        }

        hide() {
            this.rectangle.hide()                          
            if(this.mode.name != "passive" && this.mode.name != "read") {
                this.guiSelectMode.hide()
            }
        }

        show() {

            ; Switch this.mode.name {
            ;     Case "passive" : this.guiSelectMode.hide()
            ;     case "update" : this.guiSelectMode.show()
            ;     case "select" :
            ;     case "new" :
            ;     Default:

            ; }
            if(this.mode.name != "passive" &&  this.mode.name != "read") {
                this.guiSelectMode.show()
            }
            this.rectangle.show()
        }

        destroy(*) {
            this.release("LBUTTONDBLCLK")
            this.release("LBUTTONDOWN")
            this.release("RBUTTONDOWN")
            this.release("MOVE")
            this.release("MOUSEWHEEL")
            this.release("CAPTURECHANGED")
            ; this.rectangle.hide()
            ; this.guiSelectMode.hide()
            ; Pause(0)
            ; this.ReleaseAll()
            this.stopWatch()
            this.rectangle.Destroy()            
            if(this.mode.name != "passive" &&  this.mode.name != "read") {
                this.guiSelectMode.Destroy()
            }
        }

        ReadText(x := this.x, y := this.y, w := this.w, h := this.h) {
            rX := x
            rY := y
            rW := w
            rH := h
            if(this.parent) {
                WinGetPos(&x, &y, &w, &h, this.parent.hwnd)
                rX += x
                rY += y
            }
            ; text := Screen.FromRect(Integer(this.x), Integer(this.y), Integer(this.w), Integer(this.h)).Text
            ; this.event.emit(this.events.textOut, text)
            ; return text
            return Screen.FromRect(Integer(rX), Integer(rY), Integer(w), Integer(h)).Text
        }


        watchUpdate(callback := "") {
            if(callback) {
                callback(this.x, this.y, this.w, this.h)
            }
            if(this.watchUpdateCallback) {
                this.watchUpdateCallback(this.x, this.y, this.w, this.h)
            }
            this.event.emit(this.events.update, this.x, this.y, this.w, this.h)

            ; this.ReleaseAll()
            ; this.destroy()
        }

        watchUpdateCallback := ""
        onWatchUpdate(callback) {
            this.watchUpdateCallback := callback
        }

        removeWatchUpdate() {
            this.watchUpdateCallback := ""
        }


        watchCheck(callback := "") {
            text := Screen.FromRect(this.x, this.y, this.w, this.h).Text
            if(callback) {
                callback(text)
            }
            if(this.watchCheckCallback) {
                this.watchCheckCallback(text)
            }
            this.event.emit(this.events.textOut, text)
        }

        watchCheckCallback := ""
        onWatchCheck(callback) {
            this.watchCheckCallback := callback
        }
        removeWatchCheck() {
            this.watchCheckCallback := ""
        }

        Watch(period, callback := "") {
            this.watchEnabled := true
            SetTimer(onTick.Bind(this, callback), period)

            onTick(callback) {
                if(!this.watchEnabled || Screen.stopWatches) {
                    SetTimer((callback) => this.onTick(callback), 0)
                    Screen.stopWatches := false
                }
                else {
                    if(callback) {
                        callback(this.ReadText())
                        return
                    }
                    this.event.emit(this.events.watch, this.ReadText())
                }
            }

        }


        stopWatch() {
            this.watchEnabled := false
            this.event.removeAllListeners(this.events.watch)
        }

        ReadClip() {
            this.clip()
        }
    }

    Class Select extends Screen.Outline {

        __New(k, parent := "") {
            this.parent := parent
            CoordMode("Mouse", (this.parent?"client":"Screen"))
            MouseGetPos(&sX, &sY)
            this.x := 5
            this.y := 45
            this.w := 80
            this.h := 30
            super.__New('select', parent)
            ; this.select(k)
        }

        select(key) {
            CoordMode("Mouse", (this.parent?"client":"Screen"))
            MouseGetPos(&sX, &sY)
            this.x := sX
            this.y := sY
            this.w := 10
            this.h := 10
            this.mode := this.modes.select
            ; this.rectangle := this.outline(, 'select')
            while GetKeyState(key, "p") {
                MouseGetPos(&cX, &cY)
                this.w := cX - sX
                this.h := cY - sY
                ; this.console.log("select")
                this.rectangle := this.outline(, 'select')

                ; this.event.emit("update", this.rectangle)
            }

            this.handle()
            Return this
        }
    }
}

; if(A_Args.Length > 0) {
;     Switch A_Args[1] {
;         Case 'outline' : outline := Screen.Outline(,, Round(SysGet(16) / 2), Round(SysGet(17) / 2))
;         Case 'select' : Hotkey("!RButton", _screen, "On")
;         Case 'overlay' :  overlay := Screen.Overlay(100, 100, Round(SysGet(16) / 2), Round(SysGet(17) / 2))

;     }
;     _screen(*) {
;         Global
;         selection := Screen.Select('RButton')
;     }
; }



#Requires AutoHotkey v2.0
#Include utils.ahk

; Win32 API
; Functions SetWindowPos(), MoveWindow() and AdjustWindowRectEx().
;;BeginDeferWindowPos(), DeferWindowPos() and EndDeferWindowPos(). I


; onLBUTTONDOWN(callback(hwnd))
; onLBUTTONUP(callback(hwnd))
; onRBUTTONDOWN(callback(hwnd))
; onRBUTTONUP(callback(hwnd))
; onMOUSEHOVER(callback(hwnd))
; onMOUSELEAVE(callback(hwnd))
; onMOUSECAPTURECHANGED(callback(hwnd))

; onENTERSIZEMOVE(callback(hwnd))
; onMOVE(callback(hwnd))
; onMOVING(callback(hwnd))
; onSIZE(callback(hwnd))
; onSIZING(callback(hwnd))
; onCAPTURECHANGED(callback(hwnd))
; onWINDOWPOSCHANGING(callback(hwnd))
; onWINDOWPOSCHANGED(callback(hwnd))


Class Win32API {

    wm := Win32API.WinUserHeader()

    

    __New() {
        this.wm.mouse(mouseHandler)
        mouseHandler(wParam, lParam, msg, hwnd) {
            Switch (msg) {
                Case Win32API.WinUserHeader.LBUTTONDOWN: this.LBUTTONDOWN_handler(hwnd)
                Case Win32API.WinUserHeader.LBUTTONUP: this.LBUTTONUP_handler(hwnd)
                Case Win32API.WinUserHeader.LBUTTONDBLCLK: this.LBUTTONDBLCLK_handler(hwnd)
                Case Win32API.WinUserHeader.RBUTTONDOWN: this.RBUTTONDOWN_handler(hwnd)
                Case Win32API.WinUserHeader.RBUTTONUP: this.RBUTTONUP_handler(hwnd)
                Case Win32API.WinUserHeader.RBUTTONDBLCLK: this.RBUTTONDBLCLK_handler(hwnd)
                Case Win32API.WinUserHeader.MOUSEWHEEL: this.MOUSEWHEEL_handler(wParam, lParam, msg, hwnd)
                Case Win32API.WinUserHeader.MOUSEMOVE: this.MOUSEMOVE_handler(hwnd)
                Case Win32API.WinUserHeader.MOUSEHOVER: this.MOUSEHOVER_handler(hwnd)
                Case Win32API.WinUserHeader.MOUSELEAVE: this.MOUSELEAVE_handler(hwnd)
                Case Win32API.WinUserHeader.MOUSECAPTURECHANGED: this.MOUSECAPTURECHANGED_handler(hwnd)
            }
        }

        this.wm.window(windowHandler)
        windowHandler(wParam, lParam, msg, hwnd) {
            Switch (msg) {
                Case Win32API.WinUserHeader.ENTERSIZEMOVE: this.ENTERSIZEMOVE_handler(hwnd)
                Case Win32API.WinUserHeader.MOVE: this.MOVE_handler(Win32API.Macro.LOWORD(lParam), Win32API.Macro.HIWORD(lParam), hwnd)
                Case Win32API.WinUserHeader.MOVING: this.MOVING_handler(hwnd)
                Case Win32API.WinUserHeader.SIZE: this.SIZE_handler(hwnd)
                Case Win32API.WinUserHeader.SIZING: this.SIZING_handler(hwnd)
                Case Win32API.WinUserHeader.CAPTURECHANGED: this.CAPTURECHANGED_handler(hwnd)
                Case Win32API.WinUserHeader.WINDOWPOSCHANGING: this.WINDOWPOSCHANGING_handler(hwnd)
                Case Win32API.WinUserHeader.WINDOWPOSCHANGED: this.WINDOWPOSCHANGED_handler(hwnd)
            }
        }    
    }

    release(which) {
        this.%which%_callbacks := ["release"]
    }

    ReleaseAll() {

        this.LBUTTONDOWN_callbacks := []
        this.LBUTTONUP_callbacks := []
        this.LBUTTONDBLCLK_callbacks := []
        this.RBUTTONDOWN_callbacks := []
        this.RBUTTONUP_callbacks := []
        this.RBUTTONDBLCLK_callbacks := []
        this.MOUSEMOVE_callbacks := []
        this.MOUSEWHEEL_callbacks := []
        this.MOUSEHOVER_callbacks := []
        this.MOUSELEAVE_callbacks := []
        this.MOUSECAPTURECHANGED_callbacks := []
        this.ENTERSIZEMOVE_callbacks := []
        this.MOVE_callbacks := []
        this.MOVING_callbacks := []
        this.SIZE_callbacks := []
        this.SIZING_callbacks := []
        this.CAPTURECHANGED_callbacks := []
        this.WINDOWPOSCHANGING_callbacks := []
        this.WINDOWPOSCHANGED_callbacks := []
    }


    cbDropState(hwnd) {            
        return SendMessage(Win32API.WinUserHeader.GETTEXT, 0, 0, hwnd)
    }


    LBUTTONDOWN_handler(hwnd) {
        For callback in this.LBUTTONDOWN_callbacks {
            if(this.LBUTTONDOWN_callbacks[1] == "release") {
                this.LBUTTONDOWN_callbacks := []
                return                
            }
            callback.Call(hwnd)
        }
    }

    LBUTTONDOWN_callbacks := []
    onLBUTTONDOWN(callback) {
        this.LBUTTONDOWN_callbacks.Push(callback)
    }

    _onLBUTTONDOWN(callback) {
        OnMessage(Win32API.WinUserHeader.LBUTTONDOWN, onMessageHandler)
        onMessageHandler(wParam, lParam, msg, hwnd) {
            callback(wParam, lParam, msg, hwnd)
        }
        
    }

    LBUTTONDOWN(ctrl, win) {
        PostMessage(Win32API.WinUserHeader.LBUTTONDOWN,,,ctrl, win)
        ; PostMessage, 0x201, , %lParam%, Edit1 , %win% ;WM_LBUTTONDOWN
    }

    LBUTTONUP_handler(hwnd) {
        For callback in this.LBUTTONUP_callbacks {
            callback.Call(hwnd)
        }
    }

    LBUTTONUP_callbacks := []
    onLBUTTONUP(callback) {
        this.LBUTTONUP_callbacks.Push(callback)
    }

    LBUTTONDBLCLK_handler(hwnd) {
        For callback in this.LBUTTONDBLCLK_callbacks {
            if(this.LBUTTONDBLCLK_callbacks[1] == "release") {
                this.LBUTTONDBLCLK_callbacks := []
                return                
            }
            callback.Call(hwnd)
        }
    }

    
    LBUTTONDBLCLK_callbacks := []
    onLBUTTONDBLCLK(callback) {
        this.LBUTTONDBLCLK_callbacks.Push(callback)
    }

    RBUTTONDOWN_handler(hwnd) {
        For callback in this.RBUTTONDOWN_callbacks {
            if(this.RBUTTONDOWN_callbacks[1] == "release") {
                this.RBUTTONDOWN_callbacks := []
                return                
            }
            callback.Call(hwnd)
        }
    }

    RBUTTONDOWN_callbacks := []
    onRBUTTONDOWN(callback) {
        this.RBUTTONDOWN_callbacks.Push(callback)
    }

    RBUTTONUP_handler(hwnd) {
        For callback in this.RBUTTONUP_callbacks {
            callback.Call(hwnd)
        }
    }

    RBUTTONUP_callbacks := []
    onRBUTTONUP(callback) {
        this.RBUTTONUP_callbacks.Push(callback)
    }

    RBUTTONDBLCLK_handler(hwnd) {
        For callback in this.RBUTTONDBLCLK_callback {
            callback.Call(hwnd)
        }
    }

    RBUTTONDBLCLK_callback := []
    onRBUTTONDBLCLK(callback) {
        this.RBUTTONDBLCLK_callback.Push(callback)
    }

    MOUSEWHEEL_handler(wParam, lParam, msg, hwnd) {
        For callback in this.MOUSEWHEEL_callbacks {
            if(this.MOUSEWHEEL_callbacks[1] == "release") {
                this.MOUSEWHEEL_callbacks := []
                return                
            }
            callback.Call(wParam, lParam, msg, hwnd)
        }
    }

    MOUSEWHEEL_callbacks := []
    onMOUSEWHEEL(callback) {
        this.MOUSEWHEEL_callbacks.Push(callback)
    }

    MOUSEMOVE_handler(hwnd) {
        For callback in this.MOUSEMOVE_callbacks {
            if(this.MOUSEMOVE_callbacks[1] == "release") {
                this.MOUSEMOVE_callbacks := []
                return                
            }
            callback.Call(hwnd)
        }
    }

    MOUSEMOVE_callbacks := []
    onMOUSEMOVE(callback) {
        this.MOUSEMOVE_callbacks.Push(callback)
    }

    MOUSEHOVER_handler(hwnd) {
        For callback in this.MOUSEHOVER_callbacks {
            callback.Call(hwnd)
        }
    }

    MOUSEHOVER_callbacks := []
    onMOUSEHOVER(callback) {
        this.MOUSEHOVER_callbacks.Push(callback)
    }

    MOUSELEAVE_handler(hwnd) {
        For callback in this.MOUSELEAVE_callbacks {
            callback.Call(hwnd)
        }
    }

    MOUSELEAVE_callbacks := []
    onMOUSELEAVE(callback) {
        this.MOUSELEAVE_callbacks.Push(callback)
    }

    MOUSECAPTURECHANGED_handler(hwnd) {
        For callback in this.MOUSECAPTURECHANGED_callbacks {
            callback.Call(hwnd)
        }
    }

    MOUSECAPTURECHANGED_callbacks := []
    onMOUSECAPTURECHANGED(callback) {
        this.MOUSECAPTURECHANGED_callbacks.Push(callback)
    }

    ENTERSIZEMOVE_handler(hwnd) {
        For callback in this.ENTERSIZEMOVE_callbacks {
            callback.Call(hwnd)
        }
    }

    ENTERSIZEMOVE_callbacks := []
    onENTERSIZEMOVE(callback) {
        this.ENTERSIZEMOVE_callbacks.Push(callback)
    }

    MOVE_handler(x, y, hwnd) {
        For callback in this.MOVE_callbacks {
            if(this.MOVE_callbacks[1] == "release") {
                this.MOVE_callbacks := []
                return                
            }
            callback.Call(x, y, hwnd)
        }
    }

    MOVE_callbacks := []
    onMOVE(callback) {
        this.MOVE_callbacks.Push(callback)
    }

    MOVING_handler(hwnd) {
        For callback in this.MOVING_callbacks {
            callback.Call(hwnd)
        }
    }

    MOVING_callbacks := []
    onMOVING(callback) {
        this.MOVING_callbacks.Push(callback)
    }

    SIZE_handler(hwnd) {
        For callback in this.SIZE_callbacks {
            callback.Call(hwnd)
        }
    }

    SIZE_callbacks := []
    onSIZE(callback) {
        this.SIZE_callbacks.Push(callback)
    }

    SIZING_handler(hwnd) {
        For callback in this.SIZING_callbacks {
            callback.Call(hwnd)
        }
    }

    SIZING_callbacks := []
    onSIZING(callback) {
        this.SIZING_callbacks.Push(callback)
    }

    CAPTURECHANGED_handler(hwnd) {
        For callback in this.CAPTURECHANGED_callbacks {
            if(this.CAPTURECHANGED_callbacks[1] == "release") {
                this.CAPTURECHANGED_callbacks := []
                return                
            }
            callback.Call(hwnd)
        }
    }

    CAPTURECHANGED_callbacks := []
    onCAPTURECHANGED(callback) {
        this.CAPTURECHANGED_callbacks.Push(callback)
    }

    WINDOWPOSCHANGING_handler(hwnd) {
        For callback in this.WINDOWPOSCHANGING_callbacks {
            callback.Call(hwnd)
        }
    }

    WINDOWPOSCHANGING_callbacks := []
    onWINDOWPOSCHANGING(callback) {
        this.WINDOWPOSCHANGING_callbacks.Push(callback)
    }

    WINDOWPOSCHANGED_handler(hwnd) {
        For callback in this.WINDOWPOSCHANGED_callbacks {
            callback.Call(hwnd)
        }
    }

    WINDOWPOSCHANGED_callbacks := []
    onWINDOWPOSCHANGED(callback) {
        this.WINDOWPOSCHANGED_callbacks.Push(callback)
    }  

    GETTEXT_handler(hwnd) {
        For callback in this.GETTEXT_callbacks {
            callback.Call(hwnd)
        }
    }

    GETTEXT_callbacks := []
    onGETTEXT(callback) {
        this.GETTEXT_callbacks.Push(callback)
    }  
    
    SETTEXT_handler(hwnd) {
        For callback in this.SETTEXT_callbacks {
            callback.Call(hwnd)
        }
    }

    SETTEXT_callbacks := []
    onSETTEXT(callback) {
        this.SETTEXT_callbacks.Push(callback)
    }

    sendSETTEXT(wParam, lParam, hwnd) {
        return Win32API.WinUserHeader.Window.Text.Set.send(wParam, lParam, hwnd)
    }

    sendGETTEXT(wParam, lParam, hwnd) {
        return Win32API.WinUserHeader.Window.Text.Get.send(wParam, lParam, hwnd)
    }

    sendLBUTTONDOWN(x, y, hwnd) {   
             
        return Win32API.WinUserHeader.Mouse.Left.Down.send("", Win32API.Macro.MAKELPARAM(Integer(x), Integer(y)), hwnd)
    }

    sendLBUTTONUP(x, y, hwnd) {
        
        lParam := Integer(x) & 0xFFFF | (Integer(y) & 0xFFFF) << 16  
        return Win32API.WinUserHeader.Mouse.Left.Up.send("", Win32API.Macro.MAKELPARAM(Integer(x), Integer(y)), hwnd)
    }
    sendLVMGetHeader(hwnd) {
        return SendMessage(Win32API.WinUserHeader.GETHEADER, 0, 0, hwnd)
    }



    class Window {
        static WM_COMMAND  := 0x111
    }

    class Edit {

        static EN_CLICKED := 0x0001 ; Notifies a click in an edit control.
        static EN_DBLCLK := 0x0002 ; Notifies a double click in an edit control.
        static EN_SETFOCUS := 0x0100 ; Notifies the receipt of the input focus.
        static EN_KILLFOCUS := 0x0200 ; Notifies the lost of the input focus.
        static EN_CHANGE := 0x0300 ; Notifies that the text is altered by the user.
        static EN_UPDATE := 0x0400 ; Notifies that the text is altered by sending MSG_SETTEXT TEM_RESETCONTENT, or EM_SETLINEHEIGHT message to it.
        static EN_MAXTEXT := 0x0501 ; Notifies reach of maximum text limitation.
        static EN_SELCHANGED := 0x0603 ; Notifies that the current selection is changed in the text field.
        static EN_CONTCHANGED := 0x0604 ; Notifies that the current content is changed in the text field when text edit losts focus.
        static EN_ENTER := 0x0700 ; Notifies the user has type the ENTER key in a single-line edit control.

        static onKillFocus(ctrl, callback) {
            OnMessage(Win32API.Window.WM_COMMAND, onMessageHandler)
            onMessageHandler(wp, lp, msg, hwnd) {
                if(ctrl.Gui.hwnd == hwnd && ctrl.hwnd == lp) {
                    lWORD := Win32API.Macro.LOWORD(wp)
                    hWORD := Win32API.Macro.HIWORD(wp)
                    if(hWORD == Win32API.Edit.EN_KILLFOCUS) {
                        callback(lp, msg)
                    }
                }
            }
        }        
        

        ; 1024 -> 0x0400 -> EN_UPDATE
        ; 768 ->  0x0300 -> EN_CHANGE
        ; 512 ->  0x0200 -> EN_KILLFOCUS
        ; 256 ->  0x0100 -> EN_SETFOCUS

        static onSetFocus(ctrl, callback) {
            OnMessage(Win32API.Window.WM_COMMAND, onMessageHandler)
            onMessageHandler(wp, lp, msg, hwnd) {
                if(ctrl.Gui.hwnd == hwnd && ctrl.hwnd == lp) {
                    lWORD := Win32API.Macro.LOWORD(wp)
                    hWORD := Win32API.Macro.HIWORD(wp)
                    if(hWORD == Win32API.Edit.EN_SETFOCUS) {
                        callback(lp, msg)
                    }
                }
            }
        } 

        
        ; static onContChanged(ctrl, callback) {
        ;     OnMessage(Win32API.Window.WM_COMMAND, onMessageHandler)
        ;     onMessageHandler(wp, lp, msg, hwnd) {
        ;         lWORD := Win32API.Macro.LOWORD(wp)
        ;         hWORD := Win32API.Macro.HIWORD(wp)
        ;         ToolTip(hWORD)
        ;         if(ctrl.Gui.hwnd == hwnd) {
        ;             if(ctrl.hwnd == lp) {

        ;                 if(hWORD == Win32API.Edit.EN_CONTCHANGED) {
        ;                     callback(lp, msg, hwnd)
        ;                 }
        ;             }
        ;         }
        ;     }
        ; } 
    }


    Class WinUserHeader {        

        ;List View Messages LVM_
        Static GETHEADER := 0x101F

        ;WM_Mouse messages
        Static LBUTTONDOWN := 0x0201
        Static LBUTTONUP := 0x0202
        Static LBUTTONDBLCLK := 0x0203
        Static RBUTTONDOWN := 0x0204
        Static RBUTTONUP := 0x0205
        Static RBUTTONDBLCLK := 0x0206
        Static MBUTTONDOWN := 0x0207
        Static MBUTTONUP := 0x0208
        Static MBUTTONDBLCLK := 0x0209
        Static XBUTTONDOWN := 0x020B
        Static XBUTTONUP := 0x020C
        Static XBUTTONDBLCLK := 0x020D
        Static MOUSEMOVE := 0x0200
        Static MOUSEWHEEL := 0x020A
        Static MOUSEHOVER := 0x02A1
        Static MOUSELEAVE := 0x02A3
        Static MOUSECAPTURECHANGED := 0x0218
        Static MOUSEACTIVATE := 0x0021

        ;Window messages WM_
        Static CONTEXTMENU := 0x007B
        Static ENTERSIZEMOVE := 0x0231
        Static EXITSIZEMOVE := 0x0232
        Static MOVE := 0x0003
        Static MOVING := 0x0216
        Static SIZE := 0x0005
        Static SIZING := 0x0214
        Static CAPTURECHANGED := 0x0215
        Static WINDOWPOSCHANGING := 0x0046
        Static WINDOWPOSCHANGED := 0x0047
        Static GETTEXT := 0x000D
        Static SETTEXT := 0x000C
        Static DROPFILES := 0x0233

        ;ComboBox
        Static GETDROPPEDSTATE := 0x0157



        _mouse := Win32API.WinUserHeader.Mouse()
        _window := Win32API.WinUserHeader.Window()
        _function := Win32API.WinUserHeader.Function()


        mouse(callback) {
            this._mouse.on(callback)
        }

        sendMouse(wParam, lParam, hwnd) {
            return this._mouse.send()
        }

        window(callback) {
            this._window.on(callback)
        }

        sendWindow(wParam, lParam, hwnd) {
            return this._window.send(wParam, lParam, hwnd)
        }

        function(name, hwnd, hWndInsertAfter, X, Y, cx, cy, uFlags) {
            Return this._function(name, hwnd, hWndInsertAfter, X, Y, cx, cy, uFlags)
        }

        Class Mouse {

            _Left := Win32API.WinUserHeader.Mouse.Left()
            _Right := Win32API.WinUserHeader.Mouse.Right()
            _Middle := Win32API.WinUserHeader.Mouse.Middle()
            _XButton1 := Win32API.WinUserHeader.Mouse.XButton1()
            _XButton2 := Win32API.WinUserHeader.Mouse.XButton2()
            _Move := Win32API.WinUserHeader.Mouse.Move()
            _Wheel := Win32API.WinUserHeader.Mouse.Wheel()
            _Hover := Win32API.WinUserHeader.Mouse.Hover()
            _CaptureChanged := Win32API.WinUserHeader.Mouse.CaptureChanged()
            _Activate := Win32API.WinUserHeader.Mouse.Activate()


            on(callback) {
                this._Left.on(callback)
                this._Right.on(callback)
                this._Middle.on(callback)
                this._XButton1.on(callback)
                this._XButton2.on(callback)
                this._Move.on(callback)
                this._Wheel.on(callback)
                this._Hover.on(callback)
                this._CaptureChanged.on(callback)
                this._Activate.on(callback)

            }

            Class Left {

                _Down := Win32API.WinUserHeader.Mouse.Left.Down()
                _Up := Win32API.WinUserHeader.Mouse.Left.Up()
                _Double := Win32API.WinUserHeader.Mouse.Left.Double()

                on(callback) {
                    this._Down.on(callback)
                    this._Up.on(callback)
                    this._Double.on(callback)
                }

                Class Down {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.LBUTTONDOWN, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }

                    static send(wParam, lParam, hwnd) {
                        return SendMessage(Win32API.WinUserHeader.LBUTTONDOWN, wParam, lParam, hwnd)
                        
                    }
                }

                Class Up {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.LBUTTONUP, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }

                    static send(wParam, lParam, hwnd) {
                        return SendMessage(Win32API.WinUserHeader.LBUTTONUP, wParam, lParam, hwnd)
                        
                    }
                }

                Class Double {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.LBUTTONDBLCLK, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }
            }

            Class Right {

                _Down := Win32API.WinUserHeader.Mouse.Right.Down()
                _Up := Win32API.WinUserHeader.Mouse.Right.Up()
                _Double := Win32API.WinUserHeader.Mouse.Right.Double()

                on(callback) {
                    this._Down.on(callback)
                    this._Up.on(callback)
                    this._Double.on(callback)
                }

                Class Down {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.RBUTTONDOWN, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Up {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.RBUTTONUP, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Double {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.RBUTTONDBLCLK, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }
            }

            Class Middle {

                _Down := Win32API.WinUserHeader.Mouse.Middle.Down()
                _Up := Win32API.WinUserHeader.Mouse.Middle.Up()
                _Double := Win32API.WinUserHeader.Mouse.Middle.Double()

                on(callback) {
                    this._Down.on(callback)
                    this._Up.on(callback)
                    this._Double.on(callback)
                }

                Class Down {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.MBUTTONDOWN, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Up {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.MBUTTONUP, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Double {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.MBUTTONDBLCLK, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }
            }

            Class XButton1 {

                _Down := Win32API.WinUserHeader.Mouse.XButton1.Down()
                _Up := Win32API.WinUserHeader.Mouse.XButton1.Up()
                _Double := Win32API.WinUserHeader.Mouse.XButton1.Double()

                on(callback) {
                    this._Down.on(callback)
                    this._Up.on(callback)
                    this._Double.on(callback)
                }

                Class Down {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.XBUTTONDOWN, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Up {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.XBUTTONUP, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Double {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.XBUTTONDBLCLK, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }
            }

            Class XButton2 {

                _Down := Win32API.WinUserHeader.Mouse.XButton2.Down()
                _Up := Win32API.WinUserHeader.Mouse.XButton2.Up()
                _Double := Win32API.WinUserHeader.Mouse.XButton2.Double()

                on(callback) {

                    this._Down.on(callback)
                    this._Up.on(callback)
                    this._Double.on(callback)
                }

                Class Down {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.XBUTTONDOWN, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Up {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.XBUTTONUP, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }

                Class Double {

                    on(callback) {
                        OnMessage(Win32API.WinUserHeader.XBUTTONDBLCLK, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }
                }
            }

            Class Move {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOUSEMOVE, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Wheel {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOUSEWHEEL, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Hover {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOUSEHOVER, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class CaptureChanged {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOUSECAPTURECHANGED, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Activate {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOUSEACTIVATE, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }
        }

        Class Edit {
            
        }

        Class Window {

            _ContextMenu := Win32API.WinUserHeader.Window.ContextMenu()
            _EnterSizeMove := Win32API.WinUserHeader.Window.EnterSizeMove()
            _ExitSizeMove := Win32API.WinUserHeader.Window.ExitSizeMove()
            _Move := Win32API.WinUserHeader.Window.Move()
            _Moving := Win32API.WinUserHeader.Window.Moving()
            _Size := Win32API.WinUserHeader.Window.Size()
            _Sizing := Win32API.WinUserHeader.Window.Sizing()
            _CaptureChanged := Win32API.WinUserHeader.Window.CaptureChanged()
            _WindowPosChanging := Win32API.WinUserHeader.Window.WindowPosChanging()
            _WindowPosChanged := Win32API.WinUserHeader.Window.WindowPosChanged()
            _Text := Win32API.WinUserHeader.Window.Text()

            on(callback) {
                this._ContextMenu.on(callback)
                this._EnterSizeMove.on(callback)
                this._ExitSizeMove.on(callback)
                this._Move.on(callback)
                this._Moving.on(callback)
                this._Size.on(callback)
                this._Sizing.on(callback)
                this._CaptureChanged.on(callback)
                this._WindowPosChanging.on(callback)
                this._WindowPosChanged.on(callback)
            }

            send(wParam, lParam, hwnd) {
                return this._Text.send(wParam, lParam, hwnd)
            }

            Class ContextMenu {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.CONTEXTMENU, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class EnterSizeMove {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.ENTERSIZEMOVE, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class ExitSizeMove {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.EXITSIZEMOVE, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Move {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOVE, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Moving {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.MOVING, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Size {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.SIZE, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Sizing {

                on(callback) {
                    Try {
                        OnMessage(Win32API.WinUserHeader.SIZING, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    } Catch Error As e {
                        MsgBox(e)
                    }
                }
            }

            Class CaptureChanged {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.CAPTURECHANGED, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class WindowPosChanging {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.WINDOWPOSCHANGING, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class WindowPosChanged {

                on(callback) {
                    OnMessage(Win32API.WinUserHeader.WINDOWPOSCHANGED, onMessageHandler)
                    onMessageHandler(wParam, lParam, msg, hwnd) {
                        callback(wParam, lParam, msg, hwnd)
                    }
                }
            }

            Class Text {

                _Get := Win32API.WinUserHeader.Window.Text.Get()
                _Set := Win32API.WinUserHeader.Window.Text.Set()

                on(callback) {
                    this._Get.on(callback)
                    this._Set.on(callback)
                }

                send(wParam, lParam, hwnd) {
                    return this._Set.send(wParam, lParam, hwnd)
                }

                Class Get {

                    static on(callback) {
                        OnMessage(Win32API.WinUserHeader.GETTEXT, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }

                    static send(wParam, lParam, hwnd) {
                        return SendMessage(Win32API.WinUserHeader.GETTEXT, wParam, lParam, hwnd)
                        
                    }
                }

                Class Set {

                    static on(callback) {
                        OnMessage(Win32API.WinUserHeader.SETTEXT, onMessageHandler)
                        onMessageHandler(wParam, lParam, msg, hwnd) {
                            callback(wParam, lParam, msg, hwnd)
                        }
                    }

                    static send(wParam, lParam, hwnd) {
                        return SendMessage(Win32API.WinUserHeader.SETTEXT, wParam, lParam, hwnd)
                        
                    }
                }
            }
        }

        Class Function {

            ;; Changes the size, position, and Z order of a child, pop-up, or top-level window. These windows are ordered according to
            ;;  their appearance on the screen. The topmost window receives the highest rank and is the first window in the Z order.
            Static SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags) {
                Return DllCall("SetWindowPos", "Ptr", hWnd, "Ptr", hWndInsertAfter, "Int", X, "Int", Y, "Int", cx, "Int", cy, "UInt", uFlags, "UInt")
            }

            Static MoveWindow(hWnd, X, Y, nWidth, nHeight, bRepaint) {
                Return DllCall("MoveWindow", "Ptr", hWnd, "Int", X, "Int", Y, "Int", nWidth, "Int", nHeight, "Int", bRepaint, "UInt")
            }

            Static AdjustWindowRectEx(lpRect, dwStyle, bMenu, dwExStyle) {
                Return DllCall("AdjustWindowRectEx", "Ptr", lpRect, "UInt", dwStyle, "Int", bMenu, "UInt", dwExStyle, "UInt")
            }

            Static BeginDeferWindowPos(nNumWindows) {
                Return DllCall("BeginDeferWindowPos", "Int", nNumWindows, "Ptr")
            }

            Static DeferWindowPos(hWinPosInfo, hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags) {
                Return DllCall("DeferWindowPos", "Ptr", hWinPosInfo, "Ptr", hWnd, "Ptr", hWndInsertAfter, "Int", X, "Int", Y, "Int", cx, "Int", cy, "UInt", uFlags, "Ptr")
            }

            Static EndDeferWindowPos(hWinPosInfo) {
                Return DllCall("EndDeferWindowPos", "Ptr", hWinPosInfo, "Int")
            }

            Static TrackMouseEventHover(hwnd) {

                TME_HOVER := 0x1, onButtonHover := false
                TME_LEAVE := 0x2, onButtonHover := false
                TRACKMOUSEEVENT := Buffer(8 + A_PtrSize * 2)
                NumPut('UInt', TRACKMOUSEEVENT.Size,
                       'UInt', TME_LEAVE,
                       'Ptr',  hwnd,
                       'Ptr',  10, TRACKMOUSEEVENT)
                DllCall('TrackMouseEvent', 'Ptr', TRACKMOUSEEVENT)

                ; ; TrackMouseEvent(hWND, 0x00000001)  ;? 0x00000001 = TME_HOVER
                ; TrackMouseEvent(hWNDTrack, dwFlags := 0x00000001, dwHoverTime := 400) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-trackmouseevent
                ;     Static cbSize := 8 + (A_PtrSize*2)
                
                ;     VarSetStrCapacity(&sEventTrack, cbSize)
                ;     NumPut("UInt", cbSize, &sEventTrack, 0)
                ;     NumPut("UInt", dwFlags, &sEventTrack, 4)
                ;     NumPut("Ptr", hWNDTrack, &sEventTrack, 8)
                ;     NumPut( "UInt", dwHoverTime, &sEventTrack, 8 + A_Ptrsize)  ;: https://docs.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-trackmouseevent
                
                ;     return (DllCall("TrackMouseEvent", "UInt", &sEventTrack, "UInt"))  ;* Non-zero on success.
                ; }
                ; TrackMouseEvent(targetHwnd)
            }


            Static TME_HOVER := 0x1
            Static TME_LEAVE := 0x2
            Static TrackMouseEvent(winHwnd, callback) {
                OnMessage(WM_MOUSEMOVE  := 0x0200, OnMouseEvent.Bind(winHwnd, callback))
                OnMessage(WM_MOUSELEAVE := 0x02A3, OnMouseEvent.Bind(winHwnd, callback))
                ; OnMessage(Win32API.WinUserHeader.MouseMove, onMouseMove.Bind(winHwnd, callback))
                OnMouseEvent(winHwnd, callback, wP, lP, msg, hwnd)
                {   
                    if(msg == Win32API.WinUserHeader.MOUSEMOVE)
                    {
                        TRACKMOUSEEVENT := Buffer(8 + A_PtrSize * 2)
                        NumPut('UInt', TRACKMOUSEEVENT.Size,
                                'UInt', Win32API.WinUserHeader.Function.TME_LEAVE,
                                'Ptr',  hwnd,
                                'Ptr',  10, TRACKMOUSEEVENT)
                        DllCall('TrackMouseEvent', 'Ptr', TRACKMOUSEEVENT)                      
                    } 
                    ; callback(Win32API.Macro.LOWORD(lP), Win32API.Macro.HIWORD(lP), msg, hwnd)
                    Switch TRACKMOUSEEVENT {
                        Case Win32API.WinUserHeader.Function.TME_HOVER : callback(wP, lP, msg, hwnd)
                        Case Win32API.WinUserHeader.Function.TME_LEAVE : callback(wP, lP, msg, hwnd)                        
                        Default:
                            
                    }
                        
                }
                 
            }

        ;    ; Win32API.WinUserHeader.Function.TrackMouseEventHover(this.overlayhwnd)
        ;    OnMessage(WM_MOUSEMOVE  := 0x0200, OnMouseEvent)
        ;    OnMessage(WM_MOUSELEAVE := 0x02A3, OnMouseEvent)
        ;    OnMessage(WM_ENTERSIZEMOVE := 0x0231, OnMouseEvent)  ;ENTERSIZEMOVE := 0x0231
        ;        ;Handle tool-tips
        ;    ;See https://www.autohotkey.com/boards/viewtopic.php?style=19&f=82&t=116086&p=517471
        ;    OnMouseEvent(wp, lp, msg, hwnd)
        ;    {

        ;        if(hwnd != this.overlayhwnd) {
        ;            return
        ;        }

        ;        static TME_LEAVE := 0x2, onButtonHover := false
        ;        if msg == WM_MOUSEMOVE && !onButtonHover
        ;        {
        ;            TRACKMOUSEEVENT := Buffer(8 + A_PtrSize * 2)
        ;            NumPut('UInt', TRACKMOUSEEVENT.Size,
        ;                    'UInt', TME_LEAVE,
        ;                    'Ptr',  hwnd,
        ;                    'Ptr',  10, TRACKMOUSEEVENT)
        ;            DllCall('TrackMouseEvent', 'Ptr', TRACKMOUSEEVENT)
        ;            try
        ;                ToolTipContents := GuiCtrlFromHwnd(hwnd).TT, ToolTip(ToolTipContents)
        ;            catch
        ;                ToolTipContents := ""
        ;        }
           


        ;        Switch msg  {
        ;            Case WM_MOUSELEAVE : ToolTip("OUTSIDE")  ;outside Gui
        ;            Case WM_MOUSEMOVE : ToolTip("INSIDE")  ;outside Gui
        ;            ; Case WM_ENTERSIZEMOVE : ToolTip("ENTERSIZEMOVE")  ;outside Gui
                       
        ;            Default:
                       
        ;        }

                  
        ;    }
            
        }
    }

    
    class Macro {

        
        ;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=68367
        ;==================================================

        ;source: minwindef.h

        static MAKEWORD(l, h)
        {
            return (l & 0xff) | (h & 0xff) << 8
        }
        static MAKELONG(l, h)
        {
            return (l & 0xffff) | (h & 0xffff) << 16
        }
        static LOWORD(l)
        {
            return l & 0xffff
        }
        static HIWORD(l)
        {
            return (l >> 16) & 0xffff
        }
        static LOBYTE(w)
        {
            return w & 0xff
        }
        static HIBYTE(w)
        {
            return (w >> 8) & 0xff
        }

        ;==================================================

        ;source: WinUser.h
        ;note: AHK stores integers (including UInt64 integers) as Int64
        ;note: wParam is UPtr (AHK 64-bit: UInt64, AHK 32-bit: UInt)
        ;note: lParam/lResult are Ptr (AHK 64-bit: Int64, AHK 32-bit: Int)

        static MAKEWPARAM(l, h)
        {
            return (l & 0xffff) | (h & 0xffff) << 16
        }
        static MAKELPARAM(l, h)
        {
            ;note: equivalent to MAKELRESULT
            ret := (l & 0xffff) | (h & 0xffff) << 16

            ;UInt to Int if necessary on 32-bit AHK:
            if (A_PtrSize == 4) && (ret >= 0x80000000)
                return ret - 0x80000000
            return ret
        }
        static MAKELRESULT(l, h)
        {
            ;note: equivalent to MAKELPARAM
            ret := (l & 0xffff) | (h & 0xffff) << 16

            ;UInt to Int if necessary on 32-bit AHK:
            if (A_PtrSize == 4) && (ret >= 0x80000000)
                return ret - 0x80000000
            return ret
        }

        ;==================================================

        ;source: winnt.h

        static MAKELANGID(p, s)
        {
            return (s << 10) | p
        }
        static PRIMARYLANGID(lgid)
        {
            return lgid & 0x3ff
        }
        static SUBLANGID(lgid)
        {
            return lgid >> 10
        }

        static MAKELCID(lgid, srtid)
        {
            return (srtid << 16) | lgid
        }
        static MAKESORTLCID(lgid, srtid, ver)
        {
            lcid := (srtid << 16) | lgid
            return lcid | (ver << 20)
        }
        static LANGIDFROMLCID(lcid)
        {
            return lcid & 0xffff
        }
        static SORTIDFROMLCID(lcid)
        {
            return (lcid >> 16) & 0xf
        }
        static SORTVERSIONFROMLCID(lcid)
        {
            return (lcid >> 20) & 0xf
        }

        ;==================================================
    }
}


; class Win32API.WinUserHeader {

;     mouse := Win32API.WinUserHeader.Mouse()
;     window := Win32API.WinUserHeader.Window()
;     ; key := Win32API.WinUserHeader.Key()
;     ; process := Win32API.WinUserHeader.Process()
;     ; file := Win32API.WinUserHeader.File()

;     __New() {
;         ; return Win32API.WinUserHeader
;     }


;     msg(symbol, callback) { ;symbol example: "LBUTTONDOWN"

;         SendMessage(symbol, callback)


;     }

;     class Mouse {

;         left := Win32API.WinUserHeader.Mouse.Left()
;         right := Win32API.WinUserHeader.Mouse.Right()
;         middle := Win32API.WinUserHeader.Mouse.Middle()
;         xButton1 := Win32API.WinUserHeader.Mouse.XButton1()
;         xButton2 := Win32API.WinUserHeader.Mouse.XButton2()
;         move := Win32API.WinUserHeader.Mouse.Move()
;         wheel := Win32API.WinUserHeader.Mouse.Wheel()
;         hover := Win32API.WinUserHeader.Mouse.Hover()
;         captureChanged := Win32API.WinUserHeader.Mouse.CaptureChanged()
;         activate := Win32API.WinUserHeader.Mouse.Activate()

;         __New() {
;             ; return Win32API.WinUserHeader.Mouse
;         }

;         ; class Left {

;         ;     symbol := "LBUTTON"
;         ;     down := Win32API.WinUserHeader.Mouse.Left.Down()
;         ;     up := Win32API.WinUserHeader.Mouse.Left.Up()
;         ;     double := Win32API.WinUserHeader.Mouse.Left.Double()


;         ;     __New() {
;         ;         ; return Win32API.WinUserHeader.Mouse.Left
;         ;     }

;         ;     class Down {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.Left.Down.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x0201
;         ;         static decimal := 513
;         ;        static symbol  := "WM_LBUTTONDOWN"
;         ;     }

;         ;     class Up {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.Left.Up.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x0202
;         ;         decimal := 514
;         ;         symbol := "WM_LBUTTONUP"

;         ;     }

;         ;     class Double {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.Left.Double.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x0203
;         ;         static decimal := 515
;         ;         static symbol := "WM_LBUTTONDBLCLK"
;         ;     }


;         ; }

;         ; class Right {

;         ;     down := Win32API.WinUserHeader.Mouse.Right.Down()
;         ;     up := Win32API.WinUserHeader.Mouse.Right.Up()
;         ;     double := Win32API.WinUserHeader.Mouse.Right.Double()

;         ;     __New() {
;         ;         ; return Win32API.WinUserHeader.Mouse.Right
;         ;     }

;         ;         class Down {

;         ;             msg(callback) {

;         ;                 OnMessage(Win32API.WinUserHeader.Mouse.Right.Down.hex, onMessageHandler)
;         ;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                         callback(wParam, lParam, msg, hwnd)
;         ;                 }
;         ;             }

;         ;             static hex := 0x0204
;         ;             decimal := 516
;         ;             symbol := "WM_RBUTTONDOWN"
;         ;         }

;         ;         class Up {

;         ;             msg(callback) {

;         ;                 OnMessage(Win32API.WinUserHeader.Mouse.Right.Up.hex, onMessageHandler)
;         ;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                         callback(wParam, lParam, msg, hwnd)
;         ;                 }
;         ;             }

;         ;             static hex := 0x0205
;         ;             decimal := 517
;         ;             symbol := "WM_RBUTTONUP"
;         ;         }

;         ;         class Double {

;         ;             msg(callback) {

;         ;                 OnMessage(Win32API.WinUserHeader.Mouse.Right.Double.hex, onMessageHandler)
;         ;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                         callback(wParam, lParam, msg, hwnd)
;         ;                 }
;         ;             }

;         ;             static hex := 0x0206
;         ;             decimal := 518
;         ;             symbol := "WM_RBUTTONDBLCLK"
;         ;         }

;         ; }

;         ; class Middle {

;         ;     down := Win32API.WinUserHeader.Mouse.Middle.Down()
;         ;     up := Win32API.WinUserHeader.Mouse.Middle.Up()
;         ;     double := Win32API.WinUserHeader.Mouse.Middle.Double()

;         ;     __New() {
;         ;         ; return Win32API.WinUserHeader.Mouse.Middle
;         ;     }

;         ;     class Down {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.Middle.Down.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x0207
;         ;         decimal := 519
;         ;         symbol := "WM_MBUTTONDOWN"

;         ;     }

;         ;     class Up {

;         ;             msg(callback) {

;         ;                 OnMessage(Win32API.WinUserHeader.Mouse.Middle.Up.hex, onMessageHandler)
;         ;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                         callback(wParam, lParam, msg, hwnd)
;         ;                 }
;         ;             }

;         ;             static hex := 0x0208
;         ;             decimal := 520
;         ;             symbol := "WM_MBUTTONUP"
;         ;     }

;         ;     class Double {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.Middle.Double.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x0209
;         ;         decimal := 521
;         ;         symbol := "WM_MBUTTONDBLCLK"
;         ;     }

;         ; }

;         ; class XButton1 {

;         ;     down := Win32API.WinUserHeader.Mouse.XButton1.Down()
;         ;     up := Win32API.WinUserHeader.Mouse.XButton1.Up()
;         ;     double := Win32API.WinUserHeader.Mouse.XButton1.Double()

;         ;     __New() {
;         ;         ; return Win32API.WinUserHeader.Mouse.XButton1
;         ;     }

;         ;     class Down {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.XButton1.Down.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x020B
;         ;         decimal := 523
;         ;         symbol := "WM_XBUTTONDOWN"
;         ;     }

;         ;     class Up {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.XButton1.Up.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x020C
;         ;         decimal := 524
;         ;         symbol := "WM_XBUTTONUP"
;         ;     }

;         ;     class Double {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.XButton1.Double.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x020D
;         ;         decimal := 525
;         ;         symbol := "WM_XBUTTONDBLCLK"
;         ;     }

;         ; }

;         ; class XButton2 {

;         ;     down := Win32API.WinUserHeader.Mouse.XButton2.Down()
;         ;     up := Win32API.WinUserHeader.Mouse.XButton2.Up()
;         ;     double := Win32API.WinUserHeader.Mouse.XButton2.Double()

;         ;     __New() {
;         ;         ; return Win32API.WinUserHeader.Mouse.XButton2
;         ;     }

;         ;     class Down {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.XButton2.Down.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x020E
;         ;         decimal := 526
;         ;         symbol := "WM_XBUTTONDOWN"
;         ;     }

;         ;     class Up {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.XButton2.Up.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x020F
;         ;         decimal := 527
;         ;         symbol := "WM_XBUTTONUP"
;         ;     }

;         ;     class Double {

;         ;         msg(callback) {

;         ;             OnMessage(Win32API.WinUserHeader.Mouse.XButton2.Double.hex, onMessageHandler)
;         ;             onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                     callback(wParam, lParam, msg, hwnd)
;         ;             }
;         ;         }

;         ;         static hex := 0x0210
;         ;         decimal := 528
;         ;         symbol := "WM_XBUTTONDBLCLK"
;         ;     }

;         ; }

;         ; class Move {

;         ;     msg(callback) {

;         ;         OnMessage(Win32API.WinUserHeader.Mouse.Move.hex, onMessageHandler)
;         ;         onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                 callback(wParam, lParam, msg, hwnd)
;         ;         }
;         ;     }

;         ;     static hex := 0x0200
;         ;     decimal := 512
;         ;     symbol := "WM_MOUSEMOVE"
;         ; }

;         ; class Wheel {

;         ;     msg(callback) {

;         ;         OnMessage(Win32API.WinUserHeader.Mouse.Wheel.hex, onMessageHandler)
;         ;         onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                 callback(wParam, lParam, msg, hwnd)
;         ;         }
;         ;     }

;         ;     static hex := 0x020A
;         ;     decimal := 522
;         ;     symbol := "WM_MOUSEWHEEL"
;         ; }

;         ; class Hover {

;         ;     msg(callback) {

;         ;         OnMessage(Win32API.WinUserHeader.Mouse.Hover.hex, onMessageHandler)
;         ;         onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                 callback(wParam, lParam, msg, hwnd)
;         ;         }
;         ;     }

;         ;     static hex := 0x02A1
;         ;     decimal := 673
;         ;     symbol := "WM_MOUSEHOVER"
;         ; }

;         ; class CaptureChanged {

;         ;     msg(callback) {

;         ;         OnMessage(Win32API.WinUserHeader.Mouse.CaptureChanged.hex, onMessageHandler)
;         ;         onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                 callback(wParam, lParam, msg, hwnd)
;         ;         }
;         ;     }

;         ;     static hex := 0x0218
;         ;     decimal := 536
;         ;     symbol := "WM_MOUSECAPTURECHANGED"
;         ; }

;         ; class Activate {

;         ;     msg(callback) {

;         ;         OnMessage(Win32API.WinUserHeader.Mouse.Activate.hex, onMessageHandler)
;         ;         onMessageHandler(wParam, lParam, msg, hwnd) {

;         ;                 callback(wParam, lParam, msg, hwnd)
;         ;         }
;         ;     }

;         ;     static hex := 0x0021
;         ;     decimal := 33
;         ;     symbol := "WM_MOUSEACTIVATE"
;         ; }


;     }


;     class Window {

;         contextMenu := Win32API.WinUserHeader.Window.ContextMenu()
;         enterSizeMove := Win32API.WinUserHeader.Window.EnterSizeMove()
;         exitSizeMove := Win32API.WinUserHeader.Window.ExitSizeMove()
;         move := Win32API.WinUserHeader.Window.Move()
;         moving := Win32API.WinUserHeader.Window.Moving()
;         size := Win32API.WinUserHeader.Window.Size()
;         sizing := Win32API.WinUserHeader.Window.Sizing()
;         captureChanged := Win32API.WinUserHeader.Window.CaptureChanged()
;         windowPosChanging := Win32API.WinUserHeader.Window.WindowPosChanging()
;         windowPosChanged := Win32API.WinUserHeader.Window.WindowPosChanged()


;         __New() {
;             ; return Win32API.WinUserHeader.Window
;         }

;         class ContextMenu {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.ContextMenu.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x007B
;             decimal := 123
;             symbol := "WM_CONTEXTMENU"
;         }

;         class EnterSizeMove {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.EnterSizeMove.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0231
;             decimal := 561
;             symbol := "WM_ENTERSIZEMOVE"
;         }

;         class ExitSizeMove {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.ExitSizeMove.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0232
;             decimal := 562
;             symbol := "WM_EXITSIZEMOVE"
;         }

;         class Move {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.Move.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0003
;             decimal := 3
;             symbol := "WM_MOVE"
;         }

;         class Moving {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.Moving.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0216
;             decimal := 534
;             symbol := "WM_MOVING"
;         }

;         class Size {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.Size.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0005
;             decimal := 5
;             symbol := "WM_SIZE"
;         }

;         class Sizing {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.Sizing.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0214
;             decimal := 532
;             symbol := "WM_SIZING"
;         }

;         class CaptureChanged {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.CaptureChanged.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0215
;             decimal := 533
;             symbol := "WM_CAPTURECHANGED"
;         }

;         class WindowPosChanging {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.WindowPosChanging.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0046
;             decimal := 70
;             symbol := "WM_WINDOWPOSCHANGING"
;         }

;         class WindowPosChanged {

;             msg(callback) {

;                 OnMessage(Win32API.WinUserHeader.Window.WindowPosChanged.hex, onMessageHandler)
;                 onMessageHandler(wParam, lParam, msg, hwnd) {

;                         callback(wParam, lParam, msg, hwnd)
;                 }
;             }

;             static hex := 0x0047
;             decimal := 71
;             symbol := "WM_WINDOWPOSCHANGED"
;         }

;     }

;         ;     hex := 0x007B
;         ;     decimal := 123
;         ;     symbol := "WM_CONTEXTMENU"
;         ; }

;         ; class EnterSizeMove {

;         ;     hex := 0x0231
;         ;     decimal := 561
;         ;     symbol := "WM_ENTERSIZEMOVE"
;         ; }

;         ; class ExitSizeMove {

;         ;     hex := 0x0232
;         ;     decimal := 562
;         ;     symbol := "WM_EXITSIZEMOVE"
;         ; }

;         ; class Move {

;         ;     hex := 0x0003
;         ;     decimal := 3
;         ;     symbol := "WM_MOVE"
;         ; }

;         ; class Moving {

;         ;     hex := 0x0216
;         ;     decimal := 534
;         ;     symbol := "WM_MOVING"
;         ; }

;         ; class Size {

;         ;     hex := 0x0005
;         ;     decimal := 5
;         ;     symbol := "WM_SIZE"
;         ; }

;         ; class Sizing {

;         ;     hex := 0x0214
;         ;     decimal := 532
;         ;     symbol := "WM_SIZING"
;         ; }

;         ; class CaptureChanged {

;         ;     hex := 0x0215
;         ;     decimal := 533
;         ;     symbol := "WM_CAPTURECHANGED"
;         ; }

;         ; class WindowPosChanging {

;         ;     hex := 0x0046
;         ;     decimal := 70
;         ;     symbol := "WM_WINDOWPOSCHANGING"
;         ; }

;         ; class WindowPosChanged {

;         ;     hex := 0x0047
;         ;     decimal := 71
;         ;     symbol := "WM_WINDOWPOSCHANGED"
;         ; }

;     ; }

; }


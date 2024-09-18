

; ﻿/*
;     Library: events
;     Author: neovis
;     https://github.com/neovis22/events
    
;     nodejs EventEmitter 클래스의 일부분을 오토핫키로 구현
;     https://nodejs.org/api/events.html#class-eventemitter
; */

class EventEmitter {

    ; __New(owner := this) {
    ;     this.owner := owner
    ; }
    ; _events := {eventEmitterOn:"eventEmitterOn", eventEmitterOff:"eventEmitterOff"}
    ; events {
    ;     get {
    ;         return this._events
        
    ;     }
    ;     set { 
    ;         for p, v in value.OwnProps() {
    ;             this._events.DefineProp(p, {value:v})    
    ;         }
    ;     }
    ; }
    
    On := this.addListener
    
    Off := this.removeListener

    e := Map()
    
    emit(type, args*) {
        list := this.listeners(type)
        if (!list.Length)
            return false
        i := 1
        loop list.Length {
            ; eventSender := Error("", -2).what
            ; callback :=  eventSender == "EventEmitter.Prototype.addListener"  ? this.listeners(args[1])[1].listener : "internal"  ;
            ; _args := EventEmitter.EventArgs(type, args[1], callback, this, eventSender) ;, args ;.listener
            ; try list[i].listener.call()
            ; try list[i].listener.call(_args*)
            try list[i].listener.call(args*)
            catch Error as e
                Msgbox(e.stack)
                
            if (list[i].HasOwnProp("once"))
                list.removeAt(i)
            else
                i++
        }
        return true
    }
    
    eventNames() {
        names := []
        for _type in this.listeners()
            names.push(_type)
        return names
    }

    
    listeners(type := "") {        
        if (!this.HasOwnProp("_listeners")) {
            this.DefineProp("_listeners", this.GetOwnPropDesc("e"))
        }
        this.e := this._listeners   
        return type == "" ? this.e : this.e.Has(type) ? this.e[type] : this.e[type] := []
    }
    
    addListener(type, listener) {

        list := this.listeners(type)
        list.push({listener:listener})

        ; if(type != this._events["eventEmitterOn"]) {
        ;     this.emit(this._events["eventEmitterOn"], type)
        ; }
        
        return this 
    }
    
    once(type, _listener) {
        val := this.listeners(type)
        val.push({listener:_listener, once:true})
        return this 
    }
    
    prependListener(type, listener) {
        return this this.listeners(type).insertAt(1, {listener:listener})
    }
    
    prependOnceListener(type, listener) {
        return this this.listeners(type).insertAt(1, {listener:listener, once:true})
    }
    
    removeAllListeners(type := "") {
        if (type == "")
            this.DefineProp("events", {value:[]})
        else
            if(this.listeners().Has(type)) {
                this.listeners().Delete(type)
            }
           
        return this
    }
    
    removeListener(type, listener) {
        list := this.listeners(type)
        for i, v in list
            if (v.listener == listener)
                return this list.removeAt(i)
        return this
    }

    class EventArgs { 
        event := "" 
        target:= ""
        source:= "" 
        args := ""
        __New(event := "", target := "", source := "", args := '') { 
            this.event := event
            this.target := target   
            this.source := source             
            this.args := args
        }
    }

    ; class EventArgs {   
    ;     type:= ""
    ;     targetType:= ""
    ;     callback := ""
    ;     emitterOwner:= ""
    ;     eventSender:= ""
    ;     ; args:= ""

    ;     __New(type := "", targetType := "", callback := "", emitterOwner := "", eventSender := "") {  ;, args := ""
    ;         this.type := type
    ;         this.targetType := targetType   
    ;         this.callback := callback             
    ;         this.emitterOwner := emitterOwner
    ;         this.eventSender := eventSender 
    ;         ; this.args := args       
    ;     }


    ;     __Enum(NumberOfVars) {

    ;         EnumerateProperties(&key, &value) {
    ;             if (this.HasKey(key))
    ;                 value := this[key]
    ;             return True
    ;         }
    ;         Return EnumerateProperties.Bind({})

    ;     }
    
    ; }
}
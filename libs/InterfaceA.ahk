#Requires AutoHotkey v2.0

class Interface {
    events := {}

    _endpoints := Map()
    endpoints {
        get {
            return this._endpoints
        }    
        set {
            this._endpoints := value        
        }
    }

    __New(endpoints := this._endpoints) {
        this.endpoints := endpoints

        if(this.endpoints.Count > 0) {            
            this.register(endpoints)
        }
    }

    __Call(name, params) {
        for k, v in this._endpoints {
            if (k == name) {
                if (params.Length > 0) {
                    for param in params {
                        v := v.bind(param)
                    }
                }
                return v.call()
            }
        }
        return false
    }  

    register(eps := {}) {       
        ;; IN PROGRESS 
        ; for prop in this.base.OwnProps() {
        ;     if(StrSplit(prop, "__")[1]) {
        ;         desc := this.base.GetOwnPropDesc(prop).Call
        ;         this._endpoints[prop] := desc  ; ObjBindMethod(this.base, prop)  
        ;     }
        ; }        
        if(Type(eps) == Type({})) {
            for k, v in eps.OwnProps() {
                this._endpoints[k] := v
            }
        }
        else if(Type(eps) == Type(Map())) {
            for k, v in eps {
                this._endpoints[k] := v
            }
        }        
    }
}


;;  REQUIRED for endpoint registration for the class to interface with
; __New(params) {
;     this.register({
;         interfaceMemberName: ObjBindMethod(this, "classMemberName")
;     })
;     super.__New(params)           
; }
;
;;  IN PRPOGRESS 
;
; __New(params) {
;     this.register()
;     super.__New(params)           
; }
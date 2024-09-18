#Requires AutoHotkey v2.0-a
#Include import_v1lib.ahk

class VersionClient {
      
    _client := ''
    client {
        get {
            if(!this._client) {
                this._client := import_v1lib(this.targetPath, this.runtimePath)               
            }
            return this._client
        }
        set {
            this._client := value
        }

    } 

    scriptIsClass := false

    static empty := {property:{name:0, value:0}}
    static targetPath := ""
    static runtimePath := ""
    static v1Lib := ''

    __New(targetPath, runtimePath, isClass := false) {
        this.targetPath := targetPath
        this.runtimePath := runtimePath
        
        this.DefineProp('__Call', {value:this.Call})  
        this.DeleteProp('Call')
        
        this.DefineProp('__Get', {value:this.Get})
        this.DeleteProp('Get')
        
        this.DefineProp('__Set', {value:this.Set})
        this.DeleteProp('Set')

        if(isClass) {
            this.DeleteProp(this.Launch)
        }
    }  

    Call(name, params*)  {
        this.client.%name%(params*)
    }

    Get(name, params*) {
        return  this.client[name] 
    }

    Set(name, params*) {  
        this.client[name] := params[2]
    }  
    
    NewClass(className, params*) {
        return this.client["__AHKv1LibHelper"].__New(className, params*)
    }
    
    Launch() {
        this.client := import_v1lib(this.targetPath, this.runtimePath)
        ; tb := this.client["__AHKv1LibHelper"].__New("Toolbar", '')
        ; tb.Add('One')
    }
}
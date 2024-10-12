#Include disk.ahk
#Include JSON.ahk
; #Include _JXON.ahk



class Utils {
    static types := {o:{}, m:Map(), a:[], s:"", i:0, d:0.5, b:false, Closure:()=>}

    static InArray(a, i) {
        for _i in a {
            if(i == _i) {
                return true
            }
        }
        return false
    }

    static IndexOf(a, i) {
        for _i in a {
            if(i == _i) {
                return A_Index
            }
        }
        return false
    }

    static DefineProp(obj, propName, propVal){

        _type := Type(propVal)
        __clos := Type(Utils.types.Closure)
        switch Type(propVal) {
            case Type(Utils.types.o) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("o"))
            case Type(Utils.types.m) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("m"))
            case Type(Utils.types.a) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("a")) 
            case Type(Utils.types.s) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("s")) 
            case Type(Utils.types.i) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("i")) 
            case Type(Utils.types.d) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("d")) 
            case Type(Utils.types.b) : obj.DefineProp(propName, Utils.types.GetOwnPropDesc("b"))   
            case "Closure" :obj.DefineProp(propName,  Utils.types.GetOwnPropDesc("Closure"))         
            Default: MsgBox(propName " " propVal)               
        }
        return obj.%propName% := type(propVal) == type(Utils.types.m) ? Utils.MapToObject(propVal) : propVal
    }

    static Props(obj) {
        a := []
        for p in obj.OwnProps() {
            a.Push(p)
        }
        return a
    }

    static ObjectRemoveEmptyProps(obj) {
        newObj := {}
        for p, v in obj.OwnProps() {
            if(v != "") {
                Utils.DefineProp(newObj, p, v)
            }
        }
        return newObj
    }


    static ObjectToMap(&obj) {
        _map := Map()

        for p, v in obj.OwnProps() {
            if(v is Array) {

                _array := []
                if(v.Length > 0)  {
                    for i in v {
                        _array.Push((Type(i) == Type({}) ? Utils.ObjectToMap(&i) : i))
                    }
                }
                _map[p] := _array 

            }
            else {

                _map[p] := Type(v) == Type({}) ? Utils.ObjectToMap(&v) : v  
            }
        }
        return  _map 
    }


    static MapToObject(_map) {
        _obj := {}
        for k, v in _map {
            if(v is Array) {
                _array := []
                for i in v {
                    item := (Type(v) == Type(Utils.types.m) ? Utils.MapToObject(i) : i)
                    item := (Type(item) == Type(Utils.types.m) ? Utils.MapToObject(item) : item)
                    _array.Push(item)
                }             
                Utils.DefineProp(_obj, k, _array)
            } 
            else if(v is Map) {
                Utils.DefineProp(_obj, k, Utils.MapToObject(v))
            }
            else {
                Utils.DefineProp(_obj, k, v)
            }
            ; else {
            ;     Utils.DefineProp(_obj, k, (type(v) == type(Map()) ? Utils.MapToObject(v) : v))
            ; }

        }
        return _obj
    }

    static filenameFromFile(file) {
        parts := StrSplit(file, ".")   
        name := parts[parts.Length-1]
        return name
    }

    static filenameFromPath(path) {
        _file := Utils.fileFromPath(path)
        name := Utils.filenameFromFile(_file)
        return name
    }

    static fileFromPath(path) {
        parts := StrSplit(path, "\")       
        part1 := StrSplit(parts[parts.Length], "/")
        _file := part1[part1.Length]
        return _file
    }

    static timeStamp(type){
        retVal := ""
        switch(type) {
            case "fileName" : retVal := A_YYYY "_" A_MM "_" A_DD "_" A_Hour "_" A_Min "_" A_Sec "_" A_MSec
        }
        return retVal
    }

    static GetDomainName(url) {
        domainName := ""
        parts0 := StrSplit(url, "//")
        if(parts0.Has(2)) {
            parts1 := StrSplit(parts0[2], "/")
            if(parts1.Has(1)) {
                parts2 := StrSplit(parts1[1], "www.")
                if(parts2.Has(2)) {
                    parts2 := parts2[2]
                }    
                else {
                    parts2 := parts2[1]
                }  
                parts3 := StrSplit(parts2, ".com")  
                if(parts3.Has(1)) {
                    domainName := parts3[1]
                }   
            }
        }
        return domainName
    }

    static GetWebsiteNameFromURL(url) {
        parts := StrSplit(url, '?')
        parts1 := StrSplit(parts[1], 'https://')
        if(parts1.Has(2)) {            
            patrs2 := StrSplit(parts1[2], '/')
        }
        else {
            patrs2 := StrSplit(parts1[1], '/')
        }   
        ; parts3 := StrSplit(patrs2[1], '.')  
        return  patrs2[1]
    }

    static GetPageFromURL(url) {
        parts := StrSplit(url, '?')
        patrs1 := StrSplit(parts[1], '/')
        if(patrs1[patrs1.Length] != '') {
            return patrs1[patrs1.Length]
        }
        else {
            return patrs1[patrs1.Length - 1]
        }
    }

    static GetHrefParts(url) {
        hrefParts := {path:"", paths:[]}
        parts := StrSplit(url, "https://")
        if(parts.Has(2)) {
            parts1 := StrSplit(parts[2], "?")
            parts2 := StrSplit(parts1[1], "/")
            if(parts2.Has(2)) {
                ; pathPartIndex := parts2.Length
                _path := ""
                Loop(parts2.Length) {
                    if(A_Index == parts2.Length) {
                        continue
                    }
                    if(!InStr(parts2[A_Index + 1], ".")) {
                        _path .= parts2[A_Index + 1] "/"
                    }
                }
                hrefParts.path := _path
            }
        }
        else { ; if(StrSplit(url, "about:").Has()) { ;"about:/docs/"            
            parts := StrSplit(url, "about:blank")
            if(parts.Has(2)) {
                parts1 := StrSplit(parts, "#")
                if(parts1.Has(2)) {

                }
                else{

                }
            }
        }
        return hrefParts
    }

    static StrToHtml(strHtml) {
        newLine := "\n"
        tab := "\t"
        dblQuote := '\"'
        escapedDblQuote := '\"'
        escapedDblQuotePlaceHolder := "\escapedDoubleQuote\"
        strHtml := StrReplace(strHtml, newLine , "")
        strHtml := StrReplace(strHtml, tab , "")
        strHtml := StrReplace(strHtml, escapedDblQuote , escapedDblQuotePlaceHolder)
        strHtml := StrReplace(strHtml, dblQuote , "")
        strHtml := StrReplace(strHtml, escapedDblQuotePlaceHolder , escapedDblQuote)

        return strHtml
    }
    
    static ObjectToJson(obj) {
        _map := Utils.ObjectToMap(&obj)
        return JSON.stringify(_map)
    }   

    static ToObject(_json) {
        _map := JSON.parse(_json)
        return Utils.MapToObject(_map)
    }

    static JsonLoad(name, path, cleanString := 0) {
        str := Disk.FileLoad(name, path)
        if(cleanString) {
            str := Utils.CleanString(&str)  
        }
        _map := JSON.parse(str)        
        return  Utils.MapToObject(_map)
        ; return  _map
    }

    static JsonSave(obj, name, path) {
        _map := Utils.ObjectToMap(&obj)
        str := JSON.stringify(_map)
        return Disk.FileSave(str, name, path)
    }

    Static HtmlDecode(str) {
        str := StrReplace(str, "&quot;", '`"')
        str := StrReplace(str, "&amp;", "&")
        str := StrReplace(str, "&lt;", "<")
        str := StrReplace(str, "&gt;", ">")
        return str
    }

    static HtmlEncode(text) {
        text := StrReplace(text, "&", "&amp;")
        text := StrReplace(text, "<", "&lt;")
        text := StrReplace(text, ">", "&gt;")
        text := StrReplace(text, '`"' "&quot;")
        return text
    }
    
    
    static CleanString(&str) {
        ; Remove leading and trailing whitespace
        str := Utils.Trim(str)
    
        ; Replace consecutive whitespace characters with a single space
        str := RegExReplace(str, "\s+", " ")
    
        ; Remove non-printable characters and control characters
        str := RegExReplace(str, "[^\x20-\x7E]", "")

        ; Replace HTML entities with their corresponding characters
        str :=Utils.HtmlDecode(str)
    
        ; Replace newline characters with empty string
        str := StrReplace(str, "`n", "")
        ; Replace newline characters with empty string
        str := StrReplace(str, "`r", "")
        ; Replace newline characters with empty string
        str := StrReplace(str, "`t", "")
    
        return str
    }

    ; static ToHex() {
    ;     ; return Format("0x{1:x}", int)
    ;     return 1
    ; }


    static Trim(str) {
        ; Trim leading whitespace
        while (SubStr(str, 1, 1) ~= "\s")
            str := SubStr(str, 2)
    
        ; Trim trailing whitespace
        while (SubStr(str, -1) ~= "\s")
            str := SubStr(str, 1, -2)
    
        return str
    }

    ;strip all spaces
    static Compact(str) {
        return StrReplace(str, " ", "")
    }

    ;make all multi-spaces, single spaced
    static Deflate(str) {

    }

    static ToString(v) {
        switch Type(v) {
            case Type(Utils.types.m) : return Utils.MapToString(v)
            case Type(Utils.types.o) : return Utils.ObjectToString(v)
            case Type(Utils.types.a) : return Utils.ArrayToString(v)    
            case Type(Utils.types.s) : return "`"" . v . "`""              
            case Type(Utils.types.i) : return  v   
            case Type(Utils.types.d) : return  v
            case Type(Utils.types.b) : return  v ? "true" : "false" 
            default: return 0
        }
    }

    static ObjectToString(v) {        
        str := "{"
        if (v is Object) {
            for op, ov in v.OwnProps() {
                str .= "`"" . op . "`"" . ":" . Utils.toString(ov) . (A_Index != ObjOwnPropCount(v) ? "," : "" )
            }
        }
        else {
            return 0
        }
        str .= "}"
        return str
    }

    static MapToString(v) {        
        str := "{"
        if (v is Map) {
            for ok, ov in v {
                str .= "`"" . ok . "`"" . ":" . Utils.toString(ov) . (A_Index != v.Count ? "," : "" )
            }
        }
        else {
            return 0
        }
        str .= "}"
        return str
    }
    

    static ArrayToString(v) {
        str := "["
        if (v is Array) {
            for i in v {               
                str .= Utils.toString(i) . (v.Length !=  A_Index ? ", "  : "" )
            }
        }
        else {
            return 0
        }
        str .= "]"
        return str
    }

    static EncodeAHK(str) {
        escapeChars := {
            newLine: {otherChar:"\n", ahkChar:"``n"}, 
            carriageReturn: {otherChar:"\r", ahkChar:"``r"}, 
            tab: {otherChar:"\t", ahkChar:"``t"}, 
            alert: {otherChar:"\a", ahkChar:"``a"}, 
            backspace: {otherChar:"\b", ahkChar:"``b"}, 
            formFeed: {otherChar:"\f", ahkChar:"``f"}, 
            verticalTab: {otherChar:"\v", ahkChar:"``v"}, 
            singleQuote: {otherChar:"\`'", ahkChar:"``'"},
            doubleQuote: {otherChar:"\`"", ahkChar:"```""}
            ; backtick: {otherChar:"``", ahkChar:"``"}
        }
        for k, v in escapeChars.OwnProps() {
            for vp, vv in v.OwnProps() {                
                for otherChar, ahkChar in vv.OwnProps() {    
                    str := StrReplace(str, otherChar, ahkChar)                
                }
            }
        }
        return str
    }
    
    ;VERIFY
    static DecodeAHK(str) {
        escapeChars := {
            newLine: {ahkChar:"``n", otherChar:"\n"}, 
            carriageReturn: {ahkChar:"``r", otherChar:"\r"}, 
            tab: {ahkChar:"``t", otherChar:"\t"}, 
            alert: {ahkChar:"``a", otherChar:"\a"}, 
            backspace: {ahkChar:"``b", otherChar:"\b"}, 
            formFeed: {ahkChar:"``f", otherChar:"\f"}, 
            verticalTab: {ahkChar:"``v", otherChar:"\v"}, 
            singleQuote: {ahkChar:"``'", otherChar:"\`'"}, 
            doubleQuote: {ahkChar:'``"', otherChar:"\`""}
            ; backtick: {ahkChar:"``", otherChar:"``"}
        }
        for k, v in escapeChars.OwnProps() {
            ahkChar := ""
            otherChar := ""
            for vp, vv in v.OwnProps() {  
                %vp% := vv
            }
            str := StrReplace(str, ahkChar, otherChar) 
        }
        return str
    }

    ;; call property metheds as objects own
    ; __Call(name, params) {
    ;     for k, v in this._endpoints {
    ;         if (k == name) {
    ;             if (params.Length > 0) {
    ;                 for param in params {
    ;                     v := v.bind(param)
    ;                 }
    ;             }
    ;             return v.call()
    ;         }
    ;     }
    ;     return false
    ; }  
    
     
    
}
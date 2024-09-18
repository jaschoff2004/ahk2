#include %A_ScriptDir%\..\export.ahk

class a{ 
	class b{ 
	} 
}
cn := "a.b"
c :=  ClassHelper.newFromString(cn)

OutputDebug("New obj <c> is an instance of class <" Type(c) ">")
ExitApp
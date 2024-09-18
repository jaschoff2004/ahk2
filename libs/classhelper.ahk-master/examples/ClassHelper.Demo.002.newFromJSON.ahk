#include %A_ScriptDir%\..\export.ahk

class a{
	class b{
		x := 0
		y := 0
	}
}
strJSON := '{"x":42,"y":17,"_class":"a.b"}'
c := ClassHelper.newFromJSON(strJSON)
OutputDebug("New obj <c> is an instance of class <" Type(c) "> with property values (x=" c.x ", y=" c.y ")")
ExitApp
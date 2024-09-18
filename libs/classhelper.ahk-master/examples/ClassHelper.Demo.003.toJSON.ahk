#include %A_ScriptDir%\..\export.ahk

class a{ 
	class b{ 
		x := 42
		y := 17

		test() {
			return 55
		}
	} 
}
c := a.b()
retStr := ClassHelper.toJSON(c, indent := 2)

OutputDebug("Serialized obj <c> to <" retStr ">")
ExitApp
# classhelper.ahk 

[![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-green?style=plastic&logo=autohotkey)](https://autohotkey.com/)
[![Documentation](https://img.shields.io/badge/Full-Documentation-blue?style=plastic&logo=readthedocs)](https://autohotkey-v2.github.io/classhelper.ahk/)

<sub><sup>This library uses [AutoHotkey Version 2](https://autohotkey.com/v2/). (Tested with [AHK v2.0-beta.1 x64 Unicode](https://www.autohotkey.com/boards/viewtopic.php?f=24&t=93011))</sup></sub>

Misc helper functions for classes

## Installation

In a terminal or command line navigate to your project folder and type following command:
```bash
npm install AutoHotkey-V2/classhelper.ahk.git
```

## Usage

Include `export.ahk` from the `classhelper.ahk` folder into your project using standard AutoHotkey-include methods.

```autohotkey
#Include %A_ScriptDir%\node_modules\classhelper.ahk\export.ahk

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
strJSON := ClassHelper.toJSON(c, indent := 2)
; Serializes to '{"_class": "a.b", "x": 42, "y": 17}'
c := ""

; The property "_class" is used to construct the class, given by value string (here: an instance of class "a.b" is instanciated))
d := ClassHelper.newFromJSON(strJSON)
OutputDebug("New obj <c> is an instance of class <" Type(d) "> with property values (x=" d.x ", y=" d.y ")")
ExitApp
```

For usage examples have a look at the files in the *examples* folder.

For more detailed documentation have a look into the [full documentation](https://autohotkey-v2.github.io/classhelper.ahk/)
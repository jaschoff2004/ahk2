#Requires AutoHotkey v2.0-
#warn

; #include ..\cJson.ahk
#Include ..\JSON.ahk

release_version() {
	return "1.1.0"
}

; #########################################################
/*
Title: ClassHelper

Misc helper functions for classes

Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original

About: License
<MIT License: https://opensource.org/licenses/MIT> - Copyright (c) 2020 Johannes Kilian
*/

class ClassHelper {
; ***********************************************************************************************************
	static newFromString(str, Args*) {
	/* --------------------------------------------------------------------------------------
	Function: newFromString()
	Constructs a new instance of a class given by dot-separated string

	Parameters:
	str - dot separated string
	args* - parameters for class to be constructed

	Returns:
	New instance of class

	Example:
	==== AutoHotkey ====
	#include TBy\ClassHelper.ahk

	class a{
		class b{
		}
	}
	cn := "a.b"
	c :=  ClassHelper.newFromString(cn) ; c is a new instance of class "a.b"
	===

	Credits:
	* Original: <swagfag: https://www.autohotkey.com/boards/viewtopic.php?f=82&t=83945>
	*/
		ClassNames := StrSplit(str, '.')
		__GenericClass := %ClassNames.RemoveAt(1)%

		for name in ClassNames
			__GenericClass := __GenericClass.%name%

		return __GenericClass(Args*)
	}

	static newFromJSON(str) {
	/* --------------------------------------------------------------------------------------
	Function: newFromJSON()
	Converts JSON into new Object. The object class is taken from the "_class" entry within JSON

	Parameters:
	str - JSON-String

	Example:
	==== AutoHotkey ====
	#include TBy\ClassHelper.ahk

	class a{
		class b{
			x := 0
			y := 0
		}
	}
	strJSON := '{"x":42,"y":17,"_class":"a.b"}'
	c := ClassHelper.newFromJSON(strJSON)
	OutputDebug("New obj <c> is an instance of class <" Type(c) "> with property values (x=" c.x ", y=" c.y ")")
	===
	*/
		value := JSON.parse( str )
		ct := value["_class"]
		r :=  ClassHelper.newFromString(ct)
		For Name  in r.OwnProps() {
			if !RegExMatch(name, "^(_version|_class)$") {
				r.%name% := Value[name]
			}
		}
		return r
	}

	static toJSON(obj, indent:=0) {
	/* -------------------------------------------------------------------------------
	Function: toJSON()
	Converts Object into JSON

	Parameters:
	obj - Object to serialize to JSON
	indent - Indentation depth of JSON. Each indentation level is indented by this value.

	Example:
	==== AutoHotkey ====
	#include TBy\ClassHelper.ahk

	class a{
		class b{
			x := 42
			y := 17

			test() {
				return 55
			}
		}
	}
	c := a.b.new()
	str := ClassHelper.toJSON(c, indent := 2)

	OutputDebug("Serialized obj <c> to <" str ">")
	===
	*/
		; Create a map containing the class properties
		clone := Map()
		for key, value in obj.OwnProps() {
			if !RegExMatch(key, "^(_version|_class)$") {
				clone[key]:=value
			}
		}
		clone["_class"] := type(obj)

		str := JSON.stringify(clone)

		return str
	}
}
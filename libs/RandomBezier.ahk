#Requires AutoHotkey v2.0.0
; F5:: ToolTip("Points: " . RandomBezier( 0, 0, 400, 400, "T500 RO RD OT0 OB0 OL0 OR0 P4-20"))
; F5:: ToolTip("Points: " . RandomBezier( 0, 0, 400, 400, "T500 RO RD OT0 OB0 OL0 OR0 P4-2"))
; F5:: RandomBezier( 400, 300, 0, 0, "T1000 RD" )
; F5:: RandomBezier( 0, 0, -250, 250, "T500 RO RD OT100 OB-100 OL0 OR0 P4-3" )  ;;Moves +x200 relative to current mouse pos
; F5:: RandomBezier( 0, 0, 150, 150, "T1500 RO RD OT150 OB150 OL150 OR150 P6-4" )
; F5:: RandomBezier( 0, 0, 200, 200, "T1000 RO RD")
; Esc:: ExitApp

/*
    RandomBezier.ahk
    Copyright (C) 2012,2013 Antonio Fran�a

    This script is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this script.  If not, see <http://www.gnu.org/licenses/>.
*/

;========================================================================
;
; Function:     RandomBezier
; Description:  Moves the mouse through a random B�zier path
; URL (+info):  --------------------
;
; Last Update:  30/May/2013 03:00h BRT
;
; Created by MasterFocus
; - https://github.com/MasterFocus
; - http://masterfocus.ahk4.net
; - http://autohotkey.com/community/viewtopic.php?f=2&t=88198
;
;========================================================================
; XO/YO : X/Y origin
; XD/YD : X/Y destination
; O     : options
RandomBezier(XO, YO, XD, YD, O := "" ) {
   Time := RegExMatch(O, "i)T(\d+)", &M) && (M[1] > 0) ? M[1] : 200
   RO := InStr(O, "RO")
   RD := InStr(O, "RD")
   If !RegExMatch(O, "i)P(\d+)(-(\d+))?", &M)
      N := 2
   Else {
      N := (M[1] < 2) ? 2 : (M[1] > 19) ? 19 : M[1]
      If (M.Count = 3) {
         M := (M[3] < 2) ? 2 : (M[3] > 19) ? 19 : M[3]
         N := Random(N, M)
      }
   }
   OfT := RegExMatch(O, "i)OT(-?\d+)", &M) ? M[1] : 100
   OfB := RegExMatch(O, "i)OB(-?\d+)", &M) ? M[1] : 100
   OfL := RegExMatch(O, "i)OL(-?\d+)", &M) ? M[1] : 100
   OfR := RegExMatch(O, "i)OR(-?\d+)", &M) ? M[1] : 100
   MouseGetPos(&XM, &YM)
   If (RO) {
      XO += XM
      YO += YM
   }
   If (RD) {
      XD += XM
      YD += YM
   }
   If (XO < XD) {
      sX := XO - OfL
      bX := XD + OfR
   }
   Else {
      sX := XD - OfL
      bX := XO + OfR
   }
   If (YO < YD) {
      sY := YO - OfT
      bY := YD + OfB
   }
   Else {
      sY := YD - OfT
      bY := YO + OfB
   }
   MX := Map()
   MX[0] := XO
   MY := Map()
   MY[0] := YO
   Loop (--N) - 1 {
      MX[A_Index] := Random(sX, bX)
      MY[A_Index] := Random(sY, bY)
   }
   MX[N] := XD
   MY[N] := YD
   I := A_TickCount
   E := I + Time
   While (A_TickCount < E) {
      T := (A_TickCount - I) / Time
      U := 1 - T
      X := Y := 0
      Loop (N + 1) {
         F1 := F2 := F3 := 1
         Idx := A_Index - 1
         Loop Idx {
            F2 *= A_Index
            F1 *= A_Index
         }
         D := N - Idx
         Loop D {
            F3 *= A_Index
            F1 *= A_Index + Idx
         }
         M := (F1 / (F2 * F3)) * ((T + 0.000001) ** Idx)*((U - 0.000001) ** D)
         X += M * MX[Idx]
         Y += M * MY[Idx]
      }
      MouseMove(X, Y, 0)
      Sleep(1)
    }
   MouseMove(MX[N], MY[N], 0)
   Return (N + 1)
}
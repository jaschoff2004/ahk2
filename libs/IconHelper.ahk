#Requires AutoHotkey v2.0

#Include utils.ahk
#Include disk.ahk


class IconHelper {
    
    defaultBackup := "bak"
    defaultDesitation := "ico"

    __New() {

    }

    png2IcoDir() {
        dir := FileSelect("D")
        Loop Files, dir "\*.png" {   
            this.png2Ico(A_LoopFileName, A_LoopFileDir, Utils.filenameFromFile(A_LoopFileName) ".ico", A_LoopFileDir "\" this.defaultDesitation)
        }
    }

    png2Ico(srcName, srcPath, trgName, trgPath) {
        result := Disk.FileCopy(srcName, srcPath "\", srcName, srcPath "\" this.defaultBackup "\", 1)        
        ; png := FileOpen(srcPath "\" srcName, "r")        
        hBitmap := LoadPicture(srcPath "\" srcName, "GDI+")
        hIcon := this.HIconFromHBitmap(hBitmap)
        Disk.MakeDirIfNotExists(trgPath)
        this.HiconToFile(hIcon, trgPath "\" trgName)
        DllCall("DestroyIcon", "Ptr", hIcon)
        DllCall("DeleteObject", "Ptr", hBitmap)       
    }

    HIconFromHBitmap(hBitmap) {
        BITMAP := Buffer(size := 4*4 + A_PtrSize*2, 0)
        DllCall("GetObject", "Ptr", hBitmap, "Int", size, "Ptr", BITMAP)
        width := NumGet(BITMAP, 4, "UInt"), height := NumGet(BITMAP, 8, "UInt")
        hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        hCBM := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", width, "Int", height, "Ptr")
        ICONINFO := Buffer(4*2 + A_PtrSize*3, 0)
    
        NumPut("Int", 1, ICONINFO)
        NumPut("Ptr", hCBM, ICONINFO, 4*2 + A_PtrSize)
        NumPut("Ptr", hBitmap, ICONINFO, 4*2 + A_PtrSize*2)
    
        hIcon := DllCall("CreateIconIndirect", "Ptr", ICONINFO, "Ptr")
        DllCall("DeleteObject", "Ptr", hCBM), DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
        Return hIcon
    }
    
    HiconToFile(hIcon, destFile) {
        static szICONHEADER := 6, szICONDIRENTRY := 16, szBITMAP := 16 + A_PtrSize*2, szBITMAPINFOHEADER := 40
             , IMAGE_BITMAP := 0, flags := (LR_COPYDELETEORG := 0x8) | (LR_CREATEDIBSECTION := 0x2000)
             , szDIBSECTION := szBITMAP + szBITMAPINFOHEADER + 8 + A_PtrSize*3
             , copyImageParams := ["UInt", IMAGE_BITMAP, "Int", 0, "Int", 0, "UInt", flags, "Ptr"]
    
        ICONINFO := Buffer(8 + A_PtrSize*3, 0)
        DllCall("GetIconInfo", "Ptr", hIcon, "Ptr", ICONINFO)
        if !hbmMask  := DllCall("CopyImage", "Ptr", NumGet(ICONINFO, 8 + A_PtrSize, "UPtr"), copyImageParams*) {
            MsgBox("CopyImage failed. LastError: " . A_LastError)
            Return
        }
        hbmColor := DllCall("CopyImage", "Ptr", NumGet(ICONINFO, 8 + A_PtrSize*2, "UPtr"), copyImageParams*)
        mskDIBSECTION := Buffer(szDIBSECTION, 0)
        clrDIBSECTION := Buffer(szDIBSECTION, 0)
        DllCall("GetObject", "Ptr", hbmMask, "Int", szDIBSECTION, "Ptr", mskDIBSECTION)
        DllCall("GetObject", "Ptr", hbmColor, "Int", szDIBSECTION, "Ptr", clrDIBSECTION)
    
        clrWidth        := NumGet(clrDIBSECTION, 4, "UInt")
        clrHeight       := NumGet(clrDIBSECTION, 8, "UInt")
        clrBmWidthBytes := NumGet(clrDIBSECTION, 12, "UInt")
        clrBmPlanes     := NumGet(clrDIBSECTION, 16, "UShort")
        clrBmBitsPixel  := NumGet(clrDIBSECTION, 18, "UShort")
        clrBits         := NumGet(clrDIBSECTION, 16 + A_PtrSize, "UPtr")
        colorCount := clrBmBitsPixel >= 8 ? 0 : 1 << (clrBmBitsPixel * clrBmPlanes)
        clrDataSize := clrBmWidthBytes * clrHeight
    
        mskHeight       := NumGet(mskDIBSECTION, 8, "UInt")
        mskBmWidthBytes := NumGet(mskDIBSECTION, 12, "UInt")
        mskBits         := NumGet(mskDIBSECTION, 16 + A_PtrSize, "UPtr")
        mskDataSize := mskBmWidthBytes * mskHeight
    
        iconDataSize := clrDataSize + mskDataSize
        dwBytesInRes := szBITMAPINFOHEADER + iconDataSize
        dwImageOffset := szICONHEADER + szICONDIRENTRY
    
        ICONHEADER := Buffer(szICONHEADER, 0)
        NumPut("UShort", 1, ICONHEADER, 2)
        NumPut("UShort", 1, ICONHEADER, 4)
    
        ICONDIRENTRY := Buffer(szICONDIRENTRY, 0)
        NumPut("UChar", clrWidth, ICONDIRENTRY, 0)
        NumPut("UChar", clrHeight, ICONDIRENTRY, 1)
        NumPut("UChar", colorCount, ICONDIRENTRY, 2)
        NumPut("UShort", clrBmPlanes, ICONDIRENTRY, 4)
        NumPut("UShort", clrBmBitsPixel, ICONDIRENTRY, 6)
        NumPut("UInt", dwBytesInRes, ICONDIRENTRY, 8)
        NumPut("UInt", dwImageOffset, ICONDIRENTRY, 12)
    
        NumPut("UInt", clrHeight*2, clrDIBSECTION, szBITMAP +  8)
        NumPut("UInt", iconDataSize, clrDIBSECTION, szBITMAP + 20)
        
        _File := FileOpen(destFile, "w", "cp0")
        _File.RawWrite(ICONHEADER, szICONHEADER)
        _File.RawWrite(ICONDIRENTRY, szICONDIRENTRY)
        _File.RawWrite(clrDIBSECTION.Ptr + szBITMAP, szBITMAPINFOHEADER)
        _File.RawWrite(clrBits + 0, clrDataSize)
        _File.RawWrite(mskBits + 0, mskDataSize)
        _File.Close()
    
        DllCall("DeleteObject", "Ptr", hbmColor)
        DllCall("DeleteObject", "Ptr", hbmMask)
    }
}

icoHelp := IconHelper()
icoHelp.png2IcoDir()



; Png2Icon("D:\Downloads\image.png", A_Desktop . "\test.ico")

; Png2Icon(sourcePng, destIco) {
;    hBitmap := LoadPicture(sourcePng, "GDI+")
;    hIcon := HIconFromHBitmap(hBitmap)
;    HiconToFile(hIcon, destIco)
;    DllCall("DestroyIcon", "Ptr", hIcon), DllCall("DeleteObject", hBitmap)
; }



; HiconToFile(hIcon, destFile) {
;    static szICONHEADER := 6, szICONDIRENTRY := 16, szBITMAP := 16 + A_PtrSize*2, szBITMAPINFOHEADER := 40
;         , IMAGE_BITMAP := 0, flags := (LR_COPYDELETEORG := 0x8) | (LR_CREATEDIBSECTION := 0x2000)
;         , szDIBSECTION := szBITMAP + szBITMAPINFOHEADER + 8 + A_PtrSize*3
;         , copyImageParams := ["UInt", IMAGE_BITMAP, "Int", 0, "Int", 0, "UInt", flags, "Ptr"]

;    VarSetCapacity(ICONINFO, 8 + A_PtrSize*3, 0)
;    DllCall("GetIconInfo", "Ptr", hIcon, "Ptr", &ICONINFO)
;    if !hbmMask  := DllCall("CopyImage", "Ptr", NumGet(ICONINFO, 8 + A_PtrSize), copyImageParams*) {
;       MsgBox, % "CopyImage failed. LastError: " . A_LastError
;       Return
;    }
;    hbmColor := DllCall("CopyImage", "Ptr", NumGet(ICONINFO, 8 + A_PtrSize*2), copyImageParams*)
;    VarSetCapacity(mskDIBSECTION, szDIBSECTION, 0)
;    VarSetCapacity(clrDIBSECTION, szDIBSECTION, 0)
;    DllCall("GetObject", "Ptr", hbmMask , "Int", szDIBSECTION, "Ptr", &mskDIBSECTION)
;    DllCall("GetObject", "Ptr", hbmColor, "Int", szDIBSECTION, "Ptr", &clrDIBSECTION)

;    clrWidth        := NumGet(clrDIBSECTION,  4, "UInt")
;    clrHeight       := NumGet(clrDIBSECTION,  8, "UInt")
;    clrBmWidthBytes := NumGet(clrDIBSECTION, 12, "UInt")
;    clrBmPlanes     := NumGet(clrDIBSECTION, 16, "UShort")
;    clrBmBitsPixel  := NumGet(clrDIBSECTION, 18, "UShort")
;    clrBits         := NumGet(clrDIBSECTION, 16 + A_PtrSize)
;    colorCount := clrBmBitsPixel >= 8 ? 0 : 1 << (clrBmBitsPixel * clrBmPlanes)
;    clrDataSize := clrBmWidthBytes * clrHeight

;    mskHeight       := NumGet(mskDIBSECTION,  8, "UInt")
;    mskBmWidthBytes := NumGet(mskDIBSECTION, 12, "UInt")
;    mskBits         := NumGet(mskDIBSECTION, 16 + A_PtrSize)
;    mskDataSize := mskBmWidthBytes * mskHeight

;    iconDataSize := clrDataSize + mskDataSize
;    dwBytesInRes := szBITMAPINFOHEADER + iconDataSize
;    dwImageOffset := szICONHEADER + szICONDIRENTRY

;    VarSetCapacity(ICONHEADER, szICONHEADER, 0)
;    NumPut(1, ICONHEADER, 2, "UShort")
;    NumPut(1, ICONHEADER, 4, "UShort")

;    VarSetCapacity(ICONDIRENTRY, szICONDIRENTRY, 0)
;    NumPut(clrWidth      , ICONDIRENTRY,  0, "UChar")
;    NumPut(clrHeight     , ICONDIRENTRY,  1, "UChar")
;    NumPut(colorCount    , ICONDIRENTRY,  2, "UChar")
;    NumPut(clrBmPlanes   , ICONDIRENTRY,  4, "UShort")
;    NumPut(clrBmBitsPixel, ICONDIRENTRY,  6, "UShort")
;    NumPut(dwBytesInRes  , ICONDIRENTRY,  8, "UInt")
;    NumPut(dwImageOffset , ICONDIRENTRY, 12, "UInt")

;    NumPut(clrHeight*2 , clrDIBSECTION, szBITMAP +  8, "UInt")
;    NumPut(iconDataSize, clrDIBSECTION, szBITMAP + 20, "UInt")
   
;    File := FileOpen(destFile, "w", "cp0")
;    File.RawWrite(ICONHEADER, szICONHEADER)
;    File.RawWrite(ICONDIRENTRY, szICONDIRENTRY)
;    File.RawWrite(&clrDIBSECTION + szBITMAP, szBITMAPINFOHEADER)
;    File.RawWrite(clrBits + 0, clrDataSize)
;    File.RawWrite(mskBits + 0, mskDataSize)
;    File.Close()

;    DllCall("DeleteObject", "Ptr", hbmColor)
;    DllCall("DeleteObject", "Ptr", hbmMask)
; }
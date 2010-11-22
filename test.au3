Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
Opt("CaretCoordMode", 2)
#include "muBotCommon.au3"
#include <IE.au3>
#include <Tesseract.au3>
#include <ScreenCapture.au3>
#include <Constants.au3>
#include <SendMessage.au3>
#include <GDIP.au3>
#include <A-Star.au3>
HotKeySet("{ESC}", "Terminate")
HotKeySet("{TAB}", "DoTest")
WinActivate('©WakeUp')
_TesseractTempPathSet("C:\Temp\")

While 1
;~ 	DoTest()
	Sleep(100)
WEnd

Func DoTest()
;~ 	Local $coord[2] = [20, 738]
 	Local $StartTime = TimerInit()
;~   	Local $coord = GetCurrentPos()
;~  	Local $TimeTook = TimerDiff($StartTime)
;~ 	ConsoleWrite(@CRLF & "Took : " & String($TimeTook))

;~ 	_WinAPI_ShowWindow($hwnd2, @SW_SHOWNORMAL)

;~ 	ToolTip("" & String(StringSplit($coord)), 1030, 100)
;~ 	ToolTip("" & String(UBound($coord)), 1030, 100)
;~  	ToolTip("" & $coord[0] & " " & $coord[1] & @CRLF & "Took : " & $TimeTook, 1030, 100)
;~ 	$button1_pos = _TesseractWinCapture("©WakeUp", "", 0, "", 1, 10, $coord[0], $coord[1], 1024 - $coord[0] - 70, 768 - $coord[1] - 18, 0, $cCoordWhiteLevel)
;~ 	$button1_pos = StringReplace($button1_pos, "?", "7")
;~ 	Local $coord[2] = [698, 314]
;	$button1_pos = _TesseractWinCapture("©WakeUp", "", 0, "", 1, 5, $coord[0], $coord[1], 1024 - $coord[0] - 150, 768 - $coord[1] - 15, 1, $cCoordWhiteLevel)
;~ 	$button1_pos = _TesseractWinCapture("©WakeUp", "", 0, "", 1, 5, $coord[0], $coord[1], 1024 - $coord[0] - 150, 768 - $coord[1] - 15, 1)
;~  	ToolTip($button1_pos, 1030, 100)
;~ 	$button1_pos = _TesseractWinFind("©WakeUp", "", "Deafasf", 1, 0, "", 1, 1, $coord[0], $coord[1], 1024 - $coord[0] - 150, 768 - $coord[1] - 15, 0)

;~   	Local $StartTime = TimerInit()
	Local $ToCoord[2] = [191, 121]
;~ 	Local $StartCoord = GetCurrentPos()

;~ 	Local $MyMapArray[256][256]
;~ 	Local $MyMapFile = FileOpen("C:\\MU\\Data\\World4\\Terrain.att", 4)
;~ 	Local $CurCharNum = 0
;~ 	FileRead($MyMapFile, 3)
;~ 	While 1
;~ 		Local $CurChar = FileRead($MyMapFile, 1)
;~ 		If @error = -1 Then ExitLoop

;~ 		Local $CurY = Int($CurCharNum / 256)
;~ 		Local $CurX = $CurCharNum - $CurY * 256
;~ 		If Asc($CurChar) > 1 Then
;~ 			$MyMapArray[$CurY][$CurX] = "x"
;~ 		Else
;~ 			$MyMapArray[$CurY][$CurX] = "0"
;~ 		EndIf

;~ 		$CurCharNum += 1
;~ 	WEnd
;~ 	FileClose($MyMapFile)

;~ 	For $i = 0 To 255 Step 1
;~ 		$MyMapArray[0][$i] = "x"
;~ 		$MyMapArray[255][$i] = "x"
;~ 	Next
;~  	For $i = 0 To 255 Step 1
;~ 		$MyMapArray[$i][0] = "x"
;~ 		$MyMapArray[$i][255] = "x"
;~ 	Next

;~ 	$MyMapArray[$StartCoord[1]][$StartCoord[0]] = "s"
;~ 	$MyMapArray[$ToCoord[1]][$ToCoord[0]] = "g"

;~ 	_CreateMap($MyMapArray, 256, 256)

;~ 	Dim $path = _FindPath($MyMapArray, $MyMapArray[$StartCoord[1]][$StartCoord[0]], $MyMapArray[$ToCoord[1]][$ToCoord[0]])

;~ 	For $i = 0 To UBound($path) - 1 Step 1
;~ 		$item = $path[$i]
;~ 		Local $Tempo = StringSplit($item, ",")
;~ 		Local $ToToCoord[2] = [$Tempo[1], $Tempo[2]]
;~ 		GoToCoord($ToToCoord, 0, False)
;~ 	Next
	GoToCoord($ToCoord)
  	Local $TimeTook = TimerDiff($StartTime)
;~ 	CenterMouse(0, 0)
	MsgBox(0, "test", "DONE! Time TOOK : " & String($TimeTook))
;~ 	MsgBox(0, "test", "" & GetCursorColor())
;~ 	MsgBox(0, "test", "" & GetCursorColor())
;~ 	Local $curpp = MouseGetPos()
;~ 	MsgBox(0, "test", String($curpp[0] - $cMCenter[0]) & " " & String($curpp[1]  - $cMCenter[1]))
;~ 	Local $aCursor = _WinAPI_GetCursorInfo()
;~ 	MsgBox(0, "ttt", String($aCursor[1]))
;~ 	If $aCursor[1] Then
;~ 		Local $hIcon = _WinAPI_CopyIcon($aCursor[2])

;~ 	EndIf
EndFunc

Func Terminate()
    Exit 0
EndFunc

;~ $button1_pos = _TesseractWinCapture("©WakeUp", "", 0, "", 1, 1, 810, 669, 810, 775, 1)
;~ MouseMove(450, 340, 10)
;~ $button1_pos = _TesseractWinCapture("©WakeUp", "", 0, "", 1, 1, 0, 0, 0, 0, 1)
;~ MouseMove(810 * 0.55, 669 * 0.53, 10)
;~ Sleep(5000)
;~ MouseMove(1024 - 810 * 0.55, 768 - 775 * 0.53, 10)
;~ $button1_pos = _TesseractWinFind("©WakeUp", "", "Medium", 1)
;~ MsgBox(0, "", """MsgBox"" found at position " & $button1_pos)
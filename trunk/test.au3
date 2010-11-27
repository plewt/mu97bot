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
	GoToCoordAStar($ToCoord, "noria")
;~ 	GoToCoord($ToCoord)
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
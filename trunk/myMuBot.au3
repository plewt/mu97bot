#include "muBotCommon.au3"
HotKeySet("{ESC}", "Terminate")
HotKeySet("{TAB}", "PauseUnpause")

;
; ����� ����������� ���������
;
Dim Const $cCharType               = $cctDW; ����� ��� ������ ���������
;~ Dim Const $cCharType               = $cctElf; ����� ��� ������ ���������
Dim Const $cPassword               = "wdtnjxtr21" ; ������ � ����
;~ Dim Const $cCharNumber             = 1 ; ����� ������ ��������� �� ������ ������
Dim Const $cCharNumber             = 4 ; ����� ������ ��������� �� ������ ������

Dim Const $cIdleDuration           = 500 ; ����� ����� � ����� ��������
Dim Const $cMainSkillDuration      = 20  ; ������� �������� �������� �������� �����
Dim Const $cSecondarySkillDuration = 2   ; ������� �������� �������� �������������� �����

Dim Const $cAlcoholDuration        = 75  ; ������� �������� ��������� ��������
Dim Const $cLootIdleDuration       = 1  ; ������� �������� �� ����� �������� ����
Dim Const $cComeBackDuration       = 5  ; ������� �������� �� ������������
Dim Const $cHealthLowLevel         = 75  ; � % - ������� ���� �������� - ���� ��
Dim Const $cManaLowLevel           = 50  ; � % - ������� ���� �������� - ���� ����
; �����
Dim Const $cnAlcohol       = 0 ; ���� �� ��������
Dim Const $cnCoordsChanged = 0 ; ��������� �� �� ��������� ���������
Dim Const $cnDecline       = 0 ; ��������� �� �������
Dim Const $cnHeal          = 1 ; ������� ��
Dim Const $cnMana          = 0 ; ���� �� ����
Dim Const $cnSwitchSkill   = 0 ; ����������� �� �����
Dim Const $cnLoot          = 1 ; ������
Dim Const $cnTurn          = 0 ; �������������� ��
Dim Const $cnLootTurnBack  = 1 ; ���� �� ������������
Dim Const $cnF10           = 0 ; ���� �� ���� F10 ����� ���������
Dim Const $cnComeBack      = 1 ; ������������ �� �� ���� �������
Dim Const $aDungeon        = 0 ;

; ��� DW / SM
Dim Const $cManashieldDuration = 40  ; ������� �������� ��������� ��������
Dim Const $cnManashield        = 0 ; ������� �� ��������
; ��� Elf
Dim Const $cBuffDuration = 19  ; ������� �������� ��������� ���
Dim Const $cnRebuff      = 0 ; ���������� ��
Dim Const $crCount       = 2 ; ������� ������� � ���� ��������, ���� 0 - �� �������� ����
;
; ���������� ���������
;
; ������� ������� ���������
Dim Const $ccFirst       = 0 ;
Dim Const $ccAlcohol     = 0 ;
Dim Const $ccManaShield  = 1 ;
Dim Const $ccRebuff      = 2 ;
Dim Const $ccSwitchSkill = 3 ;
Dim Const $ccTurn        = 4 ;
Dim Const $ccLoot        = 5 ;
Dim Const $ccComeBack    = 6 ;
Dim Const $ccLast        = 6 ;

; ����������
Dim $HealthLevel    = 100
Dim $ManaLevel      = 100
Dim $Iteration      = 0
Dim $CoordsChecksum = PixelChecksum(15, 740, 89, 755)
Dim $Paused = True
Dim $Counters[$ccLast + 1] = [0, 0, 0, 0, 0, 0, 0]
Dim $LootCoords[2] = [0, 0]
Dim $SearchRect[4] = [100, 100, 900, 550]
Dim $LootTry = 0

WinActivate($cMuHeader)
$CoordsBefore = GetCurrentPos()
Dim $CoordsAfter = $CoordsBefore
;===============================================================
; ��������
;===============================================================
Func DoComeBack()
	If $cnF10 == 1 Then Send("{F10}")
	While GetHealthLevel() < 5
		Sleep(100)
	WEnd
	Sleep(200)
	If (Abs($CoordsAfter[0] - $CoordsBefore[0]) + Abs($CoordsAfter[1] - $CoordsBefore[1])) > 50 Then
		If ($aDungeon == 1) Then
			Sleep(1000)
			TeleportTo("dungeon3")
			Sleep(200)
		EndIf
	EndIf
	If (Abs($CoordsAfter[0] - $CoordsBefore[0]) + Abs($CoordsAfter[1] - $CoordsBefore[1])) > 4 Then
		GoToCoord($CoordsBefore)
	EndIf
	Sleep(200)
	If $cnF10 == 1 Then Send("{F10}")
EndFunc

Func DoHeal()
	If $cCharType == $cctElf Then
		DoHealBuff(1)
	Else
		DrinkHealthPoition()
	EndIf
EndFunc

; ������
Func Loot()
	$LootTry += 1
;~ 	Local $CoordsBefore = GetCurrentPos()
;~ 	Local $xv = 512 / 3500
;~ 	Local $yv = 300 / 3500
	Local $xv = 512 / 2000
	Local $yv = 300 / 2000

 	If $cnF10 == 1 Then Send("{F10}")
	Local $WasDead = False
	While GetHealthLevel() < 5
		$WasDead = True
		Sleep(100)
	WEnd
	If $WasDead Then Sleep(1000)
	Sleep(200)
	Send("{ALT down}")
	MouseMove($LootCoords[0] + 25, $LootCoords[1] + 25, 0)
	Sleep(100)
	Local $xPathLen = Abs($cMCenter[0] - $LootCoords[0] - 20)
	Local $yPathLen = Abs($cMCenter[1] - $LootCoords[1] - 20)
	Local $PathLen = Sqrt($xPathLen*$xPathLen + $yPathLen*$yPathLen)
	Local $XTime = $PathLen / $xv
	Local $YTime = 0

;~ 	Local $XTime = Abs($cMCenter[0] - $LootCoords[0] - 20) / $xv; X
;~ 	Local $YTime = Abs($cMCenter[1] - $LootCoords[1] - 20) / $yv ; Y
;~ 	ShowToolTip(String($XTime + $YTime))
	DoMainClick(200)
	CenterMouse()
	Sleep($XTime + $YTime)
	Sleep(50)
	Send("{ALT up}")
	Sleep(200)
	DoKeyPress("ALT")
	CenterMouse()
	If $cnF10 == 1 Then Send("{F10}")
;~ 	If $cnLootTurnBack == 1 Then
;~ 		Local $CoordsAfter = GetCurrentPos()
;~ 		While GetHealthLevel() < 5
;~ 			Sleep(100)
;~ 		WEnd
;~ 		If ($CoordsBefore[0] <> $CoordsAfter[0]) Or ($CoordsBefore[1] <> $CoordsAfter[1]) Then
;~ 			GoToCoord($CoordsBefore)
;~ 		EndIf
;~ 	EndIf
EndFunc

; ������ ���� �� �����
Func DoTurn()
	If $Counters[$ccTurn] == 8 Then
		$Counters[$ccTurn] = 1
	Else
		$Counters[$ccTurn] += 1
	EndIf
	DoMouseRoundMove($Counters[$ccTurn])
EndFunc

; ����������������
Func DoReconnect()
	TakeSnapshot()
	Reconnect($cPassword, $cCharNumber)
	CenterMouse()
EndFunc
;===============================================================

;===============================================================
; ��������
;===============================================================
Func NeedComeBack()
	If CounterCheck($ccComeBack, $cComeBackDuration, $cnComeBack) Then
		$CoordsAfter = GetCurrentPos()
		If ($CoordsBefore[0] <> $CoordsAfter[0]) Or ($CoordsBefore[1] <> $CoordsAfter[1]) Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunc

; ��������� �� ���� �� �������
Func NeedLoot()
;~ 	Local $BenchTimer = TimerInit()
	Const $LootColors[5] = [$calJewelTextColor, $calBlueTextColor, $calGrayTextColor, $calWhiteTextColor, $calOrangeTextColor]
	Const $LootWords[4] = ["Jewel", "Heart", "Feather", "Healing"]
	Const $LootWords1[1] = ["Heart"]
	Const $LootExcludeWords[2] = ["Chaos", "Soldier"]
;~ 	Const $LootWords[4] = ["Jewel", "Heart", "Feather"]
	If CounterCheck($ccLoot, $cLootIdleDuration, $cnLoot) Then
		Local $Res = False
		$Res = FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], $calJewelTextColor, $LootCoords, $LootWords, $LootExcludeWords, 5)
;~ 		If $Res Then Return True
;~ 		For $i = 1 To 4 Step 1
;~ 			$Res = FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], $LootColors[$i], $LootCoords, $LootWords1, 5)
;~ 			If $Res Then ExitLoop
;~ 		Next
;~ 		ConsoleWrite(@CRLF & "TOOK " & TimerDiff($BenchTimer))
;~ 		Sleep(5000)
		Return $Res
;~ 		Return FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], $calJewelTextColor, $LootCoords, "Jewel", 5)
;~ 		Return FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], $calJewelTextColor, $LootCoords, "Mana", 5)
;~ 		Return FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], 0xFFFFFF, $LootCoords, "Love", 4)
;~ 		Return FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], $calJewelTextColor, $LootCoords, "Zen", 4)
	Else
;~ 		ShowToolTip(TimerDiff($BenchTimer))
;~ 		Sleep(5000)
		Return False
	EndIf
EndFunc

; ��������� ����� �� ����������������
Func NeedReconnect()
	Local $myWinHandle = WinGetHandle ($cMuHeader)
	If @error Then Return True
	If PixelChecksum(424, 118, 434, 128) = 3937422940 Then
		MouseMove(509, 179, 0)
		Sleep(200)
		MouseDown("left")
		Sleep(30)
		MouseUp("left")
		Sleep(1000)
	EndIf
	Local $myWinHandle = WinGetHandle ($cMuHeader)
	If @error Then Return True
	Return False
EndFunc

; ��������� ���� �� ���������
Func NeedTurn()
	If $cnTurn == 0 Then Return False
	Return ($cCharType == $cctElf) Or ($cCharType == $cctME) Or ($cCharType == $cctDK) Or ($cCharType == $cctBK) Or ($cCharType == $cctMG)
EndFunc

; ��������� �� ���������� �� ����������
Func CoordsChanged()
	If $cnCoordsChanged == 0 Then Return False
	Local $curChecksum = PixelChecksum(15, 740, 89, 755)
	If $curChecksum == $CoordsChecksum Then
		Return False
	Else
		$CoordsChecksum = $curChecksum
		Return True
	EndIf
EndFunc

; ��������� �� ���� �� �������� ������ �� ����
Func NeedDeclineRequest()
	If $cnDecline == 0 Then Return False
	Return (PixelChecksum(407, 131, 616, 146) = 1290891972)
EndFunc

; ��������� �� ���� �� ��� �������� �����
Func NeedSwitchSkill()
	If $ActiveSkill == $cMainSkillKey Then
		Return CounterCheck($ccSwitchSkill, $cMainSkillDuration, $cnSwitchSkill)
	Else
		Return CounterCheck($ccSwitchSkill, $cSecondarySkillDuration, $cnSwitchSkill)
	EndIf
EndFunc

; ��������� �� ���� �� ��� �����������
Func NeedManaShield()
	If ($cCharType <> $cctDW) And ($cCharType <> $cctSM) Then Return False
	Return CounterCheck($ccManaShield, $cManashieldDuration, $cnManashield)
EndFunc

; ��������� �� ���� �� ��� �����������
Func NeedRebuff()
	Return CounterCheck($ccRebuff, $cBuffDuration, $cnRebuff)
EndFunc

; ��������� �� ���� �� ��� ���� ��������
Func NeedAlcohol()
	Return CounterCheck($ccAlcohol, $cAlcoholDuration, $cnAlcohol)
EndFunc

; ��������� ������� �� ��������� ��������
Func CounterCheck($aCounter, $aValue, $aOption)
	If $aOption == 0 Then Return False
	If $Counters[$aCounter] = $aValue Then
		$Counters[$aCounter] = 0
		Return True
	Else
		$Counters[$aCounter] += 1
		Return False
	EndIf
EndFunc

; ��������� �� ���� �� ��� ���� ����
Func NeedMana()
	If $cnMana == 0 Then Return False
	$ManaLevel = GetManaLevel()
	Return ($ManaLevel <= $cManaLowLevel)
EndFunc

; ��������� �� ���� �� ��� ��������
Func NeedHeal()
	If $cnHeal == 0 Then Return False
	$HealthLevel = GetHealthLevel()
	Local $WasDead = False
	Return ($HealthLevel <= $cHealthLowLevel)
EndFunc
;===============================================================

;===============================================================
; �������� ���� ����
;===============================================================
While 1
	If Not $Paused Then
		WinActivate($cMuHeader)
		If NeedReconnect() Then DoReconnect()
		If WinActive($cMuHeader) Then
			If NeedHeal() Then DoHeal()
			If NeedMana() Then DrinkManaPoition()
			If NeedAlcohol() Then DrinkAlcohol()
			If NeedRebuff() Then Rebuff($crCount)
			If NeedManaShield() Then DoManaShield()
			If NeedSwitchSkill() Then SwitchSkills()
			If NeedDeclineRequest() Then DeclineRequest()
			If CoordsChanged() Then TakeSnapshot(); DoCoordsChanged() ;
			If NeedTurn() Then DoTurn()
			If NeedLoot() Then Loot()
			If NeedComeBack() Then DoComeBack()
		EndIf
		ShowStats()
	EndIf
	Sleep($cIdleDuration)
WEnd

; ���������� ���������� �� ���������
Func ShowStats()
	ShowToolTip(StringFormat("Health : %3.2f", Round($HealthLevel, 2)) & "%" & @CRLF & StringFormat("Mana   : %3.2f", Round($ManaLevel, 2)) & "%" & @CRLF & StringFormat("LootTry  : %d", $LootTry) & @CRLF & StringFormat("InitCoords : %d %d", $CoordsBefore[0], $CoordsBefore[1]) & @CRLF & StringFormat("CurCoords  : %d %d", $CoordsAfter[0], $CoordsAfter[1]))
EndFunc

; ����� - �������
Func PauseUnpause()
	$CoordsChecksum = PixelChecksum(15, 740, 89, 755)
	$CoordsBefore = GetCurrentPos()
	$Paused = Not $Paused
	SetRequests($Paused)
	If $cnF10 == 1 Then DoKeyPress("F10")
EndFunc

; �����
Func Terminate()
	If Not $Paused Then PauseUnpause()
	Exit 0
EndFunc
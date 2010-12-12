#include "muBotCommon.au3"
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
HotKeySet("{F8}", "Terminate")
HotKeySet("{TAB}", "PauseUnpause")
HotKeySet("{F5}", "MyGUIHideShow")

;
; ����� ����������� ���������
;
Dim Const $cConfigFileName   = "BotConfig.ini"
Dim Const $cAlcoholDuration    = 75 ; ������� �������� ��������� ��������
Dim Const $cManashieldDuration = 40 ; ������� �������� ��������� ��������
Dim Const $cBuffDuration       = 19 ; ������� �������� ��������� ���

Dim $cCharType   ; ����� ��� ������ ���������
Dim $cCharNumber ; ����� ������ ��������� �� ������ ������
Dim $cPassword   ; ������ � ����

Dim $cLocation               ; ��� ������� ��� �� ������
Dim $cIdleDuration           ; ����� ����� � ����� ��������
Dim $cMainSkillDuration      ; ������� �������� �������� �������� �����
Dim $cSecondarySkillDuration ; ������� �������� �������� �������������� �����

Dim $cLootIdleDuration ; ������� �������� �� ����� �������� ����
Dim $cComeBackDuration ; ������� �������� �� ������������
Dim $cHealthLowLevel   ; � % - ������� ���� �������� - ���� ��
Dim $cManaLowLevel     ; � % - ������� ���� �������� - ���� ����
; �����
Dim $cnAlcohol       ; ���� �� ��������
Dim $cnCoordsChanged ; ��������� �� �� ��������� ���������
Dim $cnDecline       ; ��������� �� �������
Dim $cnHeal          ; ������� ��
Dim $cnMana          ; ���� �� ����
Dim $cnSwitchSkill   ; ����������� �� �����
Dim $cnLoot          ; ������
Dim $cnTurn          ; �������������� ��
Dim $cnAutoSkill     ; ���� �� ���� F10 ����� ���������
Dim $cnComeBack      ; ������������ �� �� ���� �������
Dim $cnMove          ; ����� �� ������ /move

; ��� DW / SM
Dim $cnManashield ; ������� �� ��������
; ��� Elf
Dim $cnRebuff ; ���������� ��
Dim $crCount  ; ������� ������� � ���� ��������, ���� 0 - �� �������� ����

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
Dim $CoordsChecksumPos[4] = [15, 740, 89, 755]
Dim $CoordsChecksum = PixelChecksum($CoordsChecksumPos[0], $CoordsChecksumPos[1], $CoordsChecksumPos[2], $CoordsChecksumPos[3])
Dim $Paused = True
Dim $GuiShown = False
Dim $Counters[$ccLast + 1] = [0, 0, 0, 0, 0, 0, 0]
Dim $LootCoords[2] = [0, 0]
Dim $SearchRect[4] = [100, 100, 900, 550]
Dim $LootTry = 0
Dim $cLootAddCoord = 25
Dim $cCurResolution = 1024
Dim $cServerNum = 1

WinActivate($cMuHeader)
Dim $CoordsBefore[2] = [-1, -1]
Dim $CoordsAfter[2] = [-1, -1]

; ���������� GUI
Dim $CharTypeCombo
Dim $CharNumberCombo
Dim $AccPasswordInput

Dim $cbAlcohol
Dim $cbDecline
Dim $cbHeal
Dim $cbCoordsChange
Dim $cbMana
Dim $cbSwitchSkills
Dim $cbLoot
Dim $cbTurn
Dim $cbAutoSkill
Dim $cbComeBack
Dim $cbNeedMove
Dim $cbManashield
Dim $cbRebuff

Dim $lbHealthLowLevel
Dim $lbManaLowLevel
Dim $lbMainSkillDur
Dim $lbSecondarySkillDur
Dim $lbLootDur
Dim $lbComeBackDur
Dim $lbPartyCount
Dim $lbLocation
Dim $lbServerNum

Dim $inIdleDuration
Dim $inMainSkillDur
Dim $inSecondarySkillDur
Dim $inLootDur
Dim $inComeBackDur
Dim $inHealthLowLevel
Dim $inManaLowLevel
Dim $inPartyCount
Dim $coLocation
Dim $coServerNum

MyLoadConfig()
MyGUICreate()
;===============================================================
; ��������
;===============================================================
Func DoSetResolution($aWidth = 1024)
	Local $Multiplier = $aWidth / 1024.0

	$CoordsChecksumPos[0] = Int(15 * $Multiplier)
	$CoordsChecksumPos[1] = Int(740 * $Multiplier)
	$CoordsChecksumPos[2] = Int(89 * $Multiplier)
	$CoordsChecksumPos[3] = Int(755 * $Multiplier)

	$CoordsChecksum = PixelChecksum($CoordsChecksumPos[0], $CoordsChecksumPos[1], $CoordsChecksumPos[2], $CoordsChecksumPos[3])

	$SearchRect[0] = Int(100 * $Multiplier)
	$SearchRect[1] = Int(100 * $Multiplier)
	$SearchRect[2] = Int(900 * $Multiplier)
	$SearchRect[3] = Int(550 * $Multiplier)

	$cLootAddCoord = Int(25 * $Multiplier)

	SetResolution($aWidth)
EndFunc

Func SwitchAutoSkill()
	If $cnAutoSkill == 1 Then Send("{" & $cAutoSkillKey & "}")
EndFunc

Func DoComeBack()
	SwitchAutoSkill()
	While GetHealthLevel() < 5
		Sleep(100)
	WEnd
	Sleep(200)
	If (Abs($CoordsAfter[0] - $CoordsBefore[0]) + Abs($CoordsAfter[1] - $CoordsBefore[1])) > 50 Then
		If ($cnMove == 1) Then
			Sleep(1000)
			TeleportTo($cLocation)
			Sleep(200)
		EndIf
	EndIf
	If (Abs($CoordsAfter[0] - $CoordsBefore[0]) + Abs($CoordsAfter[1] - $CoordsBefore[1])) > 4 Then
		GoToCoord($CoordsBefore)
	EndIf
	Sleep(200)
	SwitchAutoSkill()
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
	Local $xv = $cMainWndWidth / 4000
	Local $yv = $cMainWndHeight / 4000

	SwitchAutoSkill()
	Local $WasDead = False
	While isDead()
		$WasDead = True
		Sleep(100)
	WEnd
	If $WasDead Then Sleep(1000)
	Sleep(200)
	Send("{ALT down}")
	MouseMove($LootCoords[0] + $cLootAddCoord, $LootCoords[1] + $cLootAddCoord, 0)
	Sleep(100)
	Local $xPathLen = Abs($cMCenter[0] - $LootCoords[0] - $cLootAddCoord)
	Local $yPathLen = Abs($cMCenter[1] - $LootCoords[1] - $cLootAddCoord)
	Local $PathLen = Sqrt($xPathLen * $xPathLen + $yPathLen * $yPathLen)
	Local $XTime = $PathLen / $xv
	Local $YTime = 0

	DoMainClick(200)
	CenterMouse()
	Sleep($XTime + $YTime)
	Sleep(50)
	Send("{ALT up}")
	Sleep(200)
	DoKeyPress("ALT")
	CenterMouse()
	SwitchAutoSkill()
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
	Connect($cPassword, $cCharNumber, $cServerNum)
	SwitchAutoSkill()
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
	Const $LootColors[5] = [$calJewelTextColor, $calBlueTextColor, $calGrayTextColor, $calWhiteTextColor, $calOrangeTextColor]
	Const $LootWords[1] = ["Jewel"]
	Const $LootWords1[1] = ["Heart"]
	Const $LootExcludeWords[2] = ["Chaos", "Soldier"]
	If CounterCheck($ccLoot, $cLootIdleDuration, $cnLoot) Then
		Local $Res = False
		$Res = FindLootInRect($SearchRect, $calJewelTextSize[0], $calJewelTextSize[1], $calJewelTextColor, $LootCoords, $LootWords, $LootExcludeWords, 5)
		Return $Res
	Else
		Return False
	EndIf
EndFunc

; ��������� ����� �� ����������������
Func NeedReconnect()
	Local $myWinHandle = WinGetHandle ($cMuHeader)
	If @error Then Return True
	If IsDisconnectWindowOpen() Then
		Send("{ENTER}")
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
	Local $curChecksum = PixelChecksum($CoordsChecksumPos[0], $CoordsChecksumPos[1], $CoordsChecksumPos[2], $CoordsChecksumPos[3])
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
	; �������� ���������
	Return False
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
		Sleep($cIdleDuration)
	Else
		MyProcessGUI()
		Sleep(100)
	EndIf
WEnd

; ���������� ���������� �� ���������
Func ShowStats()
	ShowToolTip(StringFormat("Health : %3.2f", Round($HealthLevel, 2)) & "%" & @CRLF & StringFormat("Mana   : %3.2f", Round($ManaLevel, 2)) & "%" & @CRLF & StringFormat("LootTry  : %d", $LootTry) & @CRLF & StringFormat("InitCoords : %d %d", $CoordsBefore[0], $CoordsBefore[1]) & @CRLF & StringFormat("CurCoords  : %d %d", $CoordsAfter[0], $CoordsAfter[1]))
EndFunc

; ����� - �������
Func PauseUnpause()
	$cCurResolution = _WinAPI_GetClientWidth(WinGetHandle($cMuHeader))
	DoSetResolution($cCurResolution)
	$CoordsChecksum = PixelChecksum($CoordsChecksumPos[0], $CoordsChecksumPos[1], $CoordsChecksumPos[2], $CoordsChecksumPos[3])
	$CoordsBefore = GetCurrentPos()
	$Paused = Not $Paused
	SetRequests($Paused)
	SwitchAutoSkill()
EndFunc

; �����
Func Terminate()
	If Not $Paused Then PauseUnpause()
	MySaveConfig()
	Exit 0
EndFunc

; ����������/�������� �������� � ����
Func MySaveConfig()
	IniWrite($cConfigFileName, "Main", "CharType", String($cCharType))
	IniWrite($cConfigFileName, "Main", "CharNumber", String($cCharNumber))
	IniWrite($cConfigFileName, "Main", "Password", String($cPassword))

	IniWrite($cConfigFileName, "Main", "IdleDuration", String($cIdleDuration))
	IniWrite($cConfigFileName, "Main", "$MainSkillDuration", String($cMainSkillDuration))
	IniWrite($cConfigFileName, "Main", "SecondarySkillDuration", String($cSecondarySkillDuration))

	IniWrite($cConfigFileName, "Main", "LootIdleDuration", String($cLootIdleDuration))
	IniWrite($cConfigFileName, "Main", "ComeBackDuration", String($cComeBackDuration))
	IniWrite($cConfigFileName, "Main", "HealthLowLevel", String($cHealthLowLevel))
	IniWrite($cConfigFileName, "Main", "ManaLowLevel", String($cManaLowLevel))

	IniWrite($cConfigFileName, "Main", "nAlcohol", String($cnAlcohol))
	IniWrite($cConfigFileName, "Main", "nCoordsChanged", String($cnCoordsChanged))
	IniWrite($cConfigFileName, "Main", "nDecline", String($cnDecline))
	IniWrite($cConfigFileName, "Main", "nHeal", String($cnHeal))
	IniWrite($cConfigFileName, "Main", "nMana", String($cnMana))
	IniWrite($cConfigFileName, "Main", "nSwitchSkill", String($cnSwitchSkill))
	IniWrite($cConfigFileName, "Main", "nLoot", String($cnLoot))
	IniWrite($cConfigFileName, "Main", "nTurn", String($cnTurn))
	IniWrite($cConfigFileName, "Main", "nAutoSkill", String($cnAutoSkill))
	IniWrite($cConfigFileName, "Main", "nComeBack", String($cnComeBack))
	IniWrite($cConfigFileName, "Main", "nMove", String($cnMove))
	IniWrite($cConfigFileName, "Main", "Location", String($cLocation))
	IniWrite($cConfigFileName, "Main", "ServerNum", String($cServerNum))
	IniWrite($cConfigFileName, "DW", "nManashield", String($cnManashield))
	IniWrite($cConfigFileName, "Elf", "nRebuff", String($cnRebuff))
	IniWrite($cConfigFileName, "Elf", "PartyCount", String($crCount))
EndFunc

Func MyLoadConfig()
	$cCharType = Int(IniRead($cConfigFileName, "Main", "CharType", String($cctDW)))
	$cCharNumber = Int(IniRead($cConfigFileName, "Main", "CharNumber", "1"))
	$cPassword = IniRead($cConfigFileName, "Main", "Password", "")

	$cIdleDuration = Int(IniRead($cConfigFileName, "Main", "IdleDuration", "500"))
	$cMainSkillDuration = Int(IniRead($cConfigFileName, "Main", "$MainSkillDuration", "1"))
	$cSecondarySkillDuration = Int(IniRead($cConfigFileName, "Main", "SecondarySkillDuration", "1"))

	$cLootIdleDuration = Int(IniRead($cConfigFileName, "Main", "LootIdleDuration", "10"))
	$cComeBackDuration = Int(IniRead($cConfigFileName, "Main", "ComeBackDuration", "5"))
	$cHealthLowLevel = Int(IniRead($cConfigFileName, "Main", "HealthLowLevel", "75"))
	$cManaLowLevel = Int(IniRead($cConfigFileName, "Main", "ManaLowLevel", "50"))

	$cnAlcohol = Int(IniRead($cConfigFileName, "Main", "nAlcohol", "0"))
	$cnCoordsChanged = Int(IniRead($cConfigFileName, "Main", "nCoordsChanged", "0"))
	$cnDecline = Int(IniRead($cConfigFileName, "Main", "nDecline", "0"))
	$cnHeal = Int(IniRead($cConfigFileName, "Main", "nHeal", "0"))
	$cnMana = Int(IniRead($cConfigFileName, "Main", "nMana", "0"))
	$cnSwitchSkill = Int(IniRead($cConfigFileName, "Main", "nSwitchSkill", "0"))
	$cnLoot = Int(IniRead($cConfigFileName, "Main", "nLoot", "0"))
	$cnTurn = Int(IniRead($cConfigFileName, "Main", "nTurn", "0"))
	$cnAutoSkill = Int(IniRead($cConfigFileName, "Main", "nAutoSkill", "0"))
	$cnComeBack = Int(IniRead($cConfigFileName, "Main", "nComeBack", "0"))
	$cnMove = Int(IniRead($cConfigFileName, "Main", "nMove", "0"))
	$cLocation = IniRead($cConfigFileName, "Main", "Location", "")
	$cnManashield = Int(IniRead($cConfigFileName, "DW", "nManashield", "0"))
	$cnRebuff = Int(IniRead($cConfigFileName, "Elf", "nRebuff", "0"))
	$crCount = Int(IniRead($cConfigFileName, "Elf", "PartyCount", "0"))
	$cServerNum = Int(IniRead($cConfigFileName, "Main", "ServerNum", "1"))
EndFunc

; GUI
Func MyProcessGUI()
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			$GuiShown = False
			GUISetState(@SW_HIDE)

		Case $CharTypeCombo
			Local $aCharType = GUICtrlRead($CharTypeCombo)
			Select
				Case $aCharType == 'Soul Master'
					$cCharType = $cctSM
				Case $aCharType == 'Dark Wizzard'
					$cCharType = $cctDW
				Case $aCharType == 'Magic Gladiator'
					$cCharType = $cctMG
				Case $aCharType == 'Dark Warrior'
					$cCharType = $cctDK
				Case $aCharType == 'Blade Knight'
					$cCharType = $cctBK
				Case $aCharType == 'Muse Elf'
					$cCharType = $cctME
				Case $aCharType == 'Elf'
					$cCharType = $cctElf
			EndSelect

			If ($cCharType == $cctDW) Or ($cCharType == $cctSM) Then
				GUICtrlSetState($cbManashield, $GUI_ENABLE)
			Else
				GUICtrlSetState($cbManashield, $GUI_DISABLE)
			EndIf
			If ($cCharType == $cctElf) Or ($cCharType == $cctME) Then
				GUICtrlSetState($cbRebuff, $GUI_ENABLE)
				If $cnRebuff Then
					GUICtrlSetState($lbPartyCount, $GUI_ENABLE)
					GUICtrlSetState($inPartyCount, $GUI_ENABLE)
				Else
					GUICtrlSetState($lbPartyCount, $GUI_DISABLE)
					GUICtrlSetState($inPartyCount, $GUI_DISABLE)
				EndIf
			Else
				GUICtrlSetState($cbRebuff, $GUI_DISABLE)
				GUICtrlSetState($lbPartyCount, $GUI_DISABLE)
				GUICtrlSetState($inPartyCount, $GUI_DISABLE)
			EndIf

		Case $CharNumberCombo
			Local $aCharNumber = GUICtrlRead($CharNumberCombo)
			$cCharNumber = Int($aCharNumber)

		Case $AccPasswordInput
			Local $aAccPass = GUICtrlRead($AccPasswordInput)
			$cPassword = $aAccPass

		Case $cbAlcohol
			Local $acbAlcohol = GUICtrlRead($cbAlcohol)
			If $acbAlcohol == $GUI_CHECKED Then $cnAlcohol = 1
			If $acbAlcohol == $GUI_UNCHECKED Then $cnAlcohol = 0

		Case $cbDecline
			Local $acbDecline = GUICtrlRead($cbDecline)
			If $acbDecline == $GUI_CHECKED Then $cnDecline = 1
			If $acbDecline == $GUI_UNCHECKED Then $cnDecline = 0

		Case $cbHeal
			Local $acbHeal = GUICtrlRead($cbHeal)
			If $acbHeal == $GUI_CHECKED Then
				$cnHeal = 1
				GUICtrlSetState($lbHealthLowLevel, $GUI_ENABLE)
				GUICtrlSetState($inHealthLowLevel, $GUI_ENABLE)
			Else
				$cnHeal = 0
				GUICtrlSetState($lbHealthLowLevel, $GUI_DISABLE)
				GUICtrlSetState($inHealthLowLevel, $GUI_DISABLE)
			EndIf

		Case $cbCoordsChange
			Local $acbCoordsChange = GUICtrlRead($cbCoordsChange)
			If $acbCoordsChange == $GUI_CHECKED Then $cnCoordsChanged = 1
			If $acbCoordsChange == $GUI_UNCHECKED Then $cnCoordsChanged = 0

		Case $cbMana
			Local $acbMana = GUICtrlRead($cbMana)
			If $acbMana == $GUI_CHECKED Then
				$cnMana = 1
				GUICtrlSetState($lbManaLowLevel, $GUI_ENABLE)
				GUICtrlSetState($inManaLowLevel, $GUI_ENABLE)
			Else
				$cnMana = 0
				GUICtrlSetState($lbManaLowLevel, $GUI_DISABLE)
				GUICtrlSetState($inManaLowLevel, $GUI_DISABLE)
			EndIf

		Case $cbSwitchSkills
			Local $acbSwitchSkills = GUICtrlRead($cbSwitchSkills)
			If $acbSwitchSkills == $GUI_CHECKED Then
				$cnSwitchSkill = 1
				GUICtrlSetState($lbMainSkillDur, $GUI_ENABLE)
				GUICtrlSetState($inMainSkillDur, $GUI_ENABLE)
				GUICtrlSetState($lbSecondarySkillDur, $GUI_ENABLE)
				GUICtrlSetState($inSecondarySkillDur, $GUI_ENABLE)
			Else
				$cnSwitchSkill = 0
				GUICtrlSetState($lbMainSkillDur, $GUI_DISABLE)
				GUICtrlSetState($inMainSkillDur, $GUI_DISABLE)
				GUICtrlSetState($lbSecondarySkillDur, $GUI_DISABLE)
				GUICtrlSetState($inSecondarySkillDur, $GUI_DISABLE)
			EndIf

		Case $cbLoot
			Local $acbLoot = GUICtrlRead($cbLoot)
			If $acbLoot == $GUI_CHECKED Then
				$cnLoot = 1
				GUICtrlSetState($lbLootDur, $GUI_ENABLE)
				GUICtrlSetState($inLootDur, $GUI_ENABLE)
			Else
				$cnLoot = 0
				GUICtrlSetState($lbLootDur, $GUI_DISABLE)
				GUICtrlSetState($inLootDur, $GUI_DISABLE)
			EndIf

		Case $cbTurn
			Local $acbTurn = GUICtrlRead($cbTurn)
			If $acbTurn == $GUI_CHECKED Then $cnTurn = 1
			If $acbTurn == $GUI_UNCHECKED Then $cnTurn = 0

		Case $cbAutoSkill
			Local $acbAutoSkill = GUICtrlRead($cbAutoSkill)
			If $acbAutoSkill == $GUI_CHECKED Then $cnAutoSkill = 1
			If $acbAutoSkill == $GUI_UNCHECKED Then $cnAutoSkill = 0

		Case $cbComeBack
			Local $acbComeBack = GUICtrlRead($cbComeBack)
			If $acbComeBack == $GUI_CHECKED Then
				$cnComeBack = 1
				GUICtrlSetState($lbComeBackDur, $GUI_ENABLE)
				GUICtrlSetState($inComeBackDur, $GUI_ENABLE)
				GUICtrlSetState($cbNeedMove, $GUI_ENABLE)
			Else
				$cnComeBack = 0
				GUICtrlSetState($lbComeBackDur, $GUI_DISABLE)
				GUICtrlSetState($inComeBackDur, $GUI_DISABLE)
				GUICtrlSetState($cbNeedMove, $GUI_DISABLE)
			EndIf

		Case $cbNeedMove
			Local $acbNeedMove = GUICtrlRead($cbNeedMove)
			If $acbNeedMove == $GUI_CHECKED Then $cnMove = 1
			If $acbNeedMove == $GUI_UNCHECKED Then $cnMove = 0

		Case $cbManashield
			Local $acbManashield = GUICtrlRead($cbManashield)
			If $acbManashield == $GUI_CHECKED Then $cnManashield = 1
			If $acbManashield == $GUI_UNCHECKED Then $cnManashield = 0

		Case $cbRebuff
			Local $acbRebuff = GUICtrlRead($cbRebuff)
			If $acbRebuff == $GUI_CHECKED Then
				$cnRebuff = 1
				GUICtrlSetState($lbPartyCount, $GUI_ENABLE)
				GUICtrlSetState($inPartyCount, $GUI_ENABLE)
			Else
				$cnRebuff = 0
				GUICtrlSetState($lbPartyCount, $GUI_DISABLE)
				GUICtrlSetState($inPartyCount, $GUI_DISABLE)
			EndIf

		Case $inIdleDuration
			Local $ainIdleDuration = GUICtrlRead($inIdleDuration)
			$cIdleDuration = Int($ainIdleDuration)

		Case $inMainSkillDur
			Local $ainMainSkillDur = GUICtrlRead($inMainSkillDur)
			$cMainSkillDuration = Int($ainMainSkillDur)

		Case $inSecondarySkillDur
			Local $ainSecondarySkillDur = GUICtrlRead($inSecondarySkillDur)
			$cSecondarySkillDuration = Int($ainSecondarySkillDur)

		Case $inLootDur
			Local $ainLootDur = GUICtrlRead($inLootDur)
			$cLootIdleDuration = Int($ainLootDur)

		Case $inComeBackDur
			Local $ainComeBackDur = GUICtrlRead($inComeBackDur)
			$cComeBackDuration = Int($ainComeBackDur)

		Case $inHealthLowLevel
			Local $ainHealthLowLevel = GUICtrlRead($inHealthLowLevel)
			$cHealthLowLevel = Int($ainHealthLowLevel)

		Case $inManaLowLevel
			Local $ainManaLowLevel = GUICtrlRead($inManaLowLevel)
			$cManaLowLevel = Int($ainManaLowLevel)

		Case $inPartyCount
			Local $ainPartyCount = GUICtrlRead($inPartyCount)
			$crCount = Int($ainPartyCount)

		Case $coLocation
			$cLocation = GUICtrlRead($coLocation)

		Case $coServerNum
			Local $ainServerNum = GUICtrlRead($coServerNum)
			$cServerNum = Int($ainServerNum)

	EndSwitch
EndFunc

Func MyGUIHideShow()
	If $GuiShown Then
		GUISetState(@SW_HIDE)
	Else
		GUISetState(@SW_SHOW)
	EndIf
	$GuiShown = Not $GuiShown
EndFunc

Func MyGUICreate()
#Region ### GUI ###
	Dim $BotMain = GUICreate("MU Online B0t v0.01a (by DudEeer)", 623, 449, 192, 132)

	Dim $CommonConfigGroup = GUICtrlCreateGroup("����� ���������", 10, 10, 225, 105)
	Dim $CharTypeLabel = GUICtrlCreateLabel("���", 25, 35, 23, 17)
	GUICtrlSetTip(-1, "��� ��������� (��������� ����������� �����������)")
	$CharNumberLabel = GUICtrlCreateLabel("�����", 25, 60, 38, 17)
	GUICtrlSetTip(-1, "����� ��������� �� ������ ������ (����� ������� �� 1 �� 5)")

	$CharTypeCombo = GUICtrlCreateCombo("", 70, 30, 152, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	Local $aCharType = 'Soul Master'
	Switch $cCharType
		Case $cctSM
			$aCharType = 'Soul Master'
		Case $cctDW
			$aCharType = 'Dark Wizzard'
		Case $cctMG
			$aCharType = 'Magic Gladiator'
		Case $cctDK
			$aCharType = 'Dark Warrior'
		Case $cctBK
			$aCharType = 'Blade Knight'
		Case $cctME
			$aCharType = 'Muse Elf'
		Case $cctElf
			$aCharType = 'Elf'
	EndSwitch
	GUICtrlSetData(-1, "Soul Master|Magic Gladiator|Dark Wizzard|Dark Warrior|Blade Knight|Muse Elf|Elf", $aCharType)
	GUICtrlSetTip(-1, "��� ��������� (��������� ����������� �����������)")

	$CharNumberCombo = GUICtrlCreateCombo("", 70, 55, 152, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "1|2|3|4|5", String($cCharNumber))
	GUICtrlSetTip(-1, "����� ��������� �� ������ ������ (����� ������� �� 1 �� 5)")

	Dim $AccPasswordLabel = GUICtrlCreateLabel("������", 25, 85, 42, 17)
	GUICtrlSetTip(-1, "������ �� �������� (��� ����������)")
	$AccPasswordInput = GUICtrlCreateInput($cPassword, 70, 80, 152, 21)
	GUICtrlSetTip(-1, "������ �� �������� (��� ����������)")

	Dim $FlagsGroup = GUICtrlCreateGroup("���������� ��������� ����", 10, 128, 225, 305)
	$cbAlcohol = GUICtrlCreateCheckbox("���� ��������", 25, 153, 97, 17)
	If $cnAlcohol Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ��������, �� ��� ����� ������������ �������� ������ ����� ��������")

	$cbDecline = GUICtrlCreateCheckbox("��������� �������", 25, 191, 129, 17)
	If $cnDecline Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ��������, �� ����� /re off")

	$cbHeal = GUICtrlCreateCheckbox("��������", 25, 210, 97, 17)
	If $cnHeal Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� �������� �� ��� ����������� ������ �������� ��� ����� ��������")

	$cbCoordsChange = GUICtrlCreateCheckbox("����� ��� ��������� ���������", 25, 172, 193, 17)
	If $cnCoordsChanged Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ���������� ����� �������� - ����� ���� ����� (�������� ���� ������� ��� ������� - ����� ����������� ��������)")

	$cbMana = GUICtrlCreateCheckbox("���� ����", 25, 229, 97, 17)
	If $cnMana Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� �������� �� ��� ����������� ������ ���� ��� ����� ���� ����")

	$cbSwitchSkills = GUICtrlCreateCheckbox("������ ������", 25, 248, 97, 17)
	If $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� �������� �� ��� �� ��������� ���� ��������")

	$cbLoot = GUICtrlCreateCheckbox("������", 25, 268, 97, 17)
	If $cnLoot Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ��������, �� ��� ������ ����")

	$cbTurn = GUICtrlCreateCheckbox("��������������", 25, 287, 113, 17)
	If $cnTurn Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ��������, �� ����� ������� ���� �� �����")

	$cbAutoSkill = GUICtrlCreateCheckbox("�������� ������", 25, 306, 113, 17)
	If $cnAutoSkill Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� �������� - �������� ������� �����")

	$cbComeBack = GUICtrlCreateCheckbox("������������", 25, 325, 97, 17)
	If $cnComeBack Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ���������� ����������, �� ����������� ���������")

	$cbNeedMove = GUICtrlCreateCheckbox("���� /move", 25, 344, 97, 17)
	If Not $cnComeBack Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $cnMove Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ����� /move ����� ��� ��� ������������")

	$cbManashield = GUICtrlCreateCheckbox("��������", 25, 363, 97, 17)
	If Not (($cCharType == $cctDW) Or ($cCharType == $cctSM)) Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $cnManashield Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ����� ��������� ��������")

	$cbRebuff = GUICtrlCreateCheckbox("�����", 25, 382, 97, 17)
	If Not (($cCharType == $cctElf) Or ($cCharType == $cctME)) Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $cnRebuff Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "���� ����� �������� ������")

	$AdvancedConfigGroup = GUICtrlCreateGroup("�������������� ���������", 240, 128, 305, 305)
	$lbIdleDuration = GUICtrlCreateLabel("����� �������", 255, 153, 81, 17)
	GUICtrlSetTip(-1, "����� � ����� �������� - ��� ������, ��� ������ �������� �� ����")
	$inIdleDuration = GUICtrlCreateInput("500", 408, 148, 121, 21)
	GUICtrlSetTip(-1, "����� � ����� �������� - ��� ������, ��� ������ �������� �� ����")
	$inMainSkillDur = GUICtrlCreateInput("20", 408, 173, 121, 21)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "���������� �������� � ������� ������� ��������� ������ �����")
	$inSecondarySkillDur = GUICtrlCreateInput("2", 408, 198, 121, 21)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "���������� �������� � ������� ������� ��������� ������ �����")
	$lbMainSkillDur = GUICtrlCreateLabel("�������� ��������� ������", 255, 178, 148, 17)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "���������� �������� � ������� ������� ��������� ������ �����")
	$lbSecondarySkillDur = GUICtrlCreateLabel("�������� ������� ������", 255, 203, 135, 17)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "���������� �������� � ������� ������� ��������� ������ �����")
	$lbLootDur = GUICtrlCreateLabel("�������� �� ����", 255, 228, 93, 17)
	If Not $cnLoot Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "������� �������� � ��������� ����� ��������")
	$inLootDur = GUICtrlCreateInput("1", 408, 223, 121, 21)
	If Not $cnLoot Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "������� �������� � ��������� ����� ��������")
	$lbComeBackDur = GUICtrlCreateLabel("�������� �� �����������", 255, 253, 140, 17)
	If Not $cnComeBack Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "������� �������� �� �������� ���������")
	$inComeBackDur = GUICtrlCreateInput("5", 408, 248, 121, 21)
	If Not $cnComeBack Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "������� �������� �� �������� ���������")
	$lbHealthLowLevel = GUICtrlCreateLabel("����������� ������� ��", 255, 278, 131, 17)
	If Not $cnHeal Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "��� ����� �������� �������� ���� ��")
	$inHealthLowLevel = GUICtrlCreateInput("75", 408, 273, 121, 21)
	If Not $cnHeal Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "��� ����� �������� �������� ���� ��")
	$lbManaLowLevel = GUICtrlCreateLabel("����������� ������� ����", 255, 303, 144, 17)
	If Not $cnMana Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "��� ����� �������� ���� ���� ����")
	$inManaLowLevel = GUICtrlCreateInput("2", 408, 298, 121, 21)
	If Not $cnMana Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "��� ����� �������� ���� ���� ����")

	$lbPartyCount = GUICtrlCreateLabel("����� � ������", 255, 328, 84, 17)
	If (Not $cnRebuff) Or (Not (($cCharType == $cctElf) Or ($cCharType == $cctME))) Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "����� ���������� ����� ����� ��������")
	$inPartyCount = GUICtrlCreateInput(String($crCount), 408, 323, 121, 21)
	If (Not $cnRebuff) Or (Not (($cCharType == $cctElf) Or ($cCharType == $cctME))) Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "����� ���������� ����� ����� ��������")

	$lbLocation = GUICtrlCreateLabel("��� �������", 255, 353, 71, 17)
	GUICtrlSetTip(-1, "��� ����� ������ � ������������")
	$coLocation = GUICtrlCreateCombo("", 408, 348, 121, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "Lorencia|Dungeon|Davias|Noria|Lost Tower|Arena|Atlans|Tarkan|Davil Square|Icarus|Blood Castle|Chaos Castle|Kalima|CryWolf|Aida|Kantru|Kantru 1|Kantru Event|Illusion Tample|Elbeland|Raclion|Raclion Event|Vulcano|Duel Arena", String($cLocation))

    $lbServerNum = GUICtrlCreateLabel("����� �������", 255, 378, 83, 17)
	GUICtrlSetTip(-1, "��� ����������")
	$coServerNum = GUICtrlCreateCombo("", 408, 373, 121, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "1|2|3|4|5|6|7|8|9|10", String($cServerNum))
#EndRegion ### END Koda GUI section ###
;~ Dim Const $crCount       = 2 ; ������� ������� � ���� ��������, ���� 0 - �� �������� ����
EndFunc
#include "muBotCommon.au3"
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
HotKeySet("{ESC}", "Terminate")
HotKeySet("{TAB}", "PauseUnpause")
HotKeySet("{F5}", "MyGUIHideShow")

;
; Общие настроечные константы
;
Dim Const $cConfigFileName   = "BotConfig.ini"
Dim Const $cAlcoholDuration    = 75 ; Столько итераций действует алкоголь
Dim Const $cManashieldDuration = 40 ; Столько итераций действует манашилд
Dim Const $cBuffDuration       = 19 ; Столько итераций действует баф

Dim $cCharType   ; Задаём тип нашего персонажа
Dim $cCharNumber ; Номер нашего персонажа на экране выбора
Dim $cPassword   ; Пароль к акку

Dim $cLocation               ; Имя локации где мы сейчас
Dim $cIdleDuration           ; Длина паузы в конце итерации
Dim $cMainSkillDuration      ; Столько итераций держится основной скилл
Dim $cSecondarySkillDuration ; Столько итераций держится второстепенный скилл

Dim $cLootIdleDuration ; Столько итераций не исчем полезный шмот
Dim $cComeBackDuration ; Столько итераций не возвращаемся
Dim $cHealthLowLevel   ; В % - уровень ниже которого - пьём хп
Dim $cManaLowLevel     ; В % - уровень ниже которого - пьём ману
; Флаги
Dim $cnAlcohol       ; Пьём ли алкоголь
Dim $cnCoordsChanged ; Реагируем ли на изменение координат
Dim $cnDecline       ; Отклоняем ли запросы
Dim $cnHeal          ; Лечимся ли
Dim $cnMana          ; Пьём ли ману
Dim $cnSwitchSkill   ; Переключаем ли скилл
Dim $cnLoot          ; Лутаем
Dim $cnTurn          ; Поворачиваемся ли
Dim $cnF10           ; надо ли жать F10 чтобы автоскилл
Dim $cnComeBack      ; возвращаемся ли на свою позицию
Dim $cnMove          ; нужно ли делать /move

; Для DW / SM
Dim $cnManashield ; Кастуем ли манашилд
; Для Elf
Dim $cnRebuff ; Ребафаемся ли
Dim $crCount  ; Сколько человек в пати ребафаем, если 0 - то ребафаем себя

;
; Внутренние константы
;
; Индексы массива счётчиков
Dim Const $ccFirst       = 0 ;
Dim Const $ccAlcohol     = 0 ;
Dim Const $ccManaShield  = 1 ;
Dim Const $ccRebuff      = 2 ;
Dim Const $ccSwitchSkill = 3 ;
Dim Const $ccTurn        = 4 ;
Dim Const $ccLoot        = 5 ;
Dim Const $ccComeBack    = 6 ;
Dim Const $ccLast        = 6 ;

; Переменные
Dim $HealthLevel    = 100
Dim $ManaLevel      = 100
Dim $Iteration      = 0
Dim $CoordsChecksum = PixelChecksum(15, 740, 89, 755)
Dim $Paused = True
Dim $GuiShown = False
Dim $Counters[$ccLast + 1] = [0, 0, 0, 0, 0, 0, 0]
Dim $LootCoords[2] = [0, 0]
Dim $SearchRect[4] = [100, 100, 900, 550]
Dim $LootTry = 0

WinActivate($cMuHeader)
$CoordsBefore = GetCurrentPos()
Dim $CoordsAfter = $CoordsBefore

; Переменные GUI
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

Dim $inIdleDuration
Dim $inMainSkillDur
Dim $inSecondarySkillDur
Dim $inLootDur
Dim $inComeBackDur
Dim $inHealthLowLevel
Dim $inManaLowLevel
Dim $inPartyCount
Dim $coLocation

MyLoadConfig()
MyGUICreate()
;===============================================================
; Действия
;===============================================================
Func DoComeBack()
	If $cnF10 == 1 Then Send("{F10}")
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
	If $cnF10 == 1 Then Send("{F10}")
EndFunc

Func DoHeal()
	If $cCharType == $cctElf Then
		DoHealBuff(1)
	Else
		DrinkHealthPoition()
	EndIf
EndFunc

; Лутаем
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
EndFunc

; Крутим мышь по кругу
Func DoTurn()
	If $Counters[$ccTurn] == 8 Then
		$Counters[$ccTurn] = 1
	Else
		$Counters[$ccTurn] += 1
	EndIf
	DoMouseRoundMove($Counters[$ccTurn])
EndFunc

; Переподключаемся
Func DoReconnect()
	TakeSnapshot()
	Reconnect($cPassword, $cCharNumber)
	CenterMouse()
EndFunc
;===============================================================

;===============================================================
; Проверки
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

; Проверяем не надо ли слутить
Func NeedLoot()
;~ 	Local $BenchTimer = TimerInit()
	Const $LootColors[5] = [$calJewelTextColor, $calBlueTextColor, $calGrayTextColor, $calWhiteTextColor, $calOrangeTextColor]
;~ 	Const $LootWords[4] = ["Jewel", "Heart", "Feather", "Healing"]
	Const $LootWords[1] = ["Jewel"]
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

; Проверяем нужно ли переподключиться
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

; Проверяем надо ли крутиться
Func NeedTurn()
	If $cnTurn == 0 Then Return False
	Return ($cCharType == $cctElf) Or ($cCharType == $cctME) Or ($cCharType == $cctDK) Or ($cCharType == $cctBK) Or ($cCharType == $cctMG)
EndFunc

; Проверяем не поменялись ли координаты
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

; Проверяем не надо ли отменить запрос на пати
Func NeedDeclineRequest()
	If $cnDecline == 0 Then Return False
	Return (PixelChecksum(407, 131, 616, 146) = 1290891972)
EndFunc

; Проверяем не надо ли нам поменять скилл
Func NeedSwitchSkill()
	If $ActiveSkill == $cMainSkillKey Then
		Return CounterCheck($ccSwitchSkill, $cMainSkillDuration, $cnSwitchSkill)
	Else
		Return CounterCheck($ccSwitchSkill, $cSecondarySkillDuration, $cnSwitchSkill)
	EndIf
EndFunc

; Проверяем не надо ли нам ребафнуться
Func NeedManaShield()
	If ($cCharType <> $cctDW) And ($cCharType <> $cctSM) Then Return False
	Return CounterCheck($ccManaShield, $cManashieldDuration, $cnManashield)
EndFunc

; Проверяем не надо ли нам ребафнуться
Func NeedRebuff()
	Return CounterCheck($ccRebuff, $cBuffDuration, $cnRebuff)
EndFunc

; Проверяем не надо ли нам пить алкоголь
Func NeedAlcohol()
	Return CounterCheck($ccAlcohol, $cAlcoholDuration, $cnAlcohol)
EndFunc

; Проверяем счётчик на равенство значению
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

; Проверяем не надо ли нам пить ману
Func NeedMana()
	If $cnMana == 0 Then Return False
	$ManaLevel = GetManaLevel()
	Return ($ManaLevel <= $cManaLowLevel)
EndFunc

; Проверяем не надо ли нам лечиться
Func NeedHeal()
	If $cnHeal == 0 Then Return False
	$HealthLevel = GetHealthLevel()
	Local $WasDead = False
	Return ($HealthLevel <= $cHealthLowLevel)
EndFunc
;===============================================================

;===============================================================
; Основной цикл бота
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
	MyProcessGUI()
WEnd

; Показываем статистику по персонажу
Func ShowStats()
	ShowToolTip(StringFormat("Health : %3.2f", Round($HealthLevel, 2)) & "%" & @CRLF & StringFormat("Mana   : %3.2f", Round($ManaLevel, 2)) & "%" & @CRLF & StringFormat("LootTry  : %d", $LootTry) & @CRLF & StringFormat("InitCoords : %d %d", $CoordsBefore[0], $CoordsBefore[1]) & @CRLF & StringFormat("CurCoords  : %d %d", $CoordsAfter[0], $CoordsAfter[1]))
EndFunc

; Пауза - анпауза
Func PauseUnpause()
	$CoordsChecksum = PixelChecksum(15, 740, 89, 755)
	$CoordsBefore = GetCurrentPos()
	$Paused = Not $Paused
	SetRequests($Paused)
	If $cnF10 == 1 Then DoKeyPress("F10")
EndFunc

; Выход
Func Terminate()
	If Not $Paused Then PauseUnpause()
	MySaveConfig()
	Exit 0
EndFunc

; Сохранение/загрузка настроек в файл
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
	IniWrite($cConfigFileName, "Main", "nAutoSkill", String($cnF10))
	IniWrite($cConfigFileName, "Main", "nComeBack", String($cnComeBack))
	IniWrite($cConfigFileName, "Main", "nMove", String($cnMove))
	IniWrite($cConfigFileName, "Main", "Location", String($cLocation))
	IniWrite($cConfigFileName, "DW", "nManashield", String($cnManashield))
	IniWrite($cConfigFileName, "Elf", "nRebuff", String($cnRebuff))
	IniWrite($cConfigFileName, "Elf", "PartyCount", String($crCount))
EndFunc

Func MyLoadConfig()
	$cCharType = IniRead($cConfigFileName, "Main", "CharType", $cctDW)
	$cCharNumber = IniRead($cConfigFileName, "Main", "CharNumber", 1)
	$cPassword = IniRead($cConfigFileName, "Main", "Password", "")

	$cIdleDuration = IniRead($cConfigFileName, "Main", "IdleDuration", 500)
	$cMainSkillDuration = IniRead($cConfigFileName, "Main", "$MainSkillDuration", 1)
	$cSecondarySkillDuration = IniRead($cConfigFileName, "Main", "SecondarySkillDuration", 1)

	$cLootIdleDuration = IniRead($cConfigFileName, "Main", "LootIdleDuration", 10)
	$cComeBackDuration = IniRead($cConfigFileName, "Main", "ComeBackDuration", 5)
	$cHealthLowLevel = IniRead($cConfigFileName, "Main", "HealthLowLevel", 75)
	$cManaLowLevel = IniRead($cConfigFileName, "Main", "ManaLowLevel", 50)

	$cnAlcohol = IniRead($cConfigFileName, "Main", "nAlcohol", 0)
	$cnCoordsChanged = IniRead($cConfigFileName, "Main", "nCoordsChanged", 0)
	$cnDecline = IniRead($cConfigFileName, "Main", "nDecline", 0)
	$cnHeal = IniRead($cConfigFileName, "Main", "nHeal", 0)
	$cnMana = IniRead($cConfigFileName, "Main", "nMana", 0)
	$cnSwitchSkill = IniRead($cConfigFileName, "Main", "nSwitchSkill", 0)
	$cnLoot = IniRead($cConfigFileName, "Main", "nLoot", 0)
	$cnTurn = IniRead($cConfigFileName, "Main", "nTurn", 0)
	$cnF10 = IniRead($cConfigFileName, "Main", "nAutoSkill", 0)
	$cnComeBack = IniRead($cConfigFileName, "Main", "nComeBack", 0)
	$cnMove = IniRead($cConfigFileName, "Main", "nMove", 0)
	$cLocation = IniRead($cConfigFileName, "Main", "Location", "")
	$cnManashield = IniRead($cConfigFileName, "DW", "nManashield", 0)
	$cnRebuff = IniRead($cConfigFileName, "Elf", "nRebuff", 0)
	$crCount = IniRead($cConfigFileName, "Elf", "PartyCount", 0)
EndFunc

; GUI
Func MyProcessGUI()
	For $i = 0 To $cIdleDuration Step 1
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
				If $acbAutoSkill == $GUI_CHECKED Then $cnF10 = 1
				If $acbAutoSkill == $GUI_UNCHECKED Then $cnF10 = 0

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
		EndSwitch
		Sleep(1)
	Next
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

	Dim $CommonConfigGroup = GUICtrlCreateGroup("Общие настройки", 10, 10, 225, 105)
	Dim $CharTypeLabel = GUICtrlCreateLabel("Тип", 25, 35, 23, 17)
	GUICtrlSetTip(-1, "Тип персонажа (открывает специфичные особенности)")
	$CharNumberLabel = GUICtrlCreateLabel("Номер", 25, 60, 38, 17)
	GUICtrlSetTip(-1, "Номер персонажа на экране выбора (слева направо от 1 до 5)")

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
	GUICtrlSetTip(-1, "Тип персонажа (открывает специфичные особенности)")

	$CharNumberCombo = GUICtrlCreateCombo("", 70, 55, 152, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "1|2|3|4|5", String($cCharNumber))
	GUICtrlSetTip(-1, "Номер персонажа на экране выбора (слева направо от 1 до 5)")

	Dim $AccPasswordLabel = GUICtrlCreateLabel("Пароль", 25, 85, 42, 17)
	GUICtrlSetTip(-1, "Пароль от аккаунта (для реконнекта)")
	$AccPasswordInput = GUICtrlCreateInput($cPassword, 70, 80, 152, 21)
	GUICtrlSetTip(-1, "Пароль от аккаунта (для реконнекта)")

	Dim $FlagsGroup = GUICtrlCreateGroup("Триггерные настройки бота", 10, 128, 225, 305)
	$cbAlcohol = GUICtrlCreateCheckbox("Пить алкоголь", 25, 153, 97, 17)
	If $cnAlcohol Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если отмечено, то бот будет переодически нажимать кнопку питья алкоголя")

	$cbDecline = GUICtrlCreateCheckbox("Отклонять запросы", 25, 191, 129, 17)
	If $cnDecline Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если включено, то пишем /re off")

	$cbHeal = GUICtrlCreateCheckbox("Лечиться", 25, 210, 97, 17)
	If $cnHeal Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если отмечено то при критическом уровне здоровья бот будет лечиться")

	$cbCoordsChange = GUICtrlCreateCheckbox("Скрин при изменении координат", 25, 172, 193, 17)
	If $cnCoordsChanged Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если координаты будут изменены - будет снят скрин (например если двигают или убивают - можно запечатлеть обидчика)")

	$cbMana = GUICtrlCreateCheckbox("Пить ману", 25, 229, 97, 17)
	If $cnMana Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если отмечено то при критическом уровне маны бот будет пить ману")

	$cbSwitchSkills = GUICtrlCreateCheckbox("Менять скиллы", 25, 248, 97, 17)
	If $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если включено то бот по переменно бьёт скиллами")

	$cbLoot = GUICtrlCreateCheckbox("Лутать", 25, 268, 97, 17)
	If $cnLoot Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если включено, то бот лутает шмот")

	$cbTurn = GUICtrlCreateCheckbox("Поворачиваться", 25, 287, 97, 17)
	If $cnTurn Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если отмечено, то будет двигать мышь по кругу")

	$cbAutoSkill = GUICtrlCreateCheckbox("Включать кликер", 25, 306, 113, 17)
	If $cnF10 Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если отмечено - включает кликкер скила")

	$cbComeBack = GUICtrlCreateCheckbox("Возвращаться", 25, 325, 97, 17)
	If $cnComeBack Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если координаты поменялись, то попробовать вернуться")

	$cbNeedMove = GUICtrlCreateCheckbox("Надо /move", 25, 344, 97, 17)
	If Not $cnComeBack Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $cnMove Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если нужно /move перед тем как возвращаться")

	$cbManashield = GUICtrlCreateCheckbox("Манашилд", 25, 363, 97, 17)
	If Not (($cCharType == $cctDW) Or ($cCharType == $cctSM)) Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $cnManashield Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если нужно кастовать манашилд")

	$cbRebuff = GUICtrlCreateCheckbox("Ребаф", 25, 382, 97, 17)
	If Not (($cCharType == $cctElf) Or ($cCharType == $cctME)) Then GUICtrlSetState(-1, $GUI_DISABLE)
	If $cnRebuff Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetTip(-1, "Если нужно ребафать группу")

	$AdvancedConfigGroup = GUICtrlCreateGroup("Дополнительные настройки", 240, 128, 305, 305)
	$lbIdleDuration = GUICtrlCreateLabel("Время простоя", 255, 153, 81, 17)
	GUICtrlSetTip(-1, "Время в конце итерации - чем больще, тем меньше нагрузка на проц")
	$inIdleDuration = GUICtrlCreateInput("500", 408, 148, 121, 21)
	GUICtrlSetTip(-1, "Время в конце итерации - чем больще, тем меньше нагрузка на проц")
	$inMainSkillDur = GUICtrlCreateInput("20", 408, 173, 121, 21)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Количество итераций в течении которых действует первый скилл")
	$inSecondarySkillDur = GUICtrlCreateInput("2", 408, 198, 121, 21)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Количество итераций в течении которых действует второй скилл")
	$lbMainSkillDur = GUICtrlCreateLabel("Итерации основного скилла", 255, 178, 148, 17)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Количество итераций в течении которых действует первый скилл")
	$lbSecondarySkillDur = GUICtrlCreateLabel("Итерации второго скилла", 255, 203, 135, 17)
	If Not $cnSwitchSkill Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Количество итераций в течении которых действует второй скилл")
	$lbLootDur = GUICtrlCreateLabel("Итерации до лута", 255, 228, 93, 17)
	If Not $cnLoot Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Столько итераций в перерывах между лутанием")
	$inLootDur = GUICtrlCreateInput("1", 408, 223, 121, 21)
	If Not $cnLoot Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Столько итераций в перерывах между лутанием")
	$lbComeBackDur = GUICtrlCreateLabel("Итерации до возвращения", 255, 253, 140, 17)
	If Not $cnComeBack Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Столько итераций не пытаемся вернуться")
	$inComeBackDur = GUICtrlCreateInput("5", 408, 248, 121, 21)
	If Not $cnComeBack Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Столько итераций не пытаемся вернуться")
	$lbHealthLowLevel = GUICtrlCreateLabel("Критический уровень ХП", 255, 278, 131, 17)
	If Not $cnHeal Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "При таком проценте здоровья пьём хп")
	$inHealthLowLevel = GUICtrlCreateInput("75", 408, 273, 121, 21)
	If Not $cnHeal Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "При таком проценте здоровья пьём хп")
	$lbManaLowLevel = GUICtrlCreateLabel("Критический уровень маны", 255, 303, 144, 17)
	If Not $cnMana Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "При таком проценте маны пьём ману")
	$inManaLowLevel = GUICtrlCreateInput("2", 408, 298, 121, 21)
	If Not $cnMana Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "При таком проценте маны пьём ману")

	$lbPartyCount = GUICtrlCreateLabel("Людей в группе", 255, 328, 84, 17)
	If (Not $cnRebuff) Or (Not (($cCharType == $cctElf) Or ($cCharType == $cctME))) Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Такое количество людей будем ребафать")
	$inPartyCount = GUICtrlCreateInput(String($crCount), 408, 323, 121, 21)
	If (Not $cnRebuff) Or (Not (($cCharType == $cctElf) Or ($cCharType == $cctME))) Then GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetTip(-1, "Такое количество людей будем ребафать")

	$lbLocation = GUICtrlCreateLabel("Имя локации", 255, 353, 71, 17)
	GUICtrlSetTip(-1, "Для умной хотьбы и телепортации")
	$coLocation = GUICtrlCreateCombo("", 408, 348, 121, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "Lorencia|Dungeon|Davias|Noria|Lost Tower|Arena|Atlans|Tarkan|Davil Square|Icarus|Blood Castle|Chaos Castle|Kalima|CryWolf|Aida|Kantru|Kantru 1|Kantru Event|Illusion Tample|Elbeland|Raclion|Raclion Event|Vulcano|Duel Arena", "")
#EndRegion ### END Koda GUI section ###
;~ Dim Const $crCount       = 2 ; Сколько человек в пати ребафаем, если 0 - то ребафаем себя
EndFunc
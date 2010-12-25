;-------------------------------------
; Библиотека полезных функций для бота
;-------------------------------------
#include-once
#include <Math.au3>
#include <Color.au3>
#Include <Array.au3>
#Include <String.au3>
#include <Tesseract.au3>
#include <A-Star.au3>
Opt("MouseCoordMode", 2)
Opt("PixelCoordMode", 2)
;
; Константы
;

; Размеры координат
Dim $cCoordPos[2]  = [20, 738]
Dim $cCoordSize[2] = [75, 18]
Dim $cMaxScale = 6
Dim Const $cCoordDeltaDig = 2                  ; ширина между знаками в координатах
Dim Const $cCoordWhiteLevel = 90               ; значение более которого - цвет шрифта
Dim Const $cDeltaLevel = 5

; Положения указателя мыши
Dim $cMCenter[2]  = [512, 335]
Dim $cMDelta 		= 80
Dim $cMCorner     = Int(0.29 * $cMDelta)

; Для хождения
Dim Const $cgtDefaultCurColor   = 0x00FFFFFF ; Цвет дефолтового курсора
Dim $cCursorColorPos[2] = [21, 17]

; Для автолута
Dim Const $calShade             = 5 ; shade-variation для поиска первой точки нужного цвета
Dim Const $calColorDelta        = 5 ; Все различия в цвете меньше данного - не считаем
Dim Const $calJewelTextColor    = 0xFFCE18 ;0xF1CB44 ; Цвет текста надписи джувела
Dim Const $calBlueTextColor 	= 0x62B2FF
Dim Const $calGrayTextColor 	= 0xB4B2B4
Dim Const $calWhiteTextColor 	= 0xFFFFFF
Dim Const $calOrangeTextColor 	= 0xFF7D31
; Синий  -  6468351
; Серый  -  11842228
; Белый  - 0x00FFFFFF
Dim Const $calJewelBackColor    = 0x000000 ; Цвет надписи джувела
Dim Const $calJewelTextColorRGB =  _ColorGetRGB($calJewelTextColor)
Dim Const $calJewelTextSize[2]  = [80, 15] ; Размеры надписи над жувелом
Dim Const $calLikenessMinLevel  = $calJewelTextSize[0] * $calJewelTextSize[1] * 0.65
Dim Const $calLikenessMaxLevel  = $calJewelTextSize[0] * $calJewelTextSize[1] * 0.7

; Бинды
Dim Const $cMainSkillKey      = "1"
Dim Const $cSecondarySkillKey = "2"
Dim Const $cTeleportKey       = "5"
Dim Const $cManaShieldKey     = "4"
Dim Const $cPowerBuffKey      = "3"
Dim Const $cDefenceBuffKey    = "2"
Dim Const $cHealBuffKey       = "4"
Dim Const $cSummonBuffKey     = "5"
Dim Const $cHealthBottleKey   = "Q"
Dim Const $cManaBottleKey     = "W"
Dim Const $cAlcoBottleKey     = "E"
Dim Const $cAutoSkillKey      = "F10"
Dim Const $cLauncherPlay      = "!p"
Dim Const $cLauncherToWindow  = "F12"

; хп
Dim $chbRect[2][2] = [[195, 694], [195, 766]]
Dim Const $chbColors[3]  = [90, 255, 10]
; мана
Dim $cmbRect[2][2] = [[825, 694], [825, 766]]
Dim Const $cmbColors[3]  = [70, 255, 10]
; пати
Dim $crPartyStart[2] = [1000, 20]
Dim $crPartyDeltaY = 35

; Типы персонажей
Dim Const $cctElf = 0
Dim Const $cctME  = 1
Dim Const $cctDW  = 10
Dim Const $cctSM  = 11
Dim Const $cctDK  = 20
Dim Const $cctBK  = 21
Dim Const $cctMG  = 30

; Для реконнекта
Dim $cDisconnectWindowRect[4] = [397, 119, 621, 134]
Dim $cServerSelectPos[2] = [506, 364]
Dim $cSubserverSelectPos[2] = [620, 342]
Dim $cSubServerHeight = 30
Dim $cCharSelectPos[2] = [250, 500]
Dim $cCharSelectWidth = 120

; Для отказа от реквеста
Dim $cRequestCancel[2] = [580, 175]

; Общие
Dim Const $cMuHeader               = '©WakeUp' ; Заголовок окна му
Dim Const $cMuClass                = 'MU' ; Класс окна му
Dim Const $cMuPath                 = "C:\\MU"
Dim Const $cMuLauncherHeader       = 'Losena MuOnline Launcher v0.1.0.6' ; Заголовок окна лончера
Dim Const $cMuLauncherPath         = '' ; Путь к лончеру
Dim Const $cReconnectTryes         = 600 ; Сколько секунд ждём запуска mu
Dim $cMainWndWidth           = 1024
Dim $cMainWndHeight          = 768

Dim Const $cgtWorldsLocs[24][2]  = [["World1", "Lorencia"], ["World2", "Dungeon"], ["World3", "Davias"], ["World4", "Noria"], _
 							 ["World5", "Lost Tower"], ["World7", "Arena"], ["World8", "Atlans"], ["World9", "Tarkan"], _
							 ["World10", "Davil Square"], ["World11", "Icarus"], ["World12", "Blood Castle"], _
							 ["World19", "Chaos Castle"], ["World25", "Kalima"], ["World34", "CryWolf"], _
							 ["World35", "Aida"], ["World38", "Kantru"], ["World39", "Kantru 1"], ["World40", "Kantru Event"], _
							 ["World47", "Illusion Tample"], ["World52", "Elbeland"], ["World58", "Raclion"], _
							 ["World59", "Raclion Event"], ["World64", "Vulcano"], ["World65", "Duel Arena"]]
;
; Функции
;
Dim $ActiveSkill = $cMainSkillKey

;-----------------------------------------------
; Устанавливаем разрешение
; Параметры:
;		$aWidth - ширина прямоугольника надписи
;		$aHeight - высота прямоугольника надписи
Func SetResolution($aWidth = 1024)
	Local $Multiplier = $aWidth / 1024.0

	$cMainWndWidth = $aWidth

	$cMaxScale = Int(5 / $Multiplier)

	$cMainWndHeight = Int(768 * $Multiplier)

	$cCursorColorPos[0] = Int(21 * $Multiplier)
	$cCursorColorPos[1] = Int(17 * $Multiplier)

	$cCoordPos[0] = Int(20 * $Multiplier)
	$cCoordPos[1] = Int(738 * $Multiplier)

	$cCoordSize[0] = Int(74 * $Multiplier)
	$cCoordSize[1] = Int(17 * $Multiplier)

	$cMCenter[0] = Int(512 * $Multiplier)
	$cMCenter[1] = Int(335 * $Multiplier)

	$chbRect[0][0] = Int(195 * $Multiplier)
	$chbRect[0][1] = Int(694.0 * $Multiplier)
	$chbRect[1][0] = Int(195 * $Multiplier)
	$chbRect[1][1] = Int(766 * $Multiplier)

	$cmbRect[0][0] = Int(825 * $Multiplier)
	$cmbRect[0][1] = Int(694.0 * $Multiplier)
	$cmbRect[1][0] = Int(825 * $Multiplier)
	$cmbRect[1][1] = Int(766 * $Multiplier)

	$crPartyStart[0] = Int(1000 * $Multiplier)
	$crPartyStart[1] = Int(20 * $Multiplier)

	$cMDelta  = Int(80 * $Multiplier)
	$cMCorner = -Int(0.29 * $cMDelta)

	$cServerSelectPos[0] = Int(506 * $Multiplier)
	$cServerSelectPos[1] = Int(364 * $Multiplier)

	$cSubserverSelectPos[0] = Int(620 * $Multiplier)
	$cSubserverSelectPos[1] = Int(342 * $Multiplier)

	$cSubServerHeight = Int(30 * $Multiplier)

	$cCharSelectPos[0] = Int(250 * $Multiplier)
	$cCharSelectPos[1] = Int(500 * $Multiplier)

	$cCharSelectWidth = Int(120 * $Multiplier)

	$cRequestCancel[0] = Int(580 * $Multiplier)
	$cRequestCancel[1] = Int(175 * $Multiplier)

	$cDisconnectWindowRect[0] = Int(397 * $Multiplier)
	$cDisconnectWindowRect[1] = Int(119 * $Multiplier)
	$cDisconnectWindowRect[2] = Int(621 * $Multiplier)
	$cDisconnectWindowRect[3] = Int(134 * $Multiplier)

	$crPartyDeltaY = Int(35 * $Multiplier)
EndFunc

;-----------------------------------------------
; Ищем джувелы в заданном прямоугольнике
; Параметры:
;		$aSearchRect - в каком прямоугольнике ищем
;		$aWhatWidth - ширина прямоугольника надписи
;		$aWhatHeight - высота прямоугольника надписи
;		$aFirstPixelColor - какого цвета ищем
;		$aRetCoord - выходной параметр - координаты для лута
;		$aLootText - текст который ищем
;		$aScale - точность поиска
; Возвращаемое значение - логическое - если True, то нашли

;-----------------------------------------------
Func FindLootInRect(ByRef $aSearchRect, $aWhatWidth, $aWhatHeight, $aFirstPixelColor, ByRef $aRetCoord, $aLootText, $aDontLootText, $aScale = 3)
	Local $coord = PixelSearch($aSearchRect[0], $aSearchRect[1], $aSearchRect[2], $aSearchRect[3], $aFirstPixelColor, $calShade)
	If Not @error Then
		Local $GoodPoint = False
		For $aI = -1 To 1 Step 1
			For $aJ = -1 To 1 Step 1
				Local $tempRoundColor = _ColorGetRGB(PixelGetColor($coord[0] + $aI, $coord[1] + $aJ))
				Local $tempJewelBackColor = _ColorGetRGB($tempRoundColor)
				If _Max(_Max(Abs($tempRoundColor[0] - $tempJewelBackColor[0]), Abs($tempRoundColor[1] - $tempJewelBackColor[1])), Abs($tempRoundColor[2] - $tempJewelBackColor[2])) <= $calColorDelta Then
					$GoodPoint = True
					ExitLoop
				EndIf
			Next
		Next
		Local $ocrLootPos = 0
		If $GoodPoint Then
			$coord[0] -= 4
			$coord[1] -= 4
;~ 			Local $ocrText = _TesseractWinCapture($cMuHeader, "",  0, "", 1, $aScale, $coord[0], $coord[1], $cMainWndWidth - $coord[0] - $aWhatWidth, $cMainWndHeight - $coord[1] - $aWhatHeight, 0)
;~ 			ShowToolTip($ocrText)
;~ 			Sleep(2000)
;~ 			MouseMove($coord[0], $coord[1], 0)
;~ 			Local $ocrLootPos = _TesseractWinFind($cMuHeader, "", $aLootText, 1, 0, "", 1, $aScale, $coord[0], $coord[1], $cMainWndWidth - $coord[0] - $aWhatWidth, $cMainWndHeight - $coord[1] - $aWhatHeight, 0)
			Local $ocrLootPos = 0
			For $i = 0 To UBound($aLootText) - 1 Step 1
				If $i == 0 Then
					$ocrLootPos = _TesseractWinFind($cMuHeader, "", $aLootText[$i], 1, 0, "", 1, $aScale, $coord[0], $coord[1], $cMainWndWidth - $coord[0] - $aWhatWidth, $cMainWndHeight - $coord[1] - $aWhatHeight, 0)
				Else
					$ocrLootPos = _TesseractWinFind($cMuHeader, "", $aLootText[$i], 1, 1, "", 1, $aScale, $coord[0], $coord[1], $cMainWndWidth - $coord[0] - $aWhatWidth, $cMainWndHeight - $coord[1] - $aWhatHeight, 0)
				EndIf
				$ocrDontLootPos = 0
				If $ocrLootPos <> 0 Then
					For $i = 0 To UBound($aDontLootText) - 1 Step 1
						$ocrDontLootPos = _TesseractWinFind($cMuHeader, "", $aDontLootText[$i], 1, 1, "", 1, $aScale, $coord[0], $coord[1], $cMainWndWidth - $coord[0] - $aWhatWidth, $cMainWndHeight - $coord[1] - $aWhatHeight, 0)
						if $ocrDontLootPos <> 0 Then ExitLoop
					Next
					if $ocrDontLootPos == 0 Then ExitLoop
				EndIf
			Next
		EndIf
		If ($ocrLootPos  <> 0) Then
			$aRetCoord = $coord
			Return True
		Else
			If (($coord[0] - 1) >= $aSearchRect[0]) And ($coord[1] <= $aSearchRect[3]) Then
				Dim $LeftTopSearchRect[4] = [$aSearchRect[0], $aSearchRect[1], $coord[0] - 1, $coord[1]]
				If FindLootInRect($LeftTopSearchRect, $aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf

			If ($coord[0] <= $aSearchRect[2]) And (($coord[1] + 1) <= $aSearchRect[3]) Then
				Dim $LeftBottomSearchRect[4] = [$aSearchRect[0], $coord[1] + $aWhatHeight + 1, $coord[0], $aSearchRect[3]]
				If FindLootInRect($LeftBottomSearchRect, $aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf

			If ($coord[0] <= $aSearchRect[2]) And (($coord[1] - 1) >= $aSearchRect[1])Then
				Dim $RightTopSearchRect[4] = [$coord[0] + $aWhatWidth, $aSearchRect[1], $aSearchRect[2], $coord[1] - 1]
				If FindLootInRect($RightTopSearchRect, $aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf

			If (($coord[0] + 1) <= $aSearchRect[2]) And (($coord[1] - 1) <= $aSearchRect[3]) Then
				Dim $RightBottomSearchRect[4] = [$coord[0] + $aWhatWidth + 1, $coord[1] + $aWhatHeight, $aSearchRect[2], $aSearchRect[3]]
				If FindLootInRect($RightBottomSearchRect,$aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf
		EndIf
	EndIf
	Return False
EndFunc

;-----------------------------------------------
; Получение текущих координат персонажа
; Параметры:
; Возвращаемое значение - массив из 2 элементов,
;   Y X координаты соответственно
;-----------------------------------------------
Func GetCurrentPos()
;~ 	Более аккуратный метод, но в тоже время более медленный - так как использует tesseract
 	Local $CurPos[2] = [-1, -1]
	Local $TempCoords = ""
	For $CurScale = $cMaxScale To 1 Step -1
		$TempCoords = _TesseractWinCapture($cMuHeader, "", 0, "", 1, $CurScale, $cCoordPos[0], $cCoordPos[1], $cMainWndWidth - $cCoordPos[0] - $cCoordSize[0], $cMainWndHeight - $cCoordPos[1] - $cCoordSize[1], 0, $cCoordWhiteLevel)
		$TempCoords = StringReplace($TempCoords, "|", "1")
		$TempCoords = StringReplace($TempCoords, "?", "7")
		$TempCoords = StringReplace($TempCoords, @CRLF, "")
;~ 		ConsoleWrite(@CRLF & "Coords RAW : " & $TempCoords & " @Scale " & $CurScale)
		If StringRegExp($TempCoords, "[^0-9 ]", 0) == 0 Then
			Local $TempCurPos = StringSplit($TempCoords, " ")
			If Int($TempCurPos[0]) = 2 Then
				$CurPos[0] = $TempCurPos[1]
				$CurPos[1] = $TempCurPos[2]
				ExitLoop
			EndIf
		EndIf
	Next
	Return $CurPos
EndFunc

;-----------------------------------------------
; Получение текущего уровня по столбику (орбу)
; Параметры:
;		$aOrbColor - набор ограничителей цветов
;		$aOrbRect - область орба
;		$aChannel - какой канал сравниваем
; Возвращаемое значение - уровень в %
;-----------------------------------------------
Func GetOrbLevel($aOrbColor, $aOrbRect, $aChannel = 0)
	Local $OrbHeigth = $aOrbRect[1][1] - $aOrbRect[0][1] + 1
	Local $Colors[$OrbHeigth]
	Local $BadColors = 0
	Local $DeltaColor = 0
	Local $DeltaOtherColor = 0
	For $aY = $aOrbRect[0][1] To $aOrbRect[1][1] Step 1
		$Colors[$aY - $aOrbRect[0][1]] = PixelGetColor($aOrbRect[0][0], $aY)
	Next
	For $aY = 0 To $OrbHeigth - 1 Step 1
		Switch $aChannel
			Case -1
				$DeltaColor = _Max(_Max(_ColorGetRed($Colors[$aY]), _ColorGetGreen($Colors[$aY])) , _ColorGetBlue($Colors[$aY]))
				$DeltaOtherColor = $aOrbColor[2]
			Case 1
				$DeltaColor = _ColorGetRed($Colors[$aY])
				$DeltaOtherColor = _Max(_ColorGetBlue($Colors[$aY]), _ColorGetGreen($Colors[$aY]))
			Case 2
				$DeltaColor = _ColorGetGreen($Colors[$aY])
				$DeltaOtherColor = _Max(_ColorGetRed($Colors[$aY]), _ColorGetBlue($Colors[$aY]))
			Case 4
				$DeltaColor = _ColorGetBlue($Colors[$aY])
				$DeltaOtherColor = _Max(_ColorGetRed($Colors[$aY]), _ColorGetGreen($Colors[$aY]))
			Case 3
				$DeltaColor = _Max(_ColorGetRed($Colors[$aY]), _ColorGetGreen($Colors[$aY]))
				$DeltaOtherColor = _ColorGetBlue($Colors[$aY])

		EndSwitch
		If (($DeltaColor < $aOrbColor[0]) or ($DeltaColor > $aOrbColor[1])) or ($DeltaOtherColor > $aOrbColor[2]) Then $BadColors += 1
	Next
	Return ((1 - ($BadColors / $OrbHeigth)) * 100)
EndFunc

;-----------------------------------------------
; Получение текущего уровня хп
; Возвращаемое значение - % хп
;-----------------------------------------------
Func GetHealthLevel()
	Return GetOrbLevel($chbColors, $chbRect, 3)
EndFunc

Func isDead()
	Return GetHealthLevel() < 5
EndFunc
;-----------------------------------------------
; Получение текущего уровня маны
; Возвращаемое значение - % маны
;-----------------------------------------------
Func GetManaLevel()
	Return GetOrbLevel($cmbColors, $cmbRect, 4)
EndFunc

;-----------------------------------------------
; Центрируем указатель мыши на персонаже
;-----------------------------------------------
Func CenterMouse($aDX = 0, $aDY = 0)
	MouseMove($cMCenter[0] + $aDX, $cMCenter[1] + $aDY, 0)
EndFunc

;-----------------------------------------------
; Клик левой кнопкой мыши
;-----------------------------------------------
Func DoMainClick($aIdleTime = 200)
	MouseDown("left")
	Sleep($aIdleTime)
	MouseUp("left")
EndFunc

;-----------------------------------------------
; Клик правой кнопкой мыши
;-----------------------------------------------
Func DoSecondaryClick()
	MouseDown("right")
	Sleep(200)
	MouseUp("right")
EndFunc

;-----------------------------------------------
; Нажатие кнопки на клавиатуре
; Параметры:
; $aKey - Кнопка - строка
;-----------------------------------------------
Func DoKeyPress($aKey)
	Send("{" & $aKey & " down}")
	Sleep(200)
	Send("{" & $aKey & " up}")
	Sleep(200)
EndFunc

;-----------------------------------------------
; Кастует скилл
; Параметры:
; $aSkillKey - Кнопка скилла - строка
;-----------------------------------------------
Func DoSkill($aSkillKey)
	DoKeyPress($aSkillKey)
	DoSecondaryClick()
	DoKeyPress($ActiveSkill)
EndFunc

;-----------------------------------------------
; Меняем скилл на запасной или обратно
;-----------------------------------------------
Func SwitchSkills()
	If $ActiveSkill == $cMainSkillKey Then
		$ActiveSkill = $cSecondarySkillKey
		DoKeyPress($cSecondarySkillKey)
	Else
		$ActiveSkill = $cMainSkillKey
		DoKeyPress($cMainSkillKey)
	EndIf
EndFunc

;-----------------------------------------------
; Манашилд
;-----------------------------------------------
Func DoManaShield()
	DoSkill($cManaShieldKey)
EndFunc

;-----------------------------------------------
; Телепорт
;-----------------------------------------------
Func DoTeleport()
	DoSkill($cTeleportKey)
EndFunc

;-----------------------------------------------
; Выпить хп
;-----------------------------------------------
Func DrinkHealthPoition()
	DoKeyPress($cHealthBottleKey)
EndFunc

;-----------------------------------------------
; Выпить ману
;-----------------------------------------------
Func DrinkManaPoition()
	DoKeyPress($cManaBottleKey)
EndFunc

;-----------------------------------------------
; Ребафаем
;-----------------------------------------------
Func Rebuff($aPartyCount = 0)
	If $aPartyCount = 0 Then
		DoPowerBuff(1)
		DoDefenceBuff(1)
	Else
		Local $OldMousePos = MouseGetPos()
		For $aY = 1 To $aPartyCount Step 1
			MouseMove($crPartyStart[0], $crPartyStart[1] + ($aY - 1) * $crPartyDeltaY , 0)
			DoPowerBuff()
			DoDefenceBuff()
		Next
		MouseMove($OldMousePos[0], $OldMousePos[1], 0)
	EndIf
EndFunc

;-----------------------------------------------
; Выпить алкоголь
;-----------------------------------------------
Func DrinkAlcohol()
	DoKeyPress($cAlcoBottleKey)
EndFunc

Func DoBuff($aKey, $aSelf)
	Local $OldMousePos
	If $aSelf == 1 Then
		$OldMousePos = MouseGetPos()
		CenterMouse()
	EndIf
	DoSkill($aKey)
	If $aSelf == 1 Then MouseMove($OldMousePos[0], $OldMousePos[1], 0)
EndFunc

Func DoHealBuff($aSelf = 0)
	DoBuff($cHealBuffKey, $aSelf)
EndFunc

;-----------------------------------------------
; Бафаем атаку
;-----------------------------------------------
Func DoPowerBuff($aSelf = 0)
	DoBuff($cPowerBuffKey, $aSelf)
EndFunc

;-----------------------------------------------
; Бафаем защиту
;-----------------------------------------------
Func DoDefenceBuff($aSelf = 0)
	DoBuff($cDefenceBuffKey, $aSelf)
EndFunc

;-----------------------------------------------
; Меняем статус разрешения запросов
; Параметры
;		$aStatus - False - выкл, True - вкл
;-----------------------------------------------
Func SetRequests($aStatus)
	Switch($aStatus)
		Case False
			Send("{ENTER}")
			Sleep(100)
			Send("/re off")
			Sleep(100)
			Send("{ENTER}")
		Case True
			Send("{ENTER}")
			Sleep(100)
			Send("/re on")
			Sleep(100)
			Send("{ENTER}")
	EndSwitch
EndFunc

;-----------------------------------------------
; Меняем статус разрешения запросов
; Параметры
;		$aStatus - False - выкл, True - вкл
;-----------------------------------------------
Func TeleportTo($aLocName)
	Send("{ENTER}")
	Sleep(100)
	Send("/move " & $aLocName)
	Sleep(100)
	Send("{ENTER}")
EndFunc

;-----------------------------------------------
; Реконнект
; Параметры
;		$aPassword - пароль к акку
;		$aCharNumber - номер персонажа
;-----------------------------------------------
Func Connect($aPassword, $aCharNumber, $aServerNumber = 1)
	Local $LauncherHandle = WinGetHandle($cMuLauncherHeader)
	_WinAPI_SwitchToThisWindow($LauncherHandle, True)
	Sleep(200)
	Send($cLauncherPlay)
	Local $myWinHandle = WinGetHandle($cMuHeader)
	Local $runTry = 1
	While @error And ($runTry < $cReconnectTryes)
		$myWinHandle = WinGetHandle ($cMuHeader)
		$runTry += 1
		Sleep(1000)
	WEnd
	Sleep(120000) ; Ждём пока запустится игра
	Send("{" & $cLauncherToWindow & "}")
	Sleep(10000)
	_WinAPI_SwitchToThisWindow($cMuHeader, True)
	MouseMove($cServerSelectPos[0], $cServerSelectPos[1], 0)
	Sleep(200)
	DoMainClick()
	Sleep(1000)
	MouseMove($cSubserverSelectPos[0], $cSubserverSelectPos[1] + ($aServerNumber - 1) * $cSubServerHeight, 0)
	DoMainClick()
	Sleep(5000)
	Send($aPassword)
	Sleep(100)
	Send("{ENTER}")
	Sleep(5000)
	MouseMove($cCharSelectPos[0] + ($aCharNumber - 1) * $cCharSelectWidth, $cCharSelectPos[1], 0)
	Sleep(200)
	DoMainClick(300)
	Sleep(500)
	Send("{ENTER}")
	Sleep(5000)
	DoKeyPress($ActiveSkill)
	Sleep(100)
	CenterMouse()
EndFunc

;-----------------------------------------------
; Делаем скриншот
;-----------------------------------------------
Func TakeSnapshot()
	DoKeyPress("PRINTSCREEN")
EndFunc

;-----------------------------------------------
; Цвет курсора в точке
;-----------------------------------------------
Func GetCursorColor($aX = 0, $aY = 0)
	If ($aX == 0) Then $aX = $cCursorColorPos[0]
	If ($aY == 0) Then $aY = $cCursorColorPos[1]
	Local $CaptureCrosshair = MouseGetPos()
	_GDIPlus_Startup()
	Local $hWnd = WinGetHandle($cMuHeader)
	Local $hBmp = _ScreenCapture_CaptureWndClient("", $hWnd, $CaptureCrosshair[0], $CaptureCrosshair[1], $CaptureCrosshair[0] + 30 - $cMainWndWidth, $CaptureCrosshair[1] + 30 - $cMainWndHeight, True)
	Local $bitMP = _GDIPlus_BitmapCreateFromHBITMAP($hBmp)
	Local $aColor = BitXOR(_GDIPlus_BitmapGetPixel($bitMP, $aX, $aY), 0xFF000000)
	_GDIPlus_ImageDispose($bitMP)
	_WinAPI_DeleteObject($hBmp)
	_GDIPlus_Shutdown()
	Return $aColor
EndFunc

;-----------------------------------------------
; Отказываемся от запроса
;-----------------------------------------------
Func DeclineRequest()
	TakeSnapshot()
	Sleep(500)
	MouseMove($cRequestCancel[0], $cRequestCancel[1], 0)
	DoMainClick()
	CenterMouse()
EndFunc

;-----------------------------------------------
; Получаем наименование папки по имени локации
; Параметры:
; $aLocationName - Наименование локации
;-----------------------------------------------
Func GetWorldByLocation($aLocationName)
	For $i = 0 To UBound($cgtWorldsLocs) - 1 Step 1
		If StringCompare($cgtWorldsLocs[$i][1], $aLocationName, False) == 0 Then Return $cgtWorldsLocs[$i][0]
	Next
EndFunc

;-----------------------------------------------
; Пытается перейти на коордионаты по алгоритму A*
; Параметры:
; $aToCoords - Куда идти - массив из 2 элементов,
;   Y X координаты соответственно
; $aMapName - Наименование локации в которой идём
; $aCanTeleport - Можно ли телепортироваться
;-----------------------------------------------
Func GoToCoordAStar($aToCoords, $aMapName, $aCanTeleport = 0, $aCenterMouse = True)
	$first_label = 0
	$last_label = 0
	$estimate = 1.001
	$closedList_Str = "_"
	$openList_Str = "_"
	$barrier = _ArrayCreate(-1)

	Local $StartCoord = GetCurrentPos()
	Local $WorldName = GetWorldByLocation($aMapName)
	Local $MyMapArray[256][256]
	Local $MyMapFile = FileOpen($cMuPath & "\\Data\\" & $WorldName & "\\Terrain.att", 4)
	Local $CurCharNum = 0
	FileRead($MyMapFile, 3)
	While 1
		Local $CurChar = FileRead($MyMapFile, 1)
		If @error = -1 Then ExitLoop

		Local $CurY = Int($CurCharNum / 256)
		Local $CurX = $CurCharNum - $CurY * 256
		If Asc($CurChar) > 1 Then
			$MyMapArray[$CurY][$CurX] = "x"
		Else
			$MyMapArray[$CurY][$CurX] = "0"
		EndIf

		$CurCharNum += 1
	WEnd
	FileClose($MyMapFile)

	For $i = 0 To 255 Step 1
		$MyMapArray[0][$i] = "x"
		$MyMapArray[255][$i] = "x"
	Next
 	For $i = 0 To 255 Step 1
		$MyMapArray[$i][0] = "x"
		$MyMapArray[$i][255] = "x"
	Next

	$MyMapArray[$StartCoord[1]][$StartCoord[0]] = "s"
	$MyMapArray[$aToCoords[1]][$aToCoords[0]] = "g"

	_CreateMap($MyMapArray, 256, 256)

	Dim $path = _FindPath($MyMapArray, $MyMapArray[$StartCoord[1]][$StartCoord[0]], $MyMapArray[$aToCoords[1]][$aToCoords[0]])
	Dim $goodPath = _ArrayCreate("" & $StartCoord[0] & "," & $StartCoord[1])
	Local $aPrevCoord = $StartCoord
	Local $PrevDX = 0
	Local $PrevDY = 0
	Local $aDX = 0
	Local $aDY = 0
	For $i = 0 To UBound($path) - 1 Step 1
		$item = $path[$i]
		Local $Tempo = StringSplit($item, ",")
		Local $ToToCoord[2] = [$Tempo[1], $Tempo[2]]
		$aDX = Abs($aPrevCoord[0] - $ToToCoord[0])
		$aDY = Abs($aPrevCoord[1] - $ToToCoord[1])
		If ($PrevDX <> $aDX) Or ($PrevDY <> $aDY) Then
			$PrevDX = $aDX
			$PrevDY = $aDY
			_ArrayAdd($goodPath, $item)
		EndIf
		$aPrevCoord = $ToToCoord
	Next
	For $i = 0 To UBound($goodPath) - 1 Step 1
		Local $Tempo = StringSplit($item, ",")
		Local $ToToCoord[2] = [$Tempo[1], $Tempo[2]]
		GoToCoord($ToToCoord, 0, False)
	Next
EndFunc

;-----------------------------------------------
; Пытается перейти на коордионаты
; Параметры:
; $aToCoords - Куда идти - массив из 2 элементов,
;   Y X координаты соответственно
; $aCanTeleport - Можно ли телепортироваться
;-----------------------------------------------
Func GoToCoord($aToCoords, $aCanTeleport = 0, $aCenterMouse = True)
	Local Const $GoToValues[8] = [1, 0, 10, 20, 21, 22, 12, 2]

	Local $curCoords = GetCurrentPos()
	If ($curCoords[0] == $aToCoords[0]) And ($curCoords[1] == $aToCoords[1]) Then Return
	Local $prevCurCoords[2] = [-1, -1]
	Local $multiplier = 1
	Local $MaxGotoIter = (Abs($curCoords[0] - $aToCoords[0]) + Abs($curCoords[1] - $aToCoords[1]))
	If $MaxGotoIter == 0 Then Return
	Local $curIter = 0
	Local $CanTeleport = $aCanTeleport
	Local $curRetryIter = 0

	Local $MDx = 0
	Local $MDy = 0
	Do
		$MDx = 0
		$MDy = 0

		If isDead() Then ExitLoop

		Local $GoToPos = 0

		Local $AddX = 0
		Local $AddY = 0
		If $curCoords[0] <> $aToCoords[0] Then $AddX = ($aToCoords[0] - $curCoords[0])/ Abs($aToCoords[0] - $curCoords[0])
		If $curCoords[1] <> $aToCoords[1] Then $AddY = -($aToCoords[1] - $curCoords[1])/ Abs($aToCoords[1] - $curCoords[1])

		Local $SearchValue = ($AddX + 1) * 10 + ($AddY + 1)
		For $aI = 0 To UBound($GoToValues) - 1 Step 1
			If $GoToValues[$aI] == $SearchValue Then
				$GoToPos = $aI
				ExitLoop
			EndIf
		Next

		If ($prevCurCoords[0] == $curCoords[0]) And ($prevCurCoords[1] == $curCoords[1]) Then
			If $multiplier < 4 Then $multiplier += 1
			$curRetryIter += 1
			$GoToPos += $curRetryIter
			$GoToPos = Mod($GoToPos, 8)
		Else
			$multiplier = 1
			$curRetryIter = 0
		EndIf

		If (Abs($aToCoords[0] - $curCoords[0]) <> 0) And (Abs($aToCoords[1] - $curCoords[1]) <> 0) Then
			$multiplier = _Min(Abs($aToCoords[0] - $curCoords[0]), Abs($aToCoords[1] - $curCoords[1]))
		ElseIf Abs($aToCoords[0] - $curCoords[0]) > 0 Then
			$multiplier = Abs($aToCoords[0] - $curCoords[0])
		ElseIf Abs($aToCoords[1] - $curCoords[1]) > 0 Then
			$multiplier = Abs($aToCoords[1] - $curCoords[1])
		EndIf
		if $multiplier > 4 Then $multiplier = 4
		If $multiplier < 1 Then $multiplier = 1

		$MDx = Sign(Mod($GoToPos + 3, 4)) * (Mod(Int(($GoToPos + 3)/4), 2) * 2 - 1) * ($cMDelta + $cMCorner * Sign(Mod($GoToPos + 1, 2))) * $multiplier
		$MDy = Sign(Mod($GoToPos + 1, 4)) * (    Int ($GoToPos     /4)     * 2 - 1) * ($cMDelta + $cMCorner * Sign(Mod($GoToPos + 1, 2))) * $multiplier * 0.7

		$multiplier = 1
		MouseMove($cMCenter[0] + $MDx, $cMCenter[1] + $MDy, 0)
 		Sleep(200)
		If (GetCursorColor() <> $cgtDefaultCurColor) then
			While $multiplier < 4
				Local $Iteration = 0
				While (GetCursorColor() <> $cgtDefaultCurColor) and ($Iteration <> 8)
					$GoToPos += 1
					$Iteration += 1
					$MDx = Sign(Mod($GoToPos - 1, 4)) * (Mod(Int(($GoToPos + 3)/4), 2) * 2 - 1) * ($cMDelta + $cMCorner * Sign(Mod($GoToPos + 1, 2))) * $multiplier
					$MDy = Sign(Mod($GoToPos + 1, 4)) * (    Int ($GoToPos     /4)     * 2 - 1) * ($cMDelta + $cMCorner * Sign(Mod($GoToPos + 1, 2))) * $multiplier
					MouseMove($cMCenter[0] + $MDx, $cMCenter[1] + $MDy, 0)
					Sleep(200)
				WEnd
				$multiplier += 1
			WEnd
			$multiplier = 1
		EndIf
		If $CanTeleport == 1 Then
			DoTeleport()
		Else
			DoMainClick(50)
			Sleep($multiplier * 500)
		EndIf

		Local $TempCoords = GetCurrentPos()
		$prevCurCoords = $curCoords
		If $TempCoords <> -1 Then
			$curCoords = $TempCoords
		Else
			$curCoords[0] += $AddX
			$curCoords[1] += $AddY
		EndIf
		$curIter += $AddX + $AddY
	Until (($curCoords[0] == $aToCoords[0]) And ($curCoords[1] == $aToCoords[1])) Or ($curIter == $MaxGotoIter)
	if $aCenterMouse Then CenterMouse()
EndFunc

;-----------------------------------------------
; Крутим мышой по кругу
; Параметры:
; $aRadius - радиус
; $aSleepTime - сколько спим после поворота
;-----------------------------------------------
Func DoMouseRoundMove($aStage = 0, $aRadius = 100, $aSleepTime = 2000)
	If ($aStage == 0) Or ($aStage == 1) Then
		CenterMouse()
		CenterMouse($aRadius, 0)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 2) Then
		CenterMouse($aRadius, $aRadius)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 3) Then
		CenterMouse(0, $aRadius)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 4) Then
		CenterMouse(-$aRadius, $aRadius)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 5) Then
		CenterMouse(-$aRadius, 0)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 6) Then
		CenterMouse(-$aRadius, -$aRadius)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 7) Then
		CenterMouse(0, -$aRadius)
		Sleep($aSleepTime)
	EndIf
	If ($aStage == 0) Or ($aStage == 8) Then
		CenterMouse($aRadius, -$aRadius)
		Sleep($aSleepTime)
	EndIf
EndFunc

Func IsDisconnectWindowOpen($aScale = 5)
	Local $TempCoords = _TesseractWinCapture($cMuHeader, "", 0, "", 1, $aScale, $cDisconnectWindowRect[0], $cDisconnectWindowRect[1], $cMainWndWidth - $cDisconnectWindowRect[2], $cMainWndHeight - $cDisconnectWindowRect[3], 0, $cCoordWhiteLevel)
	Local $Words = StringSplit($TempCoords, " ")
	Local $Found = False
	For $Word In $Words
		If StringCompare($Word, "disconnected") == 0 Then
			$Found = True
			ExitLoop
		EndIf
	Next
	If $Found Then Return True
	Return False
EndFunc
;-------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------
Func Move($aDirection)
	Switch $aDirection
	Case "left"
		CenterMouse()
	Case "right"
	Case "up"
	Case "down"
	EndSwitch
EndFunc

Func Sign($aWhat)
	If $aWhat == 0 Then
		Return 0
	ElseIf $aWhat < 0 Then
		Return -1
	Else
		Return 1
	EndIf
EndFunc


Func ShowToolTip($aMessage)
	ToolTip($aMessage, $cMainWndWidth + 10, 100)
EndFunc
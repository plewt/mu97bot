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
Dim Const $cXCoordRect[4] = [22, 742, 47, 753] ; прямоугольник, объемлющий X координату
Dim Const $cYCoordRect[4] = [61, 742, 86, 753] ; прямоугольник, объемлющий Y координату
Dim Const $cCoordDeltaDig = 2                  ; ширина между знаками в координатах
Dim Const $cCoordWhiteLevel = 90               ; значение более которого - цвет шрифта
Dim Const $cDeltaLevel = 5
; Шаблоны распознования для цифр
Dim Const $cDigitCount = 11
Dim Const $cCoordDigitsXHisto[$cDigitCount][12]  = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], _
													[5, 3, 4, 4, 4, 4, 4, 3, 4, 3, 5, 4], _
													[2, 3, 4, 3, 2, 2, 2, 2, 2, 2, 2, 2], _
													[5, 4, 3, 2, 1, 2, 2, 3, 2, 2, 7, 7], _
													[5, 3, 4, 2, 3, 3, 2, 3, 4, 4, 5, 4], _
													[2, 3, 3, 4, 4, 3, 4, 8, 7, 2, 2, 2], _
													[6, 2, 1, 1, 7, 3, 3, 3, 3, 4, 5, 4], _
													[5, 3, 4, 1, 7, 4, 4, 4, 4, 4, 5, 5], _
													[8, 2, 1, 2, 2, 2, 3, 2, 2, 3, 3, 3], _
													[5, 3, 4, 3, 4, 4, 4, 3, 3, 4, 5, 4], _
													[5, 4, 4, 3, 5, 6, 7, 2, 2, 4, 4, 4]]
Dim Const $cCoordDigitsYHisto[$cDigitCount][8] =   [[0, 0,  0, 0, 0,  0,  0,  0], _
													[7, 8,  3, 2,  3,  11, 10, 3], _
													[0, 2,  2, 12, 12, 0,  0,  0], _
													[5, 7,  5, 5,  5,  8,  5,  0], _
													[3, 6,  4, 3,  5,  10, 9,  2], _
													[3, 5,  4, 5,  12, 12, 2,  1], _
													[3, 9,  5, 3,  4,  8,  8,  2], _
													[8, 8,  4, 3,  4,  11, 9,  3], _
													[1, 4,  7, 9,  5,  4,  2,  1], _
													[5, 10, 5, 3,  5,  10, 8,  0], _
													[5, 9,  5, 3,  5,  11, 9,  3]]

; Окружающие разряды координат прямоугольники (только 8x12)
Dim Const $cCoordXD1[4] = [22, 742, 29, 753]
Dim Const $cCoordXD2[4] = [31, 742, 38, 753]
Dim Const $cCoordXD3[4] = [40, 742, 47, 753]

Dim Const $cCoordXD22[4] = [28, 742, 35, 753]
Dim Const $cCoordXD32[4] = [38, 742, 45, 753]

Dim Const $cCoordXD33[4] = [36, 742, 43, 753]

Dim Const $cCoordYD1[4] = [61, 742, 68, 753]
Dim Const $cCoordYD2[4] = [70, 742, 77, 753]
Dim Const $cCoordYD3[4] = [79, 742, 86, 753]

Dim Const $cCoordYD22[4] = [67, 742, 74, 753]
Dim Const $cCoordYD32[4] = [76, 742, 83, 753]

Dim Const $cCoordYD33[4] = [74, 742, 81, 753]

; Положения указателя мыши
Dim Const $cMCenter[2]  = [512, 335]
Dim Const $cMDelta 		= 80
Dim Const $cMCorner     = -23
Dim Const $cMDRight[2]  = [ $cMDelta, -$cMDelta]
Dim Const $cMDLeft[2]   = [-$cMDelta,  $cMDelta]
Dim Const $cMDTop[2]    = [-$cMDelta, -$cMDelta]
Dim Const $cMDBottom[2] = [ $cMDelta,  $cMDelta]

; Для хождения
Dim Const $cgtDefaultCurColor   = 0x00FFFFFF ; Цвет дефолтового курсора

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

; Константы для орбов хп и маны
Dim Const $cbDeltaColor          = 5 ; отклонение цвета на это значение не считаем отклонением
; хп
Dim Const $chbRect[2][2]         = [[198, 694], [198, 768]]
Dim Const $chbColors[$chbRect[1][1] - $chbRect[0][1] + 1] = [6946816, 6946816, 8060928, _
			8060928, 6946816, 8585216, 8585216, 10747904, 9109504, 9109504, 9699328, 9699328, _
			10223616, 10747904, 10747904, 10747904, 11272192, 11272192, 11796480, 11796480, _
			10747904, 10223616, 10223616, 10223616, 9109504, 9109504, 9109504, 9109504, 9699328, _
			10223616, 10223616, 10223616, 10223616, 10223616, 10747904, 10747904, 10747904, 11796480, _
			11796480, 12386304, 12910592, 12910592, 12910592, 12910592, 13959168, 13959168, 13959168, _
			12386304, 12910592, 12910592, 12910592, 12910592, 13434880, 15073280, 15073280, 15597568, _
			15597568, 15597568, 15597568, 15597568, 16121856, 15597568, 15597568, 16121856, 13959168, _
			13959168, 11272192, 11272192, 12910592, 12386304, 12386304, 11796480, 9110528, 9110528, _
			12177898]
; мана
Dim Const $cmbRect[2][2]         = [[830, 694], [830, 768]]
Dim Const $cmbColors[$chbRect[1][1] - $chbRect[0][1] + 1] = [90, 90, 106, 106, 90, 106, 106, 123, 98, _
			98, 123, 123, 139, 139, 139, 139, 139, 139, 123, 123, 106, 98, 98, 98, 106, 106, 115, 115, _
			115, 123, 123, 123, 131, 131, 131, 131, 131, 139, 139, 139, 139, 139, 131, 131, 156, 172, _
			172, 148, 139, 139, 148, 148, 164, 197, 197, 197, 189, 189, 197, 197, 205, 197, 197, 197, _
			180, 180, 131, 131, 148, 148, 148, 139, 526426, 526426, 12177898]
; пати
Dim Const $crPartyStart[2] = [1000, 20]
Dim Const $crPartyDeltaY   = 50

; Типы персонажей
Dim Const $cctElf = 0
Dim Const $cctME  = 1
Dim Const $cctDW  = 10
Dim Const $cctSM  = 11
Dim Const $cctDK  = 20
Dim Const $cctBK  = 21
Dim Const $cctMG  = 30

; Общие
Dim Const $cMuHeader               = '©WakeUp' ; Заголовок окна му
Dim Const $cMuClass                = 'MU' ; Класс окна му
Dim Const $cMuPath                 = "C:\\MU"
Dim Const $cMuLauncherHeader       = 'Losena MuOnline Launcher v0.1.0.6' ; Заголовок окна лончера
Dim Const $cMuLauncherPath         = '' ; Путь к лончеру
Dim Const $cReconnectTryes         = 600 ; Сколько секунд ждём запуска mu
Dim Const $cMainWndWidth           = 1024
Dim Const $cMainWndHeight          = 768

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
;~ 				Dim $LeftBottomSearchRect[4] = [$aSearchRect[0], $coord[1] + 1, $coord[0], $aSearchRect[3]]
				Dim $LeftBottomSearchRect[4] = [$aSearchRect[0], $coord[1] + $aWhatHeight + 1, $coord[0], $aSearchRect[3]]
				If FindLootInRect($LeftBottomSearchRect, $aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf

			If ($coord[0] <= $aSearchRect[2]) And (($coord[1] - 1) >= $aSearchRect[1])Then
;~ 				Dim $RightTopSearchRect[4] = [$coord[0], $aSearchRect[1], $aSearchRect[2], $coord[1] - 1]
				Dim $RightTopSearchRect[4] = [$coord[0] + $aWhatWidth, $aSearchRect[1], $aSearchRect[2], $coord[1] - 1]
				If FindLootInRect($RightTopSearchRect, $aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf

			If (($coord[0] + 1) <= $aSearchRect[2]) And (($coord[1] - 1) <= $aSearchRect[3]) Then
;~ 				Dim $RightBottomSearchRect[4] = [$coord[0] + 1, $coord[1], $aSearchRect[2], $aSearchRect[3]]
				Dim $RightBottomSearchRect[4] = [$coord[0] + $aWhatWidth + 1, $coord[1] + $aWhatHeight, $aSearchRect[2], $aSearchRect[3]]
				If FindLootInRect($RightBottomSearchRect,$aWhatWidth, $aWhatHeight, $aFirstPixelColor, $aRetCoord, $aLootText, $aScale) Then Return True
			EndIf
		EndIf
	EndIf
	Return False
EndFunc

;-----------------------------------------------
; Получение текстового значения координатного разряда
; Параметры:
;		$aRect - в каком прямоугольнике ищем
; Возвращаемое значение - текстовое значение
;   либо " ", либо цифра (0 - 9)
;-----------------------------------------------
Func GetDigitValue($aRect, $aCompareType = 2)
	If ($aRect[2] - $aRect[0]) <> 7  Then Return ""
	If ($aRect[3] - $aRect[1]) <> 11 Then Return ""

	Local $MyDigitsRating[$cDigitCount] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $MyXHistoGramm[12] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $MyYHistoGramm[8]  = [0, 0, 0, 0, 0, 0, 0, 0]
	For $aY = $aRect[1] To $aRect[3] Step 1
		For $aX = $aRect[0] To $aRect[2] Step 1
			Local $pixColor = _ColorGetRGB(PixelGetColor($aX, $aY))
			If _Min(_Min($pixColor[0], $pixColor[1]), $pixColor[2]) > $cCoordWhiteLevel Then
				If ($aCompareType == 0) Or ($aCompareType == 2) Then
					$MyXHistoGramm[$aY - $aRect[1]] += 1
				EndIf
				If ($aCompareType == 1) Or ($aCompareType == 2) Then
					$MyYHistoGramm[$aX - $aRect[0]] += 1
				EndIf
			EndIf
		Next
	Next
	For $digit = 0 To $cDigitCount - 1 Step 1
		If ($aCompareType == 0) Or ($aCompareType == 2) Then
			For $aY = 0 To 11 Step 2
				$MyDigitsRating[$digit] += Abs($MyXHistoGramm[$aY] - $cCoordDigitsXHisto[$digit][$aY])
			Next
		EndIf
		If ($aCompareType == 1) Or ($aCompareType == 2) Then
			For $aX = 0 To 7 Step 1
				$MyDigitsRating[$digit] += Abs($MyYHistoGramm[$aX] - $cCoordDigitsYHisto[$digit][$aX])
			Next
		EndIf
	Next

	Local $MinDifference = $MyDigitsRating[0]
	Local $MinDifferenceNum = 0
	For $digit = 0 To $cDigitCount - 1 Step 1
		If $MinDifference > $MyDigitsRating[$digit] Then
			$MinDifference = $MyDigitsRating[$digit]
			$MinDifferenceNum = $digit
		EndIf
	Next

	If $MinDifferenceNum == 0 Then
		Return ""
	Else
		Return String($MinDifferenceNum - 1)
	EndIf
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
	Local $coord[2] = [20, 738]
	Local $TempCoords = _TesseractWinCapture($cMuHeader, "", 0, "", 1, 1, $coord[0], $coord[1], 1024 - $coord[0] - 75, 768 - $coord[1] - 18, 0, $cCoordWhiteLevel)
	$TempCoords = StringReplace($TempCoords, "|", "1")
	$TempCoords = StringReplace($TempCoords, "?", "7")
	Local $TempCurPos = StringSplit($TempCoords, " ")
 	If Int($TempCurPos[0]) = 2 Then
		$CurPos[0] = $TempCurPos[1]
		$CurPos[1] = $TempCurPos[2]
 	EndIf
	Return $CurPos

;~  Быстрый, но часто ошибающийся метод
;~ 	Local $CurPos[2] = [-1, -1]
;~ 	Local $FirstXC = GetDigitValue($cCoordXD1)
;~ 	Local $FirstYC = GetDigitValue($cCoordXD1)

;~ 	Local $SecondXC = ""
;~ 	Local $SecondYC = ""

;~ 	If $FirstXC == "" Then
;~ 		$SecondXC = GetDigitValue($cCoordXD22)
;~ 		If $SecondXC == "" Then
;~ 			$CurPos[0] = Int($FirstXC & $SecondXC & GetDigitValue($cCoordXD33))
;~ 		Else
;~ 			$CurPos[0] = Int($FirstXC & $SecondXC & GetDigitValue($cCoordXD32))
;~ 		EndIf
;~ 	Else
;~ 		$CurPos[0] = Int($FirstXC & GetDigitValue($cCoordXD2) & GetDigitValue($cCoordXD3))
;~ 	EndIf

;~ 	If $FirstYC == "" Then
;~ 		$SecondYC = GetDigitValue($cCoordYD22)
;~ 		If $SecondYC == "" Then
;~ 			$CurPos[1] = Int($FirstYC & $SecondYC & GetDigitValue($cCoordYD33))
;~ 		Else
;~ 			$CurPos[1] = Int($FirstYC & $SecondYC & GetDigitValue($cCoordYD32))
;~ 		EndIf
;~ 	Else
;~ 		$CurPos[1] = Int($FirstXC & GetDigitValue($cCoordYD2) & GetDigitValue($cCoordYD3))
;~ 	EndIf
;~ 	Return $CurPos
EndFunc

;-----------------------------------------------
; Получение текущего уровня по столбику (орбу)
; Параметры:
;		$aOrbColors - цвета полного орба
;		$aOrbRect - область орба
;		$aChannel - какой канал сравниваем
; Возвращаемое значение - уровень в %
;-----------------------------------------------
Func GetOrbLevel($aOrbColors, $aOrbRect, $aChannel = 0)
	Local $OrbHeigth = $aOrbRect[1][1] - $aOrbRect[0][1] + 1
	Local $Colors[$OrbHeigth]
	Local $BadColors = 0
	Local $DeltaColor = 0
	For $aY = $aOrbRect[0][1] To $aOrbRect[1][1] Step 1
		$Colors[$aY - $aOrbRect[0][1]] = PixelGetColor($aOrbRect[0][0], $aY)
	Next
	For $aY = 0 To $OrbHeigth - 1 Step 1
		If $Colors[$aY] <> $aOrbColors[$aY] Then
			; сравниваем только красный канал
			Switch $aChannel
				Case -1
					$DeltaColor = Abs($Colors[$aY] - $aOrbColors[$aY])
					$DeltaColor = _ColorGetRed($DeltaColor) + _ColorGetGreen($DeltaColor) + _ColorGetBlue($DeltaColor)
				Case 0
					$DeltaColor = _ColorGetRed(Abs($Colors[$aY] - $aOrbColors[$aY]))
				Case 1
					$DeltaColor = _ColorGetGreen(Abs($Colors[$aY] - $aOrbColors[$aY]))
				Case 2
					$DeltaColor = _ColorGetBlue(Abs($Colors[$aY] - $aOrbColors[$aY]))
			EndSwitch
			If $DeltaColor > $cbDeltaColor Then $BadColors += 1
		EndIf
	Next
	Return ((1 - ($BadColors / $OrbHeigth)) * 100)
EndFunc

;-----------------------------------------------
; Получение текущего уровня хп
; Возвращаемое значение - % хп
;-----------------------------------------------
Func GetHealthLevel()
	Return GetOrbLevel($chbColors, $chbRect, 1)
EndFunc

Func isDead()
	Return GetHealthLevel() < 5
EndFunc
;-----------------------------------------------
; Получение текущего уровня маны
; Возвращаемое значение - % маны
;-----------------------------------------------
Func GetManaLevel()
	Return GetOrbLevel($cmbColors, $cmbRect, 2)
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
Func Reconnect($aPassword, $aCharNumber)
	Sleep(4000)
	WinActivate($cMuLauncherHeader)
	Sleep(1000)
	Send("!p")
	Sleep(100)
	Local $myWinHandle = WinGetHandle($cMuHeader)
	Local $runTry = 1
	While @error And ($runTry < $cReconnectTryes)
		$myWinHandle = WinGetHandle ($cMuHeader)
		$runTry += 1
		Sleep(1000)
	WEnd
	Sleep(120000)
	Send("{F12}")
	Sleep(10000)
	WinActivate($cMuHeader)
	MouseMove(506, 364, 0)
	Sleep(200)
	MouseDown("left")
	Sleep(300)
	MouseUp("left")
	Sleep(1000)
	MouseMove(620, 342, 0)
	Sleep(200)
	MouseDown("left")
	Sleep(300)
	MouseUp("left")
	Sleep(5000)
	Send($aPassword)
	Sleep(200)
	Send("{ENTER}")
	Sleep(5000)
	MouseMove(250 + ($aCharNumber - 1) * 120, 500, 0) ;
	Sleep(200)
	MouseDown("left")
	Sleep(300)
	MouseUp("left")
	Sleep(500)
	Send("{ENTER}")
	Sleep(5000)
	Send("{1 down}")
	Sleep(200)
	Send("{1 up}")
	sleep(100)
	Send("{F10}")
	Sleep(1000)
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
Func GetCursorColor($aX = 21, $aY = 17)
	Local $CaptureCrosshair = MouseGetPos()
	_GDIPlus_Startup()
	Local $hWnd = WinGetHandle($cMuHeader)
	Local $hBmp = _ScreenCapture_CaptureWndClient("", $hWnd, $CaptureCrosshair[0], $CaptureCrosshair[1], $CaptureCrosshair[0] + 30 - $cMainWndWidth, $CaptureCrosshair[1] + 30 - $cMainWndHeight, True)
;~ 	GLOBAL $MYI
;~ 	$MYI += 1
;~ 	_ScreenCapture_SaveImage("test" & String($MYI) & ".bmp", $hBmp)
	Local $bitMP = _GDIPlus_BitmapCreateFromHBITMAP($hBmp)
	Local $aColor = BitXOR(_GDIPlus_BitmapGetPixel($bitMP, $aX, $aY), 0xFF000000)
;~ 	ToolTip("0x" & Hex($aColor) , 1030, 100)
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
	MouseMove(580, 175, 0)
	DoSecondaryClick()
	MouseMove(520, 321, 0)
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
	Local $MaxGotoIter = 2 * (Abs($curCoords[0] - $aToCoords[0]) + Abs($curCoords[1] - $aToCoords[1]))
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

		$prevCurCoords = $curCoords
		$curCoords = GetCurrentPos()
		$curIter += 1
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

Func GetDigit()
	local $result = ""
	Local $MyXHistoGramm[12] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	Local $MyYHistoGramm[8]  = [0, 0, 0, 0, 0, 0, 0, 0]
	For $j = 742 to 753 step 1
;~ 		For $i = $cCoordXD1[0] to $cCoordXD1[2] step 1
;~ 		For $i = $cCoordXD2[0] to $cCoordXD2[2] step 1
;~ 		For $i = $cCoordXD3[0] to $cCoordXD3[2] step 1

;~ 		For $i = $cCoordXD22[0] to $cCoordXD22[2] step 1
		For $i = $cCoordXD32[0] to $cCoordXD32[2] step 1

;~ 		For $i = $cCoordXD33[0] to $cCoordXD33[2] step 1

;~ 		For $i = $cCoordYD1[0] to $cCoordYD1[2] step 1
;~ 		For $i = $cCoordYD2[0] to $cCoordYD2[2] step 1
;~ 		For $i = $cCoordYD3[0] to $cCoordYD3[2] step 1

;~ 		For $i = $cCoordYD22[0] to $cCoordYD22[2] step 1
;~ 		For $i = $cCoordYD32[0] to $cCoordYD32[2] step 1

;~ 		For $i = $cCoordYD33[0] to $cCoordYD33[2] step 1

			$color = _ColorGetRGB(PixelGetColor($i, $j))

			If _Min(_Min($color[0], $color[1]), $color[2]) > $cCoordWhiteLevel Then
				$result = $result & "#"
				$MyXHistoGramm[$j - 742] += 1
				$MyYHistoGramm[$i - $cCoordXD32[0]] += 1
;~ 				$result = $result & "1, "
			Else
				$result = $result & "_"
;~ 				$result = $result & "0, "
			EndIf
		Next
		$result = $result & @CRLF
	Next
	Local $myLog = "C:\Temp\digits.txt"
	FileWriteLine($myLog, $result)
	Local $tempString = ""
	For $i = 0 To 11 Step 1
		$tempString &= $MyXHistoGramm[$i] & ", "
	Next
	FileWriteLine($myLog, $tempString)
	$tempString = ""
	For $i = 0 To 7 Step 1
		$tempString &= $MyYHistoGramm[$i] & ", "
	Next
	FileWriteLine($myLog, $tempString)
	Return $result
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
	ToolTip($aMessage, 1034, 100)
EndFunc
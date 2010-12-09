#include-once
#include <Array.au3>
#include <String.au3>
#include <Color.au3>
#include <File.au3>
#include <GDIP.au3>
#include <GDIPlus.au3>
#include <ScreenCapture.au3>
#include <WinAPI.au3>
#include <WinAPIEx.au3>
#include <ScrollBarConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <GuiListBox.au3>
#region Header
#cs
	Title:   		Tesseract UDF Library for AutoIt3
	Filename:  		Tesseract.au3
	Description: 	A collection of functions for capturing text in applications.
	Author:   		seangriffin
	Version:  		V0.6
	Last Update: 	17/03/09
	Requirements: 	AutoIt3 3.2 or higher,
	Tesseract 2.01.
	Changelog:		---------15/02/09---------- v0.1
	Initial release.

	---------15/02/09---------- v0.2
	Changed path to tesseract.exe to @ProgramFilesDir.
	Added scaling as input to _TesseractCapture.
	Fixed indentation.
	Changed CaptureHWNDToTIFF to input window and control IDs.

	---------16/02/09---------- v0.3
	Added the parameter $get_last_capture to _TesseractCapture.
	Added the parameter $show_capture to _TesseractCapture.

	---------16/02/09---------- v0.4
	Added the function _TesseractFind.

	---------21/02/09---------- v0.5
	Updated _TesseractCapture to remove a listbox selection entirely,
	and return it after the text capture is done.

	---------17/03/09---------- v0.6
	Split the function "_TesseractCapture" into 3 functions:
	_TesseractScreenCapture
	_TesseractWinCapture
	_TesseractControlCapture
	Split the function "_TesseractFind" into 3 functions:
	_TesseractScreenFind
	_TesseractWinFind
	_TesseractControlFind
	Renamed the function "CaptureHWNDToTIFF" to "CaptureToTIFF",
	and modified it to allow for handling of the screen, windows
	and controls.
	Added the function "_TesseractTempPathSet".
#ce
#endregion Header
#region Global Variables and Constants
Global $last_capture
Global $tesseract_temp_path = "C:\"
#endregion Global Variables and Constants
#region Core functions
; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractTempPathSet()
; Description ...:	Sets the location where Tesseract functions temporary store their files.
;						You must have read and write access to this location.
;						The default location is "C:\".
; Syntax.........:	_TesseractTempPathSet($temp_path)
; Parameters ....:	$temp_path	- The path to use for temporary file storage.
;									This path must not contain any spaces (see "Remarks" below).
; Return values .: 	On Success	- Returns 1.
;                 	On Failure	- Returns 0.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:	The current version of Tesseract doesn't support paths with spaces.
; Related .......:
; Link ..........:
; Example .......:	No
;
; ;==========================================================================================
Func _TesseractTempPathSet($temp_path)

	$tesseract_temp_path = $temp_path

	Return 1
EndFunc   ;==>_TesseractTempPathSet

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractScreenCapture()
; Description ...:	Captures text from the screen.
; Syntax.........:	_TesseractScreenCapture($get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$get_last_capture	- Retrieve the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not retrieve the last capture (default)
;											1 = retrieve the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be returned if this isn't provided.
;											An array of delimited text will be returned if this is provided.
;											Eg. Use @CRLF to return the items of a listbox as an array.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the screen.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the screen.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the screen.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the screen.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success	- Returns an array of text that was captured.
;                 	On Failure	- Returns an empty array.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:	Use the default values for first time use.  If the text recognition accuracy is low,
;					I suggest setting $show_capture to 1 and rerunning.  If the screenshot of the
;					window or control includes borders or erroneous pixels that may interfere with
;					the text recognition process, then use $left_indent, $top_indent, $right_indent and
;					$bottom_indent to adjust the portion of the screen being captured, to
;					exclude these non-textural elements.
;					If text accuracy is still low, increase the $scale parameter.  In general, the higher
;					the scale the clearer the font and the more accurate the text recognition.
; Related .......:
; Link ..........:
; Example .......:	No
;
; ;==========================================================================================
Func _TesseractScreenCapture($get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	Local $tInfo
	Dim $aArray, $final_ocr[1], $xyPos_old = -1, $capture_scale = 3
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_ALL)

	If $last_capture = "" Then

		$last_capture = ObjCreate("Scripting.Dictionary")
	EndIf

	; if last capture is requested, and one exists.
	If $get_last_capture = 1 And $last_capture.item(0) <> "" Then

		Return $last_capture.item(0)
	EndIf

	$capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
	$ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)
	$ocr_filename_and_ext = $ocr_filename & ".txt"

	CaptureToTIFF("", "", "", $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent)

;~ 	ShellExecuteWait(@ProgramFilesDir & "\tesseract-ocr\tesseract.exe", $capture_filename & " " & $ocr_filename, "", "open", @SW_HIDE)
	RunWait(@ProgramFilesDir & "\tesseract-ocr\tesseract.exe " & $capture_filename & " " & $ocr_filename, $tesseract_temp_path, @SW_HIDE)

	; If no delimter specified, then return a string
	If StringCompare($delimiter, "") = 0 Then

		$final_ocr = FileRead($ocr_filename_and_ext)
	Else

		_FileReadToArray($ocr_filename_and_ext, $aArray)
		_ArrayDelete($aArray, 0)

		; Append the recognised text to a final array
		_ArrayConcatenate($final_ocr, $aArray)
	EndIf

	; If the captures are to be displayed
	If $show_capture = 1 Then

		GUICreate("Tesseract Screen Capture.  Note: image displayed is not to scale", 640, 480, 0, 0, $WS_SIZEBOX + $WS_SYSMENU) ; will create a dialog box that when displayed is centered

		GUISetBkColor(0xE0FFFF)

		$Obj1 = ObjCreate("Preview.Preview.1")
		$Obj1_ctrl = GUICtrlCreateObj($Obj1, 0, 0, 640, 480)
		$Obj1.ShowFile($capture_filename, 1)

		GUISetState()

		If IsArray($final_ocr) Then

			_ArrayDisplay($aArray, "Tesseract Text Capture")
		Else

			MsgBox(0, "Tesseract Text Capture", $final_ocr)
		EndIf

		GUIDelete()
	EndIf

	FileDelete($ocr_filename & ".*")

	; Cleanup
	If IsArray($final_ocr) And $cleanup = 1 Then

		; Cleanup the items
		For $final_ocr_num = 1 to (UBound($final_ocr) - 1)

			; Remove erroneous characters
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ".", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "'", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ",", "")
			$final_ocr[$final_ocr_num] = StringStripWS($final_ocr[$final_ocr_num], 3)
		Next

		; Remove duplicate and blank items
		For $each In $final_ocr

			$found_item = _ArrayFindAll($final_ocr, $each)

			; Remove blank items
			If IsArray($found_item) Then
				If StringCompare($final_ocr[$found_item[0]], "") = 0 Then

					_ArrayDelete($final_ocr, $found_item[0])
				EndIf
			EndIf

			; Remove duplicate items
			For $found_item_num = 2 To UBound($found_item)

				_ArrayDelete($final_ocr, $found_item[$found_item_num - 1])
			Next
		Next
	EndIf

	; Store a copy of the capture
	If $last_capture.item(0) = "" Then

		$last_capture.item(0) = $final_ocr
	EndIf

	Return $final_ocr
EndFunc   ;==>_TesseractScreenCapture

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractWinCapture()
; Description ...:	Captures text from a window.
; Syntax.........:	_TesseractWinCapture($win_title, $win_text = "", $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to capture text from.
;					$win_text			- Optional: The text of the window to capture text from.
;					$get_last_capture	- Retrieve the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not retrieve the last capture (default)
;											1 = retrieve the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be returned if this isn't provided.
;											An array of delimited text will be returned if this is provided.
;											Eg. Use @CRLF to return the items of a listbox as an array.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the window.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the window.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the window.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the window.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success	- Returns an array of text that was captured.
;                 	On Failure	- Returns an empty array.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:	Use the default values for first time use.  If the text recognition accuracy is low,
;					I suggest setting $show_capture to 1 and rerunning.  If the screenshot of the
;					window or control includes borders or erroneous pixels that may interfere with
;					the text recognition process, then use $left_indent, $top_indent, $right_indent and
;					$bottom_indent to adjust the portion of the window being captured, to
;					exclude these non-textural elements.
;					If text accuracy is still low, increase the $scale parameter.  In general, The higher
;					the scale the clearer the font and the more accurate the text recognition.
; Related .......:
; Link ..........:
; Example .......:	No
;
; ;==========================================================================================
Func _TesseractWinCapture($win_title, $win_text = "", $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0, $aWhiteLevel = -1)

	Local $tInfo
	Dim $aArray, $final_ocr[1], $xyPos_old = -1, $capture_scale = 3
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_ALL)

	If $last_capture = "" Then

		$last_capture = ObjCreate("Scripting.Dictionary")
	EndIf

	$hWnd = WinGetHandle($win_title, $win_text)

	; if last capture is requested, and one exists.
	If $get_last_capture = 1 And $last_capture.item(Number($hWnd)) <> "" Then

		Return $last_capture.item(Number($hWnd))
	EndIf

	; Perform the text recognition

	$capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
	$ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)
	$ocr_filename_and_ext = $ocr_filename & ".txt"

	CaptureToTIFF($win_title, $win_text, "", $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $aWhiteLevel)

	ShellExecuteWait(@ProgramFilesDir & "\tesseract-ocr\tesseract.exe", $capture_filename & " " & $ocr_filename, "", "open", @SW_HIDE)
;~ 	RunWait(@ProgramFilesDir & "\tesseract-ocr\tesseract.exe " & $capture_filename & " " & $ocr_filename, $tesseract_temp_path, @SW_HIDE)

	; If no delimter specified, then return a string
	If StringCompare($delimiter, "") = 0 Then

		$final_ocr = FileRead($ocr_filename_and_ext)
	Else

		_FileReadToArray($ocr_filename_and_ext, $aArray)
		_ArrayDelete($aArray, 0)

		; Append the recognised text to a final array
		_ArrayConcatenate($final_ocr, $aArray)
	EndIf

	; If the captures are to be displayed
	If $show_capture = 1 Then

		GUICreate("Tesseract Screen Capture.  Note: image displayed is not to scale", 640, 480, 0, 0, $WS_SIZEBOX + $WS_SYSMENU) ; will create a dialog box that when displayed is centered

		GUISetBkColor(0xE0FFFF)

;~ 		Local $Obj1 = ObjCreate("Preview.Preview.1")
;~ 		Local $Obj1_ctrl = GUICtrlCreateObj($Obj1, 0, 0, 640, 480)
;~ 		$Obj1.ShowFile ($capture_filename, 1)

		_GDIPlus_Startup()
		$hImage1 = _GDIPlus_ImageLoadFromFile($capture_filename)
		$iwx = _GDIPlus_ImageGetWidth($hImage1)
		$iwy = _GDIPlus_ImageGetHeight($hImage1)
		$hGUI = GUICreate("Preview", $iwx, $iwy, 0, 0, $WS_OVERLAPPEDWINDOW)
		GUISetState()
		$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
		_GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage1, 0, 0, $iwx, $iwy)
		While GUIGetMsg() <> -3 * Sleep(50)
		WEnd

		_GDIPlus_ImageDispose($hImage1)
		_GDIPlus_Shutdown()

;~ 		GUISetState()

		If IsArray($final_ocr) Then
			_ArrayDisplay($aArray, "Tesseract Text Capture")
		Else
;~ 			MsgBox(0, "Tesseract Text Capture", $final_ocr)
		EndIf

		GUIDelete()
	EndIf

	FileDelete($ocr_filename & ".*")

	; Cleanup
	If IsArray($final_ocr) And $cleanup = 1 Then

		; Cleanup the items
		For $final_ocr_num = 1 to (UBound($final_ocr) - 1)

			; Remove erroneous characters
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ".", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "'", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ",", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "|", "")
			$final_ocr[$final_ocr_num] = StringStripWS($final_ocr[$final_ocr_num], 3)
		Next

		; Remove duplicate and blank items
		For $each In $final_ocr

			$found_item = _ArrayFindAll($final_ocr, $each)

			; Remove blank items
			If IsArray($found_item) Then
				If StringCompare($final_ocr[$found_item[0]], "") = 0 Then

					_ArrayDelete($final_ocr, $found_item[0])
				EndIf
			EndIf

			; Remove duplicate items
			For $found_item_num = 2 To UBound($found_item)

				_ArrayDelete($final_ocr, $found_item[$found_item_num - 1])
			Next
		Next
	ElseIf $cleanup = 1 Then
		$final_ocr = StringReplace($final_ocr, ".", "")
		$final_ocr = StringReplace($final_ocr, "'", "")
		$final_ocr = StringReplace($final_ocr, ",", "")
		$final_ocr = StringStripWS($final_ocr, 3)
	EndIf

	; Store a copy of the capture
;	If $last_capture.item(Number($hWnd)) = "" Then
;		$last_capture.item(Number($hWnd)) = $final_ocr
;	EndIf
	$last_capture.item(Number($hWnd)) = $final_ocr


	Return $final_ocr
EndFunc   ;==>_TesseractWinCapture

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractControlCapture()
; Description ...:	Captures text from a control.
; Syntax.........:	_TesseractControlCapture($win_title, $win_text = "", $ctrl_id = "", $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to capture text from.
;					$win_text			- Optional: The text of the window to capture text from.
;					$ctrl_id			- Optional: The ID of the control to capture text from.
;											The text of the window will be returned if one isn't provided.
;					$get_last_capture	- Retrieve the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not retrieve the last capture (default)
;											1 = retrieve the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be returned if this isn't provided.
;											An array of delimited text will be returned if this is provided.
;											Eg. Use @CRLF to return the items of a listbox as an array.
;					$expand				- Optional: Expand the control before capturing text from it?
;											0 = do not expand the control
;											1 = expand the control (default)
;					$scrolling			- Optional: Scroll the control to capture all it's text?
;											0 = do not scroll the control
;											1 = scroll the control (default)
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$max_scroll_times	- The maximum number of scrolls to capture in a control
;											If a control has a very long scroll bar, the text recognition
;											process will take too long.  Use this value to restrict
;											the amount of text to recognise in a long control.
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the control.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the control.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the control.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the control.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success	- Returns an array of text that was captured.
;                 	On Failure	- Returns an empty array.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:	Use the default values for first time use.  If the text recognition accuracy is low,
;					I suggest setting $show_capture to 1 and rerunning.  If the screenshot of the
;					window or control includes borders or erroneous pixels that may interfere with
;					the text recognition process, then use $left_indent, $top_indent, $right_indent and
;					$bottom_indent to adjust the portion of the control being captured, to
;					exclude these non-textural elements.
;					If text accuracy is still low, increase the $scale parameter.  In general, The higher
;					the scale the clearer the font and the more accurate the text recognition.
; Related .......:
; Link ..........:
; Example .......:	Yes
;
; ;==========================================================================================
Func _TesseractControlCapture($win_title, $win_text = "", $ctrl_id = "", $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	Local $tInfo
	Dim $aArray, $final_ocr[1], $xyPos_old = -1, $capture_scale = 3
	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)
	DllStructSetData($tSCROLLINFO, "cbSize", DllStructGetSize($tSCROLLINFO))
	DllStructSetData($tSCROLLINFO, "fMask", $SIF_ALL)

	If $last_capture = "" Then

		$last_capture = ObjCreate("Scripting.Dictionary")
	EndIf

	; if a control ID is specified, then get it's HWND
	If StringCompare($ctrl_id, "") <> 0 Then

		$hWnd = ControlGetHandle($win_title, $win_text, $ctrl_id)

		; if expansion of the control is required.
		If $expand = 1 And StringCompare($delimiter, "") <> 0 Then

			$hwnd2 = $hWnd

			If _GUICtrlComboBox_GetComboBoxInfo($hWnd, $tInfo) Then

				$hWnd = DllStructGetData($tInfo, "hList")
			EndIf

			; Expand the control.
			_GUICtrlComboBox_ShowDropDown($hwnd2, True)
		EndIf
	EndIf

	; if last capture is requested, and one exists.
	If $get_last_capture = 1 And $last_capture.item(Number($hWnd)) <> "" Then

		Return $last_capture.item(Number($hWnd))
	EndIf

	; Text recognition improves alot if the current selection and focus rectangle is removed.
	;	The following code will remove the selection.
	;	After text recognition the selection is returned.
	$sel_index = _GUICtrlListBox_GetCurSel($hWnd)

	; The following two lines should remove the current selection and focus rectangle
	;	in all cases.
	_GUICtrlListBox_SetCurSel($hWnd, -1)
	_GUICtrlListBox_SetCaretIndex($hWnd, -1)

	; Scroll to the top
	DllCall("user32.dll", "int", "SendMessage", "hwnd", $hWnd, "int", $WM_VSCROLL, "int", $SB_TOP, "int", 0)

	For $i = 1 To $max_scroll_times

		If $i > 1 Then

			; Scroll the list down one page
			DllCall("user32.dll", "int", "SendMessage", "hwnd", $hWnd, "int", $WM_VSCROLL, "int", $SB_PAGEDOWN, "int", 0)

		EndIf

		; Get the position of the scroll bar
		DllCall("user32.dll", "int", "GetScrollInfo", "hwnd", $hWnd, "int", $SB_VERT, "ptr", DllStructGetPtr($tSCROLLINFO))
		$xyPos = DllStructGetData($tSCROLLINFO, "nPos")

		; If the scroll bar hasn't moved, we have finished scrolling
		If $xyPos_old = $xyPos Then ExitLoop

		$xyPos_old = $xyPos

		; Perform the text recognition
		WinActivate($win_title)

		$capture_filename = _TempFile($tesseract_temp_path, "~", ".tif")
		$ocr_filename = StringLeft($capture_filename, StringLen($capture_filename) - 4)
		$ocr_filename_and_ext = $ocr_filename & ".txt"

		CaptureToTIFF($win_title, $win_text, $hWnd, $capture_filename, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent)

;~ 		ShellExecuteWait(@ProgramFilesDir & "\tesseract-ocr\tesseract.exe", $capture_filename & " " & $ocr_filename, "", "open", @SW_HIDE)
		RunWait(@ProgramFilesDir & "\tesseract-ocr\tesseract.exe " & $capture_filename & " " & $ocr_filename, $tesseract_temp_path, @SW_HIDE)

		; Return the current selection (if one existed)
		If $sel_index > -1 Then

			_GUICtrlListBox_SetCurSel($hWnd, $sel_index)
		EndIf

		; If no delimter specified, then return a string
		If StringCompare($delimiter, "") = 0 Then

			$final_ocr = FileRead($ocr_filename_and_ext)
			$i = $max_scroll_times
		Else

			_FileReadToArray($ocr_filename_and_ext, $aArray)
			_ArrayDelete($aArray, 0)

			; Append the recognised text to a final array
			_ArrayConcatenate($final_ocr, $aArray)
		EndIf

		; If the captures are to be displayed
		If $show_capture = 1 Then

			GUICreate("Tesseract Screen Capture.  Note: image displayed is not to scale", 640, 480, 0, 0, $WS_SIZEBOX + $WS_SYSMENU) ; will create a dialog box that when displayed is centered

			GUISetBkColor(0xE0FFFF)

			$Obj1 = ObjCreate("Preview.Preview.1")
			$Obj1_ctrl = GUICtrlCreateObj($Obj1, 0, 0, 640, 480)
			$Obj1.ShowFile($capture_filename, 1)

			GUISetState()

			If IsArray($final_ocr) Then

				_ArrayDisplay($aArray, "Tesseract Text Capture")
			Else

				MsgBox(0, "Tesseract Text Capture", $final_ocr)
			EndIf

			GUIDelete()
		EndIf

		FileDelete($ocr_filename & ".*")
	Next

	; Cleanup
	If IsArray($final_ocr) And $cleanup = 1 Then

		; Cleanup the items
		For $final_ocr_num = 1 to (UBound($final_ocr) - 1)

			; Remove erroneous characters
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ".", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], "'", "")
			$final_ocr[$final_ocr_num] = StringReplace($final_ocr[$final_ocr_num], ",", "")
			$final_ocr[$final_ocr_num] = StringStripWS($final_ocr[$final_ocr_num], 3)
		Next

		; Remove duplicate and blank items
		For $each In $final_ocr

			$found_item = _ArrayFindAll($final_ocr, $each)

			; Remove blank items
			If IsArray($found_item) Then
				If StringCompare($final_ocr[$found_item[0]], "") = 0 Then

					_ArrayDelete($final_ocr, $found_item[0])
				EndIf
			EndIf

			; Remove duplicate items
			For $found_item_num = 2 To UBound($found_item)

				_ArrayDelete($final_ocr, $found_item[$found_item_num - 1])
			Next
		Next
	EndIf

	; Store a copy of the capture
	If $last_capture.item(Number($hWnd)) = "" Then

		$last_capture.item(Number($hWnd)) = $final_ocr
	EndIf

	Return $final_ocr
EndFunc   ;==>_TesseractControlCapture

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractScreenFind()
; Description ...:	Finds the location of a string within text captured from the screen.
; Syntax.........:	_TesseractScreenFind($find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$find_str			- The text (string) to find.
;					$partial			- Optional: Find the text using a partial match?
;											0 = use a full text match
;											1 = use a partial text match (default)
;					$get_last_capture	- Search within the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not use the last capture (default)
;											1 = use the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be searched if this isn't provided.
;											The index of the item found will be returned if this is provided.
;											Eg. Use @CRLF to find an item in a listbox.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the screen.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the screen.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the screen.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the screen.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success			- Returns the location of the text that was found.
;											If $delimiter is "", then the character position of the text found
;												is returned.
;											If $delimiter is not "", then the element of the array where the
;												text was found is returned.
;                 	On Failure			- Returns an empty array.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:	No
;
; ;==========================================================================================
Func _TesseractScreenFind($find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	; Get all the text from the screen
	$recognised_text = _TesseractScreenCapture($get_last_capture, $delimiter, $cleanup, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $show_capture)

	If IsArray($recognised_text) Then

		$index_found = _ArraySearch($recognised_text, $find_str, 0, 0, 0, $partial)
	Else

		If $partial = 1 Then
			$index_found = StringInStr($recognised_text, $find_str)
		Else
			If StringCompare($recognised_text, $find_str) = 0 Then
				$index_found = 1
			Else
				$index_found = 0
			EndIf
		EndIf
	EndIf

	Return $index_found
EndFunc   ;==>_TesseractScreenFind

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractWinFind()
; Description ...:	Finds the location of a string within text captured from a window.
; Syntax.........:	_TesseractWinFind($win_title, $win_text = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to find text in.
;					$win_text			- Optional: The text of the window to find text in.
;					$find_str			- The text (string) to find.
;					$partial			- Optional: Find the text using a partial match?
;											0 = use a full text match
;											1 = use a partial text match (default)
;					$get_last_capture	- Search within the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not use the last capture (default)
;											1 = use the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be searched if this isn't provided.
;											The index of the item found will be returned if this is provided.
;											Eg. Use @CRLF to find an item in a listbox.
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the window.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the window.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the window.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the window.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success			- Returns the location of the text that was found.
;											If $delimiter is "", then the character position of the text found
;												is returned.
;											If $delimiter is not "", then the element of the array where the
;												text was found is returned.
;                 	On Failure			- Returns an empty array.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:	No
;
; ;==========================================================================================
Func _TesseractWinFind($win_title, $win_text = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $cleanup = 1, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	; Get all the text from the window
	$recognised_text = _TesseractWinCapture($win_title, $win_text, $get_last_capture, $delimiter, $cleanup, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $show_capture)

	If IsArray($recognised_text) Then

		$index_found = _ArraySearch($recognised_text, $find_str, 0, 0, 0, $partial)
	Else

		If $partial = 1 Then

			$index_found = StringInStr($recognised_text, $find_str)
		Else

			If StringCompare($recognised_text, $find_str) = 0 Then

				$index_found = 1
			Else

				$index_found = 0
			EndIf
		EndIf
	EndIf

	Return $index_found
EndFunc   ;==>_TesseractWinFind

; #FUNCTION# ;===============================================================================
;
; Name...........:	_TesseractControlFind()
; Description ...:	Finds the location of a string within text captured from a control.
; Syntax.........:	_TesseractControlFind($win_title, $win_text = "", $ctrl_id = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)
; Parameters ....:	$win_title			- The title of the window to find text in.
;					$win_text			- Optional: The text of the window to find text in.
;					$ctrl_id			- Optional: The ID of the control to find text in.
;											The text of the window will be usee if one isn't provided.
;					$find_str			- The text (string) to find.
;					$partial			- Optional: Find the text using a partial match?
;											0 = use a full text match
;											1 = use a partial text match (default)
;					$get_last_capture	- Search within the text of the last capture, rather than
;											performing another capture.  Useful if the text in
;											the window or control hasn't changed since the last capture.
;											0 = do not use the last capture (default)
;											1 = use the last capture
;					$delimiter			- Optional: The string that delimits elements in the text.
;											A string of text will be searched if this isn't provided.
;											The index of the item found will be returned if this is provided.
;											Eg. Use @CRLF to find an item in a listbox.
;					$expand				- Optional: Expand the control before searching it?
;											0 = do not expand the control
;											1 = expand the control (default)
;					$scrolling			- Optional: Scroll the control to search all it's text?
;											0 = do not scroll the control
;											1 = scroll the control (default)
;					$cleanup			- Optional: Remove invalid text recognised
;											0 = do not remove invalid text
;											1 = remove invalid text (default)
;					$max_scroll_times	- The maximum number of scrolls to capture in a control
;											If a control has a very long scroll bar, the text recognition
;											process will take too long.  Use this value to restrict
;											the amount of text to recognise in a long control.
;					$scale				- Optional: The scaling factor of the screenshot prior to text recognition.
;											Increase this number to improve accuracy.
;											The default is 2.
;					$left_indent		- A number of pixels to indent the capture from the
;											left of the control.
;					$top_indent			- A number of pixels to indent the capture from the
;											top of the control.
;					$right_indent		- A number of pixels to indent the capture from the
;											right of the control.
;					$bottom_indent		- A number of pixels to indent the capture from the
;											bottom of the control.
;					$show_capture		- Display screenshot and text captures
;											(for debugging purposes).
;											0 = do not display the screenshot taken (default)
;											1 = display the screenshot taken and exit
; Return values .: 	On Success			- Returns the location of the text that was found.
;											If $delimiter is "", then the character position of the text found
;												is returned.
;											If $delimiter is not "", then the element of the array where the
;												text was found is returned.
;                 	On Failure			- Returns an empty array.
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:	Yes
;
; ;==========================================================================================
Func _TesseractControlFind($win_title, $win_text = "", $ctrl_id = "", $find_str = "", $partial = 1, $get_last_capture = 0, $delimiter = "", $expand = 1, $scrolling = 1, $cleanup = 1, $max_scroll_times = 5, $scale = 2, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $show_capture = 0)

	; Get all the text from the control
	$recognised_text = _TesseractControlCapture($win_title, $win_text, $ctrl_id, $get_last_capture, $delimiter, $expand, $scrolling, $cleanup, $max_scroll_times, $scale, $left_indent, $top_indent, $right_indent, $bottom_indent, $show_capture)

	If IsArray($recognised_text) Then

		$index_found = _ArraySearch($recognised_text, $find_str, 0, 0, 0, $partial)
	Else

		If $partial = 1 Then

			$index_found = StringInStr($recognised_text, $find_str)
		Else

			If StringCompare($recognised_text, $find_str) = 0 Then

				$index_found = 1
			Else

				$index_found = 0
			EndIf
		EndIf
	EndIf

	Return $index_found
EndFunc   ;==>_TesseractControlFind

; #FUNCTION# ;===============================================================================
;
; Name...........:	CaptureToTIFF()
; Description ...:	Captures an image of the screen, a window or a control, and saves it to a TIFF file.
; Syntax.........:	CaptureToTIFF($win_title = "", $win_text = "", $ctrl_id = "", $sOutImage = "", $scale = 1, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0)
; Parameters ....:	$win_title		- The title of the window to capture an image of.
;					$win_text		- Optional: The text of the window to capture an image of.
;					$ctrl_id		- Optional: The ID of the control to capture an image of.
;										An image of the window will be returned if one isn't provided.
;					$sOutImage		- The filename to store the image in.
;					$scale			- Optional: The scaling factor of the capture.
;					$left_indent	- A number of pixels to indent the screen capture from the
;										left of the window or control.
;					$top_indent		- A number of pixels to indent the screen capture from the
;										top of the window or control.
;					$right_indent	- A number of pixels to indent the screen capture from the
;										right of the window or control.
;					$bottom_indent	- A number of pixels to indent the screen capture from the
;										bottom of the window or control.
; Return values .: 	None
; Author ........:	seangriffin
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:	No
;
; ;==========================================================================================
Func CaptureToTIFF($win_title = "", $win_text = "", $ctrl_id = "", $sOutImage = "", $scale = 1, $left_indent = 0, $top_indent = 0, $right_indent = 0, $bottom_indent = 0, $aWhiteLevel = -1)
	Local $hWnd, $hwnd2, $hDC, $hBMP, $hImage1, $hGraphic, $CLSID, $tParams, $pParams, $tData, $i = 0, $hImage2, $pos[4]
	Local $Ext = StringUpper(StringMid($sOutImage, StringInStr($sOutImage, ".", 0, -1) + 1))
	Local $giTIFColorDepth = 24
	Local $giTIFCompression = $GDIP_EVTCOMPRESSIONNONE

	; If capturing a control
	If StringCompare($ctrl_id, "") <> 0 Then

		$hwnd2 = ControlGetHandle($win_title, $win_text, $ctrl_id)
		$pos = ControlGetPos($win_title, $win_text, $ctrl_id)
	Else

		; If capturing a window
		If StringCompare($win_title, "") <> 0 Then
			$hwnd2 = WinGetHandle($win_title, $win_text)

			Local $tRect = _WinAPI_GetClientRect($hwnd2)
			$pos[0] = DllStructGetData($tRect, "Left")
			$pos[1] = DllStructGetData($tRect, "Top")
			$pos[2] = DllStructGetData($tRect, "Right")
			$pos[3] = DllStructGetData($tRect, "Bottom")
		Else

			; If capturing the desktop
			$hwnd2 = ""
			$pos[0] = 0
			$pos[1] = 0
			$pos[2] = @DesktopWidth
			$pos[3] = @DesktopHeight
		EndIf
	EndIf

	If IsHWnd($hwnd2) Then
		_WinAPI_SwitchToThisWindow($hwnd2, True)
		$hBitmap2 = _ScreenCapture_CaptureWndClient("", $hwnd2, $left_indent, $top_indent, -$right_indent, -$bottom_indent, False)
	Else
		$hBitmap2 = _ScreenCapture_Capture("", 0, 0, -1, -1, False)
	EndIf

	_GDIPlus_Startup()

	; Convert the image to a bitmap
	$hImage2 = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap2)

	$hWnd = _WinAPI_GetDesktopWindow()
	$hDC = _WinAPI_GetDC($hWnd)
	$hBMP = _WinAPI_CreateCompatibleBitmap($hDC, (($pos[2] - $right_indent) - ($pos[0] + $left_indent)) * $scale, (($pos[3] - $bottom_indent) - ($pos[1] + $top_indent)) * $scale)

	_WinAPI_ReleaseDC($hWnd, $hDC)
	$hImage1 = _GDIPlus_BitmapCreateFromHBITMAP($hBMP)
	$hGraphic = _GDIPlus_ImageGetGraphicsContext($hImage1)
;~     _GDIPLus_GraphicsDrawImageRect($hGraphic, $hImage2, 0 - ($left_indent * $scale), 0 - ($top_indent * $scale), ($pos[2] + $left_indent) * $scale, ($pos[3] + $top_indent) * $scale)
	$hImage3 = _GDIPlus_ImageGrayscale($hImage2)

	If $aWhiteLevel > -1 Then
		For $aX = $pos[0] To ($pos[2] - $pos[0]) - $right_indent - $left_indent - 1 Step 1
			For $aY = $pos[1] To ($pos[3] - $pos[1]) - $bottom_indent - $top_indent - 1 Step 1
				Local $curPixel = BitXOR(_GDIPlus_BitmapGetPixel($hImage3, $aX, $aY), 0xFF000000)
				$curPixel = _ColorGetRGB($curPixel)
				If Not @error Then
					If $curPixel[0] < $aWhiteLevel Then
						_GDIPlus_BitmapSetPixel($hImage3, $aX, $aY, $GDIP_BLACK)
					Else
						_GDIPlus_BitmapSetPixel($hImage3, $aX, $aY, $GDIP_WHITE)
					EndIf
				EndIf
			Next
		Next
	EndIf

	Local $tColorMatrix = _GDIPlus_ColorMatrixCreate()
	Local $tPreHue = _GDIPlus_ColorMatrixCreate()
	Local $tPostHue = _GDIPlus_ColorMatrixCreate()

	_GDIPlus_ColorMatrixInitHue($tPreHue, $tPostHue)
	Local $pColorMatrix = DllStructGetPtr($tColorMatrix)

	; Adjust the image hue by 90 degrees rotation
	_GDIPlus_ColorMatrixRotateHue($tColorMatrix, $tPreHue, $tPostHue, 90)

	; Create the contrast ImageAttributes object
	Local $hContIA = _GDIPlus_ImageAttributesCreate()
	$tColorMatrix = _GDIPlus_ColorMatrixCreateNegative()
	_GDIPlus_ColorMatrixScale($tColorMatrix, 4, 4, 4)
	$pColorMatrix = DllStructGetPtr($tColorMatrix)

	; Fix colors by hue rotation
	_GDIPlus_ColorMatrixRotateHue($tColorMatrix, $tPreHue, $tPostHue, 0)

	; Adjust the image contrast
	_GDIPlus_ImageAttributesSetColorMatrix($hContIA, 0, True, $pColorMatrix)

;~     _GDIPLus_GraphicsDrawImageRect($hGraphic, $hImage3, 0 - ($left_indent * $scale), 0 - ($top_indent * $scale), ($pos[2] - $pos[0]) * $scale , ($pos[3] - $pos[1]) * $scale)
	_GDIPlus_GraphicsScaleTransform($hGraphic, $scale, $scale)
;~     _GDIPLus_GraphicsDrawImageRectRectIA($hGraphic, $hImage3, $left_indent, $top_indent, ($pos[2] - $pos[0]) - $left_indent - $right_indent, ($pos[3] - $pos[1]) - $top_indent - $bottom_indent, 0, 0, (($pos[2] - $right_indent) - ($pos[0] + $left_indent)), (($pos[3] - $bottom_indent) - ($pos[1] + $top_indent)), $hContIA)
    _GDIPLus_GraphicsDrawImageRectRectIA($hGraphic, $hImage3, 0, 0, ($pos[2] - $pos[0]) - $left_indent - $right_indent, ($pos[3] - $pos[1]) - $top_indent - $bottom_indent, 0, 0, (($pos[2] - $right_indent) - ($pos[0] + $left_indent)), (($pos[3] - $bottom_indent) - ($pos[1] + $top_indent)), $hContIA)

;~ 	_GDIPLus_GraphicsDrawImageRectRectIA($hGraphic, $hImage3, $left_indent, $top_indent, ($pos[2] - $pos[0]) - $left_indent - $right_indent, ($pos[3] - $pos[1]) - $top_indent - $bottom_indent, 0, 0, (($pos[2] - $right_indent) - ($pos[0] + $left_indent)), (($pos[3] - $bottom_indent) - ($pos[1] + $top_indent)), $hContIA)

	_GDIPlus_ImageAttributesDispose($hContIA)
;~     _GDIPLus_GraphicsDrawImageRect($hGraphic, $hImage2, 0 - $left_indent, 0 - $top_indent, (($pos[2] - $right_indent) - ($pos[0] + $left_indent)) * $scale, (($pos[3] - $bottom_indent) - ($pos[1] + $top_indent)) * $scale)
	$CLSID = _GDIPlus_EncodersGetCLSID($Ext)

	; Set TIFF parameters
	$tParams = _GDIPlus_ParamInit(2)
	$tData = DllStructCreate("int ColorDepth;int Compression")
	DllStructSetData($tData, "ColorDepth", $giTIFColorDepth)
	DllStructSetData($tData, "Compression", $giTIFCompression)
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOLORDEPTH, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "ColorDepth"))
	_GDIPlus_ParamAdd($tParams, $GDIP_EPGCOMPRESSION, 1, $GDIP_EPTLONG, DllStructGetPtr($tData, "Compression"))
	If IsDllStruct($tParams) Then $pParams = DllStructGetPtr($tParams)

	; Save TIFF and cleanup
	_GDIPlus_ImageSaveToFileEx($hImage1, $sOutImage, $CLSID, $pParams)
	_WinAPI_DeleteObject($hBitmap2)
	_GDIPlus_ImageDispose($hImage1)
	_GDIPlus_ImageDispose($hImage2)
	_GDIPlus_ImageDispose($hImage3)
	_GDIPlus_GraphicsDispose($hGraphic)
	_WinAPI_DeleteObject($hBMP)
	_GDIPlus_Shutdown()
EndFunc   ;==>CaptureToTIFF

;;    Creates a grayscale copy of Image object and returns its handle. To destroy it, use _GDIPlus_ImageDispose() or _GDIPlus_BitmapDispose()
Func _GDIPlus_ImageGrayscale(Const ByRef $hImage)
	Local $iW = _GDIPlus_ImageGetWidth($hImage), $iH = _GDIPlus_ImageGetHeight($hImage)

	Local $tColorMatrix = _GDIPlus_ColorMatrixCreate()
	Local $tPreHue = _GDIPlus_ColorMatrixCreate()
	Local $tPostHue = _GDIPlus_ColorMatrixCreate()
	_GDIPlus_ColorMatrixInitHue($tPreHue, $tPostHue)
	Local $pColorMatrix = DllStructGetPtr($tColorMatrix)
	_GDIPlus_ColorMatrixRotateHue($tColorMatrix, $tPreHue, $tPostHue, 90)

Local $hContIA = _GDIPlus_ImageAttributesCreate()
	$tColorMatrix = _GDIPlus_ColorMatrixCreateGrayScale()
	$pColorMatrix = DllStructGetPtr($tColorMatrix)
	_GDIPlus_ColorMatrixRotateHue($tColorMatrix, $tPreHue, $tPostHue, 0)
	_GDIPlus_ImageAttributesSetColorMatrix($hContIA, 0, True, $pColorMatrix)
	;;copy image
	$hGraphics = _GDIPlus_ImageGetGraphicsContext($hImage)
	$hBitmap = _GDIPlus_BitmapCreateFromGraphics($iW, $iH, $hGraphics)
	$hGraphics2 = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	;;draw original into copy with attributes
	_GDIPlus_GraphicsDrawImageRectRectIA($hGraphics2, $hImage, 0, 0, $iW, $iH, 0, 0, $iW, $iH, $hContIA)
	;;clean up
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_GraphicsDispose($hGraphics2)
	_GDIPlus_ImageAttributesDispose($hContIA)

	Return $hBitmap
EndFunc   ;==>_GDIPlus_ImageGreyscale

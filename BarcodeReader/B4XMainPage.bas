B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private cvs As B4XCanvas
	Private lblResult As B4XView
	Private reader As DBR
	Private Panel1 As B4XView
	Private xPercent As Double
	Private yPercent As Double
End Sub

Public Sub Initialize
    reader.Initialize
	#if b4a
	reader.initLicenseFromLTS("200001")	
	#Else if b4j
	reader.initLicenseFromKey("t0075xQAAAEUicOSVdOGZ4EZ/VxishmCoVr+hWw1MHA/HVLn/Tcn4rrPWS5q4/XutioRWZuPhRqYc7M819vfK8OJWilkG+Ic1yw9e6ypy")
	#Else if b4i
	reader.initLicenseFromKey("t0068MgAAAJWPwDybm7nk0f9xYH25MMaVrZYcmhsiVoZrVo2hfcwRS74T6QA79OfzyvhC+9fgFI2noI8zBc66WHFCusVUgqk=")
	#else
	
	#End If	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")	
	cvs.Initialize(Panel1)
End Sub

'You can see the list of page related events in the B4XPagesManager object. The event name is B4XPage.

Private Sub btnLoadImage_Click
	Dim bm As B4XBitmap
	
	#if b4a 
	Dim cc As ContentChooser
	cc.Initialize("CC")
	cc.Show("image/*", "Choose image")
	Wait For CC_Result (Success As Boolean, Dir As String, FileName As String)
	If Success Then
		bm=LoadBitmap(Dir,FileName)
	Else
		ToastMessageShow("No image selected", True)
	End If	
	#End If
	
	#if b4i
	Dim cam As Camera
	cam.Initialize("camera",B4XPages.GetNativeParent(Me))
	cam.SelectFromSavedPhotos(Sender, cam.TYPE_ALL)
	Wait For camera_Complete (Success As Boolean, Image As Bitmap, VideoPath As String)
	Log(Success)
	If Success Then
		bm=Image
		bm=bm.Rotate(90)	
	End If
	#End If
	
	#if b4j
    Dim fc As FileChooser
	fc.Initialize
	Dim path As String=fc.ShowOpen(B4XPages.GetNativeParent(Me))	
	If File.Exists(path,"") Then
	    Dim fx As JFX
		bm=fx.LoadImage(path,"")
	End If		
	#End If	
	
	cvs.ClearRect(cvs.TargetRect)
	
	drawBitmap(bm)
	Panel1.Tag=bm
End Sub

Private Sub drawBitmap(bitmap As B4XBitmap)
	Dim resized As B4XBitmap=bitmap.Resize(cvs.TargetView.Width,cvs.TargetView.Height,True)
	Dim rect As B4XRect
	rect.Initialize(0,0,resized.Width,resized.Height)
	cvs.DrawBitmap(resized,rect)
	cvs.Invalidate
	xPercent=resized.Width/bitmap.Width
	yPercent=resized.Height/bitmap.Height
End Sub

Private Sub btnDecode_Click		
	Dim bm As B4XBitmap=Panel1.Tag
	Dim results As List=reader.decodeImage(bm)
	Dim sb As StringBuilder
	sb.Initialize
	Dim color As Int=xui.Color_Red
	Dim stroke As Int=2
	For Each result As TextResult In results
		sb.Append("Text: ").Append(result.Text).Append(CRLF)
		For i=0 To 2
			Dim x1 As Int=result.ResultPoints(i).x*xPercent
			Dim y1 As Int=result.ResultPoints(i).y*yPercent
			Dim x2 As Int=result.ResultPoints(i+1).x*xPercent
			Dim y2 As Int=result.ResultPoints(i+1).y*yPercent
			cvs.DrawLine(x1,y1,x2,y2,color,stroke)
		Next
		cvs.DrawLine(result.ResultPoints(3).x*xPercent, _
					 result.ResultPoints(3).y*yPercent, _ 
					 result.ResultPoints(0).x*xPercent, _
					 result.ResultPoints(0).y*yPercent,color,stroke)
	Next	
	cvs.Invalidate
	lblResult.Text=sb.ToString
End Sub
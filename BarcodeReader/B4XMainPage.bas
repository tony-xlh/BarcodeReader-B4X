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
	'request your license here: https://www.dynamsoft.com/customer/license/trialLicense?ver=latest
	#if b4j
	reader.initLicenseFromKey("t0075xQAAAEUicOSVdOGZ4EZ/VxishmCoVr+hWw1MHA/HVLn/Tcn4rrPWS5q4/XutioRWZuPhRqYc7M819vfK8OJWilkG+Ic1yw9e6ypy")
	#else
	reader.initLicenseFromLTS("200001")	
	#End If	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")	
	cvs.Initialize(Panel1)
	B4XPages.SetTitle(Me,"Barcode Reader")
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
	cam.SelectFromSavedPhotos(Sender, cam.TYPE_IMAGE)	
	Wait For camera_Complete (Success As Boolean, Image As Bitmap, VideoPath As String)
	Log(Success)
	If Success Then
		bm=Utils.asNO(Me).RunMethod("normalizedImage:",Array(Image))			
	End If
	#End If
	
	#if b4j
    Dim fc As FileChooser
	fc.Initialize
	Dim path As String=fc.ShowOpen(B4XPages.GetNativeParent(Me))	
	If File.Exists(path,"") Then
		bm=xui.LoadBitmap(path,"")
	End If		
	#End If	
	
	If bm.IsInitialized And bm<>Null Then		 
		cvs.ClearRect(cvs.TargetRect)
		drawBitmap(bm)
		Panel1.Tag=bm
	End If
End Sub

Private Sub drawBitmap(bitmap As B4XBitmap)	
	Dim resized As B4XBitmap=resizeIfNeeded(bitmap)
	Dim rect As B4XRect
	rect.Initialize(0,0,resized.Width,resized.Height)
	cvs.DrawBitmap(resized,rect)
	cvs.Invalidate
	xPercent=resized.Width/bitmap.Width
	yPercent=resized.Height/bitmap.Height
End Sub

private Sub resizeIfNeeded(bitmap As B4XBitmap) As B4XBitmap
	Dim ratio As Double=bitmap.Width/bitmap.Height
	Dim targetWidth,targetHeight As Int
	targetWidth=bitmap.Width
	targetHeight=bitmap.Height
	If targetWidth>=cvs.TargetView.Width Then
		targetWidth=cvs.TargetView.Width
		targetHeight=targetWidth/ratio
	End If
	If targetHeight>=cvs.TargetView.Height Then
		targetWidth=targetHeight/cvs.TargetView.Height*targetWidth
		targetHeight=cvs.TargetView.Height
	End If
	If targetWidth=bitmap.Width And targetHeight=bitmap.Height Then ' no need to resize
		Return bitmap
	Else
		Return bitmap.Resize(targetWidth,targetHeight,True)
	End If
	
End Sub

Private Sub btnDecode_Click		
	If (Panel1.Tag Is B4XBitmap)=False  Then
		xui.MsgboxAsync("Please load an image first","")
		Return
	End If
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

Private Sub lblResult_Click
    Utils.SetClipboardString(lblResult.Text)
	xui.MsgboxAsync("Copied to clipboard","")
End Sub

#if b4j
Private Sub lblResult_MouseClicked (EventData As MouseEvent)
	lblResult_Click
End Sub
#End If

#if b4i
#if objc
//https://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
- (UIImage *)normalizedImage: (UIImage*) image {
    if (image.imageOrientation == UIImageOrientationUp) return image; 
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}
#End If
#End If



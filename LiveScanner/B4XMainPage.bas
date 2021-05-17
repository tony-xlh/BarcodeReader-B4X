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
	Private pnlPreview As B4XView
	Private btnStartStop As B4XView
	#if B4J
	Private vlc As B4JVlcj
	Private MRITextField As B4XView
	Private OptionsTextField As B4XView
	Private Timer1 As Timer
	Private decoding As Boolean=False
	#else
	Private LastPreview As Long
	Private IntervalBetweenPreviewsMs As Int = 200
	#if B4A
	Private rp As RuntimePermissions
	Private camEx As CameraExClass
	#End If
	#if B4i
	Private llc As LLCamera
	#End If
	#End If
	Private reader As DBR
	Private toast As BCToast
	Private lblResult As B4XView
	Private Capturing As Boolean
End Sub

Public Sub Initialize
	
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	toast.Initialize(Root)
	StopCamera
	B4XPages.SetTitle(Me, "Barcode Example") 	
	reader.Initialize
	
	#if b4j
	If vlc.IsVLCInstalled = False Then
		'Implement your own code to tell user that VLC must be installed.
		'Note: if VLC has been installed in a non-standard directory, VLC might not be found.
		Log("VLC must be installed on the computer to run this program.")
		ExitApplication
	End If
	vlc.Initialize("vlc")
	pnlPreview.AddView(vlc.Player,0,0,pnlPreview.Width,pnlPreview.Height)
	Timer1.Initialize("Timer1",1000)
	reader.initLicenseFromKey("t0075xQAAAEUicOSVdOGZ4EZ/VxishmCoVr+hWw1MHA/HVLn/Tcn4rrPWS5q4/XutioRWZuPhRqYc7M819vfK8OJWilkG+Ic1yw9e6ypy")
	#else
	reader.initLicenseFromLTS("200001")
	#End If
	
	btnStartStop.Enabled = True
End Sub

Private Sub B4XPage_Disappear
	StopCamera
End Sub


Sub btnStartStop_Click
	If Capturing = False Then
		StartCamera
	Else
		StopCamera
	End If
End Sub

Private Sub StopCamera
	Capturing = False
	btnStartStop.Text = "Start"
	pnlPreview.Visible = False
	#if B4A
	If camEx.IsInitialized Then
		camEx.Release
	End If
	#Else If B4i
	llc.StopPreview
	#Else If B4j
	vlc.Pause
	Timer1.Enabled=False
	#end if
End Sub

Private Sub StartCameraShared
	btnStartStop.Text = "Stop"
	pnlPreview.Visible = True
	Capturing = True
End Sub

Private Sub ShowResults (results As List)
	If results.Size=0 Then
		lblResult.Text=""
	Else
		Dim sb As StringBuilder
		sb.Initialize
		Dim index As Int=0
		For Each result As TextResult In results
			sb.Append(result.Text)
			If index<>results.Size-1 Then
				sb.Append(", ")
			End If
			index=index+1
		Next
		lblResult.Text = sb.ToString		
		toast.Show($"Found [Color=Blue][b][plain]${results.Size}[/plain][/b][/Color] barcode(s)"$)
	End If
	
End Sub

#if B4A
Private Sub StartCamera
	rp.CheckAndRequest(rp.PERMISSION_CAMERA)
	Wait For B4XPage_PermissionResult (Permission As String, Result As Boolean)
	If Result = False Then
		toast.Show("No permission!")
		Return
	End If
	StartCameraShared
	camEx.Initialize(pnlPreview, False, Me, "Camera1")
	Wait For Camera1_Ready (Success As Boolean)
	If Success Then
		camEx.SetContinuousAutoFocus
		camEx.CommitParameters
		camEx.StartPreview
	Else
		toast.Show("Error opening camera")
		StopCamera
	End If
End Sub

Private Sub Camera1_Preview (data() As Byte)
	If DateTime.Now > LastPreview + IntervalBetweenPreviewsMs Then			
		Dim bm As Bitmap=BytesToImage(camEx.PreviewImageToJpeg(data,100))		
		Dim results As List=reader.decodeImage(bm)	
		ShowResults(results)
		LastPreview = DateTime.Now
	End If
End Sub

Public Sub BytesToImage(bytes() As Byte) As Bitmap
	Dim In As InputStream
	In.InitializeFromBytesArray(bytes, 0, bytes.Length)
	Dim bmp As Bitmap
	bmp.Initialize2(In)
	Return bmp
End Sub

#Else if B4I

Private Sub StartCamera
	If llc.IsInitialized Then llc.StopPreview
	llc.Initialize(pnlPreview, "llc", False)
	llc.StartPreview	
	ConfigureCamera
	StartCameraShared
End Sub

Private Sub ConfigureCamera
	Try
		llc.BeginConfiguration
		llc.FlashMode = llc.FLASH_AUTO		
		llc.PreserveRatio = True		
		llc.CommitConfiguration
	Catch
		Log("Error configuring camera: " & LastException.Description)
	End Try
End Sub

Private Sub llc_Preview (Image As Bitmap)
	If DateTime.Now > LastPreview + IntervalBetweenPreviewsMs Then				
		Dim results As List=reader.decodeImage(Image)
		ShowResults(results)	
		LastPreview = DateTime.Now	
	End If
	llc.ReleaseFrame(Image)
End Sub

#Else if B4J

Private Sub StartCamera
	If OptionsTextField.Text<>"" Then
		getMp.RunMethod("playMedia",Array(MRITextField.Text,getOptions))		
	Else
		vlc.Play(MRITextField.Text)
	End If
	Timer1.Enabled=True
	StartCameraShared
End Sub

Private Sub getOptions As String()
	Dim values() As String=Regex.Split(" :",OptionsTextField.Text)
	Dim index As Int=0
	For Each item As String In values
		values(index)=":"&item.Trim()
		index=index+1
	Next
	': :dshow-vdev=USB Camera :dshow-adev= :dshow-size=640x480 :live-caching=300
	'dshow://
	Return values
End Sub

private Sub getMp As JavaObject
	Dim jo As JavaObject=vlc.player
	Dim mp As JavaObject=jo.RunMethod("getMp",Null)
	Return mp
End Sub

Sub Timer1_Tick
	If decoding Then
		Return
	End If
	Dim bufferedImage As JavaObject=getMp.RunMethod("getSnapshot",Null)
	If bufferedImage.IsInitialized Then
		Dim SwingFXUtils As JavaObject
		SwingFXUtils.InitializeStatic("javafx.embed.swing.SwingFXUtils")
		Dim image As B4XBitmap = SwingFXUtils.RunMethod("toFXImage",Array(bufferedImage, Null))
		decoding=True
		ShowResults(reader.decodeImage(image))
		decoding=False
	End If
End Sub

Private Sub pnlPreview_Resize (Width As Double, Height As Double)
	Dim n As Node=vlc.player
	If n.IsInitialized Then
		n.SetSize(Width,Height)
	End If
End Sub

Sub B4XPage_CloseRequest As ResumableSub
	Log("We are closing the mainform")
	Try
		vlc.stop
		vlc.release
	Catch
		Log(LastException)
	End Try	
End Sub

#End If



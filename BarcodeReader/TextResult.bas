B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private mTextResult As JavaObject
	Private mText As String
	Private mResultPoints(4) As Point
	Type Point(x As Int,y As Int)
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(result As Object)
	mTextResult=result	
	Parse
End Sub

Private Sub Parse
	mText=mTextResult.GetField("barcodeText")
	Dim points() As Object=mTextResult.GetFieldJO("localizationResult").GetField("resultPoints")
	For i=0 To 3
		Dim point As JavaObject=points(i)
		Dim b4xPoint As Point
		b4xPoint.Initialize
		b4xPoint.x=point.GetField("x")
		b4xPoint.y=point.GetField("y")
		mResultPoints(i)=b4xPoint
	Next
End Sub

Public Sub getObject As Object
	Return mTextResult
End Sub

Public Sub getText As String
	Return mText
End Sub

Public Sub getResultPoints As Point()
	Return mResultPoints
End Sub

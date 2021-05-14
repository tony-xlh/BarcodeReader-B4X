B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.8
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

#if b4i
Public Sub asNO(o As Object) As NativeObject
	Dim no As NativeObject
	no=o
	Return no
End Sub
#else
public Sub asJO(o As Object) As JavaObject
	Dim jo As JavaObject
	jo=o
	Return jo
End Sub
#End If

public Sub SetClipboardString(s As String)
	#if b4i
	Dim cb As Clipboard
	cb.StringItem=s
	#End If	
	#if b4j	
	Dim fx As JFX
	fx.Clipboard.SetString(s)	
	#End If
	#if b4a
	Dim cb As BClipboard
	cb.setText(s)
	#End If
End Sub

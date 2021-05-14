B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.8
@EndOfDesignText@
'Static code module
Sub Process_Globals

End Sub

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

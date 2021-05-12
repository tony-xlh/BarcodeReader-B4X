B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	Private reader As JavaObject
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	reader.InitializeNewInstance("com.dynamsoft.dbr.BarcodeReader",Null)		
End Sub

'not available for B4J
public Sub initLicenseFromLTS(organizationID As String)
	asJO(Me).RunMethod("initLicenseFromLTS",Array(reader,organizationID))
	Log(reader.RunMethod("getVersion",Null))
End Sub

public Sub initLicenseFromKey(license As String)
	reader.RunMethod("initLicense",Array(license))
	Log(reader.RunMethod("getVersion",Null))
End Sub

Sub ConvertToTextResults(results() As Object) As List
	Dim list1 As List
	list1.Initialize
	For Each result As Object In results
		Dim tr As TextResult
		tr.Initialize(result)
		list1.Add(tr)
	Next
	Return list1
End Sub

Sub decodeBufferedImage(bitmap As B4XBitmap) As List	
	Dim results() As Object
	#If b4j
	Dim utils As JavaObject
	utils.InitializeStatic("javafx.embed.swing.SwingFXUtils")
	Dim bufferedImage As Object=utils.RunMethod("fromFXImage",Array(bitmap,Null))
	results=reader.RunMethod("decodeBufferedImage",Array(bufferedImage,""))
	#else
	results=reader.RunMethod("decodeBufferedImage",Array(bitmap,""))    
	#End If	
	Return ConvertToTextResults(results)
End Sub


#If b4i

#Else
private Sub asJO(o As Object) As JavaObject
	Dim jo As JavaObject
	jo=o
	Return jo
End Sub
#End If

#If b4a

#if java
import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.BarcodeReaderException;
import com.dynamsoft.dbr.DMLTSConnectionParameters;
import com.dynamsoft.dbr.DBRLTSLicenseVerificationListener;
public static void initLicenseFromLTS(BarcodeReader dbr,String organizationID){
	DMLTSConnectionParameters parameters = new DMLTSConnectionParameters();
    parameters.organizationID = organizationID;
    dbr.initLicenseFromLTS(parameters, new DBRLTSLicenseVerificationListener() {
        @Override
        public void LTSLicenseVerificationCallback(boolean isSuccess, Exception error) {
            if (!isSuccess) {
                error.printStackTrace();
            }
        }
    });
}
#End If

#End If

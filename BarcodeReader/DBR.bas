B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10.5
@EndOfDesignText@
Sub Class_Globals
	#if b4i
	Private reader As NativeObject 'ignore
	#else
	Private reader As JavaObject
	#End If
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(license As String)
	#if b4j
	Dim readerStatic As JavaObject
	readerStatic.InitializeStatic("com.dynamsoft.dbr.BarcodeReader")
	readerStatic.RunMethod("initLicense",Array(license))
	#End If
	
	#if b4a
	asJO(Me).RunMethod("initLicense",Array(license))
	#End If
	
	#if b4i
reader=asNO(Me).RunMethod("initializeDBRFromLTS:",Array(organizationID))
	#else
	reader.InitializeNewInstance("com.dynamsoft.dbr.BarcodeReader",Null)		
	#End If
End Sub

private Sub ConvertToTextResults(results() As Object) As List
	Dim list1 As List
	list1.Initialize
	For Each result As Object In results
		Dim tr As TextResult
		tr.Initialize(result)
		list1.Add(tr)
	Next
	Return list1
End Sub

private Sub ConvertToTextResults2(results As List) As List
	Dim list1 As List
	list1.Initialize
	For Each result As Object In results
		Dim tr As TextResult
		tr.Initialize(result)
		list1.Add(tr)
	Next
	Return list1
End Sub

Sub decodeImage(bitmap As B4XBitmap) As List	
		
	#if b4i	
	Dim results As List=asNO(Me).RunMethod("decodeImage:",Array(bitmap))
	Return ConvertToTextResults2(results)
	
	#Else	
	Dim results() As Object
	
	#If b4j
	
	Dim SwingFXUtils As JavaObject
	SwingFXUtils.InitializeStatic("javafx.embed.swing.SwingFXUtils")
	Dim bufferedImage As Object=SwingFXUtils.RunMethod("fromFXImage",Array(bitmap,Null))
	results=reader.RunMethod("decodeBufferedImage",Array(bufferedImage,""))
	
	#else if b4a
	
	results=reader.RunMethod("decodeBufferedImage",Array(bitmap,""))    
	
	#End If	
	
	Return ConvertToTextResults(results)
	#end if
	
End Sub


#if b4i
private Sub asNO(o As Object) As NativeObject
	Dim no As NativeObject
	no=o
	Return no
End Sub
#else
private Sub asJO(o As Object) As JavaObject
	Dim jo As JavaObject
	jo=o
	Return jo
End Sub
#End If

#If b4a

#if java
import com.dynamsoft.dbr.BarcodeReader;
import com.dynamsoft.dbr.DBRLicenseVerificationListener;
public static void initLicense(String license){
    BarcodeReader.initLicense(license, new DBRLicenseVerificationListener() {
        @Override
        public void DBRLicenseVerificationCallback(boolean isSuccess, Exception error) {
            if(!isSuccess){
               error.printStackTrace();
            }
        }
    });
}
#End If

#End If

#if b4i
#If ObjC
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>
- (DynamsoftBarcodeReader*) initializeDBR: (NSString*) license {

    DynamsoftBarcodeReader *dbr;

    dbr = [[DynamsoftBarcodeReader alloc] initWithLicense:license];
    NSLog(dbr.getVersion);
    return dbr;

}

- (DynamsoftBarcodeReader*) initializeDBRFromLTS: (NSString*) organizationID {

    DynamsoftBarcodeReader *dbr;
	iDMLTSConnectionParameters* lts = [[iDMLTSConnectionParameters alloc] init];
	lts.organizationID = organizationID;	
	dbr = [[DynamsoftBarcodeReader alloc] initLicenseFromLTS:lts verificationDelegate:self];
	return dbr;
 }
 
- (NSArray<iTextResult*>*) decodeImage: (UIImage*) image {
    NSError __autoreleasing * _Nullable error;
    DynamsoftBarcodeReader* dbr=self->__reader.object;
    NSArray<iTextResult*>* result = [dbr decodeImage:image withTemplate:@"" error:&error];    
	NSLog(@"%lu",(unsigned long)result.count);
    return result;
}

#end if
#End If

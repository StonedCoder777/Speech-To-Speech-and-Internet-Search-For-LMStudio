unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, uWVWinControl,
  uWVWindowParent, uWVBrowserBase, uWVBrowser,
  uWVTypes, uWVConstants, uWVTypeLibrary,
  uWVLibFunctions, uWVLoader, uWVInterfaces, uWVCoreWebView2Args,
  uWVCoreWebView2SharedBuffer, Vcl.StdCtrls, System.IOUtils, unit1;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    Panel1: TPanel;
    Timer1: TTimer;
    Timer2: TTimer;
    WVBrowser1: TWVBrowser;
    WVWindowParent1: TWVWindowParent;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure CheckAndCreateMicAccessFile;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure WVBrowser1AfterCreated(Sender: TObject);
    procedure WVBrowser1WebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
    Procedure Myshow;
  private
    { Private declarations }

    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;

  public
    { Public declarations }
       ReallyShow:Boolean;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}



Procedure Tform2.Myshow;
begin

  begin
  self.BorderStyle := bsDialog;
  Form2.Width:=1405;
  Form2.Height:=650;
  Form2.Top := Form1.Top-20;
  Form2.Left := Form1.Left;
  Form2.ReallyShow := True;
  Form2.Show;
  WVWindowParent1.UpdateSize;
  end;
end;

procedure TForm2.WVBrowser1WebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
var
  TempArgs: TCoreWebView2WebMessageReceivedEventArgs;
  MessageData: string;
  ButtonSelected: Integer;
begin
  TempArgs := TCoreWebView2WebMessageReceivedEventArgs.Create(aArgs);
  MessageData := TempArgs.WebMessageAsString;

  if pos('[MICSTATUS]',messagedata)>0 then
  begin

    if pos('[MICSTATUS]Allowed',MessageData)>0 then
   begin
   Button1.click;  // Start Speech Recognition
   CheckAndCreateMicAccessFile;
   EXIT;
   end;

     if pos('[MICSTATUS]Denied',MessageData)=0 then
   begin
   // Delete cache before loading browser so it prompts again for mic access
   Form1.MyShowMessage2('Access to the microphone has been denied.');
   end;

      if pos('[MICSTATUS]Error',MessageData)=0 then
   begin
       Form1.MyShowMessage2('There was an error whilst accessing the microphone.');
   end;
  end;

      if pos('[INTERIM]',messagedata)>0 then
  begin
     Delete(messagedata,1,9);
     Form1.Memo3.Text:= MessageData;
     exit;
  end;

      if pos('[FINAL]',messagedata)>0 then
  begin
    Delete(messagedata,1,7);
    Form1.Memo3.Text:= MessageData;

    //Auto submit recognized speech
      if Form1.Checkbox3.Checked then
     Begin
     if Form1.Button1.enabled=True then Form1.Button1.Click;
     End;
     exit;
  end;

      if pos('[STARTED]',messagedata)>0 then
  begin
  Form1.SpeechRecognitionOn:=True;
  Form1.Image2.Visible:=False;      // black
  Form1.Image3.Visible:=True;       // green
  Form1.Image4.Visible:=False;      // red
  Application.ProcessMessages;
  end;

      if pos('[STOPPED]',messagedata)>0 then
  begin
    Form1.SpeechRecognitionOn:=False;
    Form1.Image2.Visible:=True;       // black
    Form1.Image3.Visible:=False;      //green
    Form1.Image4.Visible:=False;      // red
    Application.ProcessMessages;
  //  Button2.Click;
  end;

end;

//------------------------------------------------------------------------------
// Start Speech Recognition
procedure TForm2.Button1Click(Sender: TObject);

var
  jsCode: string;

begin
  jsCode :=

  'document.getElementById("start_button").style.display = "none";' + #13#10 +
  'var firstH1 = document.querySelector(''h1'');' + #13#10 +
  'if (firstH1) { ' + #13#10 +
  '    firstH1.textContent = ''Voice Recognition for LM Studio'';' + #13#10 +
  '}' + #13#10 +
  '' + #13#10 +
  'var final_transcript = '''';' + #13#10 +
  'var interim_transcript = '''';' + #13#10 +
  'var timeout;  // This will hold the timeout function' + #13#10 +
  '' + #13#10 +
  '// Add event listeners for start and end of speech recognition' + #13#10 +

  'recognition.start();' + #13#10 +

  'recognition.onstart = function() {' + #13#10 +
  '    sendMessage(''[STARTED]'');' + #13#10 +
  '};' + #13#10 +
  '' + #13#10 +
  'recognition.onend = function() {' + #13#10 +
  '    sendMessage(''[STOPPED]'');' + #13#10 +
  '};' + #13#10 +
  '' + #13#10 +
  'recognition.onresult = function(event) {' + #13#10 +
  '    interim_transcript = '''';' + #13#10 +
  '    for (var i = event.resultIndex; i < event.results.length; ++i) {' + #13#10 +
  '        if (event.results[i].isFinal) {' + #13#10 +
  '            final_transcript += event.results[i][0].transcript;' + #13#10 +
  '        } else {' + #13#10 +
  '            interim_transcript += event.results[i][0].transcript;' + #13#10 +
  '        }' + #13#10 +
  '    }' + #13#10 +
  '' + #13#10 +
  '    // Update the HTML with the final and interim results' + #13#10 +
  '    document.getElementById(''final_span'').innerHTML = linebreak(final_transcript);' + #13#10 +
  '    document.getElementById(''interim_span'').innerHTML = linebreak(interim_transcript);' + #13#10 +
  '' + #13#10 +
  '    // Trim and send interim transcript if it contains text' + #13#10 +
  '    var trimmedInterim = interim_transcript.trim();' + #13#10 +
  '    if (trimmedInterim) {' + #13#10 +
  '        sendMessage(''[INTERIM] '' + trimmedInterim);' + #13#10 +
  '    }' + #13#10 +
  '' + #13#10 +
  '    // Clear any previous timeout' + #13#10 +
  '    clearTimeout(timeout);' + #13#10 +
  '' + #13#10 +
  '    // Set a new timeout to stop recognition if no new text is recognized in 3 seconds' + #13#10 +
  '    timeout = setTimeout(function() {' + #13#10 +
  '        recognition.stop();  // Stop recognition after 3 seconds of inactivity' + #13#10 +
  '' + #13#10 +
  '        // Trim and send final transcript if it contains text' + #13#10 +
  '        var trimmedFinal = final_transcript.trim();' + #13#10 +
  '        if (trimmedFinal) {' + #13#10 +
  '            sendMessage(''[FINAL] '' + trimmedFinal);' + #13#10 +
  'document.getElementById(''final_span'').innerHTML = "";' + #13#10 +
  'document.getElementById(''interim_span'').innerHTML = "";' + #13#10 +
  '        }' + #13#10 +
  '    }, 3000);  // Wait for 3 seconds (3000 ms)' + #13#10 +
  '};' + #13#10 +
  '' + #13#10 +
  'function sendMessage(message) {' + #13#10 +
  '    console.log(''Sending message:'', message);' + #13#10 +
  '    if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === "function") {' + #13#10 +
  '        window.chrome.webview.postMessage(message);' + #13#10 +
  '    } else {' + #13#10 +
  '        console.log(''window.chrome.webview.postMessage is not available.'');' + #13#10 +
  '        console.log(''Message:'', message);' + #13#10 +
  '    }' + #13#10 +
  '}';

 if Assigned(WVBrowser1) then  WVBrowser1.ExecuteScript(jscode);

end;

//------------------------------------------------------------------------------
 // Stop Speech Recognition
procedure TForm2.Button2Click(Sender: TObject);
var jscode:String;
begin
  jscode:= 'recognition.stop();';
   if Assigned(WVBrowser1) then  WVBrowser1.ExecuteScript(jscode);
end;
//------------------------------------------------------------------------------
// Check Mic Status

procedure TForm2.Button4Click(Sender: TObject);
var js:String;
begin

js:=
   'document.getElementById("start_button").style.display = "none";' + #13#10 +
  'var firstH1 = document.querySelector(''h1'');' + #13#10 +
  'if (firstH1) { ' + #13#10 +
  '    firstH1.textContent = ''Voice Recognition for LM Studio'';' + #13#10 +
  '}' + #13#10 +

  'function sendMessage(message) {' + #13#10 +

  '    console.log(''Sending message:'', message);' + #13#10 +
  '    if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === "function") {' + #13#10 +
  '        window.chrome.webview.postMessage(message);' + #13#10 +
  '    } else {' + #13#10 +
  '        console.log(''window.chrome.webview.postMessage is not available.'');' + #13#10 +
  '        console.log(''Message:'', message);' + #13#10 +
  '    }' + #13#10 +
  '}'+ #13#10 +

'async function checkMicPermission() {' + #13#10 +
'    try {' + #13#10 +
'        // Attempt to get access to the microphone' + #13#10 +
'        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });' + #13#10 +
'        // If successful, stop the stream' + #13#10 +
'        stream.getTracks().forEach(track => track.stop());' + #13#10 +
'        console.log(''Microphone access granted'');' + #13#10 +
'            sendMessage("[MICSTATUS]Allowed");' + #13#10 +
'        return true; // Permission granted' + #13#10 +
'    } catch (error) {' + #13#10 +
'        if (error.name === ''NotAllowedError'' || error.name === ''PermissionDeniedError'') {' + #13#10 +
'            sendMessage(''[MICSTATUS]Denied'');' + #13#10 +
'        } else {' + #13#10 +
'            sendMessage(''[MICSTATUS]Error'');' + #13#10 +
'        }' + #13#10 +
'        return false; // Permission denied' + #13#10 +
'    }' + #13#10 +
'}' + #13#10 +

'checkMicPermission();' ;

if Assigned(WVBrowser1) then  WVBrowser1.ExecuteScript(js);
end;
//--------------------------------------------------------------------=---------
procedure TForm2.Button5Click(Sender: TObject);
begin
Form2.hide;
end;
//------------------------------------------------------------------------------
procedure TForm2.FormCreate(Sender: TObject);
begin
Form2.ReallyShow:=False;
Form2.hide;
end;
//------------------------------------------------------------------------------
procedure TForm2.FormShow(Sender: TObject);
  var
  jsCode : string;
  begin

    if Not Form2.ReallyShow then
  begin
    form2.Top := Form1.Top;
    form2.Left := Form1.Left;
    Self.BorderStyle := bsNone;
    form2.Height :=10;
    form2.Width :=10;
    Application.ProcessMessages;
    Form2.Update;
  end;


  jsCode :=

   // Make Sure we Hid The Mic Button And Cahnge The H1 Header
   'document.getElementById("start_button").style.display = "none";' + #13#10 +
  'var firstH1 = document.querySelector(''h1'');' + #13#10 +
  'if (firstH1) { ' + #13#10 +
  '    firstH1.textContent = ''Voice Recognition for LM Studio'';' + #13#10 +
  '}' ;

   if Assigned(WVBrowser1) then  WVBrowser1.ExecuteScript(jscode);

   // Load The Browser
  if GlobalWebView2Loader.InitializationError then
    showmessage(GlobalWebView2Loader.ErrorMessage)
    else
    if GlobalWebView2Loader.Initialized then
    WVBrowser1.CreateBrowser(WVWindowParent1.Handle)
    else
    Timer1.Enabled := True;
    end;

//------------------------------------------------------------------------------
// Load The Browser Timer
procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if GlobalWebView2Loader.Initialized then
    WVBrowser1.CreateBrowser(WVWindowParent1.Handle)
   else
    Timer1.Enabled := True;
end;
//------------------------------------------------------------------------------
// Handles Hiding Form 2 - If it is hidden initially the window to Request Mic Access Will Not Show
procedure TForm2.Timer2Timer(Sender: TObject);
begin
Timer2.Enabled:=False;
if ReallyShow=False then begin
Form2.Hide;
end;

end;
//------------------------------------------------------------------------------
procedure TForm2.WMMove(var aMessage : TWMMove);
begin
  inherited;
  if (WVBrowser1 <> nil) then
  WVBrowser1.NotifyParentWindowPositionChanged;
end;
//------------------------------------------------------------------------------
procedure TForm2.WMMoving(var aMessage : TMessage);
begin
  inherited;
  if (WVBrowser1 <> nil) then
  WVBrowser1.NotifyParentWindowPositionChanged;
end;
 //-----------------------------------------------------------------------------
procedure TForm2.WVBrowser1AfterCreated(Sender: TObject);
begin
  WVWindowParent1.UpdateSize;
  WVBrowser1.Navigate('https://www.google.com/intl/en/chrome/demos/speech.html');
  WVWindowParent1.UpdateSize;
end;
//------------------------------------------------------------------------------

// If  micaccessgranted.txt Doesn't exist then create it. This is the flag that
// tells us whether mic access has been granted for voice recognition
procedure Tform2.CheckAndCreateMicAccessFile;
var
  FileName: string;
begin
  FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'micaccessgranted.txt');

  if not FileExists(FileName) then
  begin
    try
      TFile.Create(FileName).Free;
      Form1. DeleteFileIfExists('deletecache.txt');  // If access Has Been Granted we Don't Need This Flag
    //  ShowMessage('File created: ' + FileName);
    except
      on E: Exception do
    //  ShowMessage('Error creating file: ' + E.Message);
    end;
  end
  else
  begin
   //  ShowMessage('File already exists: ' + FileName);
  end;
end;
//------------------------------------------------------------------------------
initialization
  GlobalWebView2Loader                := TWVLoader.Create(nil);
  GlobalWebView2Loader.UserDataFolder := ExtractFileDir(Application.ExeName) + '\CustomCache';
  GlobalWebView2Loader.StartWebView2;
end.

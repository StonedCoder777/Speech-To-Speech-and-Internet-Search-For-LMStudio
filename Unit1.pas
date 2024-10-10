
// This app enables you to send Prompts to Large Language Models running in LM Studio using your voice in 90 languages and 125 dialects
// The Model's esponses can be spoken back to you in over 1400 voices in 90 languages
//   This app also enables LM Studio Models to be able to access Google, wikipedia etc

// Compiled with Delphi Rio
// You Will Need Browser Component https://github.com/salvadordf/WebView4Delphi

// Demo on Youtube
// https://www.youtube.com/watch?v=l1uYTuZoB6Q

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdTCPConnection,
  IdTCPClient, IdHTTP, IdBaseComponent, IdComponent, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdGlobal, System.JSON,
  uWVWinControl, uWVWindowParent, uWVBrowserBase, uWVBrowser,
  uWVTypes, uWVConstants, uWVTypeLibrary,
  uWVLibFunctions, uWVLoader, uWVInterfaces, uWVCoreWebView2Args,
  uWVCoreWebView2SharedBuffer, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.Imaging.pngimage, System.IOUtils, Inifiles;


type
  TForm1 = class(TForm)
     // Network components
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdHTTP1: TIdHTTP;

    // UI components
    Button1: TButton; // Injects JavaScript
    Button2: TButton;   // New Chat
    Button3: TButton; // Retry TTS After Error
    Button4: TButton; // Grants Internet Access
    Button5: TButton; // Denys Internet Access
    Button6: TButton;   //Cancel Button

    Memo1: TMemo;     // Chat Window
    Memo2: TMemo;     // Extracted Text
    Memo3: TMemo;     // User Prompt Input
    Memo4: TMemo;     // System Prompt
    Memo5: TMemo;     // Javascript Injected On DomContentLoaded After Webpage Has Loaded
    Memo6: TMemo;     // Enter Model
    Memo7: TMemo;           // Debug Memo

    Label1: TLabel;   // Enter Model
    Label2: TLabel;

    Panel1: TPanel;   // Web Browser Panel
    Panel2: TPanel;   // Flashing Panel For Internet Access Request

    RadioGroup1: TRadioGroup; // Controls Visibility Of Memos 2, 4, 5 & 6
    ComboBox1: TComboBox;   // Voice Selection

    // Browser components
    WVBrowser1: TWVBrowser;
    WVWindowParent1: TWVWindowParent;

    // Timer components
    Timer1: TTimer;     // Load Web Browser
    Timer2: TTimer;    // Flash Internet Access Request Panel
    Timer3: TTimer;   // Launch URL
    Timer4: TTimer;         // Send Ai generated Text To Toext To Speech

    Edit1: TEdit;           // LM Studio Server Address

    CheckBox1: TCheckBox; // Grant Permanent Internet Access
    CheckBox2: TCheckBox;   // Sets LM Studio Connection To Local Host
    CheckBox3: TCheckBox;   // Auto Submit Recognized Speech
    CheckBox4: TCheckBox;    // Enable TTS

    Image1: TImage;   // Animated Image Wait Whilst I process Webpage
    Image2: TImage;         //Mic Black  (OFF)
    Image3: TImage;         //Mic Green (ON)
    Image4: TImage;          //Mic Red  (ERROR)
    Image5: TImage;     // Black TTS Icon (TTS OFF)
    Image6: TImage;     // Green TTS Icon (TTS ON)
    Image7: TImage;         // Green TTS Icon (LOADING)   // ** From Old TTS
    Image8: TImage;         // Animated Green TTS Icon (Speaking)




    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure WVBrowser1AfterCreated(Sender: TObject);
    procedure ExecuteJavaScript(const JavaScriptCode: string);
    procedure WVBrowser1WebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
    procedure GoToURL(URL: String);
    procedure WVBrowser1DOMContentLoaded(Sender: TObject;
      const aWebView: ICoreWebView2;
      const aArgs: ICoreWebView2DOMContentLoadedEventArgs);

    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure SendPrompt(const Prompt: string);
    procedure RadioGroup1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image2DblClick(Sender: TObject);
    procedure Image3DblClick(Sender: TObject);
    procedure Image4DblClick(Sender: TObject);
    Procedure MyShowMessage2(str:string);
    procedure CheckAndCreateMicAccessFile(Create:Boolean);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DeleteFileIfExists(const FileName: string);
    procedure Timer4Timer(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image5MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Image3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image7Click(Sender: TObject);
    procedure Image7MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image8Click(Sender: TObject);
    procedure Image8MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBox1Change(Sender: TObject);
    procedure SaveSettings;
    procedure LoadSettings;
    procedure Edit1Exit(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Memo3Change(Sender: TObject);


  private
     Conversation:String;  // Chat History

     MyShowMessage: Boolean; // We do not want to show the message in the chat window if we are sending the text extracted from a webpage and asking for a summerization
     PanelVisible:Boolean;   // Flash Green Panel When Requesting Internet Accesss
     PermanentAccess:Boolean; // Has The User Granted Permanent Access To The Internet
     ServerAddress:string;
     PromptThread: TThread;  // Global thread variable allows us to kill the thread when Cancel Button is clicked
    function ParseContentFromJSON(const JSONResponse: string): string;
    function GetUrl(const Response: string): string;
   protected

    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;


  public
    { Public declarations }
   SpeechRecognitionOn:Boolean; // Are we Recognizing Speech
    GlobalResponse:String; // Global string to hold response from server
    TTStatus:String;       // Status Of TTS  speaking / ready etc
    Initializing : Boolean;  //  used for when loading settings when app starts
  end;



  type
  TSendPromptThread = class(TThread)
  private
    FForm: TForm1;
    FPrompt: string;

  protected
    procedure Execute; override;
  public
    constructor Create(AForm: TForm1; const APrompt: string);
  end;



var
  Form1: TForm1;



implementation



{$R *.dfm}
        uses unit2, unit3;

//------------------------------------------------------------------------------
// Stop the app freezing when sending requests to the LM Studio Server

constructor TSendPromptThread.Create(AForm: TForm1; const APrompt: string);
begin
  inherited Create(True); // Create the thread suspended
  FreeOnTerminate := True; // Free the thread when done
  FForm := AForm;
  FPrompt := APrompt;
  Resume; // Start the thread
end;

//------------------------------------------------------------------------------

procedure TSendPromptThread.Execute;
begin
    FForm.SendPrompt(FPrompt); // Execute SendPrompt in the thread
end;
//------------------------------------------------------------------------------
// Save Settings When Exiting Edit1
 procedure TForm1.Edit1Exit(Sender: TObject);
begin
SaveSettings;
end;
//------------------------------------------------------------------------------
// Executes Javascript
procedure TForm1.ExecuteJavaScript(const JavaScriptCode: string);

  begin
  if Assigned(WVBrowser1) then
  WVBrowser1.ExecuteScript(JavaScriptCode);
  end;
//------------------------------------------------------------------------------
// Stop certain characters messing up the prompt being sent
function JsonEscape(const Value: string): string;
var
  I: Integer;
  Ch: Char;
  IsEscaped: Boolean;
begin
  Result := '';
  IsEscaped := False;
  for I := 1 to Length(Value) do
  begin
    Ch := Value[I];
    if IsEscaped then
    begin
      Result := Result + Ch;
      IsEscaped := False;
    end
    else if Ch = '\' then
    begin
      Result := Result + '%5C';
      IsEscaped := True;
    end
    else
    begin
      case Ch of
        '"': Result := Result + '';
        '/': Result := Result + '/';
        #8: Result := Result + ' ';
        #9: Result := Result + ' ';
        #10: Result := Result + ' ';
        #12: Result := Result + ' ';
        #13: Result := Result + ' ';
        else
          if (Ch < ' ') or (Ch > '~') then
            Result := Result + '\u' + IntToHex(Ord(Ch), 4)
          else
            Result := Result + Ch;
      end;
    end;
  end;
end;
//------------------------------------------------------------------------------
//============================  Start Chat  ====================================
procedure TForm1.Button1Click(Sender: TObject);
Begin

// If othe button to retry TSS after there was an error is present, hide it and clear tts list ready for fresh response
if Button3.Visible then
begin
 Form3.ListofThingsToSay.Clear;
 Button3.Visible := False;
end;

  // Show Processing Image
  Image1.Visible:=True;

  // Prevent New pages Being Loaded & Further Prompts Being Sent Until A Response Is Received
  Button1.Enabled:=False;
  Button2.Enabled:=False;
  WVWindowParent1.Enabled:=False;
  Button6.Visible:=True;  // Cancel Button
  // Start thread that posts prompt to the LMStudio Server
  PromptThread := TSendPromptThread.Create(Self, Memo3.Text);
End;
//-----------------------------------------------------------------------------

// Start thread that posts prompt to the LMStudio Server

procedure TForm1.SendPrompt(const Prompt: string);

var
  JsonToSend: string;
  StringStream: TStringStream;
  Response: string;
  EscapedTextToSend: string;
  SystemPrompt: string;
  ParseMarker:integer;
  SummerizedText:String;
  addconvo:Boolean;
begin
addconvo:=True;
SystemPrompt := Memo4.Text;

 // We do not want to show the message in the chat window if we are sending the text extracted from a webpage and asking for a summerization
 if MyShowMessage then
   Begin
  Memo1.Lines.Add('User: ' + Prompt);
  Memo1.Lines.Add('');
   End;

  MyShowMessage:=True;
  Conversation := JsonEscape(Conversation);
  EscapedTextToSend := JsonEscape(Prompt);

  // If there is no chat history  just send prompt
 if length(Conversation) < 2 then
    JsonToSend := '{' +
      '"model": "''",' +
      '"messages": [' +
      '  { "role": "system", "content": "' + JsonEscape(SystemPrompt) + '" },' +
      '  { "role": "user", "content": "' + EscapedTextToSend + '" }' +
      '],' +
      '"temperature": 0.7,' +
      '"max_tokens": -1,' +
      '"stream": false' +
      '}' ;

      // If there is chat history append chat history to prompt
  if length(Conversation) > 2 then
    JsonToSend := '{' +
     '"model": "''",' +
      '"messages": [' +
      '  { "role": "system", "content": "' + JsonEscape(SystemPrompt) + '" },' +
      '  { "role": "user", "content": "Conversation History To be used as reference only, ' +
      'do not mention it in your response: ' + Conversation + ' | End of Conversation History. ' +
      'Now respond to the users last input: ' + EscapedTextToSend + '" }' +
      '],' +
      '"temperature": 0.7,' +
      '"max_tokens": -1,' +
      '"stream": false' +
      '}';


   // If we are not asking to summerize text from websearch Append new Prompt to chat history
   // Should add AI side of conversation too ??

   Memo3.Clear;
   Application.ProcessMessages;
  Conversation := JsonEscape(Conversation);
  StringStream := TStringStream.Create(JsonToSend, TEncoding.UTF8);
  try
    IdHTTP1.Request.ContentType := 'application/json';
    IdHTTP1.ReadTimeout := 600000; // 60 seconds
    IdHTTP1.ConnectTimeout := 30000; // 30 seconds
    IdHTTP1.IOHandler := IdSSLIOHandlerSocketOpenSSL1;
    IdHTTP1.HandleRedirects := True;
    IdHTTP1.Request.Accept := 'text/event-stream';

    try

      Response := IdHTTP1.Post(Edit1.Text, StringStream);
      //Memo2.Lines.Add(Response);
      Response := ParseContentFromJSON(Response);

      // Hide "Processing Webpage" Label and  Animated Image
      Label1.Visible:=False;
      Image1.Visible:=False;

      //Enabled Send Prompt & New Chat Button & Browser
      Button1.Enabled:=True;
      Button2.Enabled:=True;
      Button6.Visible:=False; // Cancel Button
      WVWindowParent1.Enabled:=True;


      Response := StringReplace(Response, '</Iinternet>', '</Internet>', [rfReplaceAll]); // Llama 3.1 8B Q8 Likes to do this ?
      Response := StringReplace(Response, '<Iinternet>', '<Internet>', [rfReplaceAll]); // Llama 3.1 8B Q8 Likes to do this ?
      Response := StringReplace(Response, '<Iternet>', '<Internet>', [rfReplaceAll]); // Llama 3.1 8B Q8 Likes to do this ?
      Response := StringReplace(Response, '</Iternet>', '</Internet>', [rfReplaceAll]); // Llama 3.1 8B Q8 Likes to do this ?
      Response := StringReplace(Response, '</internet>', '</Internet>', [rfReplaceAll]); // Llama 3.1 8B Q8 Likes to do this ?
      Response := StringReplace(Response, '<internet>', '<Internet>', [rfReplaceAll]); // Llama 3.1 8B Q8 Likes to do this ?


      //  Check If <Internet> Tag is in Response
      if (Pos('<Internet>', Response) > 0) and (Pos('</Internet>', Response) > 0) then

      begin
                                                                           // Only continue if the <Internet> is NOT in a summerization
            if (Pos('I found this on the Internet:', Response) = 0) then   // do not open urls in sumerizations can cause a loop



      Begin
         GlobalResponse:=Response;

        // Request Internet Access
        if Not PermanentAccess then
        begin
        Application.ProcessMessages;
        Timer2.Enabled:=True;
        end;


        // No Need To Request Access
        if  PermanentAccess then
        begin
        // Execute in Timer because of threading
        Timer3.Enabled:=True;
        end;

       end;

     end;

   // If the response is a summerization of a webpage then add it to the coversation history for context


   // If 'I found this on the Internet:' is not included in the response do not add AI's response to the conversation it can get big quick..
   // maybe refine this so it keeps limmited context ??
   if (Pos('I found this on the Internet:', Response) > 0) then
  begin

    Response:=Form3.RemoveInternetTags(Response); // delete any internet tags else we could end up dow a rabbit hole of infinite loop
                                                  // with AI outputting links in summerizations then
    ParseMarker := Pos('I found this on the Internet:', Response) + Length('I found this on the Internet:');
    SummerizedText:=Copy(Response, ParseMarker, Length(Response));
    Conversation:=Conversation+'. '+ SummerizedText;
  end;

      // Add the AI's response to the chat window
      Memo1.Lines.Add('AI Assistant: ' + Response);
      Memo1.Lines.Add('');

      // Check TTS
   //   if Checkbox4.Checked = True then
     // begin
      GlobalResponse:=Response;
      Timer4.Enabled:=True;
     // end;


    except
      on E: Exception do
      begin
      addconvo:=false;
      if pos('Disconnected.',E.Message)=0 then  // In Case User Clicked Cancel Button Do Not Show Error

      begin
        Memo1.Lines.Add('Error: ' + E.Message);
        addconvo:=False; // Promt was unlikely to be sent so do not add it to Conversation History
       // ShowMessage('Error: ' + E.Message);
       end;

      // Hide "Processing Webpage" Label and  Animated Image
      Label1.Visible:=False;
      Image1.Visible:=False;

      //Enabled Send Prompt & New Chat Button & Browser
      Button1.Enabled:=True;
      Button2.Enabled:=True;
      Button6.Visible:=False; // Cancel Button
      WVWindowParent1.Enabled:=True;
      end;
    end;
  finally
    Memo1.Lines.Add('');
    if Memo1.Text <> '' then
    // update the conversation history
    if addconvo then
    begin

      If pos('<Instruction>', Prompt)=0 then
   Begin
   Conversation := Conversation +'. '+ Prompt;
   End;
    Conversation := JsonEscape(Conversation);

    end;
    idhttp1.Disconnect;
    StringStream.Free;
  end;
end;

//-----------------------------------------------------------------------------

// Request Internet Access Buttons

//------------------------------------------------------------------------------
// Access Granted Button Clicked

procedure TForm1.Button4Click(Sender: TObject);
begin
  Button4.Visible:=False;
  Button5.Visible:=False;
  Timer2.Enabled:=False;
  PanelVisible:=False;
  Panel2.Visible:=False;
  GoToURL(GetUrl(GlobalResponse));
end;
//------------------------------------------------------------------------------
// Access Denied Button CLicked
procedure TForm1.Button5Click(Sender: TObject);
begin
  Button4.Visible:=False;
  Button5.Visible:=False;
  Timer2.Enabled:=False;
  PanelVisible:=False;
  Panel2.Visible:=False;

  //Enabled Send Prompt & New Chat Button & Browser
  Button1.Enabled:=True;
  Button2.Enabled:=True;
  WVWindowParent1.Enabled:=True;
end;
//------------------------------------------------------------------------------
// Cancel Button
procedure TForm1.Button6Click(Sender: TObject);
begin

    // Check if the thread is running and terminate it
 try
  if IdHTTP1.Connected then
    IdHTTP1.Disconnect;
except
  // Handle any exceptions during disconnection, if necessary
end;

   if Assigned(PromptThread) then
  begin
    PromptThread.Terminate;
    PromptThread := nil;  // Clear the reference
  end;
  // Hide "Processing Webpage" Label and  Animated Image
      Label1.Visible:=False;
      Image1.Visible:=False;

      //Enabled Send Prompt & New Chat Button & Browser
      Button1.Enabled:=True;
      Button2.Enabled:=True;
      Button6.Visible:=False; // Cancel Button
      WVWindowParent1.Enabled:=True;
end;

//-----------------------------------------------------------------------------

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
 if Checkbox1.checked then PermanentAccess:=True;
 if NOt Checkbox1.checked then PermanentAccess:=True;
 SaveSettings;
end;
//------------------------------------------------------------------------------
procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.checked then
    Edit1.Text := 'http://localhost:1234/v1/chat/completions'
  else
    Edit1.Text := ServerAddress;
    SaveSettings;
end;
procedure TForm1.CheckBox3Click(Sender: TObject);
begin
 SaveSettings;
end;

procedure TForm1.CheckBox4Click(Sender: TObject);
begin

 SaveSettings;

end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
str:string;
begin
  if ComboBox1.ItemIndex >= 0 then
  Begin
    Form3.VoiceToUse := Form3.RealNamesList[ComboBox1.ItemIndex];
    Form3.ServiceToUse := Form3.ServiceList[ComboBox1.ItemIndex];
   if Form3.CharLimitList[ComboBox1.ItemIndex]<>'' then Form3.TTSMaxLength :=  StrToInt(Form3.CharLimitList[ComboBox1.ItemIndex]);
     end;

 
    if Form3.TTSMaxLength <> Form3.OldTTSMaxLength then   // if max length has changed and there are things to say we need
                                                          // to resplit the text to be spoken so it matches the right length
     begin




       if Form3.ListofThingsToSay.Count>0 then       // if there are items on the list to say we need to join them all up and re-split
       Begin                                        // them according to the new voice's maximum character allowance
       str := Form3.ListofThingsToSay.Text; // Gather the seperate segments into one string
       Form3.ListofThingsToSay.clear;     //  clear the list of segments split at a different maximum character allowance
       Form3.ManageTTSList(str);  // resubmit the complete string to be split at the appropriate character limit
       End;

     end;

    Form3.OldTTSMaxLength := Form3.TTSMaxLength; // This Helps Detect If The Max Character Count Changes
   if Not Initializing then SaveSettings;
end;

//------------------------------------------------------------------------------
procedure TForm1.GoToURL(URL: String);
begin
   WVWindowParent1.UpdateSize;
   WVBrowser1.Navigate(URL);
   WVWindowParent1.UpdateSize;
end;

//------------------------------------------------------------------------------
// Speech Recognition Start Image Is Clicked
procedure TForm1.Image2Click(Sender: TObject);
var
FileName:string;
begin

  FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'micaccessgranted.txt');

  if  FileExists(FileName) then
  begin
  Form2.Button1.click; // Start Voice Recognition We Know Mic access has been granted
  end;

  if not FileExists(FileName) then
  begin
  Form2.Button4.click; // Check Mic Permissions // Injects Javascript to access mic to trigger permissions request
  end;

end;

//------------------------------------------------------------------------------
procedure TForm1.Image3Click(Sender: TObject);
begin
Form2.Button2.click; // stop recognition Refresh Voice Recognition Page
    Form1.Image2.Visible:=True;      // black
    Form1.Image3.Visible:=False;      //green
    Form1.Image4.Visible:=False;     // red
end;
//------------------------------------------------------------------------------
procedure TForm1.Image2DblClick(Sender: TObject);
begin
 Form2.ReallyShow:=True;
 Form2.Myshow;
end;
//------------------------------------------------------------------------------
procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button=MBRight then
begin

  Form2.ReallyShow:=True;
  Form2.Myshow;
end;
end;
//------------------------------------------------------------------------------
procedure TForm1.Image3DblClick(Sender: TObject);
begin
  Form2.ReallyShow:=True;
  Form2.Myshow;
end;
procedure TForm1.Image3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=MBRight then
begin
  Form2.ReallyShow:=True;
  Form2.MyShow;
end;
end;

//------------------------------------------------------------------------------
procedure TForm1.Image4DblClick(Sender: TObject);
begin
ShowMessage('Please restart the app and reactivate speech recognition.');
end;

procedure TForm1.Image5Click(Sender: TObject);
begin
Image6.Visible := True;
Image5.Visible := False;
Checkbox4.Checked := True;
end;

procedure TForm1.Image5MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button=MBRight then
begin
  Form3.ReallyShow := True;
  Form3.MYShow;
end;
end;

procedure TForm1.Image6Click(Sender: TObject);
begin
Image6.Visible := False;
Image5.Visible := True;
Checkbox4.Checked := False;
Form3.ListofThingsToSay.clear;
end;

procedure TForm1.Image6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button=MBRight then
begin
 Form3.ReallyShow := True;
 Form3.MyShow;

end;
end;

// Cancel TTS When It Is Loading  Loading Image
procedure TForm1.Image7Click(Sender: TObject);
begin
 Form3.Button4.Click;
end;
 // animated Speaking Image
procedure TForm1.Image7MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if Button=MBRight then
begin
 Form3.ReallyShow := True;
 Form3.MyShow;
end;
end;

procedure TForm1.Image8Click(Sender: TObject);
begin

Form3.ListofThingsToSay.Clear;
form3.StopSpeaking;

end;

procedure TForm1.Image8MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin


if Button=MBRight then
begin
 Form3.ReallyShow := True;
 Form3.MyShow;
end;

end;

//------------------------------------------------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
begin
Initializing := True;
Memo1.Clear;
Memo2.Clear;
Memo3.Clear;
Memo4.Clear;
Memo5.Clear;
Memo6.Clear;
Memo7.Clear;
PermanentAccess:=False;
Conversation:='';
MyShowMessage:=True;
PanelVisible:=False;
(Image1.Picture.Graphic as TGIFImage).Animate := True;
(Image7.Picture.Graphic as TGIFImage).Animate := True;
(Image8.Picture.Graphic as TGIFImage).Animate := True;
SpeechRecognitionOn:=False;
Form1.TTStatus := '[READY]';

Image2.Hint := 'Start Speech Recognition' + #13#10 + 'Right Click for settings';
Image3.Hint := 'Stop Speech Recognition' + #13#10 + 'Right Click for settings';
Image4.Hint := 'Restart Application And Allow Mic Access' + #13#10 + 'To Enable Speech Recognition';


Image5.Hint := 'Enable AI Voice' + #13#10 + 'Right click for settings';
Image6.Hint := 'Disable AI Voice' + #13#10 + 'Right click for settings';


// System Prompt
Memo4.Text:= 'You are a helpful, smart, kind, and efficient AI assistant. ' +
    'You always fulfill the users requests to the best of your ability. ' +
    'Keep your responses AS SHORT AS POSSIBLE!!!! unless asked to elaborate. ' +
    'For contemporary or up-to-date information, you can retrieve information from webpages by outputting the URL between <Internet> tags. ' +
    'To gather up-to-date information on a SUBJECT, output ' +
    '<Internet>https://www.google.com/search?q=SUBJECT</Internet>. ONLY EVER output google urls in internet tags ';

Memo4.Text:='You are a helpful, smart, kind, and efficient AI assistant. ' +
   'You always fulfill the users requests to the best of your ability. ' +
   'Keep your responses AS SHORT AS POSSIBLE!!!!' +
   'When asked for up-to-date information, output a variation of:' +
   'I''ll look online now<Internet>https://www.google.com/search?q=SUBJECTOFENQUIRY</Internet>';

Memo4.Text:='You are a helpful, smart, kind, and efficient AI assistant. ' +
   'You always fulfill the users requests to the best of your ability. ' +
   'Keep your responses AS SHORT AS POSSIBLE!!!!' +
   'When asked for up-to-date information, output a VARIATION of ' +
   'I''ll look online now<Internet>https://www.google.com/search?q=SUBJECTOFENQUIRY</Internet> ' +
   'then say what, if any current info you have';



// Javascript that extracts text from google
Memo5.Text:= 'console.log("Starting text extraction script...");' +

    'function extractTextFromPage() {' +
    '  return document.body.innerText;' +
    '}' +
    'var extractedText = extractTextFromPage();' +
    'if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === "function") {' +
    '  window.chrome.webview.postMessage("[EXTRACTEDTEXT]"+extractedText);' +
    '} else {' +
    '  console.log("window.chrome.webview.postMessage is not available.");' +
    '}';

// Prompt sent to Lm Studio with the text extracted from the webpage
// [EXTRACTEDTEXT] is replaced with the extracted text
// the <Instruction> tag prevents the prompt being shown in the chat memo
Memo6.Text:= '<Instruction>[EXTRACTEDTEXT] Summerize this AS BRIEFLY AS POSSIBLE,retaining ALL relevant facts, do not comment just do it!...Start your output with "I found this on the Internet:" followed by the summerization</Instruction>';


RadioGroup1.ItemIndex:=0;

end;
//------------------------------------------------------------------------------
procedure TForm1.FormShow(Sender: TObject);
  begin

    CheckAndCreateMicAccessFile(False);// if the deletecache.txt is present it deletes the cache before loading the browser
    // This will make the Allow Mic Access Show After The User Has Refused Access Previously

  if GlobalWebView2Loader.InitializationError then
    showmessage(GlobalWebView2Loader.ErrorMessage)
    else
    if GlobalWebView2Loader.Initialized then
      WVBrowser1.CreateBrowser(WVWindowParent1.Handle)
     else
      Timer1.Enabled := True;
    end;
//------------------------------------------------------------------------------
function TForm1.ParseContentFromJSON(const JSONResponse: string): string;
var
  JSONValue: TJSONValue;
  JSONObject: TJSONObject;
  ChoicesArray: TJSONArray;
  MessageObject: TJSONObject;
  ContentObject: TJSONObject; // New variable to hold the 'message' object
  ContentValue: TJSONValue;
begin
  Result := '';

  JSONValue := TJSONObject.ParseJSONValue(JSONResponse);
  try
    if JSONValue <> nil then
    begin
      JSONObject := JSONValue as TJSONObject;

      // Extract choices array
      ChoicesArray := JSONObject.GetValue('choices') as TJSONArray;
      if (ChoicesArray <> nil) and (ChoicesArray.Count > 0) then
      begin
        // Extract first choice object
        MessageObject := ChoicesArray.Items[0] as TJSONObject;

        // Extract 'message' object from the choice
        ContentObject := MessageObject.GetValue('message') as TJSONObject;
        if ContentObject <> nil then
        begin
          // Extract 'content' value from the 'message' object
          ContentValue := ContentObject.GetValue('content');
          if ContentValue <> nil then
            Result := ContentValue.Value;
        end;
      end;
    end;
  finally
    JSONValue.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TForm1.RadioGroup1Click(Sender: TObject);

begin
  // Handle the radio button selection and set memo visibility
  case RadioGroup1.ItemIndex of
    0:   // System Prompt
      begin
        Memo4.Visible := True;
        Memo2.Visible := False;
        Memo5.Visible := False;
        Memo6.Visible := False;
      end;
    1: // Javascript
      begin
        Memo2.Visible := False;
        Memo4.Visible := False;
        Memo5.Visible := True;
        Memo6.Visible := False;
      end;
    2: // Extracted Text
      begin
        Memo2.Visible := True;
        Memo4.Visible := False;
        Memo5.Visible := False;
        Memo6.Visible := False;
      end;
    3:
      begin
        // Extracted Text Prompt
        Memo2.Visible := False;
        Memo4.Visible := False;
        Memo5.Visible := False;
        Memo6.Visible := True;
      end;
  else
    begin
      Memo2.Visible := False;
      Memo4.Visible := False;
      Memo5.Visible := False;
      Memo6.Visible := False;
    end;
  end;
end;

//------------------------------------------------------------------------------

// Extract URL generated by AI
function TForm1.GetUrl(const Response: string): string;
var
  StartPos, EndPos: Integer;
begin
  Result := ''; // Default result if tags are not found

  // Find the position of the start tag and end tag
  StartPos := Pos('<Internet>', Response);
  EndPos := Pos('</Internet>', Response);

  // Check if both tags are found and are in the correct order
  if (StartPos > 0) and (EndPos > StartPos) then
  begin
    Inc(StartPos, Length('<Internet>')); // Move StartPos to after the start tag

    // Extract the text between the tags
    Result := Copy(Response, StartPos, EndPos - StartPos);

  end;
end;

//------------------------------------------------------------------------------
 // Check Browser Has Loaded
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if GlobalWebView2Loader.Initialized then
    WVBrowser1.CreateBrowser(WVWindowParent1.Handle)
   else
    Timer1.Enabled := True;
end;
//------------------------------------------------------------------------------
// Flash Request To Access The Internet Green Panel
procedure TForm1.Timer2Timer(Sender: TObject);
begin
// Prevent New pages Being Loaded & Further Prompts Being Sent Until A Response Is Received
  Button1.Enabled:=False;
  Button2.Enabled:=False;
  WVWindowParent1.Enabled:=False;
  Button4.Visible:=True;
  Button5.Visible:=True;
  Timer2.Enabled:=False;

  if PanelVisible then
  begin
  PanelVisible:=False;
  Panel2.Visible:=False;
  Timer2.Enabled:=True;
  exit;
  end;

 PanelVisible:=True;
 Panel2.Visible:=True;
 Timer2.Enabled:=True;
end;

// Permenant Internet Access Timer
procedure TForm1.Timer3Timer(Sender: TObject);
begin
Timer3.Enabled:=False;
GoToURL(GetUrl(GlobalResponse));
end;

procedure TForm1.Timer4Timer(Sender: TObject);
begin
Timer4.Enabled:=False;
Memo7.Lines.Add('Sending text' +#13#10 + GlobalResponse );
Memo7.Lines.Add('Form1 Timer 4 TTSStatus: ' + TTStatus ) ;
Form3.ManageTTSList(GlobalResponse);
end;


//------------------------------------------------------------------------------
// Load Google As HomePage When Browser Loads
procedure TForm1.WVBrowser1AfterCreated(Sender: TObject);
begin
  WVWindowParent1.UpdateSize;
  WVBrowser1.Navigate('https://google.com/');
  WVWindowParent1.UpdateSize;
end;
//------------------------------------------------------------------------------
// After Webpage Has Loaded Initiate Extracting Text From Webpage
procedure TForm1.WVBrowser1DOMContentLoaded(Sender: TObject;
  const aWebView: ICoreWebView2;
  const aArgs: ICoreWebView2DOMContentLoadedEventArgs);
  var
  url:string;

begin
url:= WVBrowser1.CoreWebView2.Source;

// If the page that has loaded is not google's homepage then inject the javascript that retreives the text from the webpage
if url = 'https://www.google.com/' then exit;
ExecuteJavaScript(Memo5.Text);

end;

//------------------------------------------------------------------------------
// When We Receive A Message From WebPage Process It
procedure TForm1.WVBrowser1WebMessageReceived(Sender: TObject; const aWebView: ICoreWebView2; const aArgs: ICoreWebView2WebMessageReceivedEventArgs);
var
  TempArgs: TCoreWebView2WebMessageReceivedEventArgs;
  MessageData: string;

begin
  TempArgs := TCoreWebView2WebMessageReceivedEventArgs.Create(aArgs);
  // Retrieve message data from web message
  MessageData := TempArgs.WebMessageAsString;

  // If Javascript was injected into the web page to get the text from the page we will receive a string begining with TEXTBACK
  if Pos('[EXTRACTEDTEXT]',MessageData)>0 then
  begin
   Delete(MessageData,1,15); // Delete "[EXTRACTEDTEXT]"  From MessageData
   // Display text from webpage in memo pad for user to see
  Memo2.Text:=MessageData;
  //Replace " [EXTRACTEDTEXT] " from the memo with the actual text from the webpage to send to the AI
  Memo3.Text := StringReplace(Memo6.Text, '[EXTRACTEDTEXT]', MessageData, [rfReplaceAll]);

  // Do Not Display Above Message Being Sent To AI In Chat Window
  MyShowMessage:=False;
  // Show Label "Please Wait Whilst I process WebPage"
  Label1.Visible:=True;
  Image1.Visible:=True;

  // Prevent New pages Being Loaded & Further Prompts Being Sent Until A Response Is Received
  Button1.Enabled:=False;
  Button2.Enabled:=False;
  WVWindowParent1.Enabled:=False;
  Button6.Visible:=True; // Cancel Button
  // Send Memo3.Text To AI
  Button1.Click;
  end;
end;

 //-----------------------------------------------------------------------------


// Get Text From WebPage By Injecting Javascript

procedure TForm1.Button2Click(Sender: TObject);
begin
Memo1.Clear;
Conversation:='';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
Form1.TTStatus := '[READY]';
Form3.Speak(Form3.Retry);



//Form3.Speak(Memo3.Text);
//ShowMessage(Conversation);
end;

// Show Message from speech recognition form - being here ensures the message is visible when Form2 is hidden
//------------------------------------------------------------------------------
procedure TForm1.Memo3Change(Sender: TObject);
begin
  if Lowercase(memo3.text) = 'debug' then Memo7.Visible:=True;
  if Lowercase(memo3.text) <> 'debug' then Memo7.Visible:=False;
end;

Procedure Tform1.MyShowMessage2(str:string);
   begin
      ShowMessage(str);
      Image2.Visible:=False;
      Image3.Visible:=False;
      Image4.Visible:=True;
      CheckAndCreateMicAccessFile(True);
   end;

//------------------------------------------------------------------------------
// Create File as a flag so the next time the app is launched it will delete browser cache
// The Allow Mic Prompt will show again if speech recognition is activated
procedure TForm1.CheckAndCreateMicAccessFile(Create:Boolean);
var
  FileName, CacheFolder: string;
begin
  FileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'deletecache.txt');
  CacheFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), 'CustomCache'); // Path to the CustomCache folder

  if not FileExists(FileName) then
  begin
    try
     If Create=True then TFile.Create(FileName).Free;  // Create the file if it does not exist

     DeleteFileIfExists('micaccessgranted.txt'); // dlete this file if it exists

    except
      on E: Exception do
        // ShowMessage('Error creating file: ' + E.Message);
    end;
  end
  else
  begin
    // ShowMessage('File already exists: ' + FileName);
    try
      // Check if the CustomCache folder exists and delete it
      if TDirectory.Exists(CacheFolder) then
      begin
        TDirectory.Delete(CacheFolder, True); // Deletes the folder and all its contents
        if not TDirectory.Exists(CacheFolder) then
        begin
          // If folder deleted successfully, delete the deletecache.txt file
          DeleteFile(FileName);

          // ShowMessage('Successfully deleted CustomCache folder and deletecache.txt');
        end;
      end;
    except
      on E: Exception do
        // ShowMessage('Error: ' + E.Message);
    end;
  end;
end;

//--------------- check If file exists and deltes it  -------------------------

 procedure TForm1.DeleteFileIfExists(const FileName: string);
begin
  // Check if the file exists
  if FileExists(FileName) then
  begin
    try
      // Try to delete the file
      DeleteFile(FileName);
    except
      on E: Exception do
        Writeln('Error deleting file: ', E.Message);
    end;
  end
  else
    Writeln('File not found: ', FileName);
end;
//------------------------------------------------------------------------------
procedure TForm1.LoadSettings;
var
  Ini: TIniFile;
  VoiceSetting: string;
  IniFilePath: string;
begin
  // Set the INI file path to the application directory or specify a known writable path
  IniFilePath := ExtractFilePath(Application.ExeName) + 'settings.ini';

  // Check if the settings file exists before attempting to load it
  if not FileExists(IniFilePath) then
  begin
    ShowMessage('Settings file not found: ' + IniFilePath);
    Exit;
  end;

  // Create an instance of TIniFile with the specified file path
  Ini := TIniFile.Create(IniFilePath);
  try
    // Read the value of the "Voice" setting from the INI file
    VoiceSetting := Ini.ReadString('Settings', 'Voice', '');
    ServerAddress := Ini.ReadString('Settings', 'ServerAddress', '');


    if length(ServerAddress) < 1 then  ServerAddress := 'http://64.247.196.44:8080/v1/chat/completions';

    CheckBox1.Checked := Ini.ReadBool('Settings', 'InternetAccessGranted', False);
    CheckBox2.Checked := Ini.ReadBool('Settings', 'LocalHost', True);
    CheckBox3.Checked := Ini.ReadBool('Settings', 'AutoSubmitSpeech', False);
    CheckBox4.Checked := Ini.ReadBool('Settings', 'EnableTTS', False);


    if checkbox4.checked then
    begin
      Image5Click(Image5);
    end;


    // Check if the value read from the INI file exists in the ComboBox items
   if ComboBox1.Items.IndexOf(VoiceSetting) <> -1 then
    begin
      // Set the ComboBox to the saved voice setting
      ComboBox1.ItemIndex := ComboBox1.Items.IndexOf(VoiceSetting);

      // Trigger the OnChange event manually
      if Assigned(ComboBox1.OnChange) then
        ComboBox1.OnChange(ComboBox1);
    end
    else
    begin
      //ShowMessage('Saved voice setting "' + VoiceSetting + '" not found in ComboBox items.');

    ///    ****************************  here select 1st item


    end;
  finally
    // Free the TIniFile instance to release resources
    Ini.Free;
    Initializing := False;
  end;
end;


//------------------------------------------------------------------------------
procedure TForm1.SaveSettings;
var
  Ini: TIniFile;
  IniFilePath: string;
begin
  // Prevent saving if the form is initializing
  if Initializing then
  begin

    Exit;
  end;

  // Set the INI file path to the application directory or specify a known writable path
  IniFilePath := ExtractFilePath(Application.ExeName) + 'settings.ini';

  // Create an instance of TIniFile with the specified file path
  Ini := TIniFile.Create(IniFilePath);
  try
    Ini.WriteString('Settings', 'ServerAddress', Edit1.Text);
    Ini.WriteBool('Settings', 'InternetAccessGranted', CheckBox1.Checked);
    Ini.WriteBool('Settings', 'LocalHost', CheckBox2.Checked);
    Ini.WriteBool('Settings', 'AutoSubmitSpeech', CheckBox3.Checked);
    Ini.WriteBool('Settings', 'EnableTTS', CheckBox4.Checked);
    // Save the selected ComboBox item to the "Voice" field in the "Settings" section
    if ComboBox1.ItemIndex <> -1 then
    Begin
    Ini.WriteString('Settings', 'Voice', ComboBox1.Items[ComboBox1.ItemIndex]);
    End
    else
   //   ShowMessage('No item selected in the ComboBox.');
  finally
    // Free the TIniFile instance to release resources
    Ini.Free;
  end;

  // Show a message or use breakpoints to confirm save success
 // ShowMessage('Settings saved to: ' + IniFilePath);
end;


//------------------------------------------------------------------------------
procedure TForm1.WMMove(var aMessage : TWMMove);
begin
  inherited;

  if (WVBrowser1 <> nil) then
    WVBrowser1.NotifyParentWindowPositionChanged;
end;

procedure TForm1.WMMoving(var aMessage : TMessage);
begin
  inherited;

  if (WVBrowser1 <> nil) then
    WVBrowser1.NotifyParentWindowPositionChanged;
end;

initialization
  GlobalWebView2Loader                := TWVLoader.Create(nil);
  GlobalWebView2Loader.UserDataFolder := ExtractFileDir(Application.ExeName) + '\CustomCache';
  GlobalWebView2Loader.StartWebView2;

end.


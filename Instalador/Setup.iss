#define MyAppName "Oppiot"
#define MyAppVersion "1.0"
#define MyAppPublisher "Henutsen"

;Vinculo de Soporte Tecnico
#define MyAppURL "https://Henutsen.com/"
     
#define MyAppExeName "Oppiot.exe"

;Estructura de directorios para cargar archivos de Instalacion
;------------------------------------------------------------        
        #define dir_archivos_fuentes   "Fuentes\"

[Setup]

;no cambiar Appid{D3E1CD6F-EAF8-4F20-BC9F-294CA9F61F23}
AppId= {{D3E1CD6F-EAF8-4F20-BC9F-294CA9F61F23}  
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}          
AppPublisherURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputBaseFilename={#MyAppName}-{#MyAppVersion} 
Compression=lzma
SolidCompression=yes
AppContact= Audisoft Soporte Técnico

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: dontinheritcheck

[Files]
; se meten todos los archivos al .exe
Source: "{#dir_archivos_fuentes}*"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[CODE] 
var
  DIR_INSTALACI : string;
  SW_CANCELAR_I : BOOLEAN;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if Confirm then
    SW_CANCELAR_I   :=  true;
end;

procedure DeinitializeSetup();
var
  ResultCode: Integer;
begin
  if SW_CANCELAR_I  then
    exit;
  MsgBox('Ha finalizado la instalación del Oppiot V {#SetupSetting("AppVersion")}.', mbInformation, MB_OK);   
end;
 
procedure MyAfterInstall();
begin
  DIR_INSTALACI := ExpandConstant('{app}');      
end;

end.
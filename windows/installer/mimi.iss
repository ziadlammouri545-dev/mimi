; Mimi for Windows, the setup program (Inno Setup 6.3 or later).
;
; It installs for the current user, so it needs no admin rights, and it carries the
; Microsoft C++ runtime next to mimi.exe, so it runs on a PC that has never had the
; Visual C++ Redistributable. See docs/RELEASING.md.
;
;   flutter build windows --release
;   ISCC /DAppVersion=1.0.0 /DRedistDir="<VS>\VC\Redist\MSVC\<ver>\x64\Microsoft.VC145.CRT" windows\installer\mimi.iss
;
; The result is build\installer\Mimi-<version>-windows-x64-setup.exe.

#ifndef AppVersion
  #define AppVersion "1.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\build\installer"
#endif
#ifndef RedistDir
  #error Pass /DRedistDir= the x64 Microsoft.VC14x.CRT folder of your Visual Studio
#endif

[Setup]
; Never change the AppId: upgrades and the uninstaller find Mimi by it.
AppId={{FBFAE5A2-6129-4F8C-ACA9-5BDE61E949AC}
AppName=Mimi
AppVersion={#AppVersion}
AppVerName=Mimi {#AppVersion}
AppPublisher=MultiX0
AppPublisherURL=https://github.com/ziadlammouri545-dev/mimi
AppSupportURL=https://github.com/ziadlammouri545-dev/mimi/issues
AppUpdatesURL=https://github.com/ziadlammouri545-dev/mimi/releases/latest
DefaultDirName={autopf}\Mimi
DisableProgramGroupPage=yes
DisableDirPage=auto
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename=Mimi-{#AppVersion}-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\mimi.exe
UninstallDisplayName=Mimi
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
CloseApplications=yes
RestartApplications=no
VersionInfoVersion={#AppVersion}
VersionInfoCompany=MultiX0
VersionInfoProductName=Mimi
VersionInfoDescription=Mimi setup

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RedistDir}\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RedistDir}\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RedistDir}\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\Mimi"; Filename: "{app}\mimi.exe"
Name: "{autodesktop}\Mimi"; Filename: "{app}\mimi.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\mimi.exe"; Description: "{cm:LaunchProgram,Mimi}"; Flags: nowait postinstall skipifsilent

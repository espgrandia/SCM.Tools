@echo off

:: ===============================================
:: Note
:: �ץ� dll �� exe �� �ɮ׸�T (using verpatch.exe).
:: ref: Simple Version Resource Tool for Windows
:: website:  http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
:: ����²����T, �n�Χ���V�Шϥ� patchFileInfo_Integrated.bat.

:: �ץ� �ɮ״y�z: �ɮת���.
:: %1: patchFileInfo_FileName (�t path)
:: %2: patchFileInfo_FileVersionInfo => fileVersion ��T, ���t���.
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: patchFileInfo_FileName (�t path)
SET patchFileInfo_FileName=
SET patchFileInfo_FileName=%1

:: patchFileInfo_FileVersionInfo => fileVersion ��T, ���t���.
SET patchFileInfo_FileVersionInfo=
SET patchFileInfo_FileVersionInfo=%2

ECHO [patchFileInfo_FileName] %patchFileInfo_FileName%
ECHO [patchFileInfo_FileVersionInfo] %patchFileInfo_FileVersionInfo%

:: ===============================================
:: Check input param.
IF "%patchFileInfo_FileName%"=="" (
	ECHO "patchFileInfo_FileName is illegal." 
	start cmd /K ECHO patchFileInfo_FileName is illegal. : %patchFileInfo_FileName%
	SET ReVal=1
	GOTO END
)

IF "%patchFileInfo_FileVersionInfo%"=="" (
	ECHO "patchFileInfo_FileVersionInfo is illegal." 
	start cmd /K ECHO patchFileInfo_FileVersionInfo is illegal. : %patchFileInfo_FileVersionInfo%
	SET ReVal=1
	GOTO END
)

:: ===============================================
:: copy right ���~��.
SET CopyRightYear=
FOR /F "usebackq delims=/ tokens=1" %%a in ('%date%') DO SET CopyRightYear=%%a
ECHO [CopyRightYear] %CopyRightYear%

:: �]�w��J�Ѽ�.
:: �]�w�覡�ѦҺ��� �p�W���� Note.
SET VERSION="%patchFileInfo_FileVersionInfo% (%date%)"
SET FILEDESCR=/s desc ""
SET COMPINFO=/s company "" /s (c) "(c) Copy Right %CopyRightYear%"
SET PRODINFO=/s product "" /pv "%patchFileInfo_FileVersionInfo%"
SET BUILDINFO=/s pb "Built by %USERNAME%"

:: log ��X.
ECHO.
ECHO ===============================================
ECHO [VERSION] : %VERSION%
ECHO [FILEDESCR] : %FILEDESCR%
ECHO [COMPINFO] : %COMPINFO%
ECHO [PRODINFO] : %PRODINFO%
ECHO [BUILDINFO] : %BUILDINFO%

:: ===============================================
:: execute verpatch.exe

SET oldPath=%CD%

ECHO.
ECHO [oldPath] : %oldPath%

CHDIR %~dp0

ECHO [currentPath] : %CD%
ECHO execute verpatch.exe

verpatch /va %patchFileInfo_FileName% %VERSION% %FILEDESCR% %COMPINFO% %PRODINFO% %BUILDINFO%
SET ReVal=%ERRORLEVEL%

CHDIR %oldPath%
ECHO [currentPath] : %CD%

:: ===============================================
:END

ECHO [patchInfo: ERRORLEVEL] %ReVal%
ECHO ===============================================
ECHO.

EXIT /B %ReVal%

@ECHO ON

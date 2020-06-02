@ECHO OFF

:: ===============================================
:: Note
:: �ץ� dll �� exe �� �ɮ׸�T (using verpatch.exe).
:: ref: Simple Version Resource Tool for Windows
:: website:  http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
:: �����������㪺��T, �n��²�����Шϥ� patchFileInfo.bat.

:: %1: patchFileInfo_Integrated_FileName (�t path)
:: %2: patchFileInfo_FileVersionInfo => fileVersion ��T, ���t���.
:: %3: patchFileInfo_ProjName => �M�צW��.
:: %4: patchFileInfo_CompanyName => company �W��, ���ťժ��ܻݥ� "" �]�_��, like as "Gosmio Inc.".
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: patchFileInfo_Integrated_FileName (�t path)
SET patchFileInfo_Integrated_FileName=
SET patchFileInfo_Integrated_FileName=%1

:: patchFileInfo_FileVersionInfo => fileVersion ��T, ���t���.
SET patchFileInfo_FileVersionInfo=
SET patchFileInfo_FileVersionInfo=%2

:: patchFileInfo_ProjName => �M�צW��.
SET patchFileInfo_ProjName=
SET patchFileInfo_ProjName=%3

:: patchFileInfo_CompanyName => company �W��.
SET patchFileInfo_CompanyName=
SET patchFileInfo_CompanyName=%4

ECHO [patchFileInfo_Integrated_FileName] %patchFileInfo_Integrated_FileName%
ECHO [patchFileInfo_FileVersionInfo] %patchFileInfo_FileVersionInfo%
ECHO [patchFileInfo_ProjName] %patchFileInfo_ProjName%
ECHO [patchFileInfo_CompanyName] %patchFileInfo_CompanyName%

:: ===============================================
:: Check input param.
IF "%patchFileInfo_Integrated_FileName%"=="" (
	ECHO "patchFileInfo_Integrated_FileName is illegal." 
	start cmd /K ECHO patchFileInfo_Integrated_FileName is illegal. : %patchFileInfo_Integrated_FileName%
	SET ReVal=1
	GOTO END
)

IF "%patchFileInfo_FileVersionInfo%"=="" (
	ECHO "patchFileInfo_FileVersionInfo is illegal." 
	start cmd /K ECHO patchFileInfo_FileVersionInfo is illegal. : %patchFileInfo_FileVersionInfo%
	SET ReVal=1
	GOTO END
)

IF "%patchFileInfo_ProjName%"=="" (
	ECHO "patchFileInfo_ProjName is illegal." 
	start cmd /K ECHO patchFileInfo_ProjName is illegal. : %patchFileInfo_ProjName%
	SET ReVal=1
	GOTO END
)

IF %patchFileInfo_CompanyName%=="" (
	ECHO "patchFileInfo_CompanyName is illegal." 
	start cmd /K ECHO patchFileInfo_CompanyName is illegal. : %patchFileInfo_CompanyName%
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
SET FILEDESCR=/s desc "%patchFileInfo_ProjName%"
SET COMPINFO=/s company %patchFileInfo_CompanyName% /s (c) "(c) Copy Right %CopyRightYear%"
SET PRODINFO=/s product "%patchFileInfo_ProjName%" /pv "%patchFileInfo_FileVersionInfo%"
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

verpatch /va %patchFileInfo_Integrated_FileName% %VERSION% %FILEDESCR% %COMPINFO% %PRODINFO% %BUILDINFO%
SET ReVal=%ERRORLEVEL%

CHDIR %oldPath%
ECHO [currentPath] : %CD%

:: ===============================================
:END

ECHO [patchFileInfo_Integrated: ERRORLEVEL] %ReVal%
ECHO ===============================================
ECHO.

EXIT /B %ReVal%

@ECHO ON

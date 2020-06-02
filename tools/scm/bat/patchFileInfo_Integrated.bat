@ECHO OFF

:: ===============================================
:: Note
:: 修正 dll 或 exe 的 檔案資訊 (using verpatch.exe).
:: ref: Simple Version Resource Tool for Windows
:: website:  http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
:: 此為較為完整的資訊, 要用簡易版請使用 patchFileInfo.bat.

:: %1: patchFileInfo_Integrated_FileName (含 path)
:: %2: patchFileInfo_FileVersionInfo => fileVersion 資訊, 不含日期.
:: %3: patchFileInfo_ProjName => 專案名稱.
:: %4: patchFileInfo_CompanyName => company 名稱, 有空白的話需用 "" 包起來, like as "Gosmio Inc.".
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: patchFileInfo_Integrated_FileName (含 path)
SET patchFileInfo_Integrated_FileName=
SET patchFileInfo_Integrated_FileName=%1

:: patchFileInfo_FileVersionInfo => fileVersion 資訊, 不含日期.
SET patchFileInfo_FileVersionInfo=
SET patchFileInfo_FileVersionInfo=%2

:: patchFileInfo_ProjName => 專案名稱.
SET patchFileInfo_ProjName=
SET patchFileInfo_ProjName=%3

:: patchFileInfo_CompanyName => company 名稱.
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
:: copy right 的年份.
SET CopyRightYear=
FOR /F "usebackq delims=/ tokens=1" %%a in ('%date%') DO SET CopyRightYear=%%a
ECHO [CopyRightYear] %CopyRightYear%

:: 設定輸入參數.
:: 設定方式參考網頁 如上面的 Note.
SET VERSION="%patchFileInfo_FileVersionInfo% (%date%)"
SET FILEDESCR=/s desc "%patchFileInfo_ProjName%"
SET COMPINFO=/s company %patchFileInfo_CompanyName% /s (c) "(c) Copy Right %CopyRightYear%"
SET PRODINFO=/s product "%patchFileInfo_ProjName%" /pv "%patchFileInfo_FileVersionInfo%"
SET BUILDINFO=/s pb "Built by %USERNAME%"

:: log 輸出.
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

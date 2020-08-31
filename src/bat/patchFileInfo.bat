@echo off

:: ===============================================
:: Note
:: 修正 dll 或 exe 的 檔案資訊 (using verpatch.exe).
:: ref: Simple Version Resource Tool for Windows
:: website:  http://www.codeproject.com/Articles/37133/Simple-Version-Resource-Tool-for-Windows
:: 此為簡易資訊, 要用完整訓請使用 patchFileInfo_Integrated.bat.

:: 修正 檔案描述: 檔案版本.
:: %1: patchFileInfo_FileName (含 path)
:: %2: patchFileInfo_FileVersionInfo => fileVersion 資訊, 不含日期.
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: patchFileInfo_FileName (含 path)
SET patchFileInfo_FileName=
SET patchFileInfo_FileName=%1

:: patchFileInfo_FileVersionInfo => fileVersion 資訊, 不含日期.
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
:: copy right 的年份.
SET CopyRightYear=
FOR /F "usebackq delims=/ tokens=1" %%a in ('%date%') DO SET CopyRightYear=%%a
ECHO [CopyRightYear] %CopyRightYear%

:: 設定輸入參數.
:: 設定方式參考網頁 如上面的 Note.
SET VERSION="%patchFileInfo_FileVersionInfo% (%date%)"
SET FILEDESCR=/s desc ""
SET COMPINFO=/s company "" /s (c) "(c) Copy Right %CopyRightYear%"
SET PRODINFO=/s product "" /pv "%patchFileInfo_FileVersionInfo%"
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

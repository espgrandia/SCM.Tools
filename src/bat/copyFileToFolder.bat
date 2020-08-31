@ECHO OFF

:: ===============================================
:: Note: copy one file to output folder
:: 該 output folder 不存在時, 會嘗試建立.

:: %1: copyFileToFolder_FileName => 檔案名稱 (含路徑).
:: %2: copyFileToFolder_OutputPath => 輸出的位置 (一般為 目錄, 含路徑).
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: 設定 輸出的目錄.
SET copyFileToFolder_FileName=
SET copyFileToFolder_FileName=%1

:: 設定 輸出的目錄.
SET copyFileToFolder_OutputPath=
SET copyFileToFolder_OutputPath=%2

:: show log.
ECHO [copyFileToFolder_FileName] %copyFileToFolder_FileName%
ECHO [copyFileToFolder_OutputPath] %copyFileToFolder_OutputPath%

:: ===============================================
:: Check input param.
IF "%copyFileToFolder_FileName%"=="" (
	ECHO "copyFileToFolder_FileName is illegal." 
	start cmd /K ECHO copyFileToFolder_FileName is illegal. : %copyFileToFolder_FileName%
	SET ReVal=1
	GOTO END
)

IF "%copyFileToFolder_OutputPath%"=="" (
	ECHO "copyFileToFolder_OutputPath is illegal." 
	start cmd /K ECHO copyFileToFolder_OutputPath is illegal. : %copyFileToFolder_OutputPath%
	SET ReVal=1
	GOTO END
)

:: ===============================================
:: copy files
REM SETLOCAL ENABLEDELAYEDEXPANSION

:: 沒有 copyFileToFolder_OutputPath 會嘗試建立.
IF NOT EXIST %copyFileToFolder_OutputPath% (
	MKDIR %copyFileToFolder_OutputPath%

	IF %ERRORLEVEL% NEQ 0 (
		SET ReVal=%ERRORLEVEL%
		GOTO End
	)
)

:: execute copy file.
XCOPY %copyFileToFolder_FileName% %copyFileToFolder_OutputPath% /Y /S /Q

IF %ERRORLEVEL% NEQ 0 (
	SET ReVal=%ERRORLEVEL%
	GOTO End
)

:: ===============================================
:END

@ECHO on
ECHO [copyFileToFolder: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

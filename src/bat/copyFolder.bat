@ECHO OFF

:: ===============================================
:: Note
:: copy 目標目錄下的所有資料夾及檔案
:: 輸入參數
:: %1: copyFolder_OriPath => 原有的目錄.
:: %2: copyFolder_ExecutePath => 要執行 xcopy floder 的目錄.
:: %3: copyFolder_CopyFolderName => 要 copy 的 資料夾名稱.
:: %4: copyFolder_OutputPath => 輸出的位置 (一般為 目錄, 含路徑).
:: 參數一定要是對的, 目前沒有防呆, 只有簡易的判斷.
:: 絕對路徑相對來說比較沒有問題.
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: 初始化 基本資訊.
SET copyFolder_OriPath=
SET copyFolder_ExecutePath=
SET copyFolder_CopyFolderName=
SET copyFolder_OutputPath=

SET copyFolder_OriPath=%1
SET copyFolder_ExecutePath=%2
SET copyFolder_CopyFolderName=%3
SET copyFolder_OutputPath=%4

ECHO [copyFolder_OriPath] %copyFolder_OriPath%
ECHO [copyFolder_ExecutePath] %copyFolder_ExecutePath%
ECHO [copyFolder_CopyFolderName] %copyFolder_CopyFolderName%
ECHO [copyFolder_OutputPath] %copyFolder_OutputPath%

:: ===============================================
:: Check input param.
IF "%copyFolder_OriPath%"=="" (
	ECHO "copyFolder_OriPath is illegal." 
	start cmd /K ECHO copyFolder_OriPath is illegal. : %copyFolder_OriPath%
	SET ReVal=1
	GOTO END
)

IF "%copyFolder_ExecutePath%"=="" (
	ECHO "copyFolder_ExecutePath is illegal." 
	start cmd /K ECHO copyFolder_ExecutePath is illegal. : %copyFolder_ExecutePath%
	SET ReVal=1
	GOTO END
)

IF "%copyFolder_CopyFolderName%"=="" (
	ECHO "copyFolder_CopyFolderName is illegal." 
	start cmd /K ECHO copyFolder_CopyFolderName is illegal. : %copyFolder_CopyFolderName%
	SET ReVal=1
	GOTO END
)

IF "%copyFolder_OutputPath%"=="" (
	ECHO "copyFolder_OutputPath is illegal." 
	start cmd /K ECHO copyFolder_OutputPath is illegal. : %copyFolder_OutputPath%
	SET ReVal=1
	GOTO END
)

:: ===============================================
:: 切換到要 copy folder 目錄.
CHDIR %copyFolder_ExecutePath%

:: 沒有 copyFolder_OutputPath 會嘗試建立.
IF NOT EXIST %copyFolder_OutputPath% (
	MKDIR %copyFolder_OutputPath%

	IF %ERRORLEVEL% NEQ 0 (
		SET ReVal=%ERRORLEVEL%
		GOTO End
	)
)

:: execute copy file.
XCOPY %copyFolder_CopyFolderName% %copyFolder_OutputPath% /Y /S /Q

IF %ERRORLEVEL% NEQ 0 (
	SET ReVal=%ERRORLEVEL%
)

:: 切換回原有目錄.
CHDIR %copyFolder_OriPath%

:: ===============================================
:END

@ECHO on
ECHO [copyFolder: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

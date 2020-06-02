@ECHO OFF

:: ===============================================
:: Note
:: 輸入參數
:: %1: log_SearchRootFolderPath => root folder 路徑.
:: %2: log_RootLastChangeRev => root folder 的最後改變版本.
:: %3: log_ExportedLastChangeRev => 發佈 folder 的最後改變版本.
:: %4: log_LimitCount => root folder 的最後改變版本.
:: %5: log_OutputLogFileName => 輸出的 log 檔名 (含路徑)
:: %6: log_TempleteLogFileName => 輸出 log 的起始範本檔名(含路徑).

:: 參數一定要是對的, 目前沒有防呆.
:: Folder Path 最後面不要加上 \, svn commit command 在有加上 "" 會有問題.
:: ===============================================

:: ===============================================
:: 設定 Root Folder 
SET log_SearchRootFolderPath=%~1

:: 設定 log_RootLastChangeRev Svn.
SET /A log_RootLastChangeRev=%2

:: 設定 Exported_LCR_Num, Log 用.
SET /A log_ExportedLastChangeRev=%3

:: 設定 差異的版本數量
SET /A log_LimitCount=%4

:: 設定 輸出的 log 檔名 (含路徑)
SET log_OutputLogFileName=%~5

:: 設定 輸出 log 的起始範本檔名(含路徑).
SET log_TempleteLogFileName=%~6

ECHO [log_SearchRootFolderPath: ] %log_SearchRootFolderPath%
ECHO [log_RootLastChangeRev: ] %log_RootLastChangeRev%
ECHO [log_ExportedLastChangeRev: ] %log_ExportedLastChangeRev%
ECHO [log_LimitCount: ] %log_LimitCount%
ECHO [log_OutputLogFileName: ] %log_OutputLogFileName%
ECHO [log_TempleteLogFileName: ] %log_TempleteLogFileName%

:: ===============================================
:: Check input param.
IF "%log_SearchRootFolderPath%"=="" (
	ECHO "log_SearchRootFolderPath is illegal." 
	start cmd /K ECHO log_SearchRootFolderPath is illegal. : %log_SearchRootFolderPath%
	SET ReVal=1
	GOTO END
)

IF "%log_RootLastChangeRev%"=="" (
	ECHO "log_RootLastChangeRev is illegal." 
	start cmd /K ECHO log_RootLastChangeRev is illegal. : %log_RootLastChangeRev%
	SET ReVal=1
	GOTO END
)

IF "%log_ExportedLastChangeRev%"=="" (
	ECHO "log_ExportedLastChangeRev is illegal." 
	start cmd /K ECHO log_ExportedLastChangeRev is illegal. : %log_ExportedLastChangeRev%
	SET ReVal=1
	GOTO END
)

IF "%log_LimitCount%"=="" (
	ECHO "log_LimitCount is illegal." 
	start cmd /K ECHO log_LimitCount is illegal. : %log_LimitCount%
	SET ReVal=1
	GOTO END
)

IF "%log_OutputLogFileName%"=="" (
	ECHO "log_OutputLogFileName is illegal." 
	start cmd /K ECHO log_OutputLogFileName is illegal. : %log_OutputLogFileName%
	SET ReVal=1
	GOTO END
)

IF "%log_TempleteLogFileName%"=="" (
	ECHO "log_TempleteLogFileName is illegal." 
	start cmd /K ECHO log_TempleteLogFileName is illegal. : %log_TempleteLogFileName%
	SET ReVal=1
	GOTO END
)

:: ===============================================
:: 產生一個空的 "%log_OutputLogFileName%" (無此檔案則會自動建立)
copy/Y NUL "%log_OutputLogFileName%"

:: svn 標頭檔
xcopy /y "%log_TempleteLogFileName%" "%log_OutputLogFileName%"

:: ===============================================
:: output log to file.
:: 當下的 svn info.
ECHO ====================================>> "%log_OutputLogFileName%"
ECHO *** snv info ***>> "%log_OutputLogFileName%"
svn info "%log_SearchRootFolderPath%" >> "%log_OutputLogFileName%"

:: 需先確認要的 svn 版本 log
ECHO ====================================>> "%log_OutputLogFileName%"
ECHO *** log info ***>> "%log_OutputLogFileName%"
ECHO *** root folder Last Changed Rev: %log_RootLastChangeRev% ***>> "%log_OutputLogFileName%"
ECHO *** exported folder Last Changed Rev: %log_ExportedLastChangeRev% ***>> "%log_OutputLogFileName%"
ECHO *** log count: %log_LimitCount% ***>> "%log_OutputLogFileName%"
ECHO *** Following logs are depended on above svn info.>> "%log_OutputLogFileName%"
ECHO ====================================>> "%log_OutputLogFileName%"
ECHO.>> "%log_OutputLogFileName%"
ECHO.>> "%log_OutputLogFileName%"


:: ===============================================
:: 呼叫 OnceLog.bat 前先設定 chdir.
SET Log_InputPath=%CD%
ECHO [log: oldpath] %Log_InputPath%

CHDIR %~dp0

:: 設定 loop count.
SET /A Log_LoopCount=%log_LimitCount%-1
for /L %%i IN ( 0, 1, %Log_LoopCount% ) DO (
	CALL OnceLog.bat "%log_SearchRootFolderPath%" %log_RootLastChangeRev% %%i "%log_OutputLogFileName%"
)

CHDIR %Log_InputPath%

:: ===============================================
:END

ECHO [log: ERRORLEVEL] %ERRORLEVEL%

@ECHO ON

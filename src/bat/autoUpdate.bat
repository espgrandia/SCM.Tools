@ECHO OFF

:: ===============================================
:: Note
:: 自動 update 而且 check 是否要 svn commit.
:: 輸入的 batch file
::   需要自行處理目錄不相同問題, ex: 先切換到該檔案的目路再切回到原始目錄.
::   此 batch file 只是單純呼叫輸入的批次檔, 並做回傳值檢察.

:: 參數中 有空白可輸入 "xxx", 會去掉 ""

:: %1: autoUpdate_DependFolder => 要check depend 的目錄.
:: %2: autoUpdate_TitleLog: 要輸出 log 的 Title.
:: %3: autoUpdate_UpdateSvnExternalsBatch: 自動更新 depend 的 batch file.
:: %4: autoUpdate_CleanUpSvnBatch: 清除 svn 的 batch file.
:: %5: autoUpdate_CheckBatch: 驗證是否更新後可以 work 的 batch file (通常為 build.bat).
:: ===============================================

:: ===============================================
SETLOCAL ENABLEDELAYEDEXPANSION

:: 切換到當前目錄.
SET autoUpdate_InputPath=%CD%

ECHO.
ECHO [autoUpdate: oldPath] : %autoUpdate_InputPath%

CHDIR %~dp0

ECHO [autoUpdate: currentPath] : %CD%

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: 設定並先產生空的暫存檔.
:: svn:externals 的差異log, 目前是檢查用, 不做為show log 的內容, 因為該內容有 CRLF 跟 LF 兩種斷行不同, 導致無法 svn commit.
SET SvnDiffLogFileName=autoUpdate_SvnDiff.log
copy/Y NUL %SvnDiffLogFileName%

SET SvnCommitLogFileName=autoUpdate_SvnCommit.log
copy/Y NUL %SvnCommitLogFileName%

:: autoUpdate_DependFolder => 要check depend 的目錄.
SET autoUpdate_DependFolder=
SET autoUpdate_DependFolder=%~1

:: autoUpdate_TitleLog: 要輸出 log 的 Title, 有空白可輸入 "xxx", 會去掉 "".
SET autoUpdate_TitleLog=
SET autoUpdate_TitleLog=%~2

:: autoUpdate_UpdateSvnExternalsBatch: 自動更新 depend 的 batch file.
SET autoUpdate_UpdateSvnExternalsBatch=
SET autoUpdate_UpdateSvnExternalsBatch=%~3

:: autoUpdate_CleanUpSvnBatch: 清除 svn 的 batch file.
SET autoUpdate_CleanUpSvnBatch=
SET autoUpdate_CleanUpSvnBatch=%~4

:: 驗證是否更新後可以 work 的 batch file (通常為 build.bat).
SET autoUpdate_CheckBatch=
SET autoUpdate_CheckBatch=%~5

:: show log.
ECHO [autoUpdate_DependFolder] %autoUpdate_DependFolder%
ECHO [autoUpdate_TitleLog] %autoUpdate_TitleLog%
ECHO [autoUpdate_UpdateSvnExternalsBatch] %autoUpdate_UpdateSvnExternalsBatch%
ECHO [autoUpdate_CleanUpSvnBatch] %autoUpdate_CleanUpSvnBatch%
ECHO [autoUpdate_CheckBatch] %autoUpdate_CheckBatch%

:: ===============================================
:: Check input param.
IF "%autoUpdate_DependFolder%"=="" (
	ECHO "autoUpdate_DependFolder is illegal." 
	start cmd /K ECHO autoUpdate_DependFolder is illegal. : %autoUpdate_DependFolder%
	SET ReVal=1
	GOTO END
)

IF "%autoUpdate_TitleLog%"=="" (
	ECHO "autoUpdate_TitleLog is illegal." 
	start cmd /K ECHO autoUpdate_TitleLog is illegal. : %autoUpdate_TitleLog%
	SET ReVal=1
	GOTO END
)

IF "%autoUpdate_UpdateSvnExternalsBatch%"=="" (
	ECHO "autoUpdate_UpdateSvnExternalsBatch is illegal." 
	start cmd /K ECHO autoUpdate_UpdateSvnExternalsBatch is illegal. : %autoUpdate_UpdateSvnExternalsBatch%
	SET ReVal=1
	GOTO END
)

IF "%autoUpdate_CleanUpSvnBatch%"=="" (
	ECHO "autoUpdate_CleanUpSvnBatch is illegal." 
	start cmd /K ECHO autoUpdate_CleanUpSvnBatch is illegal. : %autoUpdate_CleanUpSvnBatch%
	SET ReVal=1
	GOTO END
)

IF "%autoUpdate_CheckBatch%"=="" (
	ECHO "autoUpdate_CheckBatch is illegal." 
	start cmd /K ECHO autoUpdate_CheckBatch is illegal. : %autoUpdate_CheckBatch%
	SET ReVal=1
	GOTO END
)

:: ===============================================
CALL %autoUpdate_UpdateSvnExternalsBatch%

IF %ERRORLEVEL% NEQ 0 (
	SET ReVal=%ERRORLEVEL%
	ECHO *** execute %autoUpdate_UpdateSvnExternalsBatch% Fail ***
	GOTO End
)

svn diff "%autoUpdate_DependFolder%" > %SvnDiffLogFileName%

FOR /F "usebackq" %%A IN ('%SvnDiffLogFileName%') DO SET /A FileSize=%%~zA

ECHO.
ECHO [%SvnDiffLogFileName%] size is %FileSize%
ECHO.

:: Check svn diff 是否有改變.
IF %FileSize% GTR 0 (

	CALL %autoUpdate_CheckBatch%
	IF !ERRORLEVEL! NEQ 0 (
		SET ReVal=!ERRORLEVEL!
		ECHO *** execute %autoUpdate_CheckBatch% Fail ***
		GOTO End
	)

	ECHO %autoUpdate_TitleLog%>> %SvnCommitLogFileName%
	ECHO.>> %SvnCommitLogFileName%
	ECHO.>> %SvnCommitLogFileName%

	REM :: ===============================================
	REM :: output log to file.
	REM :: 當下的 svn info.
	ECHO ====================================>> %SvnCommitLogFileName%
	ECHO *** snv info ***>> %SvnCommitLogFileName%
	svn info "%autoUpdate_DependFolder%" >> %SvnCommitLogFileName%
	
	ECHO ====================================>> %SvnCommitLogFileName%
	ECHO svn external as following...>> %SvnCommitLogFileName%

	ECHO.>> %SvnCommitLogFileName%

	REM svn diff svn::externals 有 CRLF 跟 LF 兩種斷行不同, 導致無法 svn commit, 先 mark 起來.
	REM TYPE %SvnDiffLogFileName%>> %SvnCommitLogFileName%
	svn propget svn:externals %autoUpdate_DependFolder% >> %SvnCommitLogFileName%

	ECHO.>> %SvnCommitLogFileName%
	ECHO ====================================>> %SvnCommitLogFileName%

	REM svn commit
	svn commit %autoUpdate_DependFolder% -F "%SvnCommitLogFileName%" --force-log

	IF !ERRORLEVEL! NEQ 0 (
		SET ReVal=!ERRORLEVEL!
		ECHO *** execute svn commit Fail ***
		GOTO End
	)

	REM 呼叫 cleanUp 的批次檔.
	CALL %autoUpdate_CleanUpSvnBatch%

	IF !ERRORLEVEL! NEQ 0 (
		SET ReVal=!ERRORLEVEL!
		ECHO *** execute %autoUpdate_CleanUpSvnBatch% Fail ***
		GOTO End
	)
)

:: ===============================================
:END

:: del temp file.
del %SvnDiffLogFileName%
del %SvnCommitLogFileName%

:: ===============================================
:: 切換回原始目錄.
CHDIR %autoUpdate_InputPath%
ECHO [autoUpdate: currentPath] : %CD%

@ECHO on
ECHO [autoUpdate: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

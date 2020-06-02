@ECHO OFF

:: ===============================================
:: Note
:: 指定 svn folder 的 ver 資訊, 並將資訊導出到該輸入的參數檔案.

:: 輸入參數
:: %1: svnAssignVer_OutputLogFileName => 輸出的 log 檔名 (含路徑)
:: %2: svnAssignVer_UrlPath => 要 指定 的 folder, 可以是 svn 完整路徑.
:: %3: svnAssignVer_LocalPath => 本地端的別名 (要depend的路徑).
:: %4: svnAssignVer_AssignedNum => 要指定的 svn ver number.
:: ===============================================

:: ===============================================
SETLOCAL ENABLEDELAYEDEXPANSION

:: 切換到當前目錄.
SET SvnAssignVer_InputPath=%CD%

ECHO.
ECHO [svnAssignVer: oldPath] : %SvnAssignVer_InputPath%

CHDIR %~dp0

ECHO [svnAssignVer: currentPath] : %CD%

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: 初始化 基本資訊.
SET svnAssignVer_OutputLogFileName=
SET svnAssignVer_UrlPath=
SET svnAssignVer_AssignedNum=
SET svnAssignVer_LocalPath=

SET svnAssignVer_OutputLogFileName=%1
SET svnAssignVer_UrlPath=%2
SET svnAssignVer_LocalPath=%3
SET svnAssignVer_AssignedNum=%4

ECHO [svnAssignVer_OutputLogFileName] %svnAssignVer_OutputLogFileName%
ECHO [svnAssignVer_UrlPath] %svnAssignVer_UrlPath%
ECHO [svnAssignVer_LocalPath] %svnAssignVer_LocalPath%
ECHO [svnAssignVer_AssignedNum] %svnAssignVer_AssignedNum%

:: ===============================================
:: Check input param.
IF "%svnAssignVer_OutputLogFileName%"=="" (
	ECHO "svnAssignVer_OutputLogFileName is illegal." 
	start cmd /K ECHO svnAssignVer_OutputLogFileName is illegal. : %svnAssignVer_OutputLogFileName%
	SET ReVal=1
	GOTO END
)

IF "%svnAssignVer_UrlPath%"=="" (
	ECHO "svnAssignVer_UrlPath is illegal." 
	start cmd /K ECHO svnAssignVer_UrlPath is illegal. : %svnAssignVer_UrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnAssignVer_LocalPath%"=="" (
	ECHO "svnAssignVer_LocalPath is illegal." 
	start cmd /K ECHO svnAssignVer_LocalPath is illegal. : %svnAssignVer_LocalPath%
	SET ReVal=1
	GOTO END
)

:: 同一層目錄下的批次檔.
CALL checkNum.bat %svnAssignVer_AssignedNum%
IF %ERRORLEVEL% NEQ 0 (
	start cmd /K ECHO svnAssignVer_AssignedNum is illegal. : %svnAssignVer_AssignedNum%
	SET ReVal=1
	GOTO END
)

:: ===============================================
ECHO -r %svnAssignVer_AssignedNum% %svnAssignVer_UrlPath%@%svnAssignVer_AssignedNum% %svnAssignVer_LocalPath%>> %svnAssignVer_OutputLogFileName%

:: ===============================================
:END

:: ===============================================
:: 切換回原始目錄.
CHDIR %SvnAssignVer_InputPath%
ECHO [svnAssignVer: currentPath] : %CD%

@ECHO ON
ECHO [svnAssignVer: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

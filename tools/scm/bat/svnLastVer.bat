@ECHO OFF

:: ===============================================
:: Note
:: 抓取 要收尋的 svn last change ver 資訊, 並將資訊導出到該輸入的參數檔案.

:: 輸入參數
:: %1: svnLastVer_OutputLogFileName => 輸出的 log 檔名 (含路徑)
:: %2: svnLastVer_SearchUrlPath => 要 收尋 的 folder, 可以是 svn 完整路徑.
:: %3: svnLastVer_LocalPath => 本地端的別名 (要depend的路徑).
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: 初始化 基本資訊.
SET svnLastVer_OutputLogFileName=
SET svnLastVer_SearchUrlPath=
SET svnLastVer_LocalPath=

SET svnLastVer_OutputLogFileName=%1
SET svnLastVer_SearchUrlPath=%2
SET svnLastVer_LocalPath=%3

ECHO [svnLastVer_OutputLogFileName] %svnLastVer_OutputLogFileName%
ECHO [svnLastVer_SearchUrlPath] %svnLastVer_SearchUrlPath%
ECHO [svnLastVer_LocalPath] %svnLastVer_LocalPath%

:: ===============================================
:: Check input param.
IF "%svnLastVer_OutputLogFileName%"=="" (
	ECHO "svnLastVer_OutputLogFileName is illegal." 
	start cmd /K ECHO svnLastVer_OutputLogFileName is illegal. : %svnLastVer_OutputLogFileName%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_SearchUrlPath%"=="" (
	ECHO "svnLastVer_SearchUrlPath is illegal." 
	start cmd /K ECHO svnLastVer_SearchUrlPath is illegal. : %svnLastVer_SearchUrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_LocalPath%"=="" (
	ECHO "svnLastVer_LocalPath is illegal." 
	start cmd /K ECHO svnLastVer_LocalPath is illegal. : %svnLastVer_LocalPath%
	SET ReVal=1
	GOTO END
)

:: ===============================================
:: 設定 指定路徑上ㄧ次修改的 svn 版本.
SET Exported_LCR_Num=
FOR /F "tokens=4" %%a IN ('svn info %svnLastVer_SearchUrlPath% -r HEAD ^| findstr /R /C:"Last Changed Rev:"') DO SET Exported_LCR_Num=%%a

:: 輸出相關版本資訊.
ECHO [ExportedLastChangedRev] %Exported_LCR_Num%

:: output to file.
ECHO -r %Exported_LCR_Num% %svnLastVer_SearchUrlPath%@%Exported_LCR_Num% %svnLastVer_LocalPath%>> %svnLastVer_OutputLogFileName%

:: ===============================================
:END

@ECHO ON
ECHO [svnLastVer: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

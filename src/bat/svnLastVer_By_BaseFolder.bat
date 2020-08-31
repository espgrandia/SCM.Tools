@ECHO OFF

:: ===============================================
:: Note
:: 抓取 要收尋的 svn last change ver 資訊, 並將資訊導出到該輸入的參數檔案.
:: 以 svnLastVer_By_BaseFolder_SearchBaseUrlPath 為收尋的 svn last change ver 路徑, svnLastVer_By_BaseFolder_SearchSubUrlPath 為該 子目錄. 

:: 輸入參數
:: %1: svnLastVer_By_BaseFolder_OutputLogFileName => 輸出的 log 檔名 (含路徑)
:: %2: svnLastVer_By_BaseFolder_SearchBaseUrlPath => 要 收尋 的 folder, 可以是 svn 完整路徑.
:: %3: svnLastVer_By_BaseFolder_SearchSubUrlPath => 要 收尋 的 sub folder(需自行帶入分隔線).
:: %4: svnLastVer_By_BaseFolder_LocalPath => 本地端的別名 (要depend的路徑).
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

:: 初始化 基本資訊.
SET svnLastVer_By_BaseFolder_OutputLogFileName=
SET svnLastVer_By_BaseFolder_SearchBaseUrlPath=
SET svnLastVer_By_BaseFolder_LocalPath=

SET svnLastVer_By_BaseFolder_OutputLogFileName=%1
SET svnLastVer_By_BaseFolder_SearchBaseUrlPath=%2
SET svnLastVer_By_BaseFolder_SearchSubUrlPath=%3
SET svnLastVer_By_BaseFolder_LocalPath=%4

ECHO [svnLastVer_By_BaseFolder_OutputLogFileName] %svnLastVer_By_BaseFolder_OutputLogFileName%
ECHO [svnLastVer_By_BaseFolder_SearchBaseUrlPath] %svnLastVer_By_BaseFolder_SearchBaseUrlPath%
ECHO [svnLastVer_By_BaseFolder_SearchSubUrlPath] %svnLastVer_By_BaseFolder_SearchSubUrlPath%
ECHO [svnLastVer_By_BaseFolder_LocalPath] %svnLastVer_By_BaseFolder_LocalPath%

:: ===============================================
:: Check input param.
IF "%svnLastVer_By_BaseFolder_OutputLogFileName%"=="" (
	ECHO "svnLastVer_By_BaseFolder_OutputLogFileName is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_OutputLogFileName is illegal. : %svnLastVer_By_BaseFolder_OutputLogFileName%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_By_BaseFolder_SearchBaseUrlPath%"=="" (
	ECHO "svnLastVer_By_BaseFolder_SearchBaseUrlPath is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_SearchBaseUrlPath is illegal. : %svnLastVer_By_BaseFolder_SearchBaseUrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_By_BaseFolder_SearchSubUrlPath%"=="" (
	ECHO "svnLastVer_By_BaseFolder_SearchSubUrlPath is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_SearchSubUrlPath is illegal. : %svnLastVer_By_BaseFolder_SearchSubUrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_By_BaseFolder_LocalPath%"=="" (
	ECHO "svnLastVer_By_BaseFolder_LocalPath is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_LocalPath is illegal. : %svnLastVer_By_BaseFolder_LocalPath%
	SET ReVal=1
	GOTO END
)

:: 由使用者決定分隔符號.
SET DependFolder=%svnLastVer_By_BaseFolder_SearchBaseUrlPath%%svnLastVer_By_BaseFolder_SearchSubUrlPath%

:: ===============================================
:: 設定 指定路徑上ㄧ次修改的 svn 版本.
SET Exported_LCR_Num=
FOR /F "tokens=4" %%a IN ('svn info %svnLastVer_By_BaseFolder_SearchBaseUrlPath% -r HEAD ^| findstr /R /C:"Last Changed Rev:"') DO SET Exported_LCR_Num=%%a

:: 輸出相關版本資訊.
ECHO [ExportedLastChangedRev] %Exported_LCR_Num%

:: output to file.
ECHO -r %Exported_LCR_Num% %DependFolder%@%Exported_LCR_Num% %svnLastVer_By_BaseFolder_LocalPath%>> %svnLastVer_By_BaseFolder_OutputLogFileName%

:: ===============================================
:END

@ECHO ON
ECHO [svnLastVer_By_BaseFolder: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

:: ===============================================
:: Note
:: 由DependFileName設定檔案內容 此檔案來清除 svn cleanup.

:: 輸入參數
:: %1: svnCleanup_SearchFolder => 要收尋的 depend folder (含路徑)

:: external 的格式: like as follow, 雙引號內容, 不含雙引號.
:: "-r 473 https://svn32.gosmio.biz/svn/SGT.GameCore.Publish/trunk/core.tools/vs2012@473 SGT.GameCore.Publish/core.tools"
:: "https://svn32.gosmio.biz/svn/SGT.GameCore.Publish/trunk/protocols/vs2012 SGT.GameCore.Publish/protocols"
:: ===============================================

:: ===============================================
:: 初始化 基本資訊.
SET svnCleanup_SearchFolder=

SET svnCleanup_SearchFolder=%1

ECHO [svnCleanup_SearchFolder] %svnCleanup_SearchFolder%


:: ===============================================
:: Check input param.
IF "%svnCleanup_SearchFolder%"=="" (
	ECHO "svnCleanup_SearchFolder is illegal." 
	start cmd /K ECHO svnCleanup_SearchFolder is illegal. : %svnCleanup_SearchFolder%
	GOTO END
)


:: ===============================================
:: 建立臨時性的 svn external files.
SET DependFileName=%svnCleanup_SearchFolder%\svnCleanupTmp.txt

copy/Y NUL %DependFileName%
svn propget svn:externals %svnCleanup_SearchFolder%>%DependFileName%


:: ===============================================
:: svn clean up depend
:: 由檔案內容判斷 每一筆以空白做區隔, 第二個跟第四個 為可能需要清除的 folder
:: token:4 為空, 則表示 token:2 是 folder.
@ECHO OFF&SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "usebackq delims= tokens=1" %%i IN ( %DependFileName% ) DO (
	ECHO ===============================================
	ECHO [%%i] : %%i
	FOR /F "usebackq tokens=2,4 delims= " %%j IN ( '%%i' ) DO (
	ECHO [token:2] : %%j
	ECHO [token:4] : %%k
	ECHO.
		IF "%%k"=="" (
			svn cleanup %svnCleanup_SearchFolder%/%%j
		) ELSE (
			svn cleanup %svnCleanup_SearchFolder%/%%k
		)
	)
)

:: 刪除 臨時性檔案.
del %DependFileName%

:: ===============================================
:END

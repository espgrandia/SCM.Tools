@ECHO OFF

:: ===============================================
:: Note
:: 輸入參數
:: %1: onceLog_SearchRootFolderPath => root folder 路徑.
:: %2: RootLastChangeRev => root folder 的最後改變版本.
:: %3: 差距 count => 與 root folder 的最後改變版本 往前推的差距版本.
:: %4: onceLog_OutputLogFileName => 輸出的 log 檔名 (含路徑)

:: 參數一定要是對的, 目前沒有防呆.
:: Folder Path 最後面不要加上 \, svn commit command 在有加上 "" 會有問題.
:: ===============================================

:: ===============================================
SET onceLog_SearchRootFolderPath=%~1

:: 單一一次的 svn log
SET /A onceLog_SvnNum=%2-%3

SET onceLog_OutputLogFileName=%~4

:: 設定 差異的版本數量
SET limitCount=%3

:: ===============================================
ECHO.>> "%onceLog_OutputLogFileName%"
ECHO *** svn log [onceLog_SvnNum]: %onceLog_SvnNum%: Begin ***>> "%onceLog_OutputLogFileName%"
svn log "%onceLog_SearchRootFolderPath%" -r %onceLog_SvnNum% >> "%onceLog_OutputLogFileName%"
ECHO *** svn log [onceLog_SvnNum]: %onceLog_SvnNum%: End ***>> "%onceLog_OutputLogFileName%"
ECHO.>> "%onceLog_OutputLogFileName%"

:: ===============================================
:END

ECHO [onceLog: ERRORLEVEL] %ERRORLEVEL%

@ECHO ON
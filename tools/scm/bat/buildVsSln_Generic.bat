@ECHO OFF
:: ===============================================
:: Visual studio 通用的編譯批次檔.

:: Visual studio version note:
::   9.0 : vs2008, 10.0 : vs2010, 11.0 : vs2012
:: buildVsSln_Generic_VsVer 請輸入前面的編碼 => 實際 folder 的名稱.

:: %1: buildVsSln_Generic_VsVer => visual studio 的版本.
:: %2: buildVsSln_Generic_VsSlnPath => 建置的方案 檔名 (含路徑).
:: %3: buildVsSln_Generic_Configuration => 編譯組態.
:: ===============================================

:: ===============================================
:: 設定回傳值, 0: 成功.
SET ReVal=0

SET buildVsSln_Generic_VsVer=
SET buildVsSln_Generic_VsVer=%1

REM 建置的方案
SET buildVsSln_Generic_VsSlnPath=
SET buildVsSln_Generic_VsSlnPath=%2

REM 編譯的組態
SET buildVsSln_Generic_Configuration=
SET buildVsSln_Generic_Configuration=%3

ECHO [buildVsSln_Generic_VsVer] %buildVsSln_Generic_VsVer%
ECHO [buildVsSln_Generic_VsSlnPath] %buildVsSln_Generic_VsSlnPath%
ECHO [buildVsSln_Generic_Configuration] %buildVsSln_Generic_Configuration%

:: ===============================================
:: Check input param.
IF "%buildVsSln_Generic_VsVer%"=="" (
	ECHO "buildVsSln_Generic_VsVer is illegal." 
	start cmd /K ECHO buildVsSln_Generic_VsVer is illegal. : %buildVsSln_Generic_VsVer%
	SET ReVal=1
	GOTO END
)

IF "%buildVsSln_Generic_VsSlnPath%"=="" (
	ECHO "buildVsSln_Generic_VsSlnPath is illegal." 
	start cmd /K ECHO buildVsSln_Generic_VsSlnPath is illegal. : %buildVsSln_Generic_VsSlnPath%
	SET ReVal=1
	GOTO END
)

IF "%buildVsSln_Generic_Configuration%"=="" (
	ECHO "buildVsSln_Generic_Configuration is illegal." 
	start cmd /K ECHO buildVsSln_Generic_Configuration is illegal. : %buildVsSln_Generic_Configuration%
	SET ReVal=1
	GOTO END
)

:: ===============================================
REM 編譯軟體路徑
SET VsDevenvFilePath=
SET VsDevenvFilePathDefault="C:\Program Files\Microsoft Visual Studio %buildVsSln_Generic_VsVer%\Common7\IDE\devenv.com"
SET VsDevenvFilePathx86="C:\Program Files (x86)\Microsoft Visual Studio %buildVsSln_Generic_VsVer%\Common7\IDE\devenv.com"


:: ===============================================
REM 決定 Program Files 的資料夾路徑
IF EXIST %VsDevenvFilePathDefault% (
	SET VsDevenvFilePath=%VsDevenvFilePathDefault%
) ELSE (
	IF EXIST %VsDevenvFilePathx86% (
		SET VsDevenvFilePath=%VsDevenvFilePathx86%
	) ELSE (
		SET ReVal=1
		GOTO END
	)
)

:: ===============================================
REM 重建專案
ECHO [VsDevenvFilePath] %VsDevenvFilePath%
%VsDevenvFilePath% %buildVsSln_Generic_VsSlnPath% /rebuild %buildVsSln_Generic_Configuration%

REM 如果建置失敗就跳到建置錯誤
IF %ERRORLEVEL% EQU 1 (
	start cmd /K ECHO BuildError : [VsDevenvFilePath] %VsDevenvFilePath% [buildVsSln_Generic_VsSlnPath] %buildVsSln_Generic_VsSlnPath% [buildVsSln_Generic_Configuration] %buildVsSln_Generic_Configuration%
	SET ReVal=1
	GOTO End
)


:: ===============================================
:END

@ECHO on
ECHO [buildVsSln_Generic: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%


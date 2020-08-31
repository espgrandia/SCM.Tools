@ECHO OFF

:: ===============================================
:: Note: copy one file to output folder
:: �� output folder ���s�b��, �|���իإ�.

:: %1: copyFileToFolder_FileName => �ɮצW�� (�t���|).
:: %2: copyFileToFolder_OutputPath => ��X����m (�@�묰 �ؿ�, �t���|).
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: �]�w ��X���ؿ�.
SET copyFileToFolder_FileName=
SET copyFileToFolder_FileName=%1

:: �]�w ��X���ؿ�.
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

:: �S�� copyFileToFolder_OutputPath �|���իإ�.
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

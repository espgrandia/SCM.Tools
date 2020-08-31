@ECHO OFF

:: ===============================================
:: Note
:: copy �ؼХؿ��U���Ҧ���Ƨ����ɮ�
:: ��J�Ѽ�
:: %1: copyFolder_OriPath => �즳���ؿ�.
:: %2: copyFolder_ExecutePath => �n���� xcopy floder ���ؿ�.
:: %3: copyFolder_CopyFolderName => �n copy �� ��Ƨ��W��.
:: %4: copyFolder_OutputPath => ��X����m (�@�묰 �ؿ�, �t���|).
:: �ѼƤ@�w�n�O�諸, �ثe�S�����b, �u��²�����P�_.
:: ������|�۹�ӻ�����S�����D.
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: ��l�� �򥻸�T.
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
:: ������n copy folder �ؿ�.
CHDIR %copyFolder_ExecutePath%

:: �S�� copyFolder_OutputPath �|���իإ�.
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

:: �����^�즳�ؿ�.
CHDIR %copyFolder_OriPath%

:: ===============================================
:END

@ECHO on
ECHO [copyFolder: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

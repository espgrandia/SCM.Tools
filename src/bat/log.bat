@ECHO OFF

:: ===============================================
:: Note
:: ��J�Ѽ�
:: %1: log_SearchRootFolderPath => root folder ���|.
:: %2: log_RootLastChangeRev => root folder ���̫���ܪ���.
:: %3: log_ExportedLastChangeRev => �o�G folder ���̫���ܪ���.
:: %4: log_LimitCount => root folder ���̫���ܪ���.
:: %5: log_OutputLogFileName => ��X�� log �ɦW (�t���|)
:: %6: log_TempleteLogFileName => ��X log ���_�l�d���ɦW(�t���|).

:: �ѼƤ@�w�n�O�諸, �ثe�S�����b.
:: Folder Path �̫᭱���n�[�W \, svn commit command �b���[�W "" �|�����D.
:: ===============================================

:: ===============================================
:: �]�w Root Folder 
SET log_SearchRootFolderPath=%~1

:: �]�w log_RootLastChangeRev Svn.
SET /A log_RootLastChangeRev=%2

:: �]�w Exported_LCR_Num, Log ��.
SET /A log_ExportedLastChangeRev=%3

:: �]�w �t���������ƶq
SET /A log_LimitCount=%4

:: �]�w ��X�� log �ɦW (�t���|)
SET log_OutputLogFileName=%~5

:: �]�w ��X log ���_�l�d���ɦW(�t���|).
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
:: ���ͤ@�ӪŪ� "%log_OutputLogFileName%" (�L���ɮ׫h�|�۰ʫإ�)
copy/Y NUL "%log_OutputLogFileName%"

:: svn ���Y��
xcopy /y "%log_TempleteLogFileName%" "%log_OutputLogFileName%"

:: ===============================================
:: output log to file.
:: ��U�� svn info.
ECHO ====================================>> "%log_OutputLogFileName%"
ECHO *** snv info ***>> "%log_OutputLogFileName%"
svn info "%log_SearchRootFolderPath%" >> "%log_OutputLogFileName%"

:: �ݥ��T�{�n�� svn ���� log
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
:: �I�s OnceLog.bat �e���]�w chdir.
SET Log_InputPath=%CD%
ECHO [log: oldpath] %Log_InputPath%

CHDIR %~dp0

:: �]�w loop count.
SET /A Log_LoopCount=%log_LimitCount%-1
for /L %%i IN ( 0, 1, %Log_LoopCount% ) DO (
	CALL OnceLog.bat "%log_SearchRootFolderPath%" %log_RootLastChangeRev% %%i "%log_OutputLogFileName%"
)

CHDIR %Log_InputPath%

:: ===============================================
:END

ECHO [log: ERRORLEVEL] %ERRORLEVEL%

@ECHO ON

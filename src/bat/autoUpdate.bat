@ECHO OFF

:: ===============================================
:: Note
:: �۰� update �ӥB check �O�_�n svn commit.
:: ��J�� batch file
::   �ݭn�ۦ�B�z�ؿ����ۦP���D, ex: ����������ɮת��ظ��A���^���l�ؿ�.
::   �� batch file �u�O��©I�s��J���妸��, �ð��^�ǭ��˹�.

:: �ѼƤ� ���ťեi��J "xxx", �|�h�� ""

:: %1: autoUpdate_DependFolder => �ncheck depend ���ؿ�.
:: %2: autoUpdate_TitleLog: �n��X log �� Title.
:: %3: autoUpdate_UpdateSvnExternalsBatch: �۰ʧ�s depend �� batch file.
:: %4: autoUpdate_CleanUpSvnBatch: �M�� svn �� batch file.
:: %5: autoUpdate_CheckBatch: ���ҬO�_��s��i�H work �� batch file (�q�`�� build.bat).
:: ===============================================

:: ===============================================
SETLOCAL ENABLEDELAYEDEXPANSION

:: �������e�ؿ�.
SET autoUpdate_InputPath=%CD%

ECHO.
ECHO [autoUpdate: oldPath] : %autoUpdate_InputPath%

CHDIR %~dp0

ECHO [autoUpdate: currentPath] : %CD%

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: �]�w�å����ͪŪ��Ȧs��.
:: svn:externals ���t��log, �ثe�O�ˬd��, ������show log �����e, �]���Ӥ��e�� CRLF �� LF ����_�椣�P, �ɭP�L�k svn commit.
SET SvnDiffLogFileName=autoUpdate_SvnDiff.log
copy/Y NUL %SvnDiffLogFileName%

SET SvnCommitLogFileName=autoUpdate_SvnCommit.log
copy/Y NUL %SvnCommitLogFileName%

:: autoUpdate_DependFolder => �ncheck depend ���ؿ�.
SET autoUpdate_DependFolder=
SET autoUpdate_DependFolder=%~1

:: autoUpdate_TitleLog: �n��X log �� Title, ���ťեi��J "xxx", �|�h�� "".
SET autoUpdate_TitleLog=
SET autoUpdate_TitleLog=%~2

:: autoUpdate_UpdateSvnExternalsBatch: �۰ʧ�s depend �� batch file.
SET autoUpdate_UpdateSvnExternalsBatch=
SET autoUpdate_UpdateSvnExternalsBatch=%~3

:: autoUpdate_CleanUpSvnBatch: �M�� svn �� batch file.
SET autoUpdate_CleanUpSvnBatch=
SET autoUpdate_CleanUpSvnBatch=%~4

:: ���ҬO�_��s��i�H work �� batch file (�q�`�� build.bat).
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

:: Check svn diff �O�_������.
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
	REM :: ��U�� svn info.
	ECHO ====================================>> %SvnCommitLogFileName%
	ECHO *** snv info ***>> %SvnCommitLogFileName%
	svn info "%autoUpdate_DependFolder%" >> %SvnCommitLogFileName%
	
	ECHO ====================================>> %SvnCommitLogFileName%
	ECHO svn external as following...>> %SvnCommitLogFileName%

	ECHO.>> %SvnCommitLogFileName%

	REM svn diff svn::externals �� CRLF �� LF ����_�椣�P, �ɭP�L�k svn commit, �� mark �_��.
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

	REM �I�s cleanUp ���妸��.
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
:: �����^��l�ؿ�.
CHDIR %autoUpdate_InputPath%
ECHO [autoUpdate: currentPath] : %CD%

@ECHO on
ECHO [autoUpdate: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

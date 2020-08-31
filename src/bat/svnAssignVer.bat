@ECHO OFF

:: ===============================================
:: Note
:: ���w svn folder �� ver ��T, �ñN��T�ɥX��ӿ�J���Ѽ��ɮ�.

:: ��J�Ѽ�
:: %1: svnAssignVer_OutputLogFileName => ��X�� log �ɦW (�t���|)
:: %2: svnAssignVer_UrlPath => �n ���w �� folder, �i�H�O svn ������|.
:: %3: svnAssignVer_LocalPath => ���a�ݪ��O�W (�ndepend�����|).
:: %4: svnAssignVer_AssignedNum => �n���w�� svn ver number.
:: ===============================================

:: ===============================================
SETLOCAL ENABLEDELAYEDEXPANSION

:: �������e�ؿ�.
SET SvnAssignVer_InputPath=%CD%

ECHO.
ECHO [svnAssignVer: oldPath] : %SvnAssignVer_InputPath%

CHDIR %~dp0

ECHO [svnAssignVer: currentPath] : %CD%

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: ��l�� �򥻸�T.
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

:: �P�@�h�ؿ��U���妸��.
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
:: �����^��l�ؿ�.
CHDIR %SvnAssignVer_InputPath%
ECHO [svnAssignVer: currentPath] : %CD%

@ECHO ON
ECHO [svnAssignVer: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

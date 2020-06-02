@ECHO OFF
:: ===============================================
:: Visual studio �q�Ϊ��sĶ�妸��.

:: Visual studio version note:
::   9.0 : vs2008, 10.0 : vs2010, 11.0 : vs2012
:: buildVsSln_Generic_VsVer �п�J�e�����s�X => ��� folder ���W��.

:: %1: buildVsSln_Generic_VsVer => visual studio ������.
:: %2: buildVsSln_Generic_VsSlnPath => �ظm����� �ɦW (�t���|).
:: %3: buildVsSln_Generic_Configuration => �sĶ�պA.
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

SET buildVsSln_Generic_VsVer=
SET buildVsSln_Generic_VsVer=%1

REM �ظm�����
SET buildVsSln_Generic_VsSlnPath=
SET buildVsSln_Generic_VsSlnPath=%2

REM �sĶ���պA
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
REM �sĶ�n����|
SET VsDevenvFilePath=
SET VsDevenvFilePathDefault="C:\Program Files\Microsoft Visual Studio %buildVsSln_Generic_VsVer%\Common7\IDE\devenv.com"
SET VsDevenvFilePathx86="C:\Program Files (x86)\Microsoft Visual Studio %buildVsSln_Generic_VsVer%\Common7\IDE\devenv.com"


:: ===============================================
REM �M�w Program Files ����Ƨ����|
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
REM ���رM��
ECHO [VsDevenvFilePath] %VsDevenvFilePath%
%VsDevenvFilePath% %buildVsSln_Generic_VsSlnPath% /rebuild %buildVsSln_Generic_Configuration%

REM �p�G�ظm���ѴN����ظm���~
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


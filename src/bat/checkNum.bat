@ECHO OFF

:: ===============================================
:: Note
:: �T�{ input �O�_���Ʀr.

:: Ref: http://stackoverflow.com/questions/17584282/how-to-check-if-a-parameter-or-variable-is-numeric-in-windows-batch-file

:: ��J�Ѽ�
:: %1: Number
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

ECHO [checkNum: Number] %1

SET "Var="&FOR /F "delims=0123456789" %%i in ("%1") do set Var=%%i
IF Defined Var (
	ECHO %1 is Not numeric
	SET ReVal=1
	GOTO END
) else (
	ECHO %1 is numeric
)

:: ===============================================
:END

@ECHO ON
ECHO [checkNum: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

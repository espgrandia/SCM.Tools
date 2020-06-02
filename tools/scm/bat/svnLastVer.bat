@ECHO OFF

:: ===============================================
:: Note
:: ��� �n���M�� svn last change ver ��T, �ñN��T�ɥX��ӿ�J���Ѽ��ɮ�.

:: ��J�Ѽ�
:: %1: svnLastVer_OutputLogFileName => ��X�� log �ɦW (�t���|)
:: %2: svnLastVer_SearchUrlPath => �n ���M �� folder, �i�H�O svn ������|.
:: %3: svnLastVer_LocalPath => ���a�ݪ��O�W (�ndepend�����|).
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: ��l�� �򥻸�T.
SET svnLastVer_OutputLogFileName=
SET svnLastVer_SearchUrlPath=
SET svnLastVer_LocalPath=

SET svnLastVer_OutputLogFileName=%1
SET svnLastVer_SearchUrlPath=%2
SET svnLastVer_LocalPath=%3

ECHO [svnLastVer_OutputLogFileName] %svnLastVer_OutputLogFileName%
ECHO [svnLastVer_SearchUrlPath] %svnLastVer_SearchUrlPath%
ECHO [svnLastVer_LocalPath] %svnLastVer_LocalPath%

:: ===============================================
:: Check input param.
IF "%svnLastVer_OutputLogFileName%"=="" (
	ECHO "svnLastVer_OutputLogFileName is illegal." 
	start cmd /K ECHO svnLastVer_OutputLogFileName is illegal. : %svnLastVer_OutputLogFileName%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_SearchUrlPath%"=="" (
	ECHO "svnLastVer_SearchUrlPath is illegal." 
	start cmd /K ECHO svnLastVer_SearchUrlPath is illegal. : %svnLastVer_SearchUrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_LocalPath%"=="" (
	ECHO "svnLastVer_LocalPath is illegal." 
	start cmd /K ECHO svnLastVer_LocalPath is illegal. : %svnLastVer_LocalPath%
	SET ReVal=1
	GOTO END
)

:: ===============================================
:: �]�w ���w���|�W�����ק諸 svn ����.
SET Exported_LCR_Num=
FOR /F "tokens=4" %%a IN ('svn info %svnLastVer_SearchUrlPath% -r HEAD ^| findstr /R /C:"Last Changed Rev:"') DO SET Exported_LCR_Num=%%a

:: ��X����������T.
ECHO [ExportedLastChangedRev] %Exported_LCR_Num%

:: output to file.
ECHO -r %Exported_LCR_Num% %svnLastVer_SearchUrlPath%@%Exported_LCR_Num% %svnLastVer_LocalPath%>> %svnLastVer_OutputLogFileName%

:: ===============================================
:END

@ECHO ON
ECHO [svnLastVer: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

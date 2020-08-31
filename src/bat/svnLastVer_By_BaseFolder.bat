@ECHO OFF

:: ===============================================
:: Note
:: ��� �n���M�� svn last change ver ��T, �ñN��T�ɥX��ӿ�J���Ѽ��ɮ�.
:: �H svnLastVer_By_BaseFolder_SearchBaseUrlPath �����M�� svn last change ver ���|, svnLastVer_By_BaseFolder_SearchSubUrlPath ���� �l�ؿ�. 

:: ��J�Ѽ�
:: %1: svnLastVer_By_BaseFolder_OutputLogFileName => ��X�� log �ɦW (�t���|)
:: %2: svnLastVer_By_BaseFolder_SearchBaseUrlPath => �n ���M �� folder, �i�H�O svn ������|.
:: %3: svnLastVer_By_BaseFolder_SearchSubUrlPath => �n ���M �� sub folder(�ݦۦ�a�J���j�u).
:: %4: svnLastVer_By_BaseFolder_LocalPath => ���a�ݪ��O�W (�ndepend�����|).
:: ===============================================

:: ===============================================
:: �]�w�^�ǭ�, 0: ���\.
SET ReVal=0

:: ��l�� �򥻸�T.
SET svnLastVer_By_BaseFolder_OutputLogFileName=
SET svnLastVer_By_BaseFolder_SearchBaseUrlPath=
SET svnLastVer_By_BaseFolder_LocalPath=

SET svnLastVer_By_BaseFolder_OutputLogFileName=%1
SET svnLastVer_By_BaseFolder_SearchBaseUrlPath=%2
SET svnLastVer_By_BaseFolder_SearchSubUrlPath=%3
SET svnLastVer_By_BaseFolder_LocalPath=%4

ECHO [svnLastVer_By_BaseFolder_OutputLogFileName] %svnLastVer_By_BaseFolder_OutputLogFileName%
ECHO [svnLastVer_By_BaseFolder_SearchBaseUrlPath] %svnLastVer_By_BaseFolder_SearchBaseUrlPath%
ECHO [svnLastVer_By_BaseFolder_SearchSubUrlPath] %svnLastVer_By_BaseFolder_SearchSubUrlPath%
ECHO [svnLastVer_By_BaseFolder_LocalPath] %svnLastVer_By_BaseFolder_LocalPath%

:: ===============================================
:: Check input param.
IF "%svnLastVer_By_BaseFolder_OutputLogFileName%"=="" (
	ECHO "svnLastVer_By_BaseFolder_OutputLogFileName is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_OutputLogFileName is illegal. : %svnLastVer_By_BaseFolder_OutputLogFileName%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_By_BaseFolder_SearchBaseUrlPath%"=="" (
	ECHO "svnLastVer_By_BaseFolder_SearchBaseUrlPath is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_SearchBaseUrlPath is illegal. : %svnLastVer_By_BaseFolder_SearchBaseUrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_By_BaseFolder_SearchSubUrlPath%"=="" (
	ECHO "svnLastVer_By_BaseFolder_SearchSubUrlPath is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_SearchSubUrlPath is illegal. : %svnLastVer_By_BaseFolder_SearchSubUrlPath%
	SET ReVal=1
	GOTO END
)

IF "%svnLastVer_By_BaseFolder_LocalPath%"=="" (
	ECHO "svnLastVer_By_BaseFolder_LocalPath is illegal." 
	start cmd /K ECHO svnLastVer_By_BaseFolder_LocalPath is illegal. : %svnLastVer_By_BaseFolder_LocalPath%
	SET ReVal=1
	GOTO END
)

:: �ѨϥΪ̨M�w���j�Ÿ�.
SET DependFolder=%svnLastVer_By_BaseFolder_SearchBaseUrlPath%%svnLastVer_By_BaseFolder_SearchSubUrlPath%

:: ===============================================
:: �]�w ���w���|�W�����ק諸 svn ����.
SET Exported_LCR_Num=
FOR /F "tokens=4" %%a IN ('svn info %svnLastVer_By_BaseFolder_SearchBaseUrlPath% -r HEAD ^| findstr /R /C:"Last Changed Rev:"') DO SET Exported_LCR_Num=%%a

:: ��X����������T.
ECHO [ExportedLastChangedRev] %Exported_LCR_Num%

:: output to file.
ECHO -r %Exported_LCR_Num% %DependFolder%@%Exported_LCR_Num% %svnLastVer_By_BaseFolder_LocalPath%>> %svnLastVer_By_BaseFolder_OutputLogFileName%

:: ===============================================
:END

@ECHO ON
ECHO [svnLastVer_By_BaseFolder: ERRORLEVEL] %ReVal%
EXIT /B %ReVal%

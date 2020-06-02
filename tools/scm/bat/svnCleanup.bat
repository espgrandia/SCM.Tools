:: ===============================================
:: Note
:: ��DependFileName�]�w�ɮפ��e ���ɮרӲM�� svn cleanup.

:: ��J�Ѽ�
:: %1: svnCleanup_SearchFolder => �n���M�� depend folder (�t���|)

:: external ���榡: like as follow, ���޸����e, ���t���޸�.
:: "-r 473 https://svn32.gosmio.biz/svn/SGT.GameCore.Publish/trunk/core.tools/vs2012@473 SGT.GameCore.Publish/core.tools"
:: "https://svn32.gosmio.biz/svn/SGT.GameCore.Publish/trunk/protocols/vs2012 SGT.GameCore.Publish/protocols"
:: ===============================================

:: ===============================================
:: ��l�� �򥻸�T.
SET svnCleanup_SearchFolder=

SET svnCleanup_SearchFolder=%1

ECHO [svnCleanup_SearchFolder] %svnCleanup_SearchFolder%


:: ===============================================
:: Check input param.
IF "%svnCleanup_SearchFolder%"=="" (
	ECHO "svnCleanup_SearchFolder is illegal." 
	start cmd /K ECHO svnCleanup_SearchFolder is illegal. : %svnCleanup_SearchFolder%
	GOTO END
)


:: ===============================================
:: �إ��{�ɩʪ� svn external files.
SET DependFileName=%svnCleanup_SearchFolder%\svnCleanupTmp.txt

copy/Y NUL %DependFileName%
svn propget svn:externals %svnCleanup_SearchFolder%>%DependFileName%


:: ===============================================
:: svn clean up depend
:: ���ɮפ��e�P�_ �C�@���H�ťհ��Ϲj, �ĤG�Ӹ�ĥ|�� ���i��ݭn�M���� folder
:: token:4 ����, �h��� token:2 �O folder.
@ECHO OFF&SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "usebackq delims= tokens=1" %%i IN ( %DependFileName% ) DO (
	ECHO ===============================================
	ECHO [%%i] : %%i
	FOR /F "usebackq tokens=2,4 delims= " %%j IN ( '%%i' ) DO (
	ECHO [token:2] : %%j
	ECHO [token:4] : %%k
	ECHO.
		IF "%%k"=="" (
			svn cleanup %svnCleanup_SearchFolder%/%%j
		) ELSE (
			svn cleanup %svnCleanup_SearchFolder%/%%k
		)
	)
)

:: �R�� �{�ɩ��ɮ�.
del %DependFileName%

:: ===============================================
:END

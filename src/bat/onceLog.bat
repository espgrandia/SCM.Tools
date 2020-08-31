@ECHO OFF

:: ===============================================
:: Note
:: ��J�Ѽ�
:: %1: onceLog_SearchRootFolderPath => root folder ���|.
:: %2: RootLastChangeRev => root folder ���̫���ܪ���.
:: %3: �t�Z count => �P root folder ���̫���ܪ��� ���e�����t�Z����.
:: %4: onceLog_OutputLogFileName => ��X�� log �ɦW (�t���|)

:: �ѼƤ@�w�n�O�諸, �ثe�S�����b.
:: Folder Path �̫᭱���n�[�W \, svn commit command �b���[�W "" �|�����D.
:: ===============================================

:: ===============================================
SET onceLog_SearchRootFolderPath=%~1

:: ��@�@���� svn log
SET /A onceLog_SvnNum=%2-%3

SET onceLog_OutputLogFileName=%~4

:: �]�w �t���������ƶq
SET limitCount=%3

:: ===============================================
ECHO.>> "%onceLog_OutputLogFileName%"
ECHO *** svn log [onceLog_SvnNum]: %onceLog_SvnNum%: Begin ***>> "%onceLog_OutputLogFileName%"
svn log "%onceLog_SearchRootFolderPath%" -r %onceLog_SvnNum% >> "%onceLog_OutputLogFileName%"
ECHO *** svn log [onceLog_SvnNum]: %onceLog_SvnNum%: End ***>> "%onceLog_OutputLogFileName%"
ECHO.>> "%onceLog_OutputLogFileName%"

:: ===============================================
:END

ECHO [onceLog: ERRORLEVEL] %ERRORLEVEL%

@ECHO ON
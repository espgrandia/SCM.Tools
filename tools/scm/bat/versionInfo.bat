@ECHO OFF

:: ===============================================
:: Note: show exe (or dll) �� file version
:: %1: FileName => �ɮצW�� (�t���|).
:: ===============================================

echo %cd%

cscript //nologo %~dp0versioninfo.vbs %1

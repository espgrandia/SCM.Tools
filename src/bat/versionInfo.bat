@ECHO OFF

:: ===============================================
:: Note: show exe (or dll) 的 file version
:: %1: FileName => 檔案名稱 (含路徑).
:: ===============================================

echo %cd%

cscript //nologo %~dp0versioninfo.vbs %1

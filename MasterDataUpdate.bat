SET server=localhost
SET database=TEST

SET username=RalWebClientAdmin
SET password=ralwebclientadmin

@echo Updating Master Data
@echo off
For /R ".\Master Data" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

pause
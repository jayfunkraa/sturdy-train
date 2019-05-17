SET server=localhost
SET database=TEST

SET username=RalWebClientAdmin
SET password=ralwebclientadmin

@echo Applying System Reliability Updates

@echo Updating Tables
@echo off
For /R ".\System Reliability\Tables" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

@echo Updating Stored Procedures
@echo off
For /R ".\System Reliability\Stored Procedures" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

@echo Applying Component Reliability Updates

@echo Updating Tables
@echo off
For /R ".\Component Reliability\Tables" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

@echo Updating Stored Procedures
@echo off
For /R ".\Component Reliability\Stored Procedures" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

@echo Updating Master Data
@echo off
For /R ".\Master Data" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

pause
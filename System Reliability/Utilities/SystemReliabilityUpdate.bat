SET server=localhost
SET database=TEST

SET username=RalWebClientAdmin
SET password=ralwebclientadmin


@echo "Updating Tables"
@echo off
For /R ".\Tables" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

@echo "Updating Functions"
@echo off
For /R ".\Functions" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

@echo "Updating Stored Procedures"
@echo off
For /R ".\StoredProcedures" %%i in (*.sql) DO CALL sqlcmd.exe -U %username% -P %password% -S %server% -d %database%  -i "%%i"

pause
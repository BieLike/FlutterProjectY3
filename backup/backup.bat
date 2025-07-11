@echo off

set DATE=%date:~10,4%-%date:~4,2%-%date:~7,2%

:: Manual
mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail > "E:\Flutter_project\backup\Manually\backup-Manual-%DATE%.sql"

:: Daily
mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail > "E:\Flutter_project\backup\Daily\backup-daily-%DATE%.sql"

:: If it's Sunday, do weekly too
for /f %%d in ('powershell (Get-Date).DayOfWeek') do set DOW=%%d
if "%DOW%"=="Sunday" mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail > "E:\Flutter_project\backup\Weekly\backup-weekly-%DATE%.sql"

:: If it's first day of month
for /f %%d in ('powershell (Get-Date).Day') do set DAY=%%d
if "%DAY%"=="1" mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail > "E:\Flutter_project\backup\Monthly\backup-monthly-%DATE%.sql"

:: Every 4 days
for /f %%d in ('powershell (Get-Date).Day') do set DAY=%%d
set /a MOD4=%DAY% %% 4
if "%MOD4%"=="0" mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail > "E:\Flutter_project\backup\4days\backup-every4days-%DATE%.sql"

:: Once a year
for /f %%m in ('powershell (Get-Date).Month') do set MONTH=%%m
for /f %%d in ('powershell (Get-Date).Day') do set DAY=%%d
if "%MONTH%"=="1" if "%DAY%"=="1" mysqldump -u root dbcpr --ignore-table=dbcpr.tbsell --ignore-table=dbcpr.tbimport --ignore-table=dbcpr.tbselldetail --ignore-table=dbcpr.tbimportdetail  > "E:\Flutter_project\backup\Yearly\backup-yearly-%DATE%.sql"




:: Delete daily backups older than 90 days
forfiles /p "E:\Flutter_project\backup\Manual" /m backup-Manually-*.sql /d -90 /c "cmd /c del @path"

:: Delete daily backups older than 2 days
forfiles /p "E:\Flutter_project\backup\Daily" /m backup-daily-*.sql /d -2 /c "cmd /c del @path"

:: Delete weekly backups older than 14 days
forfiles /p "E:\Flutter_project\backup\Weekly" /m backup-weekly-*.sql /d -14 /c "cmd /c del @path"

:: Delete monthly backups older than 60 days
forfiles /p "E:\Flutter_project\backup\Monthly" /m backup-monthly-*.sql /d -60 /c "cmd /c del @path"

:: Delete monthly backups older than 8 days
forfiles /p "E:\Flutter_project\backup\4days" /m backup-every4days-*.sql /d -8 /c "cmd /c del @path"

:: Delete monthly backups older than 750 days
forfiles /p "E:\Flutter_project\backup\Yearly" /m backup-yearly-*.sql /d -750 /c "cmd /c del @path"


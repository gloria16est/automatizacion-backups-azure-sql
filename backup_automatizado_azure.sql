-- Automatización de Backups en Azure
-- Base de Datos: RepuestosPerez

--1️ Creación de Credencial 
CREATE CREDENTIAL [https://perezstorage.blob.core.windows.net/respaldos]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '?sv=2024-11-04&ss=b&srt=sco&sp=rwdlaciytfx&se=2027-02-24T08:31:22Z&st=2026-02-25T00:16:22Z&spr=https&sig=TVRNUpooXKPIkofh8tjWQLDRWryBmMnYCC6xF%2FcCvqo%3D';
GO

-- 2️ Backup Completo hacia Azure
BACKUP DATABASE [RepuestosPerez] 
TO URL = 'https://perezstorage.blob.core.windows.net/respaldos/Respaldo_UNC_Final.bak'
WITH FORMAT, 
     STATS = 10, 
     BLOCKSIZE = 65536, 
     MAXTRANSFERSIZE = 4194304;
GO

--3 Script del Job
USE [msdb]
GO

/****** Object:  Job [Backup_Diario_Azure]    Script Date: 1/03/2026 02:02:56:a. m. ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 1/03/2026 02:02:57:a. m. ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup_Diario_Azure', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'LAPTOP-QJUP9VG7\glori', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Ejecutar_Respaldo_Azure]    Script Date: 1/03/2026 02:02:57:a. m. ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Ejecutar_Respaldo_Azure', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [RepuestosPerez] 
TO URL = ''https://perezstorage.blob.core.windows.net/respaldos/Respaldo_UNC_Final.bak''
WITH FORMAT, 
     STATS = 10, 
     BLOCKSIZE = 65536, 
     MAXTRANSFERSIZE = 4194304;
GO', 
		@database_name=N'RepuestosPerez', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Respaldo_Nocturno', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20260224, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c1508e77-4406-401a-af6f-3717b14eb7cf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO




/*
  Public example only.
  Production credentials/paths are intentionally not included.

  Recommended public/reference approach:
  SQL Server Agent -> PowerShell step -> Stored Procedure / Relay Adapter

  This avoids storing relay credentials inside T-SQL and makes the external process boundary explicit.
*/

USE msdb;
GO

-- Example outbound job (disabled by default)
EXEC dbo.sp_add_job @job_name = N'EDI - Purchase Order Outbound', @enabled = 0;
EXEC dbo.sp_add_jobstep
    @job_name = N'EDI - Purchase Order Outbound',
    @step_name = N'Run PowerShell outbound',
    @subsystem = N'CmdExec',
    @command = N'pwsh -NoProfile -File "C:\EDI\powershell\Send-PurchaseOrder.ps1" -ConfigPath "C:\EDI\config.local.json"';
EXEC dbo.sp_add_schedule
    @schedule_name = N'EDI outbound every hour',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 8,
    @freq_subday_interval = 1,
    @active_start_time = 80000;
EXEC dbo.sp_attach_schedule @job_name = N'EDI - Purchase Order Outbound', @schedule_name = N'EDI outbound every hour';
GO

-- Example inbound job (disabled by default)
EXEC dbo.sp_add_job @job_name = N'EDI - Product Master Inbound', @enabled = 0;
EXEC dbo.sp_add_jobstep
    @job_name = N'EDI - Product Master Inbound',
    @step_name = N'Run PowerShell inbound',
    @subsystem = N'CmdExec',
    @command = N'pwsh -NoProfile -File "C:\EDI\powershell\Receive-ProductMaster.ps1" -ConfigPath "C:\EDI\config.local.json"';
GO

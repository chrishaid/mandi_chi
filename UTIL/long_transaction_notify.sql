/* NOTE: You have to configure/set the following 3 variables */
DECLARE @AlertingThresholdMinutes int = 15;
DECLARE @MailProfileToSendVia sysname = 'DataRobot';
DECLARE @OperatorName sysname = 'DataRescueTeam';

-------------------------------------------------------------
SET NOCOUNT ON;

DECLARE @LongestRunningTransaction int
DECLARE @LongSessions NVARCHAR(100)
DECLARE @LongSessionTime INT;

SELECT @LongestRunningTransaction = MAX(DATEDIFF(n, dtat.transaction_begin_time, GETDATE())) 
FROM sys.dm_tran_active_transactions dtat 
INNER JOIN sys.dm_tran_session_transactions dtst 
  ON dtat.transaction_id = dtst.transaction_id
  
SELECT @LongSessions = dbo.GROUP_CONCAT_D(session_id, ', ')
FROM sys.dm_tran_active_transactions dtat 
INNER JOIN sys.dm_tran_session_transactions dtst 
  ON dtat.transaction_id = dtst.transaction_id
WHERE DATEDIFF(n, dtat.transaction_begin_time, GETDATE()) >= @AlertingThresholdMinutes

SELECT @LongSessionTime = MAX(DATEDIFF(n, dtat.transaction_begin_time, GETDATE()))
FROM sys.dm_tran_active_transactions dtat 
INNER JOIN sys.dm_tran_session_transactions dtst 
  ON dtat.transaction_id = dtst.transaction_id
WHERE DATEDIFF(n, dtat.transaction_begin_time, GETDATE()) >= @AlertingThresholdMinutes;

IF ISNULL(@LongestRunningTransaction,0) >= @AlertingThresholdMinutes BEGIN 

        DECLARE @Warning nvarchar(800);
        DECLARE @Subject nvarchar(100);

        SET @subject = '[Warning] Transaction running longer than 15 minutes on' + @@SERVERNAME;
        SET @Warning = 'SessionID(s): ' + @LongSessions + '
        
The longest job has been running for at least ' + CONVERT(VARCHAR,@LongSessionTime) + ' minutes.
        
Check SSMS Activity Monitor, and KILL these jobs if necessary to avoid reboot!';
        
        EXEC msdb..sp_notify_operator
                @profile_name = @MailProfileToSendVia,
                @name = @OperatorName,
                @subject = @subject, 
                @body = @warning;
        
        PRINT @warning
END
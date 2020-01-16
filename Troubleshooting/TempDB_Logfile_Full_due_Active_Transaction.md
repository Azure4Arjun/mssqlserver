Error: 9002, Severity: 17, State: 4. 
The transaction log for database 'tempdb' is full due to 'ACTIVE_TRANSACTION'

# 1 : log reuse desc

```sql
SELECT log_reuse_wait, log_reuse_wait_desc
FROM master.sys.databases
WHERE name = N'tempdb';
```
# 2 :TempDB transaction details : 
```sql
SELECT DISTINCT s.session_id
       , a.transaction_id
       , a.name
       , c.client_net_address
       , se.login_name
       , se.host_name
       , se.program_name
       , Duration = CASE
                     WHEN DATEDIFF(SECOND,a.transaction_begin_time,GETDATE()) >= 3600  THEN
                           CAST(CAST(DATEDIFF(SECOND,a.transaction_begin_time,GETDATE()) /3600. as Decimal(7,2)) as VARCHAR) + ' Hr'
                     WHEN DATEDIFF(SECOND,a.transaction_begin_time,GETDATE()) >= 60  THEN
                           CAST(CAST(DATEDIFF(SECOND,a.transaction_begin_time,GETDATE()) /60. as Decimal(7,2)) as VARCHAR) + ' Min'
                     ELSE
                           CAST(CAST(DATEDIFF(MILLISECOND,a.transaction_begin_time,GETDATE()) /1000. as Decimal(7,2)) as VARCHAR) + ' Sec'
              END
       , a.transaction_begin_time
       , c.last_read
       , c.last_write
       , Delay_Min = CAST(DATEDIFF(SECOND,CASE WHEN c.last_read > c.last_write THEN c.last_write ELSE c.last_read END,GETDATE()) /60. as Decimal(7,2))
       , transaction_type = CASE a.transaction_type
                     WHEN 1 THEN 'Read/write transaction'
                     WHEN 2 THEN 'Read-only transaction'
                     WHEN 3 THEN 'System transaction'
                     WHEN 4 THEN 'Distributed transaction'
              END
       , transaction_state = CASE a.transaction_state
                     WHEN 0 THEN 'The transaction has not been completely initialized yet.'
                     WHEN 1 THEN 'The transaction has been initialized but has not started.'
                     WHEN 2 THEN 'transaction is active.'
                     WHEN 3 THEN 'The transaction has ended. This is used for read-only transactions.'
                     WHEN 4 THEN 'The commit process has been initiated on the distributed transaction. The distributed transaction is still active but further processing cannot take place.'
                     WHEN 5 THEN 'The transaction is in a prepared state and waiting resolution.'
                     WHEN 6 THEN 'The transaction has been committed.'
                     WHEN 7 THEN 'The transaction is being rolled back.'
                     WHEN 8 THEN 'The transaction has been rolled back.'
              END
       , dtc_state = CASE a.dtc_state WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'PREPARED' WHEN 3 THEN 'COMMITTED' WHEN 4 THEN 'ABORTED' WHEN 5 THEN 'RECOVERED' END
       , [Database ID] = dt.database_id
       , [Database Name] = DB_Name(dt.database_id)
       , dt.database_transaction_begin_time
       , database_transaction_type = CASE dt.database_transaction_type WHEN 1 THEN 'Read/write transaction' WHEN 2 THEN 'Read-only transaction' WHEN 3 THEN 'System transaction' END
       , database_transaction_state = CASE dt.database_transaction_state
                     WHEN 1 THEN 'The transaction has not been initialized.'
                     WHEN 3 THEN 'The transaction has been initialized but has not generated any log records.'
                     WHEN 4 THEN 'The transaction has generated log records.'
                     WHEN 5 THEN 'The transaction has been prepared.'
                     WHEN 10 THEN 'The transaction has been committed.'
                     WHEN 11 THEN 'The transaction has been rolled back.'
                     WHEN 12 THEN 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
              END
       , [Initiator] = CASE s.is_user_transaction WHEN 0 THEN 'System' ELSE 'User' END
       , [Is_Local] = CASE s.is_local WHEN 0 THEN 'No' ELSE 'Yes' END
       , cnn_reads = c.num_reads
       , cnn_writes = c.num_writes
       , dt.database_transaction_log_record_count
       , dt.database_transaction_log_bytes_used
       , dt.database_transaction_log_bytes_reserved
       , dt.database_transaction_log_bytes_used_system
       , dt.database_transaction_log_bytes_reserved_system
       , dt.database_transaction_begin_lsn
       , dt.database_transaction_last_lsn
       , [Transaction_Text] = IsNull((SELECT text FROM sys.dm_exec_sql_text(sp.[sql_handle])),'')
FROM sys.dm_tran_active_transactions a
LEFT JOIN sys.dm_tran_session_transactions s ON a.transaction_id=s.transaction_id
LEFT JOIN sys.[dm_exec_connections] c ON s.session_id  = c.session_id
LEFT JOIN sys.dm_exec_sessions se on c.session_id = se.session_id
LEFT JOIN sys.dm_tran_database_transactions dt
       ON a.transaction_id = dt.transaction_id
LEFT JOIN sys.sysprocesses as sp ON sp.spid = s.session_id
WHERE s.session_id is Not Null
ORDER BY a.transaction_begin_time, s.session_id
OPTION (RECOMPILE);
```
# 3 :TempDB minimal transaction details : 
```sql
SELECT s.session_id, dt.database_transaction_begin_time
FROM sys.dm_tran_session_transactions s
INNER JOIN sys.dm_tran_database_transactions dt
       ON s.transaction_id = dt.transaction_id
WHERE dt.database_id = 2 and database_transaction_log_record_count > 0
OPTION (RECOMPILE);
```
# 4 : Blocking check
```sql
;WITH DS AS (
SELECT c.session_id
       , Blk_Id = r.blocking_session_id
       , r.wait_type
       , r.last_wait_type
       , r.wait_time
       , r.wait_resource
       , [DB_Name] = DB_Name(r.database_id)
       , s.login_name
       , r.command
       , Query_Text = SUBSTRING(t.text
                     , r.statement_start_offset/2 + CASE r.statement_start_offset WHEN 0 THEN 0 ELSE 1 END
                     , ABS(
                           CASE r.statement_end_offset
                                  WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset
                           END - r.statement_start_offset
                     )/2
              )
       , Query_Plan=tqp.query_plan
       , Batch_Plan=qp.query_plan
       , qmg.query_cost
       , total_time_Min = (2 * (CAST(r.total_elapsed_time AS BIGINT) & 0x80000000) + r.total_elapsed_time) / 60000.
       , Memory_Request = qmg.request_time
       , qmg.requested_memory_kb
       , qmg.granted_memory_kb
       , qmg.required_memory_kb
       , qmg.used_memory_kb
       , qmg.max_used_memory_kb
       , r.status
       , r.cpu_time
       , total_elapsed_time = 2 * (CAST(r.total_elapsed_time AS BIGINT) & 0x80000000) + r.total_elapsed_time
       , Memory = r.granted_query_memory
       , cnn_reads = c.num_reads
       , c.last_read
       , cnn_writes = c.num_writes
       , c.last_write
       , Batch_Text = t.text
       , request_reads = r.reads
       , request_writes = r.writes
       , r.logical_reads
       , s.host_name
       , s.program_name
       , c.client_net_address
       FROM sys.[dm_exec_connections] AS c
       CROSS APPLY sys.dm_exec_sql_text(c.[most_recent_sql_handle]) AS t
       INNER JOIN sys.dm_exec_sessions AS s on c.session_id = s.session_id
       LEFT JOIN sys.dm_exec_query_memory_grants qmg on c.session_id = qmg.session_id
       LEFT JOIN sys.dm_exec_requests AS r on c.session_id = r.session_id
       OUTER APPLY sys.dm_exec_query_plan(r.[plan_handle]) AS qp
       OUTER APPLY sys.dm_exec_text_query_plan(r.[plan_handle],r.statement_start_offset,r.statement_end_offset) AS tqp
       WHERE s.is_user_process = 1
)
SELECT s1.* FROM DS as s1 WHERE IsNull(s1.Blk_Id,0) > 0
UNION ALL
SELECT s1.* FROM DS as s1
WHERE EXISTS (SELECT TOP 1 1 FROM DS as s2 WHERE s2.Blk_Id = s1.session_id)
ORDER BY Blk_Id DESC, s1.session_id
OPTION (RECOMPILE);
```

# 5 : Loginfo - Status 2 in use | Status 0 not in use
```sql
DBCC LOGINFO ('Tempdb');
```
[Blog Source ](http://slavasql.blogspot.com/2019/08/tempdb-log-file-full.html)


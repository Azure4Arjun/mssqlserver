DECLARE @s VARCHAR(MAX)

EXEC master.dbo.sp_WhoIsActive @get_outer_command = 1
       ,@get_full_inner_text = 1
       ,@get_transaction_info = 1
       ,@get_locks = 1
       ,@get_task_info = 2
       ,@get_additional_info = 1
       ,@show_sleeping_spids = 1
       ,@find_block_leaders = 1
	   ,@return_schema = 1,
    @schema = @s OUTPUT

SELECT @s;

CREATE TABLE WhoIsActive (
	[dd hh:mm:ss.mss] VARCHAR(8000) NULL
	,[session_id] SMALLINT NOT NULL
	,[sql_text] XML NULL
	,[sql_command] XML NULL
	,[login_name] NVARCHAR(128) NOT NULL
	,[wait_info] NVARCHAR(4000) NULL
	,[tasks] VARCHAR(30) NULL
	,[tran_log_writes] NVARCHAR(4000) NULL
	,[CPU] VARCHAR(30) NULL
	,[tempdb_allocations] VARCHAR(30) NULL
	,[tempdb_current] VARCHAR(30) NULL
	,[blocking_session_id] SMALLINT NULL
	,[blocked_session_count] VARCHAR(30) NULL
	,[reads] VARCHAR(30) NULL
	,[writes] VARCHAR(30) NULL
	,[context_switches] VARCHAR(30) NULL
	,[physical_io] VARCHAR(30) NULL
	,[physical_reads] VARCHAR(30) NULL
	,[locks] XML NULL
	,[used_memory] VARCHAR(30) NULL
	,[status] VARCHAR(30) NOT NULL
	,[tran_start_time] DATETIME NULL
	,[open_tran_count] VARCHAR(30) NULL
	,[percent_complete] VARCHAR(30) NULL
	,[host_name] NVARCHAR(128) NULL
	,[database_name] NVARCHAR(128) NULL
	,[program_name] NVARCHAR(128) NULL
	,[additional_info] XML NULL
	,[start_time] DATETIME NOT NULL
	,[login_time] DATETIME NULL
	,[request_id] INT NULL
	,[collection_time] DATETIME NOT NULL
	)


CREATE CLUSTERED INDEX [IX_collection_time] ON [dbo].[WhoIsActive] ([collection_time] ASC)
	WITH (
			PAD_INDEX = OFF
			,STATISTICS_NORECOMPUTE = OFF
			,SORT_IN_TEMPDB = OFF
			,DROP_EXISTING = OFF
			,ONLINE = OFF
			,ALLOW_ROW_LOCKS = ON
			,ALLOW_PAGE_LOCKS = ON
			,FILLFACTOR = 90
			) ON [PRIMARY]
GO



USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_AM$objectives_mastered#long#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';
 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#AM$objectives_mastered#long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#AM$objectives_mastered#long#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
		SELECT ar.*
		INTO [#AM$objectives_mastered#long#static|refresh]
  FROM AM$objectives_mastered#long ar
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [AM$objectives_mastered#long#static] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE dbo.[AM$objectives_mastered#long#static]');

  --STEP 5: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'AM$objectives_mastered#long#static';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[AM$objectives_mastered#long#static]
 SELECT *
 FROM [#AM$objectives_mastered#long#static|refresh];

 -- Step 4: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'AM$objectives_mastered#long#static';

 EXEC (@sql);
  
END
GO
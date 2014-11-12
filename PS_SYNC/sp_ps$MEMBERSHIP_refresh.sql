USE [PS_mirror]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PS$MEMBERSHIP|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$MEMBERSHIP|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$MEMBERSHIP|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$MEMBERSHIP|refresh]
  FROM OPENQUERY(PS_CHI,'
    SELECT 
	     s.student_number,
		 psmd.* 
    FROM PS_Membership_Defaults psmd
    JOIN students s
       ON psmd.studentid = s.id
     JOIN terms
       ON psmd.schoolid = terms.schoolid
      AND psmd.calendardate >= terms.firstday 
      AND psmd.calendardate <= terms.lastday
      AND psmd.calendardate <= SYSDATE
      AND terms.yearid >= 22
      AND terms.portion = 1
  ');

  --STEP 3: truncate 
  EXEC('TRUNCATE TABLE PS_mirror..membership');

  --STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'MEMBERSHIP';
 EXEC (@sql);

 -- step 5: insert into final destination
 INSERT INTO [dbo].[MEMBERSHIP]
 SELECT *
 FROM [#PS$MEMBERSHIP|refresh];

 -- Step 6: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'MEMBERSHIP';
 EXEC (@sql);
  
END
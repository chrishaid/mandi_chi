USE [NWEA]
GO
/****** Object:  StoredProcedure [dbo].[sp_Load_CPS_CDF]    Script Date: 11/4/2014 2:33:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_Load_CPS_CDF] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

	--I. Assessment Results
	--0. ensure temp table doesn't exist in use
	IF OBJECT_ID(N'tempdb..#cdf_CPS') IS NOT NULL
	BEGIN
		DROP TABLE #cdf_CPS
	END

    --1. bulk load csv and SELECT INTO temp table

			

        SELECT sub.*
        INTO #cdf_CPS
        FROM
            (SELECT *
            FROM OPENROWSET(
						'Microsoft.ACE.OLEDB.12.0', 
						'text;Database=C:\robots\NWEA\data\from_CPS', 
						'SELECT * FROM CPS_CDF.csv'
						)
            ) sub;

        --2. TRUNCATE table 

		EXEC('TRUNCATE TABLE NWEA..CDF_CPS');

		SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'CDF_CPS';

   EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[CDF_CPS]
 SELECT *
 FROM [#cdf_CPS];

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
  AND sys.objects.name = 'CDF_CPS';

 EXEC (@sql);
  
END
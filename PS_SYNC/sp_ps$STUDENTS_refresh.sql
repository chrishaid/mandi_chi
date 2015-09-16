USE [PS_mirror]
GO
/****** Object:  StoredProcedure [dbo].[sp_PS$STUDENTS_refresh]    Script Date: 11/20/2014 10:37:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$STUDENTS_refresh] AS
BEGIN

 SET NOCOUNT ON;

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$STUDENTS|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$STUDENTS|refresh]
		END;
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$STUDENTS|refresh]
  FROM OPENQUERY(PS_CHI,'
    SELECT DCID
          ,ID
          ,LASTFIRST
          ,FIRST_NAME
          ,MIDDLE_NAME
          ,LAST_NAME
          ,STUDENT_NUMBER
          ,ENROLL_STATUS
          ,GRADE_LEVEL
          ,SCHOOLID
          ,GENDER
          ,DOB
          ,LUNCHSTATUS
          ,ETHNICITY
          ,ENTRYDATE
          ,EXITDATE
          ,ENTRYCODE
          ,EXITCODE
          ,FTEID
          ,TEAM
          ,STATE_STUDENTNUMBER
          ,WEB_ID
          ,WEB_PASSWORD
          ,ALLOWWEBACCESS
          ,STUDENT_WEB_ID
          ,STUDENT_WEB_PASSWORD
          ,STUDENT_ALLOWWEBACCESS
          ,STREET
          ,CITY
          ,STATE
          ,ZIP
          ,MOTHER
          ,FATHER
          ,HOME_PHONE
          ,EMERG_CONTACT_1
          ,EMERG_CONTACT_2
          ,EMERG_PHONE_1
          ,EMERG_PHONE_2
		  ,geocode
    FROM STUDENTS
  ');


  --STEP 3.5 Check if STUDENTS exists, if not CRE
  --STEP 4: truncate 

  IF OBJECT_ID(N'PS_mirror..STUDENTS') IS NOT NULL
		BEGIN
			 EXEC('TRUNCATE TABLE PS_mirror..STUDENTS');
	
 

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
	AND sys.objects.name = 'STUDENTS';

	EXEC (@sql);
	END;
 -- step 6: insert into final destination
 INSERT INTO [dbo].[STUDENTS]
 SELECT *
 FROM [#PS$STUDENTS|refresh];

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
  AND sys.objects.name = 'STUDENTS';

 EXEC (@sql);
  
END
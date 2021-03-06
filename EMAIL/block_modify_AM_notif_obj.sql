/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id DESC

--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY id

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('Acc Math Objective Tracking Rise Grade 7'
 ,'auto'
 ,'2013-11-20 06:30:00.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id >= 488

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..email$template_jobs
WHERE id IN (121)
COMMIT TRANSACTION

--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Acc Math Objective Tracking Rise Grade 5'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Acc Math Objective Tracking Rise Grade 6'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Acc Math Objective Tracking Rise Grade 7'
   ,@send_again = @fake OUTPUT

END


*/

BEGIN TRANSACTION

USE KIPP_NJ
GO

DECLARE @helper_school      VARCHAR(5) 
       ,@helper_org_type    VARCHAR(10)
       ,@helper_org_unit    VARCHAR(50)
       ,@job_name_unit      VARCHAR(50)
       ,@email_list         VARCHAR(200)
       ,@this_job_name      NCHAR(100)

       ,@standard_time      NVARCHAR(1000)
       ,@send_again         NVARCHAR(1000)



SET @standard_time = 'CASE
              WHEN DATEPART(WEEKDAY, GETDATE()) = 6
                THEN DATEADD(DAY, 3, 
                DateAdd(mi, 30, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
              ELSE DATEADD(DAY, 1, 
                DateAdd(mi, 30, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
            END'


DECLARE db_cursor CURSOR FOR  
  SELECT school
        ,org_type
        ,org_unit
        ,job_name_unit
        --,'amartin@teamschools.org' AS email_list
        ,email_list
        ,send_again
  FROM
     (SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'5' AS org_unit
            ,'Grade Level' AS job_name_unit
            ,'mjoseph@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'6' AS org_unit
            ,'Grade Level' AS job_name_unit
            ,'tdempsey@teamschools.org;mjoseph@teamschools.org;lepstein@teamschools.org;rthomas@teamschools.org' AS email_list
            ,@standard_time
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'7' AS org_unit
            ,'Grade Level' AS job_name_unit
            ,'kkell@teamschools.org;lepstein@teamschools.org;mjoseph@teamschools.org;JBrooks@teamschools.org' AS email_list
            ,@standard_time
     ) sub

OPEN db_cursor
WHILE 1 = 1
 BEGIN
   FETCH NEXT FROM db_cursor INTO @helper_school, @helper_org_type, @helper_org_unit, @job_name_unit, @email_list, @send_again

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'Acc Math Objective Tracking ' + @helper_school + ' ' + @helper_org_type + ' ' + @helper_org_unit

   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

   MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
   USING 
     (VALUES 
        (  @email_list
          ,'Acc Math Objective Tracking ' + @helper_school + ' ' + @helper_org_type + ' ' + @helper_org_unit
          --figure out SEND AGAIN
          ,@send_again
          ,2
           --stat query 1
          ,'SELECT replace(convert(varchar,convert(Money, am.objectives),1),''.00'','''') AS total_obj         
            FROM KIPP_NJ..AM$objectives_mastered#long#static am
            WHERE am.year = 2013
              AND am.date = CAST(GETDATE() AS date)
              AND am.studentid = -999
              AND am.school = ''' + @helper_school + '''
              AND am.grade_level = ''' + @helper_org_unit + '''
           '
           --stat query 2
          ,'SELECT CAST(CAST(ROUND(am.avg_grade_level, 1) AS FLOAT) AS VARCHAR) AS avg_grade
            FROM KIPP_NJ..AM$objectives_mastered#long#static am
            WHERE am.year = 2013
              AND am.date = CAST(GETDATE() AS date)
              AND am.studentid = -999
              AND am.school = ''' + @helper_school + '''
              AND am.grade_level = ''' + @helper_org_unit + '''
           '
           --stat query 3
          ,' '
            --stat query 4
           ,' '
            --stat labels 1-4
           ,'Total Objectives Mastered'
           ,'Avg Obj Grade Level'
           ,' '
           ,' '
           --image stuff
           ,2
           --dynamic filepath
           ,'\\WINSQL01\r_images\' + @helper_school + '_Gr_' + @helper_org_unit + '_obj_YOY.png'
           ,'\\WINSQL01\r_images\' + @helper_school + '_Gr_' + @helper_org_unit + '_avg_gr_YOY.png'
           --regular text (use single space for nulls)
           ,' '
           ,' '
           ,' '
           ,' '
           ,' '
           --csv stuff
           ,'On'
           --csv query -- all students, no restriction on status
           ,'SELECT TOP 1000000 s.first_name + '' '' + s.last_name AS stu_name
                   ,CAST(am.grade_level AS VARCHAR) AS grade_level
                   ,CAST(am.objectives AS VARCHAR) AS mastered
                   ,CAST(CAST(ROUND(am.avg_grade_level, 1) AS FLOAT) AS VARCHAR) AS avg_grade 
             FROM KIPP_NJ..AM$objectives_mastered#long#static am
             JOIN KIPP_NJ..STUDENTS s
               ON am.studentid = s.id
             WHERE am.year = 2013
               AND am.date = CAST(GETDATE() AS date)
               AND am.school = ''' + @helper_school + '''
               AND am.grade_level = ''' + @helper_org_unit + '''
             ORDER BY s.lastfirst'
           --additional attachments
           ,' '
           --table query 1
           ,'SELECT TOP 1000000 s.first_name + '' '' + s.last_name AS stu_name
                   ,CAST(am.grade_level AS VARCHAR) AS grade_level
                   ,CAST(am.objectives AS VARCHAR) AS mastered
                   ,CAST(CAST(ROUND(am.avg_grade_level, 1) AS FLOAT) AS VARCHAR) AS avg_grade 
             FROM KIPP_NJ..AM$objectives_mastered#long#static am
             JOIN KIPP_NJ..STUDENTS s
               ON am.studentid = s.id
             WHERE am.year = 2013
               AND am.date = CAST(GETDATE() AS date)
               AND am.school = ''' + @helper_school + '''
               AND am.grade_level = ''' + @helper_org_unit + '''
             ORDER BY s.lastfirst'
           --table query 2
           ,' '
             --table query 3
           ,' '
             --table query 4
           ,' '
             --table style parameters
            ,'CSS_small'
            ,' '
            ,' '
            ,' '
        )
     ) AS SOURCE
     (  [email_recipients]
       ,[email_subject]
       ,[send_again]
       ,[stat_count]
       ,[stat_query1]
       ,[stat_query2]
       ,[stat_query3]
       ,[stat_query4]
       ,[stat_label1]
       ,[stat_label2]
       ,[stat_label3]
       ,[stat_label4]
       ,[image_count]
       ,[image_path1]
       ,[image_path2]
       ,[explanatory_text1]
       ,[explanatory_text2]
       ,[explanatory_text3]
       ,[explanatory_text4]
       ,[explanatory_text5]
       ,[csv_toggle]
       ,[csv_query]
       ,[additional_attachment]
       ,[table_query1]
       ,[table_query2]
       ,[table_query3]
       ,[table_query4]
       ,[table_style1]
       ,[table_style2]
       ,[table_style3]
       ,[table_style4]
     )
     ON target.job_name = @this_job_name

   WHEN MATCHED THEN
     UPDATE
       SET target.email_recipients = source.email_recipients
          ,target.email_subject    = source.email_subject
          ,target.send_again =  source.send_again
          ,target.stat_count =  source.stat_count
          ,target.stat_query1 =  source.stat_query1
          ,target.stat_query2 =  source.stat_query2
          ,target.stat_query3 =  source.stat_query3
          ,target.stat_query4 =  source.stat_query4
          ,target.stat_label1 =  source.stat_label1
          ,target.stat_label2 =  source.stat_label2
          ,target.stat_label3 =  source.stat_label3
          ,target.stat_label4 =  source.stat_label4
          ,target.image_count =  source.image_count
          ,target.image_path1 =  source.image_path1
          ,target.image_path2 =  source.image_path2
          ,target.explanatory_text1 =  source.explanatory_text1
          ,target.explanatory_text2 =  source.explanatory_text2
          ,target.explanatory_text3 =  source.explanatory_text3
          ,target.explanatory_text4 =  source.explanatory_text4
          ,target.explanatory_text5 =  source.explanatory_text5
          ,target.csv_toggle =  source.csv_toggle
          ,target.csv_query =  source.csv_query
          ,target.additional_attachment = source.additional_attachment
          ,target.table_query1 =  source.table_query1
          ,target.table_query2 =  source.table_query2
          ,target.table_query3 =  source.table_query3
          ,target.table_query4 =  source.table_query4
          ,target.table_style1 =  source.table_style1
          ,target.table_style2 =  source.table_style2
          ,target.table_style3 =  source.table_style3
          ,target.table_style4 =  source.table_style4
   WHEN NOT MATCHED THEN
      INSERT
      (  [job_name]
        ,[email_recipients]
        ,[email_subject]
        ,[send_again]
        ,[stat_count]
        ,[stat_query1]
        ,[stat_query2]
        ,[stat_query3]
        ,[stat_query4]
        ,[stat_label1]
        ,[stat_label2]
        ,[stat_label3]
        ,[stat_label4]
        ,[image_count]
        ,[image_path1]
        ,[image_path2]
        ,[explanatory_text1]
        ,[explanatory_text2]
        ,[explanatory_text3]
        ,[explanatory_text4]
        ,[explanatory_text5]
        ,[csv_toggle]
        ,[csv_query]
        ,[additional_attachment]
        ,[table_query1]
        ,[table_query2]
        ,[table_query3]
        ,[table_query4]
        ,[table_style1]
        ,[table_style2]
        ,[table_style3]
        ,[table_style4]
      )
      VALUES
      (  @this_job_name
        ,source.email_recipients
        ,source.email_subject
        ,source.send_again
        ,source.stat_count
        ,source.stat_query1
        ,source.stat_query2
        ,source.stat_query3
        ,source.stat_query4
        ,source.stat_label1
        ,source.stat_label2
        ,source.stat_label3
        ,source.stat_label4
        ,source.image_count
        ,source.image_path1
        ,source.image_path2
        ,source.explanatory_text1
        ,source.explanatory_text2
        ,source.explanatory_text3
        ,source.explanatory_text4
        ,source.explanatory_text5
        ,source.csv_toggle
        ,source.csv_query
        ,source.additional_attachment
        ,source.table_query1
        ,source.table_query2
        ,source.table_query3
        ,source.table_query4
        ,source.table_style1
        ,source.table_style2
        ,source.table_style3
        ,source.table_style4
      );
  --end cursor action
  END

CLOSE db_cursor
DEALLOCATE db_cursor

--ROLLBACK TRANSACTION
COMMIT TRANSACTION
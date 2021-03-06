/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id DESC
 
--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY id

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..email$template_jobs
WHERE id IN (117, 118, 119, 120)
COMMIT TRANSACTION

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('Acc Math Intervention Tracking Rise Grade Dempsey_M205_6unh'
 ,'auto'
 ,'2013-11-20 06:31:00.000')
,
 ('Acc Math Intervention Tracking Rise Grade Epstein_M105_54'
 ,'auto'
 ,'2013-11-20 06:31:00.000')
,
 ('Acc Math Intervention Tracking Rise Grade Kell_M301_71kean'
 ,'auto'
 ,'2013-11-20 06:31:00.000')
,
 ('Acc Math Intervention Tracking Rise Grade Kell_M301_71rutgers'
 ,'auto'
 ,'2013-11-20 06:31:00.000')
,
 ('Acc Math Intervention Tracking Rise Grade Kell_M301_71temple'
 ,'auto'
 ,'2013-11-20 06:31:00.000')
,
 ('Acc Math Intervention Tracking Rise Grade Thomas_M205_64'
 ,'auto'
 ,'2013-11-20 06:31:00.000')


--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id >= 488

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..email$template_jobs
WHERE id IN (114,115,116)
COMMIT TRANSACTION

--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Acc Math Intervention Tracking Rise Grade Joseph_M105_5osu'
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



SET @standard_time = 'DATEADD(DAY, 7, 
             DateAdd(mi, 20, DateAdd(hh, 7,
                --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
               (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                --SETS THE MONTH AND DAY PART TO TODAY
                  DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
               ))
             )'


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
            ,'Joseph_M105_5osu' AS org_unit
            ,'Course 1' AS job_name_unit
            ,'mjoseph@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Joseph_M105_5unc' AS org_unit
            ,'Course 2' AS job_name_unit
            ,'mjoseph@teamschools.org' AS email_list
            ,@standard_time
      UNION

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Joseph_M105_5princeton' AS org_unit
            ,'Course 3' AS job_name_unit
            ,'mjoseph@teamschools.org' AS email_list
            ,@standard_time
      UNION

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Epstein_M105_54' AS org_unit
            ,'Course 3' AS job_name_unit
            ,'lepstein@teamschools.org;mjoseph@teamschools.org' AS email_list
            ,@standard_time
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'6' AS org_unit
            ,'Grade Level' AS job_name_unit
            ,'tdempsey@teamschools.org;rthomas@teamschools.org;mjoseph@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
      UNION
      
      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Dempsey_M205_6ncarolina' AS org_unit
            ,'Course 1' AS job_name_unit
            ,'tdempsey@teamschools.org;rthomas@teamschools.org' AS email_list
            ,@standard_time
      UNION

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Dempsey_M205_6tcnj' AS org_unit
            ,'Course 2' AS job_name_unit
            ,'tdempsey@teamschools.org;rthomas@teamschools.org' AS email_list
            ,@standard_time
      UNION   

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Dempsey_M205_6unh' AS org_unit
            ,'Course 3' AS job_name_unit
            ,'tdempsey@teamschools.org;rthomas@teamschools.org' AS email_list
            ,@standard_time
      UNION   

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Thomas_M205_64' AS org_unit
            ,'Course 4' AS job_name_unit
            ,'tdempsey@teamschools.org;rthomas@teamschools.org' AS email_list
            ,@standard_time
      UNION   

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'7' AS org_unit
            ,'Grade Level' AS job_name_unit
            ,'kkell@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
      UNION   

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Kell_M301_71kean' AS org_unit
            ,'Course 1' AS job_name_unit
            ,'kkell@teamschools.org' AS email_list
            ,@standard_time
      UNION   

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Kell_M301_71rutgers' AS org_unit
            ,'Course 2' AS job_name_unit
            ,'kkell@teamschools.org' AS email_list
            ,@standard_time
      UNION   

      SELECT 'Rise' AS school
            ,'Grade' AS org_type
            ,'Kell_M301_71temple' AS org_unit
            ,'Course 3' AS job_name_unit
            ,'kkell@teamschools.org' AS email_list
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

   SET @this_job_name = 'Acc Math Intervention Tracking ' + @helper_school + ' ' + @helper_org_type + ' ' + @helper_org_unit

   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

   MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
   USING 
     (VALUES 
        (  @email_list
          ,'Acc Math Intervention Tracking ' + @helper_school + ' ' + @helper_org_type + ' ' + @helper_org_unit
          --figure out SEND AGAIN
          ,@send_again
          ,2
           --stat query 1
          ,'SELECT CAST(COUNT(*) AS VARCHAR) AS n
            FROM
                  (SELECT s.id AS studentid
                         ,CAST(s.grade_level AS VARCHAR) AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   WHERE s.enroll_status = 0
                     AND s.SCHOOLID = 73252
                   UNION ALL
                   --section
                   SELECT s.id
                         ,t.last_name + ''_'' + cc.course_number + ''_'' + sect.section_number AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   JOIN KIPP_NJ..CC
                     ON s.id = cc.STUDENTID
                    AND cc.termid >= 2300
                    AND cc.dateenrolled <= CAST(GETDATE() AS date)
                    AND cc.dateleft >= CAST(GETDATE() AS date)
                   JOIN KIPP_NJ..SECTIONS sect
                     ON cc.sectionid = sect.id
                   JOIN KIPP_NJ..COURSES c
                     ON cc.course_number = c.course_number
                    AND c.credittype = ''MATH''
                   JOIN KIPP_NJ..TEACHERS t
                     ON sect.teacher = t.id
                   WHERE s.enroll_status = 0
                     AND s.schoolid = 73252
                   ) sub
            JOIN KIPP_NJ..AM$detail#static am
              ON sub.studentid = am.base_studentid
             AND DATEDIFF(day, am.dtintervenedate, CAST(GETDATE() AS date)) <= 7
            WHERE org_unit = ''' + @helper_org_unit + ''' 
           '
           --stat query 2
          ,'SELECT CAST(COUNT(*) AS VARCHAR) AS n
            FROM
                  (SELECT s.id AS studentid
                         ,CAST(s.grade_level AS VARCHAR) AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   WHERE s.enroll_status = 0
                     AND s.SCHOOLID = 73252
                   UNION ALL
                   --section
                   SELECT s.id
                         ,t.last_name + ''_'' + cc.course_number + ''_'' + sect.section_number AS org_unit
                   FROM KIPP_NJ..STUDENTS s
                   JOIN KIPP_NJ..CC
                     ON s.id = cc.STUDENTID
                    AND cc.termid >= 2300
                    AND cc.dateenrolled <= CAST(GETDATE() AS date)
                    AND cc.dateleft >= CAST(GETDATE() AS date)
                   JOIN KIPP_NJ..SECTIONS sect
                     ON cc.sectionid = sect.id
                   JOIN KIPP_NJ..COURSES c
                     ON cc.course_number = c.course_number
                    AND c.credittype = ''MATH''
                   JOIN KIPP_NJ..TEACHERS t
                     ON sect.teacher = t.id
                   WHERE s.enroll_status = 0
                     AND s.schoolid = 73252
                   ) sub
            JOIN KIPP_NJ..AM$detail#static am
              ON sub.studentid = am.base_studentid
             AND DATEDIFF(day, am.dtmastereddate, CAST(GETDATE() AS date)) <= 7
            WHERE org_unit = ''' + @helper_org_unit + ''' 
           '
           --stat query 3
          ,' '
            --stat query 4
           ,' '
            --stat labels 1-4
           ,'Intervention, Past 7 Days'
           ,'Mastered, Past 7 Days'
           ,' '
           ,' '
           --image stuff
           ,1
           --dynamic filepath
           ,'\\WINSQL01\r_images\' + @helper_school + '_Gr_' + @helper_org_unit + '_Intv_Groups.png'
           ,' '
           --regular text (use single space for nulls)
           ,' '
           ,' '
           ,' '
           ,' '
           ,' '
           --csv stuff
           ,'On'
           --csv query -- all students, no restriction on status
           ,'SELECT TOP 10000000 sub.stu_name
                   ,topic_bin
                   ,AM_library_GLEQ
                   ,bin_label
                   ,elements
             FROM
                   (SELECT stu_name
                          ,lastfirst
                          ,school
                          ,CAST(grade AS VARCHAR) AS org_unit
                          ,CAST(topic_bin AS VARCHAR) AS topic_bin
                          ,CAST(CAST(dgradelevel AS FLOAT) AS VARCHAR) AS AM_library_GLEQ
                          ,bin_label
                          ,elements      
                    FROM RutgersReady..[AM$topic_model#recent_intv_objs#format]
                    WHERE school = ''' + @helper_school + '''

                    UNION ALL

                    SELECT stu_name
                          ,intv.lastfirst
                          ,school
                          ,t.last_name + ''_'' + cc.course_number + ''_'' + sect.section_number AS org_unit
                          ,CAST(topic_bin AS VARCHAR) AS topic_bin
                          ,CAST(CAST(dgradelevel AS FLOAT) AS VARCHAR) AS AM_library_GLEQ
                          ,bin_label    
                          ,elements
                    FROM RutgersReady..AM$topic_model#recent_intv_objs#format intv
                    JOIN KIPP_NJ..CC cc
                      ON intv.studentid = cc.studentid
                     AND cc.dateenrolled <= CAST(GETDATE() AS date)
                     AND cc.dateleft >= CAST(GETDATE() AS date)
                    JOIN KIPP_NJ..COURSES c
                      ON cc.course_number = c.course_number
                     AND c.credittype = ''MATH''
                    JOIN KIPP_NJ..SECTIONS sect
                      ON cc.sectionid = sect.id
                    JOIN KIPP_NJ..TEACHERS t
                      ON sect.teacher = t.id
                    WHERE intv.school = ''' + @helper_school + '''
                    ) sub
             WHERE org_unit = ''' + @helper_org_unit + '''
             ORDER BY school
                     ,org_unit
                     ,topic_bin
                     ,AM_library_GLEQ ASC
                     ,lastfirst'
           --additional attachments
           ,'\\WINSQL01\r_images\' + @helper_school + '_Gr_' + @helper_org_unit + '_Intv_Groups.pdf'
           --table query 1
           ,'SELECT TOP 10000000 sub.stu_name
                   ,topic_bin
                   ,AM_library_GLEQ
                   ,bin_label
                   ,elements
             FROM
                   (SELECT stu_name
                          ,lastfirst
                          ,school
                          ,CAST(grade AS VARCHAR) AS org_unit
                          ,CAST(topic_bin AS VARCHAR) AS topic_bin
                          ,CAST(CAST(dgradelevel AS FLOAT) AS VARCHAR) AS AM_library_GLEQ
                          ,bin_label
                          ,elements      
                    FROM RutgersReady..[AM$topic_model#recent_intv_objs#format]
                    WHERE school = ''' + @helper_school + '''

                    UNION ALL

                    SELECT stu_name
                          ,intv.lastfirst
                          ,school
                          ,t.last_name + ''_'' + cc.course_number + ''_'' + sect.section_number AS org_unit
                          ,CAST(topic_bin AS VARCHAR) AS topic_bin
                          ,CAST(CAST(dgradelevel AS FLOAT) AS VARCHAR) AS AM_library_GLEQ
                          ,bin_label    
                          ,elements
                    FROM RutgersReady..AM$topic_model#recent_intv_objs#format intv
                    JOIN KIPP_NJ..CC cc
                      ON intv.studentid = cc.studentid
                     AND cc.dateenrolled <= CAST(GETDATE() AS date)
                     AND cc.dateleft >= CAST(GETDATE() AS date)
                    JOIN KIPP_NJ..COURSES c
                      ON cc.course_number = c.course_number
                     AND c.credittype = ''MATH''
                    JOIN KIPP_NJ..SECTIONS sect
                      ON cc.sectionid = sect.id
                    JOIN KIPP_NJ..TEACHERS t
                      ON sect.teacher = t.id
                    WHERE intv.school = ''' + @helper_school + '''
                    ) sub
             WHERE org_unit = ''' + @helper_org_unit + '''
             ORDER BY school
                     ,org_unit
                     ,topic_bin
                     ,AM_library_GLEQ ASC
                     ,lastfirst'
           --table query 2
           ,' '
             --table query 3
           ,' '
             --table query 4
           ,' '
             --table style parameters
            ,'CSS_small'
            ,'CSS_medium'
            ,'CSS_medium'
            ,'CSS_medium'
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
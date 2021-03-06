/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id

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
 ('AR Progress Monitoring TEAM Gr 8'
 ,'auto'
 ,'2013-10-07 06:40:00.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..EMAIL$template_jobs
WHERE id = 100
ROLLBACK TRANSACTION
--COMMIT TRANSACTION

--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring NCA Katelyn Halpern'
   ,@send_again = @fake OUTPUT

END

*/


USE KIPP_NJ
GO

DECLARE @helper_first       NVARCHAR(50)
       ,@helper_last        NVARCHAR(50)
       ,@helper_school      NVARCHAR(5)
       ,@helper_schoolid    INT
       ,@job_name_text      NVARCHAR(100)
       ,@email_list         VARCHAR(500)
       ,@standard_time      NVARCHAR(1000)
       ,@send_again         NVARCHAR(1000)
       ,@this_job_name      NCHAR(100)
       ,@curterm            NVARCHAR(10)

SET @standard_time = 'CASE
              WHEN DATEPART(WEEKDAY, GETDATE()) = 6
                THEN DATEADD(DAY, 3, 
                DateAdd(mi, 40, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
              ELSE DATEADD(DAY, 1, 
                DateAdd(mi, 40, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
            END'

SELECT @curterm = time_per_name FROM REPORTING$dates WHERE schoolid = 73253 AND identifier = 'RT' AND GETDATE() >= start_date AND GETDATE() <= end_date

DECLARE db_cursor CURSOR FOR  
  SELECT first_name
        ,last_name
        ,schoolid
        ,school
        ,job_name_text
         --override:
        --,'amartin@teamschools.org' AS email_list
        --,'cbini@teamschools.org' AS email_list
        ,email_list
        ,send_again
  FROM
     (SELECT 'Anthony' AS first_name
            ,'Walters' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'awalters@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
     
      SELECT 'Daniel' AS first_name
            ,'Glaubinger' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'dglaubinger@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Jennifer' AS first_name
            ,'James' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'jjames@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Jessica' AS first_name
            ,'Morrison' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'jmorrison@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Katelyn' AS first_name
            ,'Halpern' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'khalpern@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Marisa' AS first_name
            ,'Proto' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'mproto@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Mimi' AS first_name
            ,'Richardson' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'mrichardson@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Samantha' AS first_name
            ,'Love' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'slove@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Tina' AS first_name
            ,'Scorzafava' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'tscorzafava@teamschools.org' AS email_list
            ,@standard_time AS send_again 
      UNION
     
      SELECT 'Kylie' AS first_name
            ,'Taylor' AS last_name
            ,73253 AS schoolid
            ,'NCA' AS school
            ,'' AS job_name_text
            ,'ktaylor@teamschools.org' AS email_list
            ,@standard_time AS send_again 
     ) sub

OPEN db_cursor
WHILE 1=1
  BEGIN

   FETCH NEXT FROM db_cursor INTO @helper_first, @helper_last, @helper_schoolid, @helper_school, @job_name_text, @email_list, @send_again

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'AR Progress Monitoring ' + CAST(@helper_school AS NVARCHAR) + ' ' + @helper_first + ' ' + @helper_last + @job_name_text

   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT
   SET @msg_value = RTRIM(@email_list)
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

   MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
   USING 
     (VALUES 
        ( @email_list
         ,@this_job_name
          --figure out SEND AGAIN
          ,@send_again
       ,4
        --stat query 1
       ,'SELECT CAST(CAST(ROUND(AVG(ar.stu_status_points_numeric + 0.0) * 100,0) AS FLOAT) AS NVARCHAR) + ''%'' AS pct_on_track
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
            AND yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''' + @curterm + '''
        '
        --stat query 2
       ,'SELECT replace(convert(varchar,convert(Money, CAST(ROUND(AVG(ar.points),1) AS FLOAT)),1),''.00'','''') AS avg_points
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
            AND yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''' + @curterm + '''
         '
         --stat query 3
        ,'SELECT CAST(ROUND(AVG(ar.mastery),1) AS FLOAT) AS avg_mastery
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
             AND yearid = 2300
             AND time_hierarchy = 2
             AND time_period_name = ''' + @curterm + '''
         '
         --stat query 4
        ,'SELECT CAST(ROUND(AVG(ar.pct_fiction),1) AS FLOAT) AS avg_mastery
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
          WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
             AND yearid = 2300
             AND time_hierarchy = 2
             AND time_period_name = ''' + @curterm + '''
         '
         --stat labels 1-4
        ,'% On Track'
        ,'Avg points'
        ,'Avg Mastery'
        ,'Avg % Fiction'
        --image stuff
        ,2
        --dynamic filepath
        ,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_points_' + @helper_school + '_tch_' + @helper_first + '_' + @helper_last + '.png'
        ,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_mastery_' + @helper_school + '_tch_' + @helper_first + '_' + @helper_last + '.png'
        --regular text (use single space for nulls)
        --regular text (use single space for nulls)
        ,'This table shows the percent of students on track to meet their points goal (for the quarter/for the year), by week.'
        ,'Students currently ON track to meet their quarterly goal:'
        ,'Students currently OFF track to meet their quarterly goal:'
        ,' '
        ,' '
        --csv stuff
        ,'On'
        --csv query -- all students, no restriction on status
        ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,CAST(s.grade_level AS NVARCHAR) AS ''grade''
                 ,ar.time_period_name AS term
                 ,replace(convert(varchar,convert(Money, ar.points_goal),1),''.00'','''') AS ''points_goal''
                 ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS ''points''        
                 ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_points, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                 ,ar.stu_status_points AS ''status''
                 ,ar.mastery
                 ,ar.avg_lexile
                 ,ar.pct_fiction
                 ,ar.n_passed AS passed
                 ,ar.n_total AS total
                 ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
           WHERE ar.yearid = 2300
             AND ar.time_hierarchy = 2
             AND ar.time_period_name = ''' + @curterm + '''
           ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
          '
        --table query 1
        ,'SELECT TOP 1000000000
                 [grade_level]
                ,[eng_enr]
                ,[time_period_name]
                ,SUBSTRING(students, 1, 15) AS students
                ,N
                ,[8/5]
                ,[8/12]
                ,[8/19]
                ,[8/26]
                ,[9/2]
                ,[9/9]
                ,[9/16]
                ,[9/23]
                ,[9/30]
                ,[10/7]
                ,[10/14]
                ,[10/21]
                ,[10/28]
                ,[11/4]
                ,[11/11]
                ,[11/18]
                ,[11/25]
                ,[12/2]
                ,[12/9]
                ,[12/16]
                ,[12/23]
                ,[12/29]
              FROM KIPP_NJ..[AR$on_track#wide]
              WHERE grade_level = ''' + @helper_first + ' ' + @helper_last + '''
                AND school = ''' + CAST(@helper_school AS NVARCHAR) + '''
                AND time_period_name IN (''Year'', ''Reporting Term 3'')
                AND row_type = ''POINTS''
              ORDER BY time_period_name
                      ,eng_enr
          '
          --table query 2
         ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,CAST(s.grade_level AS NVARCHAR) AS grade
                 ,ar.time_period_name AS term
                 ,replace(convert(varchar,convert(Money, ar.points_goal),1),''.00'','''') AS points_goal
                 ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS points          
                 ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_points, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                 ,ar.stu_status_points AS ''Stu Status''
                 ,ar.mastery
                 ,ar.avg_lexile AS ''Avg Lexile''
                 ,ar.pct_fiction AS ''Pct Fiction''
                 ,ar.n_passed AS passed
                 ,ar.n_total AS total
                 ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
           WHERE ar.yearid = 2300
             AND ar.time_hierarchy = 2
             AND ar.time_period_name = ''' + @curterm + '''
             AND ar.stu_status_points_numeric = 1
           ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
          '
          --table query 3
         ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,CAST(s.grade_level AS NVARCHAR) AS grade
                 ,ar.time_period_name AS term
                 ,replace(convert(varchar,convert(Money, ar.points_goal),1),''.00'','''') AS points_goal
                 ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS points          
                 ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_points, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                 ,ar.stu_status_points AS ''Stu Status''
                 ,ar.mastery
                 ,ar.avg_lexile AS ''Avg Lexile''
                 ,ar.pct_fiction AS ''Pct Fiction''
                 ,ar.n_passed AS passed
                 ,ar.n_total AS total
                 ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..CC
             ON ar.studentid = cc.studentid
           JOIN KIPP_NJ..SECTIONS
             ON cc.sectionid = sections.id
            AND cc.termid >= 2300
           JOIN KIPP_NJ..COURSES
             ON sections.course_number = courses.course_number
            AND courses.credittype LIKE ''%ENG%''
           JOIN KIPP_NJ..TEACHERS
             ON sections.teacher = teachers.id
            AND teachers.first_name = ''' + @helper_first + '''
            AND teachers.last_name  = ''' + @helper_last + '''
           WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
             AND ar.yearid = 2300
             AND ar.time_hierarchy = 2
             AND ar.time_period_name = ''' + @curterm + '''
             AND ar.stu_status_points_numeric = 0
           ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
          '
          --table query 4
         ,' '
          --table style parameters
         ,'CSS_small'
         ,'CSS_small'
         ,'CSS_small'
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
        ,source.table_query1
        ,source.table_query2
        ,source.table_query3
        ,source.table_query4
        ,source.table_style1
        ,source.table_style2
        ,source.table_style3
        ,source.table_style4
      );

  END

CLOSE db_cursor
DEALLOCATE db_cursor


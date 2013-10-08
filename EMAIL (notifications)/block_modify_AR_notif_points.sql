/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id

--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs

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


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring NCA Katelyn Halpern'
   ,@send_again = @fake OUTPUT

END


Anthony Walters
Daniel Glaubinger
Jennifer James
Jessica Morrison
Katelyn Halpern
Kylie Taylor
Marisa Proto
Mimi Richardson
Samantha Love
Tina Scorzafava

*/

USE KIPP_NJ
GO

DECLARE @helper_first       NVARCHAR(50) = 'Tina'
       ,@helper_last        NVARCHAR(50) = 'Scorzafava'
       ,@helper_schoolid    INT = 73253
       ,@helper_school      NVARCHAR(5) = 'NCA'
       ,@this_job_name      NCHAR(100) = 'AR Progress Monitoring NCA Tina Scorzafava'
       
BEGIN

MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     ( 'tscorzafava@teamschools.org'
       ,'AR Progress Monitoring: ' + @helper_first + ' ' + @helper_last + ', ' + @helper_school
       --figure out SEND AGAIN
       ,'CASE
           --if today is friday
           WHEN DATEPART(WEEKDAY, GETDATE()) = 6
             --add 3 days
             THEN DATEADD(DAY, 3, 
             --tldr - 6:40 TODAY
             DateAdd(mi, 40, DateAdd(hh, 6,
                --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
               (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                --SETS THE MONTH AND DAY PART TO TODAY
                  DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
               ))
             )
             --otherwise just add 2
           ELSE DATEADD(DAY, 2, 
             DateAdd(mi, 40, DateAdd(hh, 6,
                --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
               (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                --SETS THE MONTH AND DAY PART TO TODAY
                  DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
               ))
             )
         END'
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
            AND time_period_name = ''RT1''
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
            AND time_period_name = ''RT1''
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
             AND time_period_name = ''RT1''
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
             AND time_period_name = ''RT1''
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
             AND ar.time_period_name = ''RT1''
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
                AND time_period_name IN (''Year'', ''Reporting Term 1'')
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
             AND ar.time_period_name = ''RT1''
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
             AND ar.time_period_name = ''RT1''
             AND ar.stu_status_points_numeric = 0
           ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
          '
          --table style parameters
         ,'CSS_small'
         ,'CSS_small'
         ,'CSS_small'
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
    ,[csv_toggle]
    ,[csv_query]
    ,[table_query1]
    ,[table_query2]
    ,[table_query3]
    ,[table_style1]
    ,[table_style2]
    ,[table_style3]
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
       ,target.csv_toggle =  source.csv_toggle
       ,target.csv_query =  source.csv_query
       ,target.table_query1 =  source.table_query1
       ,target.table_query2 =  source.table_query2
       ,target.table_query3 =  source.table_query3
       ,target.table_style1 =  source.table_style1
       ,target.table_style2 =  source.table_style2
       ,target.table_style3 =  source.table_style3
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
     ,[csv_toggle]
     ,[csv_query]
     ,[table_query1]
     ,[table_query2]
     ,[table_query3]
     ,[table_style1]
     ,[table_style2]
     ,[table_style3]
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
     ,source.csv_toggle
     ,source.csv_query
     ,source.table_query1
     ,source.table_query2
     ,source.table_query3
     ,source.table_style1
     ,source.table_style2
     ,source.table_style3
   );
END
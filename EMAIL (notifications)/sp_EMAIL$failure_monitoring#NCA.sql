USE KIPP_NJ
GO

ALTER PROCEDURE sp_EMAIL$failure_monitoring#NCA
AS

BEGIN

DECLARE
 --global, entire email
  @email_body										NVARCHAR(MAX)

 --key stats
 ,@pct_enr_failing					NUMERIC(3,0)
 ,@pct_stu_failing					NUMERIC(3,0)
 ,@pct_stu_failing_2			NUMERIC(3,0)
 
 ,@pct_enr_failing_prev					NUMERIC(3,0)
 ,@pct_enr_failing_delta				NUMERIC(3,0)
 ,@enr_delta_sign											NVARCHAR(1) = ''
 
 ,@pct_stu_failing_prev					NUMERIC(3,0)
 ,@pct_stu_failing_delta				NUMERIC(3,0)
 ,@stu_failing_delta_sign			NVARCHAR(1) = ''

 ,@pct_stu_failing_2_prev					NUMERIC(3,0)
 ,@pct_stu_failing_2_delta				NUMERIC(3,0)
 ,@stu_failing_2_delta_sign			NVARCHAR(1) = ''
 
 ,@days_ago												INT
 ,@old_date												DATE
 
  --used by the stats detail
 ,@sql_stats										 NVARCHAR(MAX)
 ,@html_stats									 NVARCHAR(MAX)
 
 --0. ensure temp table not in use
 IF OBJECT_ID(N'tempdb..#failing_stats') IS NOT NULL
 BEGIN
     DROP TABLE #failing_stats
 END
 
 --0. set days back
 SET @days_ago = 30
 
 SET @old_date = CONVERT(date, getdate() - @days_ago)
 
 --1. pct class enrollments failing
   SET @pct_enr_failing =
    (SELECT * FROM 
     OPENQUERY(KIPP_NWK,
       'SELECT ROUND(AVG(off_track_flag) * 100,1) AS off_t_pct
        FROM
           (SELECT grades.date_value
                  ,CASE
                     WHEN synthetic_percent < 70 THEN 1
                     WHEN synthetic_percent >= 70 THEN 0
                   END AS off_track_flag
            FROM grades$time_series_detail grades
            JOIN students
              ON grades.studentid = students.ID
             AND students.schoolid = 73253
            JOIN courses
              ON grades.course_number = courses.course_number
             AND courses.credittype != ''STUDY''
             AND courses.credittype != ''ART''
            WHERE grades.rt_name = ''Y1''
              AND grades.synthetic_percent IS NOT NULL
              AND grades.date_value = 
                 (SELECT MAX(date_value)
                  FROM grades$time_series_detail)
            ) sub'
     )
   )
  
  --30 days ago
   SET @pct_enr_failing_prev =
    (SELECT * FROM 
     OPENQUERY(KIPP_NWK,
       'SELECT ROUND(AVG(off_track_flag) * 100,1) AS off_t_pct
        FROM
           (SELECT grades.date_value
                  ,CASE
                     WHEN synthetic_percent < 70 THEN 1
                     WHEN synthetic_percent >= 70 THEN 0
                   END AS off_track_flag
            FROM grades$time_series_detail grades
            JOIN students
              ON grades.studentid = students.ID
             AND students.schoolid = 73253
            JOIN courses
              ON grades.course_number = courses.course_number
             AND courses.credittype != ''STUDY''
             AND courses.credittype != ''ART''
            WHERE grades.rt_name = ''Y1''
              AND grades.synthetic_percent IS NOT NULL
              AND grades.date_value = 
                 TRUNC(SYSDATE) - 30
            ) sub'
     )
   )

   --change
   SET @pct_enr_failing_delta = @pct_enr_failing - @pct_enr_failing_prev
   --format sign
   IF @pct_enr_failing_delta >= 0
     BEGIN
         SET @enr_delta_sign = '+'
     END
   
   
   --2. by student: dump stats into temp table
   SELECT sub.*
   INTO #failing_stats
   FROM 
     (SELECT * FROM 
       OPENQUERY(KIPP_NWK,
         'SELECT DECODE(GROUPING(grade_level),0,TO_CHAR(grade_level),''School'') grade_level
                ,DATE_VALUE
                ,ROUND(AVG(ot_1_indicator) * 100, 0) AS pct_failing_1_or_more
                ,ROUND(AVG(ot_2_indicator) * 100, 0) AS pct_failing_2_or_more
                ,ROUND(AVG(ot_3_indicator) * 100, 0) AS pct_failing_3_or_more
                ,ROUND(AVG(ot_4_indicator) * 100, 0) AS pct_failing_4_or_more
          FROM
               (SELECT s.first_name || '' ''|| s.last_name AS stu_name
                      ,s.grade_level
                      ,gr.*
                      ,CASE
                         WHEN num_off >= 1 THEN 1
                         WHEN num_off < 1 THEN 0
                       END AS ot_1_indicator
                      ,CASE
                         WHEN num_off >= 2 THEN 1
                         WHEN num_off < 2 THEN 0
                       END AS ot_2_indicator
                      ,CASE
                         WHEN num_off >= 3 THEN 1
                         WHEN num_off < 3 THEN 0
                       END AS ot_3_indicator
                      ,CASE
                         WHEN num_off >= 4 THEN 1
                         WHEN num_off < 4 THEN 0
                       END AS ot_4_indicator
                FROM grades$time_series#counts gr
                JOIN students s
                  ON gr.studentid = s.ID
                 AND s.schoolid = 73253
                WHERE gr.date_value = 
                  (SELECT MAX(date_value)
                    FROM grades$time_series#counts)
                  OR gr.date_value = TRUNC(SYSDATE) - 30
                )
          GROUP BY DATE_VALUE
                  ,CUBE(grade_level)
          ORDER BY decode(grade_level
                     ,''School'' ,0
                     ,''9''  ,1
                     ,''10'' ,2
                     ,''11'' ,3
                     ,''12'', 4
                   ) ASC'
       )
     ) sub	
        
   --3. whole school
   SET @pct_stu_failing =
     (SELECT PCT_FAILING_1_OR_MORE
      FROM #failing_stats
      WHERE GRADE_LEVEL = 'School'
      AND DATE_VALUE > @old_date
     )
   
   SET @pct_stu_failing_prev =
     (SELECT PCT_FAILING_1_OR_MORE
      FROM #failing_stats
      WHERE GRADE_LEVEL = 'School'
      AND DATE_VALUE = @old_date
     )
   
   SET @pct_stu_failing_2 =
     (SELECT PCT_FAILING_2_OR_MORE
      FROM #failing_stats
      WHERE GRADE_LEVEL = 'School'
      AND DATE_VALUE > @old_date
     )
     
   SET @pct_stu_failing_2_prev =
     (SELECT PCT_FAILING_2_OR_MORE
      FROM #failing_stats
      WHERE GRADE_LEVEL = 'School'
      AND DATE_VALUE = @old_date
     )
   
   --change
   SET @pct_stu_failing_delta = @pct_stu_failing - @pct_stu_failing_prev    
   SET @pct_stu_failing_2_delta = @pct_stu_failing_2 - @pct_stu_failing_2_prev
   
   --format sign
   IF @pct_stu_failing_delta  >= 0
     BEGIN
         SET @stu_failing_delta_sign = '+'
     END
 
   IF @pct_stu_failing_2_delta  >= 0
     BEGIN
         SET @stu_failing_2_delta_sign = '+'
     END

   
   --4. roster to HTML
   SET @sql_stats = 
     'SELECT GRADE_LEVEL AS "Grade Level"
            ,PCT_FAILING_1_OR_MORE AS "% Failing 1+"
            ,PCT_FAILING_2_OR_MORE AS "% Failing 2+"
            ,PCT_FAILING_3_OR_MORE AS "% Failing 3+"
            ,PCT_FAILING_4_OR_MORE AS "% Failing 4+"
      FROM #failing_stats
      WHERE DATE_VALUE > CONVERT(date, getdate() - 2)'
      --WHERE DATE_VALUE > ''' + CAST(@old_date AS VARCHAR) + ''''
   
   PRINT @sql_stats
   
   --5. pass to sp_TableToHTML to get query results back as HTML table
   --EXEC [DEVSQL] .AdventureWorks.dbo.uspGetEmployeeManagers ’42′
   EXECUTE AlumniMirror.dbo.sp_TableToHTML @sql_stats, @html_stats OUTPUT
   
   
   
   -- . build the email body		
   SET @email_body = 
   '<html>
   <head>
     <style type="text/css">
      .small_text {
       font-size: 12px;
       font-family: "Helvetica", Verdana, sans-serif;
       margin: 0;
       padding: 0;
     }
      .med_text {
       font-size: 18px;
       font-family: "Helvetica", Verdana, sans-serif;
       margin: 0;
       padding: 0;
     }
     .pretty_big_text {
       font-size: 24px;
       font-family: "Helvetica", Verdana, sans-serif;
       font-weight: bold;
       text-align: center;
       margin: 0;
       padding: 0;
     }
     .big_text {
       font-size: 36px;
       font-family: "Helvetica", Verdana, sans-serif;
       font-weight: bold;
       text-align: center;
       margin: 0;
       padding: 0;
     }
     .big_number {
       font-size: 64pt;
       font-family: "Helvetica", Verdana, sans-serif;
       font-weight: bold;
       text-align: center;
       margin: 0;
       padding: 0;
     }
     </style>
   </head>

   <body> 
     
     <!--Key Stats table-->
     <table width= "100%"  cellspacing="0" cellpadding="0">
        
        <!-- BY ENROLLMENT -->
        <tr>
          <th width="50%">
            <div class="pretty_big_text">% All Academic Course Enrollments Currently Below 70</div>
          </th>
          
          <th width="50%">
            <div class="pretty_big_text">Change from ' + CAST(@days_ago AS VARCHAR) + ' days ago</div>
          </th>
          </tr>
        
        <tr>
          <td>
            <div class="big_number">' + CAST(@pct_enr_failing AS VARCHAR) + '%</div>
          </td>
          
          <td>
            <div class="big_number">' + 	
            @enr_delta_sign + 
            CAST(@pct_enr_failing_delta AS VARCHAR) + '%</div>
          </td>
        </tr>
        
        <tr>
        </tr>
        
        <!-- BY STUDENT -->
        <tr>
          <th width="50%">
            <div class="pretty_big_text">% Students Failing 1+ Academic Courses</div>
          </th>
          
          <th width="50%">
            <div class="pretty_big_text">Change from ' + CAST(@days_ago AS VARCHAR) + ' days ago</div>
          </th>
          </tr>
        
        <tr>
          <td>
            <div class="big_number">' + CAST(@pct_stu_failing AS VARCHAR) + '%</div>
          </td>
          
          <td> 
            <div class="big_number">' + 	
            @stu_failing_delta_sign + 
            CAST(@pct_stu_failing_delta AS VARCHAR) + '%</div>
          </td>
        </tr>
        
        <tr>
          <th width="50%">
            <div class="pretty_big_text">% Students Failing 2+ Academic Courses</div>
          </th>
          
          <th width="50%">
            <div class="pretty_big_text">Change from ' + CAST(@days_ago AS VARCHAR) + ' days ago</div>
          </th>
          </tr>
        
        <tr>
          <td>
            <div class="big_number">' + CAST(@pct_stu_failing_2 AS VARCHAR) + '%</div>
          </td>
          
          <td> 
            <div class="big_number">' + 	
            @stu_failing_2_delta_sign + 
            CAST(@pct_stu_failing_2_delta AS VARCHAR) + '%</div>
          </td>
        </tr>
                
     </table>
     
     <br>
     <br>
     
     <!--Scatter Chart-->
     <table width= "100%"  cellspacing="0" cellpadding="0">
       <tr>
         <td width="100%">
           <span class = "pretty_big_text">
             <center>
               NCA: Enrollment Failure Analysis
              </center>
           </span>
         </td>
       </tr>
       
       <tr>
         <td>
           <span class="small_text">
             <center>
               (Contains student data - must be on TEAM Network to view)
             </center>
           </span>
         </td>
       </tr>
       
       <tr>
         <td>
           <center>
             <img src="\\WINSQL01\r_images\failure_credittype.png" width="1330">
           </center>
         </td>
       </tr>
     </table>
     
     <br>
     <br>
     <center>
     ' + @html_stats +
     '
     </center
   </body>
   </html>
   '

   --.5 ship it!
   EXEC [msdb].[dbo].sp_send_dbmail @profile_name = 'DataRobot'
           ,@body = @email_body
           ,@body_format ='HTML'
           ,@recipients = 'amartin@teamschools.org;ldesimon@teamschools.org;nmadigan@teamschools.org;vmarigna@teamschools.org;kswearingen@teamschools.org'
           --,@recipients = 'amartin@teamschools.org'
           ,@subject = 'NCA: Credit Completion Progress Monitoring'

   
   PRINT @pct_enr_failing
   PRINT @pct_stu_failing
   PRINT @days_ago
   PRINT @old_date
   PRINT @pct_enr_failing_prev
   PRINT @email_body
END
--DEPRECATED, USE STATIC TABLE [ES_DAILY$daily_tracking_long]

/*
USE KIPP_NJ
GO

ALTER VIEW ES_DAILY$daily_tracking_long AS
SELECT ROW_NUMBER() OVER(
          PARTITION BY schoolid 
              ORDER BY att_date) AS rn
		    ,schoolid
		    ,REPLACE(CONVERT(NVARCHAR,att_date, 6),' ','-') AS att_date
		    ,studentid
		    ,student_number
		    ,lastfirst
		    ,grade_level
		    ,team
		    ,hw
		    ,color_day
		    ,thrive_am
		    ,thrive_mid
		    ,thrive_pm
		    ,CAST(student_number AS VARCHAR(20)) + '_' + CAST(REPLACE(CONVERT(NVARCHAR,att_date,6),' ','-') AS VARCHAR(20)) AS hash
FROM	(SELECT s.schoolid			         
			         ,scores.att_date
			         ,s.id AS studentid
			         ,s.student_number
			         ,s.lastfirst
			         ,s.grade_level
			         ,s.team								
			         ,scores.hw
			         ,CASE WHEN scores.schoolid = 73255 THEN NULL ELSE scores.color END AS color_day
			         ,CASE WHEN scores.schoolid = 73255 THEN scores.color     END AS thrive_am
			         ,CASE WHEN scores.schoolid = 73255 THEN scores.color_mid END AS thrive_mid
			         ,CASE WHEN scores.schoolid = 73255 THEN scores.color_pm  END AS thrive_pm
		    FROM OPENQUERY(PS_TEAM,'
             SELECT schoolid
                   ,user_defined_date AS att_date
                   ,foreignkey AS studentid
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field1'') hw
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field2'') color
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field3'') color_mid
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field4'') color_pm
                   /*
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field5'') field5
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field6
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field7
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field8
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field9
                   ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field10
                   */
             FROM virtualtablesdata2
             WHERE related_to_table = ''dailytracking''					            
             ') scores
		    JOIN STUDENTS s
		      ON s.id = scores.studentid
		    WHERE s.enroll_status = 0
		      AND s.grade_level < 5		    
	    ) sub_1
*/
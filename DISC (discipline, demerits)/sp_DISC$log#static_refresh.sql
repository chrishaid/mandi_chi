USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_DISC$log#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#DISC$log#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#DISC$log#static|refresh]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#DISC$log#static|refresh]
  FROM (SELECT oq.schoolid
              ,CAST(studentid AS INT) AS studentid
              ,entry_author
              ,entry_date
              ,logtypeid
              ,subject
              ,CASE
                --ES/MS codes
                WHEN subtype = '1'  AND logtypeid = -100000 THEN 'Detention'
                WHEN subtype = '01' AND logtypeid = -100000 THEN 'Detention'
                WHEN subtype = '2'  AND logtypeid = -100000 THEN 'Silent Lunch'
                WHEN subtype = '02' AND logtypeid = -100000 THEN 'Silent Lunch'
                WHEN subtype = '3'  AND logtypeid = -100000 THEN 'Choices'
                WHEN subtype = '03' AND logtypeid = -100000 THEN 'Choices'
                WHEN subtype = '4'  AND logtypeid = -100000 THEN 'Bench'
                WHEN subtype = '04' AND logtypeid = -100000 THEN 'Bench'
                WHEN subtype = '5'  AND logtypeid = -100000 THEN 'ISS'
                WHEN subtype = '05' AND logtypeid = -100000 THEN 'ISS'
                WHEN subtype = '6'  AND logtypeid = -100000 THEN 'OSS'
                WHEN subtype = '06' AND logtypeid = -100000 THEN 'OSS'
                WHEN subtype = '7'  AND logtypeid = -100000 THEN 'Bus Warning'
                WHEN subtype = '07' AND logtypeid = -100000 THEN 'Bus Warning'
                WHEN subtype = '8'  AND logtypeid = -100000 THEN 'Bus Suspension'
                WHEN subtype = '08' AND logtypeid = -100000 THEN 'Bus Suspension'
                WHEN subtype = '9'  AND logtypeid = -100000 THEN 'Class Removal'
                WHEN subtype = '09' AND logtypeid = -100000 THEN 'Class Removal'
                WHEN subtype = '10' AND logtypeid = -100000 THEN 'Bullying'
                --NCA merits
                WHEN subtype = '01' AND logtypeid = 3023 THEN 'No Demerits'
                WHEN subtype = '1'  AND logtypeid = 3023 THEN 'No Demerits'
                WHEN subtype = '02' AND logtypeid = 3023 THEN 'Panther Pride'
                WHEN subtype = '2'  AND logtypeid = 3023 THEN 'Panther Pride'
                WHEN subtype = '3'  AND logtypeid = 3023 THEN 'Work Crew'
                WHEN subtype = '03' AND logtypeid = 3023 THEN 'Work Crew'
                WHEN subtype = '4'  AND logtypeid = 3023 THEN 'Courage'
                WHEN subtype = '04' AND logtypeid = 3023 THEN 'Courage'
                WHEN subtype = '5'  AND logtypeid = 3023 THEN 'Excellence'
                WHEN subtype = '05' AND logtypeid = 3023 THEN 'Excellence'
                WHEN subtype = '6'  AND logtypeid = 3023 THEN 'Humanity'
                WHEN subtype = '06' AND logtypeid = 3023 THEN 'Humanity'
                WHEN subtype = '7'  AND logtypeid = 3023 THEN 'Leadership'
                WHEN subtype = '07' AND logtypeid = 3023 THEN 'Leadership'
                WHEN subtype = '8'  AND logtypeid = 3023 THEN 'Parent'
                WHEN subtype = '08' AND logtypeid = 3023 THEN 'Parent'
                WHEN subtype = '9'  AND logtypeid = 3023 THEN 'Other'
                WHEN subtype = '09' AND logtypeid = 3023 THEN 'Other'
                --NCA demerits
                WHEN subtype = '01' AND logtypeid = 3223 THEN 'Off Task'
                WHEN subtype = '02' AND logtypeid = 3223 THEN 'Gum'
                WHEN subtype = '03' AND logtypeid = 3223 THEN 'Eating/Drinking'
                WHEN subtype = '04' AND logtypeid = 3223 THEN 'Play Fight'
                WHEN subtype = '05' AND logtypeid = 3223 THEN 'Excessive Volume'
                WHEN subtype = '06' AND logtypeid = 3223 THEN 'Language'
                WHEN subtype = '07' AND logtypeid = 3223 THEN 'No Pass'
                WHEN subtype = '08' AND logtypeid = 3223 THEN 'Uniform'
                WHEN subtype = '09' AND logtypeid = 3223 THEN '> 4 Min Late'
                WHEN subtype = '10' AND logtypeid = 3223 THEN 'Other'
                --WHEN subtype = '11' AND logtypeid = 3223 THEN 'T2 Other'
                --WHEN subtype = '12' AND logtypeid = 3223 THEN 'Tier 3'
                ELSE NULL
               END AS subtype

              --Demerit tiers
              ,CASE
                WHEN subtype = '01' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '02' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '03' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '04' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '05' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '06' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '07' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '08' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '09' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '10' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '11' AND logtypeid = 3223 THEN 'Tier 1'
                WHEN subtype = '12' AND logtypeid = 3223 THEN 'Tier 1'
                ELSE NULL
               END AS tier

              --convert all of the incidenttype codes into long form. this is admittedly dumb,
              --but PS doesn't seem to store these in any way that you could just JOIN this turkey.
              ,CASE
                WHEN discipline_incidenttype = 'CE' THEN 'Cell Phone/Electronics'
                WHEN discipline_incidenttype = 'C' THEN 'Cheating'
                WHEN discipline_incidenttype = 'CU' THEN 'Cut Detention, Help Hour, Work Crew'
                WHEN discipline_incidenttype = 'SP' THEN 'Defacing School Property'
                WHEN discipline_incidenttype = 'DM' THEN 'Demerits (NCA)'
                WHEN discipline_incidenttype = 'D' THEN 'Dress Code'
                WHEN discipline_incidenttype = 'DT' THEN 'Disrespect (to Teacher)'
                WHEN discipline_incidenttype = 'DS' THEN 'Disrespect (to Student)'
                WHEN discipline_incidenttype = 'L' THEN 'Dishonesty/Forgery'
                WHEN discipline_incidenttype = 'DIS' THEN 'Disruptive/Misbehavior IN Class'
                WHEN discipline_incidenttype = 'DOC' THEN 'Misbehavior off School Campus'
                WHEN discipline_incidenttype = 'FI' THEN 'Fighting'
                WHEN discipline_incidenttype = 'PF' THEN 'Play Fighting/Inappropriate Touching'
                WHEN discipline_incidenttype = 'GO' THEN 'Going Somewhere w/o Permission'
                WHEN discipline_incidenttype = 'G' THEN 'Gum Chewing/CANDy/Food'
                WHEN discipline_incidenttype = 'HR' THEN 'Harassment/Bullying'
                WHEN discipline_incidenttype = 'H' THEN 'Homework'
                WHEN discipline_incidenttype = 'M' THEN 'Missing notices'
                WHEN discipline_incidenttype = 'PA' THEN 'Missing Major Assign. (NCA)'
                WHEN discipline_incidenttype = 'NFI' THEN 'Not Following Instructions'
                WHEN discipline_incidenttype = 'P' THEN 'Profanity'
                WHEN discipline_incidenttype = 'TB' THEN 'Talking to Benchster (TEAM/RISE)'
                WHEN discipline_incidenttype = 'T' THEN 'Tardy to School'
                WHEN discipline_incidenttype = 'TC' THEN 'Tardy to Class'
                WHEN discipline_incidenttype = 'S' THEN 'Theft/Stealing'
                WHEN discipline_incidenttype = 'UA' THEN 'Unexcused Absence'
                WHEN discipline_incidenttype = 'EU' THEN 'Unprepared or Off-Task IN Det.'
                WHEN discipline_incidenttype = 'O' THEN 'Other'
                WHEN discipline_incidenttype = 'RCHT' THEN 'Rise-Cheating'
                WHEN discipline_incidenttype = 'RHON' THEN 'Rise-Dishonesty'
                WHEN discipline_incidenttype = 'RRSP' THEN 'Rise-Disrespect'
                WHEN discipline_incidenttype = 'RFHT' THEN 'Rise-Fighting'
                WHEN discipline_incidenttype = 'RNFD' THEN 'Rise-NFD'
                WHEN discipline_incidenttype = 'RLOG' THEN 'Rise-Logistical'
                WHEN discipline_incidenttype = 'ROTH' THEN 'Rise-Other'
                WHEN discipline_incidenttype = 'SEC' THEN 'SPARK-Excessive Crying'
                WHEN discipline_incidenttype = 'STB' THEN 'SPARK-Talking Back'
                WHEN discipline_incidenttype = 'SNC' THEN 'SPARK-Name Calling'
                WHEN discipline_incidenttype = 'SH' THEN 'SPARK-Hitting'
                WHEN discipline_incidenttype = 'ST' THEN 'SPARK-Tantrum'
                WHEN discipline_incidenttype = 'STO' THEN 'SPARK-Wont Go To Time Out'
                WHEN discipline_incidenttype = 'SDW' THEN 'SPARK-Refusal To Do Work'
                WHEN discipline_incidenttype = 'BED' THEN 'BUS: Eating/Drinking'
                WHEN discipline_incidenttype = 'BPR' THEN 'BUS: Profanity'
                WHEN discipline_incidenttype = 'BOL' THEN 'BUS: Out of Line'
                WHEN discipline_incidenttype = 'BMS' THEN 'BUS: Moving Seats/StANDing'
                WHEN discipline_incidenttype = 'BTK' THEN 'BUS: Talking IN the morning'
                WHEN discipline_incidenttype = 'BND' THEN 'BUS: Not Following Directions'
                WHEN discipline_incidenttype = 'BDY' THEN 'BUS: Loud, Disruptive, or Yelling'
                WHEN discipline_incidenttype = 'BTU' THEN 'BUS: Throwing objects/Unsafe Behav.'
                WHEN discipline_incidenttype = 'BDR' THEN 'BUS: Disrespect'
                WHEN discipline_incidenttype = 'BNC' THEN 'BUS: Name Calling or Bullying'
                WHEN discipline_incidenttype = 'BIP' THEN 'BUS: Phones/iPods/Games'
                WHEN discipline_incidenttype = 'BFI' THEN 'BUS: Fighting'
                WHEN discipline_incidenttype = 'BNR' THEN 'BUS: Not reporting incidents'
                ELSE NULL
               END AS incident_decoded
              ,dates.time_per_name AS RT
              ,ROW_NUMBER() OVER(
                  PARTITION BY studentid
                      ORDER BY entry_date DESC) AS rn

        FROM OPENQUERY(PS_TEAM,'
               SELECT s.id AS studentid
                     ,log.schoolid
                     ,entry_author
                     ,entry_date
                     ,logtypeid
                     ,subject
                     ,subtype
                     ,discipline_incidenttype
               FROM STUDENTS s
               LEFT OUTER JOIN log
                 ON s.id = log.studentid
               WHERE s.schoolid != 999999
                 AND s.enroll_status = 0
                 AND log.entry_date >= TO_DATE(''2013-08-01'',''YYYY-MM-DD'') --update for new school year
                 AND log.entry_date <= TO_DATE(''2014-06-30'',''YYYY-MM-DD'') --update for new school year
                 --AND logtypeid IN (-100000,3223,3023)
               ') oq
        JOIN REPORTING$dates dates
          ON oq.entry_date >= dates.start_date
         AND oq.entry_date <= dates.end_date
         AND oq.schoolid = dates.schoolid
         AND dates.identifier = 'RT'
     ) q;

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..DISC$log#static');

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
   AND sys.objects.name = 'DISC$log#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[DISC$log#static]
 SELECT *
 FROM [#DISC$log#static|refresh]
 ORDER BY schoolid, logtypeid, studentid, entry_date DESC;
 
 -- STEP 7: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'DISC$log#static';

 EXEC (@sql);
  
END
GO
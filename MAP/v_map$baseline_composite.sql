USE KIPP_NJ
GO

ALTER VIEW MAP$baseline_composite AS
WITH roster AS
  (SELECT studentid
         ,grade_level
         ,schoolid
         ,schools.ABBREVIATION AS school
         ,cohort.year
         ,cohort.lastfirst
   FROM KIPP_NJ..COHORT$comprehensive_long#static cohort
   JOIN KIPP_NJ..SCHOOLS
     ON cohort.SCHOOLID = schools.SCHOOL_NUMBER
   WHERE schoolid != 999999
     AND rn = 1
     --AND cohort.studentid = 4562
  )
 
 ,subj AS
  (SELECT 'Mathematics' AS measurementscale
   UNION
   SELECT 'Reading'
   UNION
   SELECT 'Language Usage'
   UNION
   SELECT 'Science - General Science'
  )
  
SELECT TOP (100) PERCENT sub.*
      ,CASE 
         WHEN map_spr.testritscore IS NULL THEN map_fall.termname
         ELSE map_spr.termname
       END AS termname
      ,CASE 
         WHEN map_spr.testritscore IS NULL THEN CAST(map_fall.testritscore AS INT)
         ELSE CAST(map_spr.testritscore AS INT)
       END AS testritscore
      ,CASE 
         WHEN map_spr.testritscore IS NULL THEN CAST(map_fall.percentile_2011_norms AS INT)
         ELSE CAST(map_spr.percentile_2011_norms AS INT)
       END AS testpercentile
      ,CASE 
         WHEN map_spr.testritscore IS NULL THEN map_fall.TypicalFallToSpringGrowth
         ELSE map_spr.TypicalSpringToSpringGrowth
       END AS typical_growth_fallorspring_to_spring
      ,CASE 
         WHEN map_spr.testritscore IS NULL THEN map_fall.rittoreadingscore
         ELSE map_spr.rittoreadingscore
       END AS lexile_score
FROM
      (SELECT roster.*
             ,subj.*
      FROM roster
      JOIN subj
        ON 1=1
      ) sub
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_fall
  ON sub.studentid = map_fall.ps_studentid
 AND sub.measurementscale = map_fall.MeasurementScale
 AND map_fall.rn = 1
 --THIS YEAR FALL
 AND map_fall.map_year = sub.year
 AND map_fall.fallwinterspring = 'Fall'

LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers map_spr
  ON sub.studentid = map_spr.ps_studentid
 AND sub.measurementscale = map_spr.MeasurementScale
 AND map_spr.rn = 1
 --PREVIOUS YEAR
 AND map_spr.map_year = sub.year
 AND map_spr.fallwinterspring = 'Spring'

ORDER BY sub.school
        ,sub.GRADE_LEVEL
        ,sub.lastfirst
USE [NWEA]
GO

/****** Object:  View [dbo].[MAP$comprehensive#cps_included]    Script Date: 9/14/2015 5:44:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[MAP$comprehensive#cps_included] AS
WITH KIPP
AS (
Select	star.*, 
		cr.ClassName,
		cr.TeacherName
FROM
	(SELECT  st.StudentLastName,
			 st.StudentFirstName,
			 st.StudentMI,
			 st.StudentDateOfBirth,
			 st.StudentEthnicGroup,
			 st.StudentGender,
			 st.Grade, 
			 ar.TermName,		
			 ar.StudentID,
			 ar.SchoolName, 
			 ar.MeasurementScale,
			 ar.Discipline,
			 ar.GrowthMeasureYN,
			 ar.TestType,
			 ar.TestName,
			 ar.TestID,
			 ar.TestStartDate,
			 ar.TestDurationMinutes,
			 ar.TestRITScore,
			 ar.TestStandardError,
			 ar.TestPercentile,
			 ar.TypicalFallToFallGrowth,
			 CAST(ROUND(ar.TypicalSpringToSpringGrowth,0) as int) AS TypicalSpringToSpringGrowth,
			 ar.TypicalFallToSpringGrowth,
			 ar.TypicalFallToWinterGrowth,
			 ar.RITtoReadingScore,
			 ar.RITtoReadingMin,
			 ar.RITtoReadingMax,
			 ar.Goal1Name,
			 ar.Goal1RitScore,
			 ar.Goal1StdErr,
			 ar.Goal1Range,
			 ar.Goal1Adjective,
			 ar.Goal2Name,
			 ar.Goal2RitScore,
			 ar.Goal2StdErr,
			 ar.Goal2Range,
			 ar.Goal2Adjective,
			 ar.Goal3Name,
			 ar.Goal3RitScore,
			 ar.Goal3StdErr,
			 ar.Goal3Range,
			 ar.Goal3Adjective,
			 ar.Goal4Name,
			 ar.Goal4RitScore,
			 ar.Goal4StdErr,
			 ar.Goal4Range,
			 ar.Goal4Adjective,
			 ar.Goal5Name,
			 ar.Goal5RitScore,
			 ar.Goal5StdErr,
			 ar.Goal5Range,
			 ar.Goal5Adjective,
			 ar.Goal6Name,
			 ar.Goal6RitScore,
			 ar.Goal6StdErr,
			 ar.Goal6Range,
			 ar.Goal6Adjective,
			 ar.Goal7Name,
			 ar.Goal7RitScore,
			 ar.Goal7StdErr,
			 ar.Goal7Range,
			 ar.Goal7Adjective,
			 ar.Goal8Name,
			 ar.Goal8RitScore,
			 ar.Goal8StdErr,
			 ar.Goal8Range,
			 ar.Goal8Adjective,
			 ar.TestStartTime,
			 ar.PercentCorrect,
			 ar.ProjectedProficiency,
			 'TRUE' as Tested_at_KIPP
	FROM
			(SELECT	* 
			FROM	[dbo].[AssessmentResults$old_format]
			WHERE	GrowthMeasureYN='True'
			) ar
	INNER JOIN	(SELECT	TermName,
						StudentID,
						StudentLastName,
						StudentFirstName,
						StudentMI,
						StudentDateOfBirth,
						StudentEthnicGroup,
						StudentGender,
						Grade
			 FROM [dbo].[StudentsBySchool]
			 ) st
	ON st.StudentID=ar.StudentID AND st.TermName=ar.TermName) star
LEFT JOIN (SELECT	TermName,
					StudentID,
					ClassName,
					TeacherName
			FROM [dbo].[ClassAssignments]
			) cr
ON star.StudentID=cr.StudentID AND star.TermName=cr.TermName
)
,
CPS 
AS 
(
SELECT	StudentLastName,
		StudentFirstName,
		Null AS StudentMI,
		Null AS StudentDateOfBirth,
		Null AS StudentEthnicGroup,
		Null AS StudentGender, 
		GradeLevel AS Grade,
		TermName,		
		StudentID,
		SchoolName_KIPP AS SchoolName, 
		Discipline AS MeasurementScale,
		Discipline,
		GrowthMeasureYN,
		Null AS TestType,
		TestName,
		Null AS TestID,
		TestStartDate,
		TestDurationMinutes,
		TestRITScore,
		TestStandardError,
		TestPercentile,
		nullif(TypicalFallToFallGrowth, 'NA') AS TypicalFallToFallGrowth,
		TypicalSpringToSpringGrowth,
		nullif(TypicalFallToSpringGrowth, 'NA') AS TypicalFallToSpringGrowth,
		nullif(TypicalFallToWinterGrowth, 'NA') AS TypicalFallToWinterGrowth,
		RITtoReadingScore,
		RITtoReadingMin,
		RITtoReadingMax,
		Goal1Name,
		CAST(Goal1RitScore AS float) AS Goal1RitScore,
		CAST(Goal1StdErr AS float) AS Goal1StdErr,
		Goal1Range,
		Goal1Adjective,
		Goal2Name,
		CAST(Goal2RitScore AS float) AS Goal2RitScore,
		CAST(Goal2StdErr AS float) AS Goal2StdErr,
		Goal2Range,
		Goal2Adjective,
		Goal3Name,
		CAST(Goal3RitScore AS float) AS Goal3RitScore,
		CAST(Goal3StdErr AS float) AS Goal3StdErr,
		Goal3Range,
		Goal3Adjective,
		Goal4Name,
		CAST(Goal4RitScore AS float) AS Goal4RitScore,
		CAST(Goal4StdErr AS float) AS Goal4StdErr,
		Goal4Range,
		Goal4Adjective,
		Goal5Name,
		nullif(Goal5RitScore, 'NA') AS Goal5RitScore,
		nullif(Goal5StdErr, 'NA') AS Goal5StdErr,
		Goal5Range,
		Goal5Adjective,
		Goal6Name,
		nullif(Goal6RitScore, 'NA') AS Goal6RitScore,
		nullif(Goal6StdErr, 'NA') AS Goal6StdErr,
		Goal6Range,
		Goal6Adjective,
		Goal7Name,
		nullif(Goal7RitScore, 'NA') AS Goal7RitScore,
		nullif(Goal7StdErr, 'NA') AS Goal7StdErr,
		Goal7Range,
		Goal7Adjective,
		Goal8Name,
		nullif(Goal8RitScore, 'NA') AS Goal8RitScore,
		nullif(Goal8StdErr, 'NA') AS Goal8StdErr,
		Goal8Range,
		Goal8Adjective,
		TestStartTime,
		PercentCorrect,
		ProjectedProficiency,
		Tested_at_KIPP,	
		StudentHomeroom AS ClassName,
		SchoolName AS TeacherName
FROM CDF_CPS
WHERE Tested_at_KIPP='FALSE'
)
SELECT * FROM KIPP
UNION ALL
SELECT * FROM CPS
GO



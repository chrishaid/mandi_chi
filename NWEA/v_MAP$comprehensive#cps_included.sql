USE [NWEA]
GO

CREATE VIEW MAP$comprehensive#cps_included AS
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
			FROM	[dbo].[AssessmentResults]
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
		TypicalFallToFallGrowth,
		TypicalSpringToSpringGrowth,
		TypicalFallToSpringGrowth,
		TypicalFallToWinterGrowth,
		RITtoReadingScore,
		RITtoReadingMin,
		RITtoReadingMax,
		Goal1Name,
		Goal1RitScore,
		Goal1StdErr,
		Goal1Range,
		Goal1Adjective,
		Goal2Name,
		Goal2RitScore,
		Goal2StdErr,
		Goal2Range,
		Goal2Adjective,
		Goal3Name,
		Goal3RitScore,
		Goal3StdErr,
		Goal3Range,
		Goal3Adjective,
		Goal4Name,
		Goal4RitScore,
		Goal4StdErr,
		Goal4Range,
		Goal4Adjective,
		Goal5Name,
		Goal5RitScore,
		Goal5StdErr,
		Goal5Range,
		Goal5Adjective,
		Goal6Name,
		Goal6RitScore,
		Goal6StdErr,
		Goal6Range,
		Goal6Adjective,
		Goal7Name,
		Goal7RitScore,
		Goal7StdErr,
		Goal7Range,
		Goal7Adjective,
		Goal8Name,
		Goal8RitScore,
		Goal8StdErr,
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
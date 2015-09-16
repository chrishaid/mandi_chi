USE [NWEA]
GO

/****** Object:  View [dbo].[MAP$comprehensive#cps_included]    Script Date: 9/9/2015 6:02:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[MAP$comprehensive#plus_cps] AS
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
			 ar.NormsReferenceData,
			 ar.WISelectedAYFall,
			 ar.WISelectedAYWinter,
			 ar.WISelectedAYSpring,
			 ar.WIPreviousAYFall,
			 ar.WIPreviousAYWinter,
			 ar.WIPreviousAYSpring,
			 ar.TestType,
			 ar.TestName,
			 ar.TestID,
			 ar.TestStartDate,
			 ar.TestDurationMinutes,
			 ar.TestRITScore,
			 ar.TestStandardError,
			 ar.TestPercentile,
			
			-- BEGIN new growth colums
			-- Fall-to-Fall
			ar.FalltoFallProjectedGrowth,
			ar.FalltoFallObservedGrowth,
			ar.FalltoFallObservedGrowthSE,
			ar.FalltoFallMetProjectedGrowth,
			ar.FalltoFallConditionalGrowthIndex,
			ar.FalltoFallConditionalGrowthPercentile,
			-- Fall-to-Winter
			ar.FalltoWinterProjectedGrowth,
			ar.FalltoWinterObservedGrowth,
			ar.FalltoWinterObservedGrowthSE,
			ar.FalltoWinterMetProjectedGrowth,
			ar.FalltoWinterConditionalGrowthIndex,
			ar.FalltoWinterConditionalGrowthPercentile,
			-- Fall-to-Spring
			ar.FalltoSpringProjectedGrowth,
			ar.FalltoSpringObservedGrowth,
			ar.FalltoSpringObservedGrowthSE,
			ar.FalltoSpringMetProjectedGrowth,
			ar.FalltoSpringConditionalGrowthIndex,
			ar.FalltoSpringConditionalGrowthPercentile,
			-- Winter-to-Winter 
			ar.WintertoWinterProjectedGrowth,
			ar.WintertoWinterObservedGrowth,
			ar.WintertoWinterObservedGrowthSE,
			ar.WintertoWinterMetProjectedGrowth,
			ar.WintertoWinterConditionalGrowthIndex,
			ar.WintertoWinterConditionalGrowthPercentile,
			-- Winter-to-Spring
			ar.WintertoSpringProjectedGrowth,
			ar.WintertoSpringObservedGrowth,
			ar.WintertoSpringObservedGrowthSE,
			ar.WintertoSpringMetProjectedGrowth,
			ar.WintertoSpringConditionalGrowthIndex,
			ar.WintertoSpringConditionalGrowthPercentile,
			-- Spring-to-Spring
			ar.SpringtoSpringProjectedGrowth,
			ar.SpringtoSpringObservedGrowth,
			ar.SpringtoSpringObservedGrowthSE,
			ar.SpringtoSpringMetProjectedGrowth,
			ar.SpringtoSpringConditionalGrowthIndex,
			ar.SpringtoSpringConditionalGrowthPercentile,
			--END new growth Columns
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

			 -- BEGIN new ar.Projected proficieny columns
			 ar.ProjectedProficiencyStudy1,
			 ar.ProjectedProficiencyLevel1,
			 ar.ProjectedProficiencyStudy2,
			 ar.ProjectedProficiencyLevel2,
			 ar.ProjectedProficiencyStudy3,
			 ar.ProjectedProficiencyLevel3,
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
		NULL AS NormsReferenceData,
		NULL AS WISelectedAYFall,
		NULL AS WISelectedAYWinter,
		NULL AS WISelectedAYSpring,
		NULL AS WIPreviousAYFall,
		NULL AS WIPreviousAYWinter,
		NULL AS WIPreviousAYSpring,
		Null AS TestType,
		TestName,
		Null AS TestID,
		TestStartDate,
		TestDurationMinutes,
		TestRITScore,
		TestStandardError,
		TestPercentile,

		-- BEGIN new growth colums
		-- Fall-to-Fall
		nullif(TypicalFallToFallGrowth, 'NA') AS FalltoFallProjectedGrowth,
		NULL AS FalltoFallObservedGrowth,
		NULL AS FalltoFallObservedGrowthSE,
		NULL AS FalltoFallMetProjectedGrowth,
		NULL AS FalltoFallConditionalGrowthIndex,
		NULL AS FalltoFallConditionalGrowthPercentile,
			-- Fall-to-Winter
		nullif(TypicalFallToWinterGrowth, 'NA') AS FalltoWinterProjectedGrowth,
		NULL AS FalltoWinterObservedGrowth,
		NULL AS FalltoWinterObservedGrowthSE,
		NULL AS FalltoWinterMetProjectedGrowth,
		NULL AS FalltoWinterConditionalGrowthIndex,
		NULL AS FalltoWinterConditionalGrowthPercentile,
			-- Fall-to-Spring
		nullif(TypicalFallToFallGrowth, 'NA') AS FalltoSpringProjectedGrowth,
		NULL AS FalltoSpringObservedGrowth,
		NULL AS FalltoSpringObservedGrowthSE,
		NULL AS FalltoSpringMetProjectedGrowth,
		NULL AS FalltoSpringConditionalGrowthIndex,
		NULL AS FalltoSpringConditionalGrowthPercentile,
			-- Winter-to-Winter 
		NULL AS WintertoWinterProjectedGrowth,
		NULL AS WintertoWinterObservedGrowth,
		NULL AS WintertoWinterObservedGrowthSE,
		NULL AS WintertoWinterMetProjectedGrowth,
		NULL AS WintertoWinterConditionalGrowthIndex,
		NULL AS WintertoWinterConditionalGrowthPercentile,
			-- Winter-to-Spring
		NULL AS WintertoSpringProjectedGrowth,
		NULL AS WintertoSpringObservedGrowth,
		NULL AS WintertoSpringObservedGrowthSE,
		NULL AS WintertoSpringMetProjectedGrowth,
		NULL AS WintertoSpringConditionalGrowthIndex,
		NULL AS WintertoSpringConditionalGrowthPercentile,
			-- Spring-to-Spring
		CAST(TypicalSpringToSpringGrowth AS float) AS SpringtoSpringProjectedGrowth,
		NULL AS SpringtoSpringObservedGrowth,
		NULL AS SpringtoSpringObservedGrowthSE,
		NULL AS SpringtoSpringMetProjectedGrowth,
		NULL AS SpringtoSpringConditionalGrowthIndex,
		NULL AS SpringtoSpringConditionalGrowthPercentile,
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
		-- BEGIN new ar.Projected proficieny columns
		NULL AS ProjectedProficiencyStudy1,
		ProjectedProficiency AS ProjectedProficiencyLevel1,
		NULL AS ProjectedProficiencyStudy2,
		NULL AS ProjectedProficiencyLevel2,
		NULL AS ProjectedProficiencyStudy3,
		NULL AS ProjectedProficiencyLevel3,
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








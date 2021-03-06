USE [NWEA]
GO
/****** Object:  StoredProcedure [dbo].[sp_LoadCDF]    Script Date: 9/14/2015 5:53:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT source.*
INTO map$cdf
FROM #cdf source
WHERE 1=2

*/

ALTER PROCEDURE [dbo].[sp_LoadCDF] AS
BEGIN
	--I. Assessment Results
	--0. ensure temp table doesn't exist in use
	IF OBJECT_ID(N'tempdb..#cdf_AR') IS NOT NULL
	BEGIN
		DROP TABLE #cdf_AR
	END

    --1. bulk load csv and SELECT INTO temp table

			

        SELECT sub.*
        INTO #cdf_AR
        FROM
            (SELECT *
            FROM OPENROWSET(
						'Microsoft.ACE.OLEDB.12.0', 
						'text;Database=C:\robots\NWEA\data', 
						'SELECT * FROM AssessmentResults.csv'
						)
            ) sub;

        --2. upsert on WINSQL01
        WITH new_file AS
                    (SELECT *
                    FROM #cdf_AR)

        MERGE AssessmentResults target
        USING new_file staging
                            ON target.testid = staging.testid
        WHEN MATCHED THEN
                    UPDATE SET
                            target.termname = staging.termname
                            ,target.studentid = staging.studentid
                            ,target.schoolname = staging.schoolname
                            ,target.measurementscale = staging.measurementscale
                            ,target.discipline = staging.discipline
                            ,target.growthmeasureyn = staging.growthmeasureyn
							,target.normsreferencedata = staging.normsreferencedata
							,target.wiselectedayfall = staging.wiselectedayfall
							,target.wiselectedaywinter = staging.wiselectedaywinter	
							,target.wiselectedayspring = staging.wiselectedayspring
							,target.wipreviousayfall = staging.wipreviousayfall
							,target.wipreviousaywinter = staging.wipreviousaywinter
							,target.wipreviousayspring = staging.wipreviousayspring
                            ,target.testtype = staging.testtype
                            ,target.testname = staging.testname
                            ,target.testid = staging.testid
                            ,target.teststartdate = staging.teststartdate
                            ,target.testdurationminutes = staging.testdurationminutes
                            ,target.testritscore = staging.testritscore
                            ,target.teststandarderror = staging.teststandarderror
                            ,target.testpercentile = staging.testpercentile
							,target.falltofallprojectedgrowth = staging.falltofallprojectedgrowth
							,target.falltofallobservedgrowth = staging.falltofallobservedgrowth
							,target.falltofallobservedgrowthse = staging.falltofallobservedgrowthse
							,target.falltofallmetprojectedgrowth = staging.falltofallmetprojectedgrowth
							,target.falltofallconditionalgrowthindex = staging.falltofallconditionalgrowthindex
							,target.falltofallconditionalgrowthpercentile = staging.falltofallconditionalgrowthpercentile
							,target.falltowinterprojectedgrowth = staging.falltowinterprojectedgrowth
							,target.falltowinterobservedgrowth = staging.falltowinterobservedgrowth
							,target.falltowinterobservedgrowthse = staging.falltowinterobservedgrowthse
							,target.falltowintermetprojectedgrowth = staging.falltowintermetprojectedgrowth
							,target.falltowinterconditionalgrowthindex = staging.falltowinterconditionalgrowthindex
							,target.falltowinterconditionalgrowthpercentile = staging.falltowinterconditionalgrowthpercentile
							,target.falltospringprojectedgrowth = staging.falltospringprojectedgrowth
							,target.falltospringobservedgrowth = staging.falltospringobservedgrowth
							,target.falltospringobservedgrowthse = staging.falltospringobservedgrowthse
							,target.falltospringmetprojectedgrowth = staging.falltospringmetprojectedgrowth
							,target.falltospringconditionalgrowthindex = staging.falltospringconditionalgrowthindex
							,target.falltospringconditionalgrowthpercentile = staging.falltospringconditionalgrowthpercentile
							,target.wintertowinterprojectedgrowth = staging.wintertowinterprojectedgrowth
							,target.wintertowinterobservedgrowth = staging.wintertowinterobservedgrowth
							,target.wintertowinterobservedgrowthse = staging.wintertowinterobservedgrowthse
							,target.wintertowintermetprojectedgrowth = staging.wintertowintermetprojectedgrowth
							,target.wintertowinterconditionalgrowthindex = staging.wintertowinterconditionalgrowthindex
							,target.wintertowinterconditionalgrowthpercentile = staging.wintertowinterconditionalgrowthpercentile
							,target.wintertospringprojectedgrowth = staging.wintertospringprojectedgrowth
							,target.wintertospringobservedgrowth = staging.wintertospringobservedgrowth
							,target.wintertospringobservedgrowthse = staging.wintertospringobservedgrowthse
							,target.wintertospringmetprojectedgrowth = staging.wintertospringmetprojectedgrowth
							,target.wintertospringconditionalgrowthindex = staging.wintertospringconditionalgrowthindex
							,target.wintertospringconditionalgrowthpercentile = staging.wintertospringconditionalgrowthpercentile
							,target.springtospringprojectedgrowth = staging.springtospringprojectedgrowth
							,target.springtospringobservedgrowth = staging.springtospringobservedgrowth
							,target.springtospringobservedgrowthse = staging.springtospringobservedgrowthse
							,target.springtospringmetprojectedgrowth = staging.springtospringmetprojectedgrowth
							,target.springtospringconditionalgrowthindex = staging.springtospringconditionalgrowthindex
							,target.springtospringconditionalgrowthpercentile = staging.springtospringconditionalgrowthpercentile
                            ,target.rittoreadingscore = staging.rittoreadingscore
                            ,target.rittoreadingmin = staging.rittoreadingmin
                            ,target.rittoreadingmax = staging.rittoreadingmax
                            ,target.goal1name = staging.goal1name
                            ,target.goal1ritscore = staging.goal1ritscore
                            ,target.goal1stderr = staging.goal1stderr
                            ,target.goal1range = staging.goal1range
                            ,target.goal1adjective = staging.goal1adjective
                            ,target.goal2name = staging.goal2name
                            ,target.goal2ritscore = staging.goal2ritscore
                            ,target.goal2stderr = staging.goal2stderr
                            ,target.goal2range = staging.goal2range
                            ,target.goal2adjective = staging.goal2adjective
                            ,target.goal3name = staging.goal3name
                            ,target.goal3ritscore = staging.goal3ritscore
                            ,target.goal3stderr = staging.goal3stderr
                            ,target.goal3range = staging.goal3range
                            ,target.goal3adjective = staging.goal3adjective
                            ,target.goal4name = staging.goal4name
                            ,target.goal4ritscore = staging.goal4ritscore
                            ,target.goal4stderr = staging.goal4stderr
                            ,target.goal4range = staging.goal4range
                            ,target.goal4adjective = staging.goal4adjective
                            ,target.goal5name = staging.goal5name
                            ,target.goal5ritscore = staging.goal5ritscore
                            ,target.goal5stderr = staging.goal5stderr
                            ,target.goal5range = staging.goal5range
                            ,target.goal5adjective = staging.goal5adjective
                            ,target.goal6name = staging.goal6name
                            ,target.goal6ritscore = staging.goal6ritscore
                            ,target.goal6stderr = staging.goal6stderr
                            ,target.goal6range = staging.goal6range
                            ,target.goal6adjective = staging.goal6adjective
                            ,target.goal7name = staging.goal7name
                            ,target.goal7ritscore = staging.goal7ritscore
                            ,target.goal7stderr = staging.goal7stderr
                            ,target.goal7range = staging.goal7range
                            ,target.goal7adjective = staging.goal7adjective
                            ,target.goal8name = staging.goal8name
                            ,target.goal8ritscore = staging.goal8ritscore
                            ,target.goal8stderr = staging.goal8stderr
                            ,target.goal8range = staging.goal8range
                            ,target.goal8adjective = staging.goal8adjective
                            ,target.teststarttime = staging.teststarttime
                            ,target.percentcorrect = staging.percentcorrect
							,target.projectedproficiencystudy1 = staging.projectedproficiencystudy1
							,target.projectedproficiencylevel1 = staging.projectedproficiencylevel1
							,target.projectedproficiencystudy2 = staging.projectedproficiencystudy2
							,target.projectedproficiencylevel2 = staging.projectedproficiencylevel2
							,target.projectedproficiencystudy3 = staging.projectedproficiencystudy3
							,target.projectedproficiencylevel3 = staging.projectedproficiencylevel3
        WHEN NOT MATCHED BY target THEN
        INSERT (termname
				,studentid
                ,schoolname
                ,measurementscale
                ,discipline
                ,growthmeasureyn
				,normsreferencedata
				,wiselectedayfall
				,wiselectedaywinter
				,wiselectedayspring
				,wipreviousayfall
				,wipreviousaywinter
				,wipreviousayspring
                ,testtype
                ,testname
                ,testid
                ,teststartdate
                ,testdurationminutes
                ,testritscore
                ,teststandarderror
                ,testpercentile
				,falltofallprojectedgrowth
				,falltofallobservedgrowth
				,falltofallobservedgrowthse
				,falltofallmetprojectedgrowth
				,falltofallconditionalgrowthindex
				,falltofallconditionalgrowthpercentile
				,falltowinterprojectedgrowth
				,falltowinterobservedgrowth
				,falltowinterobservedgrowthse
				,falltowintermetprojectedgrowth
				,falltowinterconditionalgrowthindex
				,falltowinterconditionalgrowthpercentile
				,falltospringprojectedgrowth
				,falltospringobservedgrowth
				,falltospringobservedgrowthse
				,falltospringmetprojectedgrowth
				,falltospringconditionalgrowthindex
				,falltospringconditionalgrowthpercentile
				,wintertowinterprojectedgrowth
				,wintertowinterobservedgrowth
				,wintertowinterobservedgrowthse
				,wintertowintermetprojectedgrowth
				,wintertowinterconditionalgrowthindex
				,wintertowinterconditionalgrowthpercentile
				,wintertospringprojectedgrowth
				,wintertospringobservedgrowth
				,wintertospringobservedgrowthse
				,wintertospringmetprojectedgrowth
				,wintertospringconditionalgrowthindex
				,wintertospringconditionalgrowthpercentile
				,springtospringprojectedgrowth
				,springtospringobservedgrowth
				,springtospringobservedgrowthse
				,springtospringmetprojectedgrowth
				,springtospringconditionalgrowthindex
				,springtospringconditionalgrowthpercentile
                ,rittoreadingscore
                ,rittoreadingmin
                ,rittoreadingmax
                ,goal1name
                ,goal1ritscore
                ,goal1stderr
                ,goal1range
                ,goal1adjective
                ,goal2name
                ,goal2ritscore
                ,goal2stderr
                ,goal2range
                ,goal2adjective
                ,goal3name
                ,goal3ritscore
                ,goal3stderr
                ,goal3range
                ,goal3adjective
                ,goal4name
                ,goal4ritscore
                ,goal4stderr
                ,goal4range
                ,goal4adjective
                ,goal5name
                ,goal5ritscore
                ,goal5stderr
                ,goal5range
                ,goal5adjective
                ,goal6name
                ,goal6ritscore
                ,goal6stderr
                ,goal6range
                ,goal6adjective
                ,goal7name
                ,goal7ritscore
                ,goal7stderr
                ,goal7range
                ,goal7adjective
                ,goal8name
                ,goal8ritscore
                ,goal8stderr
                ,goal8range
                ,goal8adjective
                ,teststarttime
                ,percentcorrect
				,projectedproficiencystudy1
				,projectedproficiencylevel1
				,projectedproficiencystudy2
				,projectedproficiencylevel2
				,projectedproficiencystudy3
				,projectedproficiencylevel3
				)
        VALUES (staging.termname
				,staging.studentid
				,staging.schoolname
				,staging.measurementscale
				,staging.discipline
				,staging.growthmeasureyn
				,staging.normsreferencedata
				,staging.wiselectedayfall
				,staging.wiselectedaywinter
				,staging.wiselectedayspring
				,staging.wipreviousayfall
				,staging.wipreviousaywinter
				,staging.wipreviousayspring
				,staging.testtype
				,staging.testname
				,staging.testid
				,staging.teststartdate
				,staging.testdurationminutes
				,staging.testritscore
				,staging.teststandarderror
				,staging.testpercentile
				,staging.falltofallprojectedgrowth
				,staging.falltofallobservedgrowth
				,staging.falltofallobservedgrowthse
				,staging.falltofallmetprojectedgrowth
				,staging.falltofallconditionalgrowthindex
				,staging.falltofallconditionalgrowthpercentile
				,staging.falltowinterprojectedgrowth
				,staging.falltowinterobservedgrowth
				,staging.falltowinterobservedgrowthse
				,staging.falltowintermetprojectedgrowth
				,staging.falltowinterconditionalgrowthindex
				,staging.falltowinterconditionalgrowthpercentile
				,staging.falltospringprojectedgrowth
				,staging.falltospringobservedgrowth
				,staging.falltospringobservedgrowthse
				,staging.falltospringmetprojectedgrowth
				,staging.falltospringconditionalgrowthindex
				,staging.falltospringconditionalgrowthpercentile
				,staging.wintertowinterprojectedgrowth
				,staging.wintertowinterobservedgrowth
				,staging.wintertowinterobservedgrowthse
				,staging.wintertowintermetprojectedgrowth
				,staging.wintertowinterconditionalgrowthindex
				,staging.wintertowinterconditionalgrowthpercentile
				,staging.wintertospringprojectedgrowth
				,staging.wintertospringobservedgrowth
				,staging.wintertospringobservedgrowthse
				,staging.wintertospringmetprojectedgrowth
				,staging.wintertospringconditionalgrowthindex
				,staging.wintertospringconditionalgrowthpercentile
				,staging.springtospringprojectedgrowth
				,staging.springtospringobservedgrowth
				,staging.springtospringobservedgrowthse
				,staging.springtospringmetprojectedgrowth
				,staging.springtospringconditionalgrowthindex
				,staging.springtospringconditionalgrowthpercentile
				,staging.rittoreadingscore
				,staging.rittoreadingmin
				,staging.rittoreadingmax
				,staging.goal1name
				,staging.goal1ritscore
				,staging.goal1stderr
				,staging.goal1range
				,staging.goal1adjective
				,staging.goal2name
				,staging.goal2ritscore
				,staging.goal2stderr
				,staging.goal2range
				,staging.goal2adjective
				,staging.goal3name
				,staging.goal3ritscore
				,staging.goal3stderr
				,staging.goal3range
				,staging.goal3adjective
				,staging.goal4name
				,staging.goal4ritscore
				,staging.goal4stderr
				,staging.goal4range
				,staging.goal4adjective
				,staging.goal5name
				,staging.goal5ritscore
				,staging.goal5stderr
				,staging.goal5range
				,staging.goal5adjective
				,staging.goal6name
				,staging.goal6ritscore
				,staging.goal6stderr
				,staging.goal6range
				,staging.goal6adjective
				,staging.goal7name
				,staging.goal7ritscore
				,staging.goal7stderr
				,staging.goal7range
				,staging.goal7adjective
				,staging.goal8name
				,staging.goal8ritscore
				,staging.goal8stderr
				,staging.goal8range
				,staging.goal8adjective
				,staging.teststarttime
				,staging.percentcorrect
				,staging.projectedproficiencystudy1
				,staging.projectedproficiencylevel1
				,staging.projectedproficiencystudy2
				,staging.projectedproficiencylevel2
				,staging.projectedproficiencystudy3
				,staging.projectedproficiencylevel3				
				);

	--II. Students by School
	--0. ensure temp table doesn't exist in use
	IF OBJECT_ID(N'tempdb..#cdf_St') IS NOT NULL
	BEGIN
		DROP TABLE #cdf_St
	END

    --1. bulk load csv and SELECT INTO temp table

			

        SELECT sub.*
        INTO #cdf_St
        FROM
            (SELECT *
            FROM OPENROWSET(
						'Microsoft.ACE.OLEDB.12.0', 
						'text;Database=C:\robots\NWEA\data', 
						'SELECT * FROM StudentsBySchool.csv'
						)
            ) sub;

        --2. upsert on WINSQL01
        WITH new_file AS
                    (SELECT *
                    FROM #cdf_St)

        MERGE StudentsBySchool target
        USING new_file staging
        ON (target.studentid = staging.studentid)
		AND (target.termname=staging.termname)
		AND (target.SchoolName=staging.SchoolName)
		WHEN MATCHED THEN
					 UPDATE SET
                            target.termname			  = staging.TermName,
							target.DistrictName		  = staging.DistrictName,
							target.SchoolName		  = staging.SchoolName,
							target.StudentLastName	  = staging.StudentLastName,
							target.StudentFirstName	  = staging.StudentFirstName,
							target.StudentMI		  = staging.StudentMI,
							target.StudentID		  = staging.StudentID,
							target.StudentDateOfBirth = staging.StudentDateOfBirth,
							target.StudentEthnicGroup = staging.StudentEthnicGroup,
							target.StudentGender	  = staging.StudentGender,
							target.Grade			  = staging.Grade
					 WHEN NOT MATCHED BY target THEN
						INSERT (TermName,
								DistrictName,
								SchoolName,
								StudentLastName,
								StudentFirstName,
								StudentMI,
								StudentID,
								StudentDateOfBirth,
								StudentEthnicGroup,
								StudentGender,
								Grade)
							VALUES (
								staging.TermName,
								staging.DistrictName,
								staging.SchoolName,
								staging.StudentLastName,
								staging.StudentFirstName,
								staging.StudentMI,
								staging.StudentID,
								staging.StudentDateOfBirth,
								staging.StudentEthnicGroup,
								staging.StudentGender,
								staging.Grade);

	--III. Class Assignments
	--0. ensure temp table doesn't exist in use
	IF OBJECT_ID(N'tempdb..#cdf_CR') IS NOT NULL
	BEGIN
		DROP TABLE #cdf_CR
	END

    --1. bulk load csv and SELECT INTO temp table

			

        SELECT sub.*
        INTO #cdf_CR
        FROM
            (SELECT *
            FROM OPENROWSET(
						'Microsoft.ACE.OLEDB.12.0', 
						'text;Database=C:\robots\NWEA\data', 
						'SELECT * FROM ClassAssignments.csv'
						)
            ) sub;

        --2. upsert on WINSQL01
        WITH new_file AS
                    (SELECT *
                    FROM #cdf_CR)

        MERGE ClassAssignments target
        USING new_file staging
        ON (target.studentid = staging.studentid)
		AND (target.termname=staging.termname)
		AND (target.SchoolName=staging.SchoolName)
		WHEN MATCHED THEN
					 UPDATE SET
                            target.TermName    = staging.TermName,
							target.StudentID   = staging.StudentID,
							target.SchoolName  = staging.SchoolName,
							target.ClassName   = staging.ClassName,
							target.TeacherName = staging.TeacherName
					 WHEN NOT MATCHED BY target THEN
						INSERT (TermName,StudentID,SchoolName,ClassName,TeacherName)
							VALUES (
								staging.TermName,
								staging.StudentID,
								staging.SchoolName,
								staging.ClassName,
								staging.TeacherName
								);


	--IV. Accomodation Assignment
	--0. ensure temp table doesn't exist in use
	IF OBJECT_ID(N'tempdb..#cdf_AA') IS NOT NULL
	BEGIN
		DROP TABLE #cdf_AA
	END

    --1. bulk load csv and SELECT INTO temp table

			

        SELECT sub.*
        INTO #cdf_AA
        FROM
            (SELECT *
            FROM OPENROWSET(
						'Microsoft.ACE.OLEDB.12.0', 
						'text;Database=C:\robots\NWEA\data', 
						'SELECT * FROM AccommodationAssignment.csv'
						)
            ) sub;

        --2. upsert on WINSQL01
        WITH new_file AS
                    (SELECT *
                    FROM #cdf_AA)

        MERGE AccommodationAssignment target
        USING new_file staging
        ON (target.TestId = staging.TestId)
		WHEN MATCHED THEN
					 UPDATE SET
                            target.TermName				 = staging.TermName,
							target.TestId				 = staging.TestId,
							target.StudentId			 = staging.StudentId,
							target.AccommodationCategory = staging.AccommodationCategory,
							target.Accommodation		 = staging.Accommodation
					 WHEN NOT MATCHED BY target THEN
						INSERT (TermName,TestId,StudentId,AccommodationCategory,Accommodation)
							VALUES (
								staging.TermName,
								staging.TestId,
								staging.StudentId,
								staging.AccommodationCategory,
								staging.Accommodation
								);



	--V. Prograrm Assignments
	--0. ensure temp table doesn't exist in use
	IF OBJECT_ID(N'tempdb..#cdf_PA') IS NOT NULL
	BEGIN
		DROP TABLE #cdf_PA
	END

    --1. bulk load csv and SELECT INTO temp table

			

        SELECT sub.*
        INTO #cdf_PA
        FROM
            (SELECT *
            FROM OPENROWSET(
						'Microsoft.ACE.OLEDB.12.0', 
						'text;Database=C:\robots\NWEA\data', 
						'SELECT * FROM ProgramAssignments.csv'
						)
            ) sub;

        --2. upsert on WINSQL01
        WITH new_file AS
                    (SELECT *
                    FROM #cdf_PA)

        MERGE ProgramAssignments target
        USING new_file staging
        ON (target.TermName = staging.TermName) 
		AND (target.StudentID = staging.StudentID)
		WHEN MATCHED THEN
					 UPDATE SET
                            target.TermName  = staging.TermName,
							target.StudentID = staging.StudentID,
							target.Program	 = staging.Program
					 WHEN NOT MATCHED BY target THEN
						INSERT (TermName,
								StudentID,
								Program)
							VALUES (
								staging.TermName,
								staging.StudentID,
								staging.Program
								);


END





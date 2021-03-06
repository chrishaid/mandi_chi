USE KIPP_NJ
GO

ALTER VIEW AR$test_event_detail AS
--CTE to enable manipulation of this guy w/o ugly self join
WITH ar_detail AS
    (SELECT REPLACE(LEFT(rluser.[vchPreviousIDNum], 5), '-','') AS student_number
           ,arsp.[iStudentPracticeID]
           ,arsp.[iUserID]
           ,arsp.[iSchoolID]
           ,arsp.[iContentID]
           ,arsp.[iClassID]
           ,arsp.[iContentTypeID]
           ,arsp.[iRLID]
           ,arsp.[iQuizNumber]
           ,arsp.[vchContentLanguage]
           ,arsp.[vchContentTitle]
           ,arsp.[vchSortTitle]
           ,arsp.[vchAuthor]
           ,arsp.[vchSeriesShortName]
           ,arsp.[vchSeriesTitle]
           ,arsp.[chContentVersion]
           ,arsp.[chFictionNonFiction]
           ,arsp.[vchInterestLevel]
           ,arsp.[dBookLevel]
           ,arsp.[iQuestionsPresented]
           ,arsp.[iQuestionsCorrect]
           ,arsp.[dAlternateBookLevel_1]
           ,arsp.[dPointsPossible]
           ,arsp.[iAlternateBookLevel_2]
           ,arsp.[dPointsEarned]
           ,arsp.[dPassingPercentage]
           ,arsp.[tiPassed]
           ,arsp.[chTWI]
           ,arsp.[tiBookRating]
           ,arsp.[tiUsedAudio]
           ,arsp.[dtTaken]
           ,arsp.[dtTakenOriginal]
           ,arsp.[tiTeacherModified]
           ,arsp.[tiPracticeDetail]
           ,arsp.[iWordCount]
           ,arsp.[dPercentCorrect]
           ,arsp.[vchSecondTryTitle]
           ,arsp.[vchSecondTryAuthor]
           ,arsp.[chStatus]
           ,arsp.[iRetakeCount]
           ,arsp.[DeviceType]
           ,arsp.[DeviceAppletID]
           ,arsp.[sDataOrigination]
           ,arsp.[tiCSImportVersion]
           ,arsp.[iInsertByID]
           ,arsp.[dtInsertDate]
           ,arsp.[iEditByID]
           ,arsp.[dtEditDate]
           ,arsp.[tiRowStatus]
           ,arsp.[iTeacherUserID]
           ,arsp.[DeviceUniqueID]
           ,arsp.[iUserActionID]
           ,1 AS school_progression
     FROM [RM9-DSCHEDULER\SQLEXPRESS].[RL_DISTRICT].[dbo].[ar_StudentPractice] arsp
     LEFT OUTER JOIN [RM9-DSCHEDULER\SQLEXPRESS].[RL_DISTRICT].[dbo].[rl_User]  rluser
       ON arsp.iUserID = rluser.iUserID
     WHERE arsp.[iContentTypeID] = 31
       AND arsp.chStatus != 'U'
       AND arsp.tiRowStatus = 1
    )
SELECT sub.[student_number]
      ,[iStudentPracticeID]
      ,[iUserID]
      ,[iSchoolID]
      ,[iContentID]
      ,[iClassID]
      ,[iContentTypeID]
      ,[iRLID]
      ,[iQuizNumber]
      ,[vchContentLanguage]
      ,[vchContentTitle]
      ,[vchSortTitle]
      ,[vchAuthor]
      ,[vchSeriesShortName]
      ,[vchSeriesTitle]
      ,[chContentVersion]
      ,[chFictionNonFiction]
      ,[vchInterestLevel]
      ,[dBookLevel]
      ,[iQuestionsPresented]
      ,[iQuestionsCorrect]
      ,[dAlternateBookLevel_1]
      ,[dPointsPossible]
      ,[iAlternateBookLevel_2]
      ,[dPointsEarned]
      ,[dPassingPercentage]
      ,[tiPassed]
      ,[chTWI]
      ,[tiBookRating]
      ,[tiUsedAudio]
      ,[dtTaken]
      ,[dtTakenOriginal]
      ,[tiTeacherModified]
      ,[tiPracticeDetail]
      ,[iWordCount]
      ,[dPercentCorrect]
      ,[vchSecondTryTitle]
      ,[vchSecondTryAuthor]
      ,[chStatus]
      ,[iRetakeCount]
      ,[DeviceType]
      ,[DeviceAppletID]
      ,[sDataOrigination]
      ,[tiCSImportVersion]
      ,[iInsertByID]
      ,[dtInsertDate]
      ,[iEditByID]
      ,[dtEditDate]
      ,[tiRowStatus]
      ,[iTeacherUserID]
      ,[DeviceUniqueID]
      ,[iUserActionID]
FROM
      (SELECT ar_detail.*
             ,ROW_NUMBER() OVER
               (PARTITION BY ar_detail.student_number
                            ,ar_detail.iQuizNumber
                ORDER BY ar_detail.school_progression ASC
               ) AS rn
        FROM ar_detail
       ) sub
JOIN KIPP_NJ..STUDENTS s
  ON sub.student_number = CAST(s.student_number AS varchar)
WHERE rn = 1
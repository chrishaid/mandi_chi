USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [sp_LIT$READINGSCORES|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#LIT$READINGSCORES|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#LIT$READINGSCORES|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#LIT$READINGSCORES|refresh]
		FROM OPENQUERY(PS_TEAM,'
    SELECT foreignKey AS studentid
          ,user_defined_date AS test_date
          ,foreignkey_alpha AS testid
          ,user_defined_text AS step_ltr_level            
          ,user_defined_text2 AS status
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'') AS color
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'') AS instruct_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'') AS indep_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS genre
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'') AS name_ass
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'') AS ltr_nameid
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'') AS ltr_soundid
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS pa_rhymingwds
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field11'') AS pa_mfs
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field18'') AS pa_segmentation
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field8'') AS cp_orient
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field9'') AS cp_121match
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field10'') AS cp_slw
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field12'') AS devsp_first
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field13'') AS devsp_svs
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field14'') AS devsp_final
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field31'') AS devsp_ifbd
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field37'') AS devsp_longvp
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field38'') AS devsp_rcontv
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field40'') AS devsp_vcelvp
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field41'') AS devsp_vowldig
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field42'') AS devsp_cmplxb
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field47'') AS devsp_eding
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field48'') AS devsp_doubsylj
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field49'') AS devsp_longv2sw
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field50'') AS devsp_rcont2sw
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field15'') AS rr_121match
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field16'') AS rr_holdspattern
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field17'') AS rr_understanding
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field25'') AS accuracy
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field19'') AS accuracy_1a
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field20'') AS accuracy_2b
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field28'') AS ra_errors
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field22'') AS cc_factual
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field23'') AS cc_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field24'') AS cc_other
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field26'') AS cc_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field32'') AS ocomp_factual
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field33'') AS ocomp_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field39'') AS ocomp_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field34'') AS scomp_factual
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field35'') AS scomp_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field36'') AS scomp_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field43'') AS wcomp_fact
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field44'') AS wcomp_infer
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field46'') AS wcomp_ct
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field45'') AS retelling
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field27'') AS total_vwlattmpt
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field29'') AS reading_rate
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field30'') AS fluency
          ,NULL AS fp_wpmrate
          ,NULL AS fp_fluency
          ,NULL AS fp_accuracy
          ,NULL AS fp_comp_within
          ,NULL AS fp_comp_beyond
          ,NULL AS fp_comp_about
          ,NULL AS fp_keylever
    FROM virtualtablesdata3 scores
    WHERE foreignkey_alpha > 3273
      AND related_to_table = ''readingScores'' 
      --AND user_defined_text IS NOT NULL 

    UNION ALL

    SELECT foreignKey AS studentid
          ,user_defined_date AS test_date
          ,foreignkey_alpha AS testid
          ,user_defined_text AS step_ltr_level            
          ,user_defined_text2 AS status
          ,NULL AS color
          ,NULL AS instruct_lvl
          ,NULL AS indep_lvl
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field21'') AS genre
          ,NULL AS name_ass
          ,NULL AS ltr_nameid
          ,NULL AS ltr_soundid
          ,NULL AS pa_rhymingwds
          ,NULL AS pa_mfs
          ,NULL AS pa_segmentation
          ,NULL AS cp_orient
          ,NULL AS cp_121match
          ,NULL AS cp_slw
          ,NULL AS devsp_first
          ,NULL AS devsp_svs
          ,NULL AS devsp_final
          ,NULL AS devsp_ifbd
          ,NULL AS devsp_longvp
          ,NULL AS devsp_rcontv
          ,NULL AS devsp_vcelvp
          ,NULL AS devsp_vowldig
          ,NULL AS devsp_cmplxb
          ,NULL AS devsp_eding
          ,NULL AS devsp_doubsylj
          ,NULL AS devsp_longv2sw
          ,NULL AS devsp_rcont2sw
          ,NULL AS rr_121match
          ,NULL AS rr_holdspattern
          ,NULL AS rr_understanding
          ,NULL AS accuracy
          ,NULL AS accuracy_1a
          ,NULL AS accuracy_2b
          ,NULL AS ra_errors
          ,NULL AS cc_factual
          ,NULL AS cc_infer
          ,NULL AS cc_other
          ,NULL AS cc_ct
          ,NULL AS ocomp_factual
          ,NULL AS ocomp_ct
          ,NULL AS ocomp_infer
          ,NULL AS scomp_factual
          ,NULL AS scomp_infer
          ,NULL AS scomp_ct
          ,NULL AS wcomp_fact
          ,NULL AS wcomp_infer
          ,NULL AS wcomp_ct
          ,NULL AS retelling
          ,NULL AS total_vwlattmpt
          ,NULL AS reading_rate
          ,NULL AS fluency
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'') AS fp_wpmrate
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'') AS fp_fluency
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'') AS fp_accuracy
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'') AS fp_comp_within
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'') AS fp_comp_beyond
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'') AS fp_comp_about
          ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'') AS fp_keylever           
    FROM virtualtablesdata3 scores
    WHERE foreignkey_alpha = 3273
      AND related_to_table = ''readingScores'' 
      --AND user_defined_text IS NOT NULL 
      ');
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..READINGSCORES');

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
   AND sys.objects.name = 'READINGSCORES';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[READINGSCORES]
 SELECT studentid
       ,CONVERT(DATE,test_date) AS test_date
       ,testid
       ,step_ltr_level 
       ,status
       ,color
       ,CASE
         WHEN instruct_lvl = 'aa' THEN 'AA'
         ELSE instruct_lvl
        END AS instruct_lvel
       ,CASE
         WHEN indep_lvl = 'aa' THEN 'AA'
         ELSE indep_lvl
        END AS indep_lvl
       ,genre
       ,CONVERT(FLOAT,name_ass) AS name_ass
       ,CONVERT(FLOAT,ltr_nameid) AS ltr_nameid
       ,CONVERT(FLOAT,ltr_soundid) AS ltr_soundid
       ,CONVERT(FLOAT,pa_rhymingwds) AS pa_rhymingwds
       ,CONVERT(FLOAT,pa_mfs) AS pa_mfs
       ,CONVERT(FLOAT,pa_segmentation) AS pa_segmentation
       ,CONVERT(FLOAT,cp_orient) AS cp_orient
       ,CONVERT(FLOAT,cp_121match) AS cp_121match
       ,CONVERT(FLOAT,cp_slw) AS cp_slw
       ,CONVERT(FLOAT,devsp_first) AS devsp_first
       ,CONVERT(FLOAT,devsp_svs) AS devsp_svs
       ,CONVERT(FLOAT,devsp_final) AS devsp_final
       ,CONVERT(FLOAT,devsp_ifbd) AS devsp_ifbd
       ,CONVERT(FLOAT,devsp_longvp) AS devsp_longvp
       ,CONVERT(FLOAT,devsp_rcontv) AS devsp_rcontv
       ,CONVERT(FLOAT,devsp_vcelvp) AS devsp_vcelvp
       ,CONVERT(FLOAT,devsp_vowldig) AS devsp_vowldig
       ,CONVERT(FLOAT,devsp_cmplxb) AS devsp_cmplxb
       ,CONVERT(FLOAT,devsp_eding) AS devsp_eding
       ,CONVERT(FLOAT,devsp_doubsylj) AS devsp_doubsylj
       ,CONVERT(FLOAT,devsp_longv2sw) AS devsp_longv2sw
       ,CONVERT(FLOAT,devsp_rcont2sw) AS devsp_rcont2sw
       ,CONVERT(FLOAT,rr_121match) AS rr_121match
       ,CONVERT(FLOAT,rr_holdspattern) AS rr_holdspattern
       ,CONVERT(FLOAT,rr_understanding) AS rr_understanding
       ,accuracy
       ,CONVERT(FLOAT,accuracy_1a) AS accuracy_1a
       ,CONVERT(FLOAT,accuracy_2b) AS accuracy_2b
       ,CONVERT(FLOAT,ra_errors) AS ra_errors
       ,CONVERT(FLOAT,cc_factual) AS cc_factual
       ,CONVERT(FLOAT,cc_infer) AS cc_infer
       ,CONVERT(FLOAT,cc_other) AS cc_other
       ,CONVERT(FLOAT,cc_ct) AS cc_ct
       ,CONVERT(FLOAT,ocomp_factual) AS ocomp_factual
       ,CONVERT(FLOAT,ocomp_ct) AS ocomp_ct
       ,CONVERT(FLOAT,ocomp_infer) AS ocomp_infer
       ,CONVERT(FLOAT,scomp_factual) AS scomp_factual
       ,CONVERT(FLOAT,scomp_infer) AS scomp_infer
       ,CONVERT(FLOAT,scomp_ct) AS scomp_ct
       ,CONVERT(FLOAT,wcomp_fact) AS wcomp_fact
       ,CONVERT(FLOAT,wcomp_infer) AS wcomp_infer
       ,CONVERT(FLOAT,wcomp_ct) AS wcomp_ct
       ,CONVERT(FLOAT,retelling) AS retelling
       ,CONVERT(FLOAT,total_vwlattmpt) AS total_vwlattmpt
       ,reading_rate
       ,CONVERT(FLOAT,fluency) AS fluency
       ,CONVERT(FLOAT,fp_wpmrate) AS fp_wpmrate
       ,CONVERT(FLOAT,fp_fluency) AS fp_fluency
       ,CONVERT(FLOAT,fp_accuracy) AS fp_accuracy
       ,CONVERT(FLOAT,fp_comp_within) AS fp_comp_within
       ,CONVERT(FLOAT,fp_comp_beyond) AS fp_comp_beyond
       ,CONVERT(FLOAT,fp_comp_about) AS fp_comp_about
       ,fp_keylever
       ,CONVERT(FLOAT,ISNULL(cc_factual,0)) + CONVERT(FLOAT,ISNULL(cc_other,0)) + CONVERT(FLOAT,ISNULL(cc_infer,0)) AS cc_prof1
       ,CONVERT(FLOAT,ISNULL(cc_factual,0)) + CONVERT(FLOAT,ISNULL(cc_infer,0)) + CONVERT(FLOAT,ISNULL(cc_ct,0)) AS cc_prof2
       ,CONVERT(FLOAT,ISNULL(cp_orient,0)) + CONVERT(FLOAT,ISNULL(cp_121match,0)) + CONVERT(FLOAT,ISNULL(cp_slw,0)) AS cp_prof
       ,CONVERT(FLOAT,ISNULL(devsp_first,0)) + CONVERT(FLOAT,ISNULL(devsp_svs,0)) + CONVERT(FLOAT,ISNULL(devsp_final,0)) AS devsp_prof1
       ,CONVERT(FLOAT,ISNULL(devsp_svs,0)) + CONVERT(FLOAT,ISNULL(devsp_ifbd,0)) AS devsp_prof2
       ,CONVERT(FLOAT,ISNULL(ocomp_factual,0)) + CONVERT(FLOAT,ISNULL(ocomp_ct,0)) AS ocomp_prof1
       ,CONVERT(FLOAT,ISNULL(ocomp_ct,0)) + CONVERT(FLOAT,ISNULL(ocomp_infer,0)) + CONVERT(FLOAT,ISNULL(ocomp_factual,0)) AS ocomp_prof2
       ,CONVERT(FLOAT,ISNULL(rr_121match,0)) + CONVERT(FLOAT,ISNULL(rr_holdspattern,0)) + CONVERT(FLOAT,ISNULL(rr_understanding,0)) AS rr_prof
       ,CONVERT(FLOAT,ISNULL(scomp_factual,0)) + CONVERT(FLOAT,ISNULL(scomp_infer,0)) + CONVERT(FLOAT,ISNULL(scomp_ct,0)) AS scomp_prof
       ,CONVERT(FLOAT,ISNULL(wcomp_fact,0)) + CONVERT(FLOAT,ISNULL(wcomp_infer,0)) + CONVERT(FLOAT,ISNULL(wcomp_ct,0)) AS wcomp_prof
       ,CONVERT(FLOAT,ISNULL(fp_comp_within,0)) + CONVERT(FLOAT,ISNULL(fp_comp_beyond,0)) + CONVERT(FLOAT,ISNULL(fp_comp_about,0)) AS fp_comp_prof
 FROM [#LIT$READINGSCORES|refresh];

 -- Step 4: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'READINGSCORES';

 EXEC (@sql);
  
END
GO
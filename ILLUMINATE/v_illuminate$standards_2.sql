USE Illuminate_mirror
GO

CREATE VIEW standards AS

SELECT *
FROM OPENQUERY(ILL_CHI, '
  SELECT subj.document
        ,subj.year
        ,subj.code
        ,subj.title AS std_title
        ,cat.title AS cat_title
        ,cat.lo
        ,cat.hi
        ,st.state_num
        ,st.custom_code
        ,st.label
        ,st.description
        ,st.seq
        ,st.level
        ,st.linkable
        ,st.lft
        ,st.rgt
        ,st.standard_id
        ,st.parent_standard_id
  FROM standards.standards st
  JOIN standards.categories cat
    ON st.category_id = cat.category_id
  JOIN standards.subjects subj
    ON st.subject_id = subj.subject_id
  ')
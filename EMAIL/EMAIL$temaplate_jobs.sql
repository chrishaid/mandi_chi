USE [KIPP_Silo]
GO
 
/****** Object:  Table [dbo].[EMAIL$template_jobs]    Script Date: 11/12/2014 17:23:44 ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
SET ANSI_PADDING ON
GO
 
CREATE TABLE [dbo].[EMAIL$template_jobs](
                [id] [int] IDENTITY(1,1) NOT NULL,
                [job_name] [nchar](100) NOT NULL,
                [email_recipients] [nvarchar](4000) NOT NULL,
                [email_subject] [nvarchar](4000) NOT NULL,
                [send_again] [nvarchar](4000) NULL,
                [stat_count] [tinyint] NULL,
                [stat_query1] [nvarchar](max) NULL,
                [stat_query2] [nvarchar](max) NULL,
                [stat_query3] [nvarchar](max) NULL,
                [stat_query4] [nvarchar](max) NULL,
                [stat_label1] [nvarchar](50) NULL,
                [stat_label2] [nvarchar](50) NULL,
                [stat_label3] [nvarchar](50) NULL,
                [stat_label4] [nvarchar](50) NULL,
                [image_count] [tinyint] NULL,
                [image_path1] [nvarchar](4000) NULL,
                [image_path2] [nvarchar](4000) NULL,
                [explanatory_text1] [nvarchar](max) NULL,
                [explanatory_text2] [nvarchar](max) NULL,
                [explanatory_text3] [nvarchar](max) NULL,
                [explanatory_text4] [nvarchar](max) NULL,
                [explanatory_text5] [nvarchar](max) NULL,
                [csv_toggle] [varchar](3) NULL,
                [csv_query] [nvarchar](max) NULL,
                [additional_attachment] [nvarchar](4000) NULL,
                [table_query1] [nvarchar](max) NULL,
                [table_query2] [nvarchar](max) NULL,
                [table_query3] [nvarchar](max) NULL,
                [table_query4] [nvarchar](max) NULL,
                [table_style1] [nvarchar](20) NULL,
                [table_style2] [nvarchar](20) NULL,
                [table_style3] [nvarchar](20) NULL,
                [table_style4] [nvarchar](20) NULL
) ON [PRIMARY]
 
GO
 
SET ANSI_PADDING OFF
GO
USE [KIPP_Silo]
GO
 
/****** Object:  Table [dbo].[EMAIL$template_queue]    Script Date: 11/12/2014 17:24:24 ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [dbo].[EMAIL$template_queue](
                [id] [int] IDENTITY(1,1) NOT NULL,
                [job_name] [nchar](100) NULL,
                [run_type] [nchar](20) NULL,
                [send_at] [datetime] NULL,
                [sent] [tinyint] NULL,
                [sent_at] [datetime] NULL
) ON [PRIMARY]
 
GO
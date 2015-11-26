CREATE TABLE [dbo].[Questions] (
	[Id]    INT            IDENTITY (1, 1) NOT NULL,
	[Title] NVARCHAR (200) NOT NULL,
	PRIMARY KEY CLUSTERED ([Id] ASC)
);

CREATE TABLE [dbo].[Grades] (
	[Id]         INT      IDENTITY (1, 1) NOT NULL,
	[Date]       DATETIME NOT NULL,
	[QuestionId] INT      NOT NULL,
	[Answer]     INT      NOT NULL,
	[Week]       INT      NOT NULL,
	PRIMARY KEY CLUSTERED ([Id] ASC),

	CONSTRAINT [FK_Grades_Questions] FOREIGN KEY ([QuestionId]) REFERENCES [dbo].[Questions] ([Id])
);

insert into [dbo].Questions (Title) values('Hur roligt har du haft det?');
insert into [dbo].Questions (Title) values('Hur nöjd är du med egen insats/prestation?');
insert into [dbo].Questions (Title) values('Hur nöjd är du med teamets samarbete och förmåga att arbeta tillsammans?');
insert into [dbo].Questions (Title) values('Hur bra förutsättningar har teamet haft?');
insert into [dbo].Questions (Title) values('Hur hög arbetsro rådde under perioden (avsaknad av störningar)?');

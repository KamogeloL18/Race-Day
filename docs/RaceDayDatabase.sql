IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDayDB')
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    PhoneNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Participants (
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    DateOfBirth DATE NOT NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    PhoneNumber NVARCHAR(20) NULL,
    EmergencyContact NVARCHAR(255) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Participants_Users FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE TABLE Organisers (
    OrganiserID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    CompanyName NVARCHAR(255) NULL,
    OrganisationPhoneNumber NVARCHAR(20) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Organisers_Users FOREIGN KEY (UserID) 
        REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(255) NOT NULL,
    Distance DECIMAL(10,2) NOT NULL,
    EventType NVARCHAR(20) NOT NULL CHECK (EventType IN ('Run', 'Walk', 'Cycle')),
    BannerImage NVARCHAR(500) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1,
    
    CONSTRAINT FK_Events_Organisers FOREIGN KEY (OrganiserID) 
        REFERENCES Organisers(OrganiserID) ON DELETE CASCADE
);
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    MinAge INT NULL,
    MaxAge INT NULL,
    Distance DECIMAL(10,2) NULL,
    EntryFee DECIMAL(10,2) NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) 
        REFERENCES Events(EventID) ON DELETE CASCADE
);
GO

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending' 
        CHECK (Status IN ('Pending', 'Confirmed', 'Completed', 'Cancelled')),
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Unpaid'
        CHECK (PaymentStatus IN ('Unpaid', 'Paid', 'Refunded')),
    
    CONSTRAINT FK_Enrolments_Participants FOREIGN KEY (ParticipantID) 
        REFERENCES Participants(ParticipantID) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventID) 
        REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) 
        REFERENCES Categories(CategoryID),
    
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE (ParticipantID, EventID)
);
GO

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE,
    FinishTime TIME NULL,
    Position INT NULL,
    IsCompleted BIT NOT NULL DEFAULT 0,
    Notes NVARCHAR(500) NULL,
    RecordedAt DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) 
        REFERENCES Enrolments(EnrolmentID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Events_EventDate ON Events(EventDate);
CREATE INDEX IX_Events_EventType ON Events(EventType);
CREATE INDEX IX_Events_OrganiserID ON Events(OrganiserID);
CREATE INDEX IX_Categories_EventID ON Categories(EventID);
CREATE INDEX IX_Enrolments_ParticipantID ON Enrolments(ParticipantID);
CREATE INDEX IX_Enrolments_EventID ON Enrolments(EventID);
CREATE INDEX IX_Enrolments_Status ON Enrolments(Status);
CREATE INDEX IX_Results_EnrolmentID ON Results(EnrolmentID);
GO

INSERT INTO Users (Email, PasswordHash, FullName, Role, PhoneNumber, CreatedAt, IsActive)
VALUES 
    ('thabo.mokoena@raceday.co.za', 'hashed_password_1', 'Thabo Mokoena', 'Organiser', '0821234567', GETDATE(), 1),
    ('lindiwe.nkosi@raceday.co.za', 'hashed_password_2', 'Lindiwe Nkosi', 'Organiser', '0839876543', GETDATE(), 1),
    ('sipho.dlamini@gmail.com', 'hashed_password_3', 'Sipho Dlamini', 'Participant', '0712345678', GETDATE(), 1),
    ('zanele.mthembu@gmail.com', 'hashed_password_4', 'Zanele Mthembu', 'Participant', '0723456789', GETDATE(), 1),
    ('kabelo.moloi@gmail.com', 'hashed_password_5', 'Kabelo Moloi', 'Participant', '0734567890', GETDATE(), 1),
    ('lebo.masango@gmail.com', 'hashed_password_6', 'Lebo Masango', 'Participant', '0745678901', GETDATE(), 1);
GO

INSERT INTO Organisers (UserID, CompanyName, OrganisationPhoneNumber, CreatedAt)
VALUES 
    (1, 'Comrades Marathon Association', '0311234567', GETDATE()),
    (2, 'Cape Town Cycle Tour Trust', '0219876543', GETDATE());
GO

INSERT INTO Participants (UserID, DateOfBirth, Gender, PhoneNumber, EmergencyContact, CreatedAt)
VALUES 
    (3, '1990-05-15', 'Male', '0712345678', 'Mary Dlamini - 0712345679', GETDATE()),
    (4, '1985-08-22', 'Female', '0723456789', 'Thabo Mthembu - 0723456790', GETDATE()),
    (5, '1995-11-30', 'Male', '0734567890', 'Palesa Moloi - 0734567891', GETDATE()),
    (6, '1988-03-10', 'Female', '0745678901', 'Nomsa Masango - 0745678902', GETDATE());
GO

INSERT INTO Events (OrganiserID, Name, Description, EventDate, Location, Distance, EventType, BannerImage, CreatedAt, IsActive)
VALUES 
    (
        1, 
        'Comrades Marathon 2026', 
        'The Ultimate Human Race - A 90km ultra-marathon from Pietermaritzburg to Durban.',
        '2026-06-15 05:30:00',
        'Pietermaritzburg to Durban, KwaZulu-Natal',
        90.00,
        'Run',
        'https://storage.blob.core.windows.net/events/comrades2026.jpg',
        GETDATE(),
        1
    ),
    (
        2,
        'Cape Town Cycle Tour 2026',
        'The world''s largest timed cycling event - 109km scenic route around the Cape Peninsula.',
        '2026-03-10 06:00:00',
        'Cape Town, Western Cape',
        109.00,
        'Cycle',
        'https://storage.blob.core.windows.net/events/ctct2026.jpg',
        GETDATE(),
        1
    ),
    (
        2,
        'Two Oceans Marathon 2026',
        'The world''s most beautiful marathon - 56km ultra-marathon along the Cape Peninsula.',
        '2026-04-18 05:30:00',
        'Cape Town, Western Cape',
        56.00,
        'Run',
        'https://storage.blob.core.windows.net/events/twooceans2026.jpg',
        GETDATE(),
        1
    );
GO

INSERT INTO Categories (EventID, Name, Description, MinAge, MaxAge, Distance, EntryFee, CreatedAt)
VALUES 
    (1, 'Senior Men', 'Open category for male runners aged 20-39', 20, 39, NULL, 850.00, GETDATE()),
    (1, 'Senior Women', 'Open category for female runners aged 20-39', 20, 39, NULL, 850.00, GETDATE()),
    (1, '40-49 Men', 'Masters category for men aged 40-49', 40, 49, NULL, 750.00, GETDATE()),
    (1, '40-49 Women', 'Masters category for women aged 40-49', 40, 49, NULL, 750.00, GETDATE()),
    (1, '50+ Men', 'Grand Masters category for men aged 50+', 50, 99, NULL, 650.00, GETDATE()),
    (1, '50+ Women', 'Grand Masters category for women aged 50+', 50, 99, NULL, 650.00, GETDATE()),
    (2, '18-30 Years', 'Competitive category for cyclists aged 18-30', 18, 30, NULL, 550.00, GETDATE()),
    (2, '31-45 Years', 'Competitive category for cyclists aged 31-45', 31, 45, NULL, 550.00, GETDATE()),
    (2, '46-60 Years', 'Competitive category for cyclists aged 46-60', 46, 60, NULL, 500.00, GETDATE()),
    (2, '60+ Years', 'Competitive category for cyclists aged 60+', 60, 99, NULL, 450.00, GETDATE()),
    (3, 'Under 20', 'Category for athletes under 20 years', 10, 19, NULL, 400.00, GETDATE()),
    (3, 'Senior', 'Open category for athletes aged 20-39', 20, 39, NULL, 600.00, GETDATE()),
    (3, '40-49 Years', 'Category for athletes aged 40-49', 40, 49, NULL, 550.00, GETDATE()),
    (3, '50+ Years', 'Category for athletes aged 50+', 50, 99, NULL, 450.00, GETDATE());
GO

INSERT INTO Enrolments (ParticipantID, EventID, CategoryID, EnrolmentDate, Status, PaymentStatus)
VALUES 
    (1, 1, 1, DATEADD(DAY, -30, GETDATE()), 'Confirmed', 'Paid'),
    (1, 2, 7, DATEADD(DAY, -20, GETDATE()), 'Confirmed', 'Paid'),
    (2, 1, 2, DATEADD(DAY, -25, GETDATE()), 'Confirmed', 'Paid'),
    (2, 3, 12, DATEADD(DAY, -15, GETDATE()), 'Pending', 'Unpaid'),
    (3, 1, 3, DATEADD(DAY, -10, GETDATE()), 'Pending', 'Unpaid'),
    (3, 2, 8, DATEADD(DAY, -5, GETDATE()), 'Pending', 'Unpaid'),
    (4, 2, 7, DATEADD(DAY, -40, GETDATE()), 'Completed', 'Paid'),
    (4, 3, 11, DATEADD(DAY, -35, GETDATE()), 'Completed', 'Paid');
GO

INSERT INTO Results (EnrolmentID, FinishTime, Position, IsCompleted, Notes, RecordedAt)
VALUES 
    (7, '03:45:30', 47, 1, 'Finished strong, great time', GETDATE()),
    (8, '05:12:15', 312, 1, 'Paced well throughout', GETDATE());
GO
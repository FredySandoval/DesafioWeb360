IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'MiTienditaDB')
BEGIN
    CREATE DATABASE MiTienditaDB;
    PRINT 'Database MiTienditaDB has been created.';
END
ELSE
BEGIN
    PRINT 'Database MiTienditaDB already exists.';
END
GO

USE MiTienditaDB;
GO

DROP TABLE IF EXISTS Users
DROP TABLE IF EXISTS UserRoles
DROP TABLE IF EXISTS UserStatus

CREATE TABLE UserRoles (
    RoleID      INT PRIMARY KEY,
    RoleName    NVARCHAR(15) UNIQUE NOT NULL, -- Cliente, Operador, Admin.
    Description NVARCHAR(255) UNIQUE NOT NULL,
);
GO
CREATE TABLE UserStatus (
    StatusID    INT PRIMARY KEY,
    StatusName  NVARCHAR(50)  UNIQUE NOT NULL, -- active, pending, suspended, deleted
    Description NVARCHAR(255) UNIQUE NOT NULL,
);
GO
CREATE TABLE Users (
    UserID         INT IDENTITY(1,1) PRIMARY KEY,
    FirstName      NVARCHAR(50)  NOT NULL,
    LastName       NVARCHAR(50)  NOT NULL,
    Email          NVARCHAR(100) UNIQUE NOT NULL,
    DateOfBirth    DATETIME      NOT NULL,
    PasswordHash   NVARCHAR(255) NOT NULL,
    createdAt      DATETIME      NOT NULL DEFAULT GETDATE(),
    updatedAt      DATETIME      NOT NULL DEFAULT GETDATE(),
    ProfilePicture NVARCHAR(255),
    StatusID       INT,  -- Foreign key column to link to UserStatus
    RoleID         INT,
    CONSTRAINT FK_UserStatus FOREIGN KEY (StatusID) REFERENCES UserStatus(StatusID),
    CONSTRAINT FK_UserRoles  FOREIGN KEY (RoleID)   REFERENCES UserRoles(RoleID),
);
GO

INSERT INTO UserRoles (RoleID, RoleName, Description)
VALUES 
    (1, 'Client',   'Standard user with access to basic features'),
    (2, 'Operator', 'User with additional privileges to manage operations'),
    (3, 'Admin',    'User with full administrative privileges');
GO
INSERT INTO UserStatus (StatusID, StatusName, Description)
VALUES 
    (1, 'Active',    'User is active and has full access'),
    (2, 'Pending',   'User account is pending verification or activation'),
    (3, 'Suspended', 'User account is temporarily suspended'),
    (4, 'Deleted',   'User account is deleted');
GO

INSERT INTO Users (FirstName, LastName, Email, DateOfBirth, PasswordHash, ProfilePicture,StatusID, RoleID)
VALUES
    ('John',  'Doe',   'johndoe@example.com',   '1985-04-15', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 1, 1),  -- Client
    ('Jane',  'Smith', 'janesmith@example.com', '1990-09-25', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 1, 2),  -- Operator
    ('name1', 'name1', '12345@example.com',     '1980-01-01', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 2, 1),  -- Admin
    ('name2', 'name2', '1234455@example.com',    '1980-01-01','$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS', 'img.png', 3, 3),  -- Admin
    ('Admin', 'User',  'admin@example.com',     '1980-01-01', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 4, 3);  -- Admin
GO
-- myPassword
DROP VIEW vw_Users;
GO
CREATE VIEW vw_Users AS
SELECT 
    UserID,
    FirstName,
    LastName,
    Email,      
    DateOfBirth,
    createdAt,
    updatedAt,
    ProfilePicture,
    StatusID,
    RoleID
FROM
    Users;
GO

DROP VIEW vw_UserPassword;
GO
CREATE VIEW vw_UserPassword AS
SELECT
    UserID,
    FirstName,
    LastName,
    Email,
    PasswordHash,
    StatusID,
    RoleID
FROM
    Users;
GO
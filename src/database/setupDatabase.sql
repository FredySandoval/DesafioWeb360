DROP DATABASE MiTienditaDB;
GO
CREATE DATABASE MiTienditaDB;
GO
USE MiTienditaDB;
GO

-- DROP TABLE IF EXISTS UserRoles;
-- GO
-- DROP TABLE IF EXISTS UserStatus;
-- GO
-- DROP TABLE IF EXISTS Users;
-- GO
-- DROP TABLE IF EXISTS ProductCategories;
-- DROP TABLE IF EXISTS Clients;
-- DROP TABLE IF EXISTS UserActivityLog;
-- DROP TABLE IF EXISTS Order;
-- DROP TABLE IF EXISTS Products
-- DROP TABLE IF EXISTS OrderDetails;
-- DROP TABLE IF EXISTS ProductImages;


CREATE TABLE UserRoles (
    RoleID          INT PRIMARY KEY,
    RoleName        NVARCHAR(15) UNIQUE NOT NULL, -- Cliente, Operador, Admin.
    Description NVARCHAR(255) UNIQUE NOT NULL
);
GO
CREATE TABLE UserStatus (
    StatusID          INT PRIMARY KEY,
    StatusName        NVARCHAR(50)  UNIQUE NOT NULL, -- active, pending, suspended, deleted
    Description NVARCHAR(255) UNIQUE NOT NULL
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

CREATE TABLE Clients (
    ClientID         INT IDENTITY(1,1) PRIMARY KEY,
    UserID           INT UNIQUE NOT NULL,
    PhoneNumber      NVARCHAR(8),
    DeliveryAddress  NVARCHAR(255) NOT NULL,
    SocialReason     NVARCHAR(50)  NULL,
    CommercialName   NVARCHAR(50)  NULL,
    Notes            NVARCHAR(255) NULL,
    CONSTRAINT FK_Clients FOREIGN KEY (UserID) REFERENCES Users(UserID),
);
GO

CREATE TABLE UserActivityLog (
    UserActivityLogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID            INT NOT NULL,
    CreatedAt         DATETIME NOT NULL,
    CreatedBy         INT,          -- References Users.UserID (likely an admin)
    UpdatedAt         DATETIME,
    UpdatedBy         INT,          -- References Users.UserID
    LastLoginAt       DATETIME,
    CONSTRAINT FK_UserAudit_User      FOREIGN KEY (UserID)    REFERENCES Users(UserID),
    CONSTRAINT FK_UserAudit_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    CONSTRAINT FK_UserAudit_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
);
GO
CREATE TABLE Orders (
    OrderID         INT IDENTITY(1,1) PRIMARY KEY,
    ClientID        INT NOT NULL,
    CreationDate    DATETIME DEFAULT GETDATE(),
    DeliveredDate   DATETIME NULL,
    Email           NVARCHAR(100) NULL,
    PhoneNumber     NVARCHAR(8),
    TotalOrden      DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Order FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
);
GO
CREATE TABLE ProductCategories (
    CategoryID          INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName        NVARCHAR(50) NOT NULL UNIQUE,
    CategoryDescription NVARCHAR(100),
);
GO
CREATE TABLE Products (
    ProductID          INT IDENTITY(1,1) PRIMARY KEY,
    ProductName        NVARCHAR(100) NOT NULL,
    ProductBrand       NVARCHAR(100) NOT NULL,
    ProductDescription NVARCHAR(255),
    ProductCode        NVARCHAR(100),
    Price              DECIMAL(10,2) NOT NULL,
    Stock              INT NOT NULL DEFAULT 0,
    CreationDate       DATETIME DEFAULT GETDATE(),
    UpdatedAt          DATETIME,
    CategoryID         INT,
    CONSTRAINT FK_Products FOREIGN KEY (CategoryID) REFERENCES ProductCategories(CategoryID)
);
GO

CREATE TABLE OrderDetails (
    OrderDetailsID   INT IDENTITY(1,1) PRIMARY KEY,
    OrderID          INT NOT NULL,
    QuantityTotal    INT NOT NULL,
    TotalPrice       DECIMAL(10,2) NOT NULL,
    ProductID        INT NOT NULL,
    CONSTRAINT FK_Details              FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Product FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
);
GO
CREATE TABLE ProductImages (
    ImageID           INT IDENTITY(1,1) PRIMARY KEY,
    ProductID         INT,
    ImagePath         NVARCHAR(255),
    CONSTRAINT FK_Images FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
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
-- 
INSERT INTO Users (FirstName, LastName, Email, DateOfBirth, PasswordHash, ProfilePicture,StatusID, RoleID)
VALUES
    ('John',  'Doe',   'johndoe@example.com',   '1985-04-15', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 1, 1),  -- Client
    ('Jane',  'Smith', 'janesmith@example.com', '1990-09-25', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 1, 2),  -- Operator
    ('name1', 'name1', '12345@example.com',     '1980-01-01', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 2, 1),  -- Admin
    ('name2', 'name2', '1234455@example.com',    '1980-01-01','$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS', 'img.png', 3, 3),  -- Admin
    ('Admin', 'User',  'admin@example.com',     '1980-01-01', '$2b$10$.q2IXr7jrVLb0/CNLP5FVOUIuLWIGzC6aCP.Y6cnFjQxzBi6KtUUS',  'img.png', 4, 3);  -- Admin
GO
-- myPassword
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
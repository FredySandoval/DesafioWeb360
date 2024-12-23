USE MiTienditaDB;
GO

CREATE PROCEDURE CreateUser
    @UserJson NVARCHAR(MAX)
AS
BEGIN
    DECLARE @FirstName NVARCHAR(50),
            @LastName NVARCHAR(50),
            @Email NVARCHAR(100),
            @DateOfBirth DATETIME,
            @PasswordHash NVARCHAR(255),
            @ProfilePicture NVARCHAR(255) = NULL,
            @StatusID INT,
            @RoleID INT;

    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        -- Parse JSON input to extract user details
        SELECT 
            @FirstName = FirstName,
            @LastName = LastName,
            @Email = Email,
            @DateOfBirth = DateOfBirth,
            @PasswordHash = PasswordHash,
            @ProfilePicture = ProfilePicture,
            @StatusID = StatusID,
            @RoleID = RoleID
        FROM OPENJSON(@UserJson)
        WITH (
            FirstName NVARCHAR(50) '$.FirstName',
            LastName NVARCHAR(50) '$.LastName',
            Email NVARCHAR(100) '$.Email',
            DateOfBirth DATETIME '$.DateOfBirth',
            PasswordHash NVARCHAR(255) '$.PasswordHash',
            ProfilePicture NVARCHAR(255) '$.ProfilePicture',
            StatusID INT '$.StatusID',
            RoleID INT '$.RoleID'
        );

        -- Insert into Users table
        INSERT INTO Users (
            FirstName, LastName, Email, DateOfBirth, PasswordHash, ProfilePicture, StatusID, RoleID
        )
        VALUES (
            @FirstName, @LastName, @Email, @DateOfBirth, @PasswordHash, @ProfilePicture, @StatusID, @RoleID
        );

        -- Commit transaction
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        -- Rollback the transaction in case of error
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Throw the error caught
        DECLARE @ErrorMessage NVARCHAR(4000), 
                @ErrorSeverity INT, 
                @ErrorState INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
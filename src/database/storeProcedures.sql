USE MiTienditaDB;
GO

CREATE OR ALTER PROCEDURE CreateUser
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
-- UPDATE STATUS
CREATE OR ALTER PROCEDURE UpdateUserStatus
    @UpdateStatusJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserID INT,
            @NewStatusID INT;
            
    BEGIN TRY
        -- Validate JSON input
        IF ISJSON(@UpdateStatusJson) = 0
        BEGIN
            THROW 50000, 'Invalid JSON format.', 1;
        END

        BEGIN TRANSACTION;
        
        -- Parse JSON and extract values
        SELECT 
            @UserID = UserID,
            @NewStatusID = NewStatusID
        FROM OPENJSON(@UpdateStatusJson)
        WITH (
            UserID INT '$.UserID',
            NewStatusID INT '$.NewStatusID'
        );

        -- Validate parsed values
        IF @UserID IS NULL OR @NewStatusID IS NULL
        BEGIN
            THROW 50003, 'Missing required fields in JSON (UserID or NewStatusID).', 1;
        END

        -- Debug information
        PRINT 'Attempting update with:';
        PRINT 'UserID: ' + CAST(@UserID AS VARCHAR(20));
        PRINT 'NewStatusID: ' + CAST(@NewStatusID AS VARCHAR(20));

        -- Check if user exists
        IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
        BEGIN
            THROW 50001, 'User not found.', 1;
        END

        -- Check if status is valid
        IF NOT EXISTS (SELECT 1 FROM UserStatus WHERE StatusID = @NewStatusID)
        BEGIN
            THROW 50002, 'Invalid status ID.', 1;
        END

        -- Perform the update
        UPDATE Users
        SET StatusID = @NewStatusID,
            UpdatedAt = GETUTCDATE()
        WHERE UserID = @UserID;

        -- Check if update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            THROW 50004, 'Update failed - no rows affected.', 1;
        END

        COMMIT TRANSACTION;

        -- Return success message
        SELECT 'Status updated successfully' AS Result;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        DECLARE @ErrorMessage NVARCHAR(4000), 
                @ErrorSeverity INT, 
                @ErrorState INT,
                @ErrorLine INT,
                @ErrorNumber INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorLine = ERROR_LINE(),
            @ErrorNumber = ERROR_NUMBER();

        -- Provide detailed error information
        SELECT 
            @ErrorMessage AS ErrorMessage,
            @ErrorNumber AS ErrorNumber,
            @ErrorLine AS ErrorLine,
            @ErrorSeverity AS ErrorSeverity,
            @ErrorState AS ErrorState;

        -- Optionally, you can use RAISERROR or THROW
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
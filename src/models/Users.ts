import { Model, DataTypes } from "sequelize";
import sequelize from "../database/databaseConnection";

class Users extends Model {}

Users.init(
    {
        UserID:         { type: DataTypes.INTEGER, primaryKey: true },
        FirstName:      DataTypes.STRING,
        LastName:       DataTypes.STRING,
        Email:          DataTypes.STRING,
        DateOfBirth:    DataTypes.STRING,
        CreatedAt:      DataTypes.DATE,
        UpdatedAt:      DataTypes.DATE,
        ProfilePicture: DataTypes.STRING,
        StatusID:       DataTypes.INTEGER,
        RoleID:         DataTypes.INTEGER,
    },
    {
        sequelize,
        tableName: 'vw_Users',
        timestamps: false,
        freezeTableName: true,
    }
)
class UserPassword extends Model {} 
UserPassword.init(
    {
        UserID: { type: DataTypes.INTEGER, primaryKey: true },
        FirstName:    DataTypes.STRING,
        LastName:     DataTypes.STRING,
        Email:        DataTypes.STRING,
        PasswordHash: DataTypes.STRING,
        StatusID:     DataTypes.INTEGER,
        RoleID:       DataTypes.INTEGER

    },
    {
        sequelize,
        tableName: 'vw_UserPassword',
        timestamps: false,
        freezeTableName: true,
    }
)

export { Users, UserPassword }
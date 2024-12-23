import express from 'express';
import { getUsers } from '../controllers/userController';
import { loginSchemaValidation, userSchemaValidation } from '../middleware/schemaValidation';
import { login, logout } from '../controllers/authController';
import { verifyToken } from '../middleware/authToken';
import bcrypt from 'bcrypt';
import sequelize from '../database/databaseConnection';
import { QueryTypes } from 'sequelize';
const router = express.Router();

router.get('/users', userSchemaValidation, getUsers);
router.post('/login', loginSchemaValidation, login)
router.post('/logout', verifyToken, logout)


router.post('/users', async (req, res) => {
    enum Status {
        active = 1,
        pending,
        suspended, 
        deleted,   
    };
    enum Roles {
        client = 1,
        operator,
        admin,
    }
    const { 
        firstName,
        lastName,
        email,
        password,
        dateOfBirth,
        profilePicture,
        status,
        role,
    } = req.body;
    
    const passwordHash = await bcrypt.hash(password, 10)
    const userData = {
        FirstName:    firstName,
        LastName:     lastName,
        Email:        email,
        DateOfBirth:  dateOfBirth, //'1990-01-01T00:00:00Z'
        PasswordHash: passwordHash,  // Ensure the password is hashed
        ProfilePicture: profilePicture,
        StatusID: Status[status],
        RoleID:   Roles[role]
    };
    const userJson = JSON.stringify(userData);
    try {
        const result = await sequelize.query('EXEC CreateUser @UserJson = :userJson', {replacements:{userJson}, type: QueryTypes.RAW })
        res.json({ result })
    } catch (error) {
        res.status(409).json({ error: true, message: 'c/ unable to create user'})
    }
})

export default router;

import express from 'express';
import { createUser, getUsers, updateUserStatus } from '../controllers/userController';
import { loginSchemaValidation, userSchemaValidation } from '../middleware/schemaValidation';
import { login, logout } from '../controllers/authController';
import { verifyToken } from '../middleware/authToken';
const router = express.Router();

router.post('/login', loginSchemaValidation, login);
router.post('/logout', verifyToken, logout);
router.post('/users', verifyToken, createUser);
router.get('/users', verifyToken, userSchemaValidation, getUsers);
router.patch('/users/:id/status', verifyToken, updateUserStatus); 

export default router;

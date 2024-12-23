import bcrypt from 'bcrypt';
import { UserPassword } from '../models/Users';
import jwt from 'jsonwebtoken';
import { UserCache } from './casheService';

const loginService = async (email, password) => {
    const cashe = UserCache.getInstance();
    let user = cashe.get(email);
    if (!user) {
        const userResult = await UserPassword.findAll({
            where: { email },
        });
        if (!userResult || userResult.length == 0) return { error: true, user: {}, message: 'not found'}
        user = userResult[0]
        cashe.set(email, user)
    }
    
    const passwordHash = user.PasswordHash;
    const isPasswordValid = await bcrypt.compare(password, passwordHash);

    if (!isPasswordValid) return { error: true, user: {}, message: 's/s/a/l 01 invalid password'}

    const token = jwt.sign(
        {
            userId: user.UserID,
            role:   user.RoleID
        },
        process.env.JWT_SECRET,
        { expiresIn: '24h'}
    )
    return {
        token,
        user: {
            UserID:    user.UserID,
            FirstName: user.FirstName,
            LastName:  user.LastName,
            email:     user.email,
            role:      user.RoleID,
            StatusID:  user.StatusID,
        }
    }

}

export { loginService }; 
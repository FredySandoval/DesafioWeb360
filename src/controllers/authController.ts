import { Request, Response } from 'express';
import { loginService } from '../services/authService';

const login = async (req:Request, res:Response) => {
    const { email, password, } = req.body;

    try {
        const result = await loginService(email, password);
        if (result.error) return res.status(401).json(result);

        return res.status(200).json(result);
    } catch (error) {
        return res.status(500).json({success: false, message: 'c/a/l/01-internal error'})
    }
}

const logout = async (req:Request, res:Response) => {
    res.clearCookie('jwt', {
        httpOnly: true,
        secure: false, 
        sameSite: 'strict'
    })
    res.status(200).json({
        success: true,
        message: 'Deslogeado correctamented'
    })
}
export { login , logout};
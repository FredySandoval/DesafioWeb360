import { NextFunction, Request, Response } from "express";
import Joi from "joi";
import { Status, Roles } from "../controllers/userController";

const userQuerySchema = Joi.object({
  firstname: Joi.string().max(50).optional().trim(),
  lastname: Joi.string().max(50).optional().trim(),
  email: Joi.string().max(50).optional().trim(),
  status: Joi.string().optional().trim().valid(...Object.keys(Status).filter(key => isNaN(Number(key)))),
  role: Joi.string().optional().trim().valid(...Object.keys(Roles).filter(key => isNaN(Number(key)))),
  limit: Joi.number().optional().min(0).max(100),
  page: Joi.number().optional().min(0).max(40),
})

const loginQuerySchema = Joi.object({
  email: Joi.string().max(50).trim().required(),
  password: Joi.string().pattern(new RegExp('^[a-zA-Z0-9]{3,30}$')).min(8).max(50).required(),
})

const queryValidation = (schema, obj) => {
  const {error} = schema.validate(obj, { abortEarly: false });
  const test  =  schema.validate(obj, { abortEarly: false });
  console.log('test', test);
  
  if (error) {
    console.log(1);
    
    return { error: true, message: error}
  }
  return null;
}
const userSchemaValidation = (req: Request, res: Response, next: NextFunction) => {
  const error = queryValidation(userQuerySchema, req.query)
  if (error) return res.status(400).json({ error })
  next();
}
const loginSchemaValidation = (req: Request, res: Response, next: NextFunction) => {
  const error = queryValidation(loginQuerySchema, req.body)
  if (error) return res.status(400).json({ error })
  next();
}


export { userSchemaValidation, loginSchemaValidation };
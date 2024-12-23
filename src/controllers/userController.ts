import { Request, Response } from 'express';
import { Users } from '../models/Users'
import { Op, QueryTypes } from 'sequelize';
import bcrypt from 'bcrypt';
import sequelize from '../database/databaseConnection';

type UserQueryParams = {
  status?: string;
  role?: string;
  page?: number;
  limit?: number;
  email?: string;
}
export enum Status {
  active = 1,
  pending,
  suspended,
  deleted,
}
export enum Roles {
  client = 1,
  operator,
  admin,
}
const DEFAULT_PAGE_SIZE = 10 as const;
const DEFAULT_PAGE = 1 as const;

const getUsers = async (req: Request, res: Response) => {
  const { status, role, page, limit, email } = req.query as UserQueryParams;
  const whereCondition = {};
  if (status) whereCondition.StatusID = Status[status];
  if (role) whereCondition.RoleID = Roles[role]
  if (email) whereCondition.email = { [Op.like]: `%${email}%` }


  const nLimit = Number(limit) || DEFAULT_PAGE_SIZE;
  const nPage = Number(page) || DEFAULT_PAGE;
  const offset = (nPage - 1) * nLimit;

  const activeUsers = await Users.findAll({
    where: whereCondition,
    order: [['CreatedAt', 'DESC']],
    offset: offset,
    limit: nLimit
  });
  return res.status(200).json(activeUsers);
}

const createUser = async (req: Request, res: Response) => {
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
    FirstName: firstName,
    LastName: lastName,
    Email: email,
    DateOfBirth: dateOfBirth, //'1990-01-01T00:00:00Z'
    PasswordHash: passwordHash,  // Ensure the password is hashed
    ProfilePicture: profilePicture,
    StatusID: Status[status],
    RoleID: Roles[role]
  };
  const userJson = JSON.stringify(userData);
  try {
    const result = await sequelize.query('EXEC CreateUser @UserJson = :userJson', { replacements: { userJson }, type: QueryTypes.RAW })
    res.status(200).json({ result })
  } catch (error) {

    res.status(409).json({ error: error, message: 'c/uC-1 unable to create user' })
  }
}
const updateUserStatus = async (req: Request, res: Response) => {
  const UserID = req.params.id;
  const NewStatus = (req.body.status || 'active').toLowerCase();
  
  const statusJson = JSON.stringify({
    UserID : UserID,
    NewStatusID : Status[NewStatus],
  });
  console.log(statusJson)
  try {
    const result = await sequelize.query('EXEC UpdateUserStatus @UpdateStatusJson = :statusJson', { replacements: { statusJson }, type: QueryTypes.RAW })
    res.status(200).json({ result })
  } catch (error) {
    res.status(409).json({ error: error, message: 'c/uC-2 conflict'})
  }
}
export { getUsers, createUser, updateUserStatus };
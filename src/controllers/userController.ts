import { Request, Response } from 'express';
import { Users } from '../models/Users'
import { Op } from 'sequelize';

export const UserStatus = {
  active:    1,
  pending:   2,
  suspended: 3,
  deleted:   4,
} as const;
export const UserRoles = {
  client:   1,
  operator: 2,
  admin:    3,
} as const;
type UserQueryParams = {
  status?: string;
  role?  : string; 
  page?  : number;
  limit? : number;
  email? : string;
}
const DEFAULT_PAGE_SIZE = 10 as const;
const DEFAULT_PAGE = 1 as const;

const getUsers = async (req:Request, res:Response) => {
  const { status , role, page, limit, email } = req.query as UserQueryParams;
  const whereCondition = {};
  if ( status ) whereCondition.StatusID = UserStatus[status];
  if ( role   ) whereCondition.RoleID   = UserRoles[role]
  if ( email  ) whereCondition.email    = { [ Op.like ]: `%${email}%`} 

 
  const nLimit = Number(limit) || DEFAULT_PAGE_SIZE;
  const nPage  = Number(page)  || DEFAULT_PAGE;
  const offset = (nPage - 1) * nLimit ;

  const activeUsers = await Users.findAll({
    where: whereCondition,
    order: [['CreatedAt', 'DESC']],
    offset: offset,
    limit: nLimit
  });
  return res.status(200).json(activeUsers);
}
export { getUsers };
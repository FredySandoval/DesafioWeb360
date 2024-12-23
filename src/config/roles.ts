const PERMISSIONS = {
    // USERS
    READ_USERS:   "read:users",
    EDIT_USERS:   "edit:users",
    UPDATE_USERS: "update:users",
    DELETE_USERS: "delete:users",
} as const;

const clientPermissions = [
    PERMISSIONS.READ_USERS,
] as const;

const operatorPermissions = [
    ...clientPermissions,
    PERMISSIONS.EDIT_USERS,
    PERMISSIONS.UPDATE_USERS,
    PERMISSIONS.DELETE_USERS,
] as const;

const adminPermissions = [
    ...operatorPermissions
] as const;

const rolePermissions = {
  client:   clientPermissions,
  operator: operatorPermissions,
  admin:    adminPermissions
} as const;
type PermissionValue = typeof PERMISSIONS[keyof typeof PERMISSIONS];
type ArrayPermission = PermissionValue[];
type Role = 'admin' | 'operator' | 'client';

const hasPermission = (role: Role, permissions:ArrayPermission ) => {
   return permissions.every( (permission:PermissionValue) => {return rolePermissions[role].includes(permission) })
};

hasPermission('admin', ['edit:users', 'read:users'])
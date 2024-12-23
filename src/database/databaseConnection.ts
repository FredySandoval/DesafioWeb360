import { Sequelize } from "sequelize";
const DB_HOST     = 'localhost';
const DB_PORT     = 1433;
const DB_NAME     = 'MiTienditaDB'
const DB_USER     = 'sa'
const DB_PASSWORD = 'FredySandoval1+'

const sequelize = new Sequelize(DB_NAME, DB_USER, DB_PASSWORD, {
    host: DB_HOST,
    port: DB_PORT || 1433,
    dialect: 'mssql',
    // Connection pool configuration
    pool: {
        max: 5,         // Maximum number of connection in pool
        min: 0,         // Minimum number of connection in pool
        acquire: 30000, // Maximum time to acquire a connection
        idle: 10000     // Maximum time a connection can be idle
    },
    // Logging configuration
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
    dialectOptions: {
        options: {
            encrypt: true,                // For Azure SQL Database
            trustServerCertificate: true // Set to true if using self-signed certificates
        }
    },
    timezone: '-06:00' // Guatemala
});
async function testConnection() {
    try {
        await sequelize.authenticate();
        console.log('Database connection has been established successfully.');
    } catch (error) {
        console.error('Unable to connect to the database:', error);
        process.exit(1); // Exit the process if database connection fails
    }
}
// Call connection test
testConnection();
export default sequelize;

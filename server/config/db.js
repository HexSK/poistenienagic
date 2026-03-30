const mysql = require("mysql2/promise");

async function createDbConnection() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER || process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        database: process.env.DB || process.env.DB_NAME,
    });

    console.log("MySQL Connected");
    return connection;
}

module.exports = {
    createDbConnection,
};


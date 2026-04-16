const express = require("express");
const { createAuthRouter } = require("./authRoutes");
const { createUserRouter } = require("./userRoutes");
const { createAdminRouter } = require("./adminRoutes");

function createApiRouter() {
    const router = express.Router();

    router.get("/test1", async (req, res) => {
        const connection = await require("../config/db").getDbConnection();
        try {
            const [rows] = await connection.query("SELECT * FROM uzivatel AS uzivatel");
            console.table(rows);
            return res.json({ rows });
        } catch (err) {
            return res.status(500).json({ error: err.message });
        } finally {
            connection.release();
        }
    });

    router.use(createAuthRouter());
    router.use(createUserRouter());
    router.use("/admin", createAdminRouter());

    router.use((req, res) => {
        res.status(404).json({ error: "API route not found" });
    });

    return router;
}

module.exports = {
    createApiRouter,
};


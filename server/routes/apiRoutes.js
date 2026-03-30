const express = require("express");
const { createAuthRouter } = require("./authRoutes");
const { createUserRouter } = require("./userRoutes");
const { createAdminRouter } = require("./adminRoutes");

function createApiRouter({ connection }) {
    const router = express.Router();

    router.get("/test1", (req, res) => {
        connection.query("SELECT * FROM uzivatel AS uzivatel", (err, rows) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }

            console.table(rows);
            return res.json({ rows });
        });
    });

    router.use(createAuthRouter({ connection }));
    router.use(createUserRouter({ connection }));
    router.use("/admin", createAdminRouter({ connection }));

    router.use((req, res) => {
        res.status(404).json({ error: "API route not found" });
    });

    return router;
}

module.exports = {
    createApiRouter,
};


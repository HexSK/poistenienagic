const express = require("express");

require("./config/env");

const { applyAppMiddleware } = require("./config/middleware");
const { createDbConnection } = require("./config/db");
const { createApiRouter } = require("./routes/apiRoutes");

const PORT = process.env.PORT || 8080;

async function start() {
    const app = express();
    applyAppMiddleware(app);

    const connection = await createDbConnection();

    app.use("/api", createApiRouter({ connection }));

    app.use(cors({
        origin: function (origin, callback) {
            const allowedOrigins = [
                process.env.CLIENT_URL,
                "http://localhost:5173",
                "http://localhost:5174"
            ].filter(Boolean);

            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true);
            } else {
                callback(new Error('CORS not allowed'));
            }
        },
        credentials: true
    }));

    app.listen(PORT, () => {
        console.log(`Server started on port ${PORT}`);
    });
}

start().catch((err) => {
    console.error("Server failed to start: ", err);
});


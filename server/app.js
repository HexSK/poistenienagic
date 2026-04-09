const express = require("express");

require("./config/env");

const { applyAppMiddleware } = require("./config/middleware");
const { createDbConnection } = require("./config/db");
const { createApiRouter } = require("./routes/apiRoutes");

const PORT = process.env.PORT || 8080;

async function start() {
    const app = express();
    app.set("trust proxy", 1);
    applyAppMiddleware(app);

    const connection = await createDbConnection();

    app.use("/api", createApiRouter({ connection }));

    app.listen(PORT, () => {
        console.log(`Server started on port ${PORT}`);
    });
}

start().catch((err) => {
    console.error("Server failed to start: ", err);
});

const express = require("express");

require("./config/env");

const { applyAppMiddleware } = require("./config/middleware");
const { createDbConnection } = require("./config/db");
const { registerClientRoutes } = require("./routes/clientRoutes");
const { createApiRouter } = require("./routes/apiRoutes");

const PORT = process.env.PORT || 8080;

async function start() {
    const app = express();
    applyAppMiddleware(app);

    const connection = await createDbConnection();

    registerClientRoutes(app);
    app.use("/api", createApiRouter({ connection }));

    app.listen(PORT, () => {
        console.log(`Server started on port ${PORT}`);
    });
}

start().catch((err) => {
    console.error("Server failed to start: ", err);
});


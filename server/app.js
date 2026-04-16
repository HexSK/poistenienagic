const express = require("express");

require("./config/env");

const { applyAppMiddleware } = require("./config/middleware");
const { createApiRouter } = require("./routes/apiRoutes");

const PORT = process.env.PORT || 8080;

async function start() {
    const app = express();
    app.set("trust proxy", 1);
    applyAppMiddleware(app);

    app.use("/api", createApiRouter());

    app.listen(PORT, () => {
        console.log(`Server started on port ${PORT}`);
    });
}

start().catch((err) => {
    console.error("Server failed to start: ", err);
});

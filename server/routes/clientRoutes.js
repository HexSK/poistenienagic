const path = require("path");
const express = require("express");

function registerClientRoutes(app) {
    const clientDistPath = path.join(__dirname, "../../client/dist");

    app.use(express.static(clientDistPath));
    app.get(/^\/(?!api\/).*/, (req, res) => {
        res.sendFile(path.join(clientDistPath, "index.html"));
    });
}

module.exports = {
    registerClientRoutes,
};


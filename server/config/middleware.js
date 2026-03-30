const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const session = require("express-session");

function applyAppMiddleware(app) {
    app.use(helmet());
    app.use(cors());
    app.use(express.json());
    app.use(
        session({
            secret: process.env.SECRET,
            resave: false,
            saveUninitialized: false,
            cookie: { secure: false },
        }),
    );
}

module.exports = {
    applyAppMiddleware,
};


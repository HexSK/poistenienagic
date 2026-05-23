const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const session = require("express-session");

function stripQuotes(value) {
    if (!value) return value;
    return value.replace(/^['"]|['"]$/g, "");
}

function getAllowedOrigins() {
    const raw = process.env.CLIENT_URLS || process.env.CLIENT_URL || "";
    const origins = raw
        .split(",")
        .map((o) => stripQuotes(o.trim()))
        .filter(Boolean);

    origins.push("http://localhost:5173", "http://127.0.0.1:5173");
    return [...new Set(origins)];
}

function applyAppMiddleware(app) {
    app.use(helmet());

    const allowedOrigins = getAllowedOrigins();

    app.use(
        cors({
            origin(origin, callback) {
                if (!origin) return callback(null, true);
                const normalized = stripQuotes(origin);
                return callback(null, allowedOrigins.includes(normalized));
            },
            credentials: true,
        }),
    );
    app.use(express.json());

    const rawSecure = process.env.SESSION_COOKIE_SECURE;
    const rawClientUrl = stripQuotes(process.env.CLIENT_URL || "");

    let secure;
    if (rawSecure !== undefined) {
        secure = rawSecure === "true";
    } else if (rawClientUrl) {
        secure = rawClientUrl.startsWith("https://");
    } else {
        throw new Error("Cannot determine SESSION_COOKIE_SECURE: set it explicitly or provide CLIENT_URL");
    }

    app.use(
        session({
            secret: process.env.SECRET,
            resave: false,
            saveUninitialized: false,
            proxy: secure,
            cookie: {
                secure: secure,
                sameSite: secure ? "none" : "lax",
                httpOnly: true,
            },
        }),
    );
}

module.exports = {
    applyAppMiddleware,
};

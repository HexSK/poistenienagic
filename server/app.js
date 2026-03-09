const express = require("express");
const path = require("path");
const dotenv = require("dotenv");
const mysql = require("mysql2/promise");
const cors = require('cors');
const helmet = require('helmet');
const bcrypt = require('bcrypt');
const session = require("express-session");

dotenv.config({ path: path.join(__dirname, ".env"), quiet: true });

const app = express();
const PORT = process.env.PORT || 8080;

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(session({
    secret: process.env.SECRET,
    resave: false,
    saveUninitialized: true,
    cookie: { secure: true }
}));

function auth(req, res, next) {
    if (!req.session.userId) return res.status(401).json({ error: "Uzivatel neprihlaseny" });
    next();
}
async function start() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER || process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        database: process.env.DB || process.env.DB_NAME
    });
    console.log("MySQL Connected");



    app.use(express.json());

    app.use(express.static(path.join(__dirname, "../client/dist")));


    app.get(/^\/(?!api\/).*/, (req, res) => {
        res.sendFile(path.join(__dirname, "../client/dist/index.html"));
    });

    app.get('/api/test1', (req, res) => {
        connection.query('SELECT * FROM uzivatel AS uzivatel', (err, rows, fields) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }

            console.table(rows);
            return res.json({ rows });
        });
    });

    app.post('/api/register', async (req, res) => {
        const { id_mesto, meno, priezvisko, datum_narodenia, rod_cislo, email, password } = req.body;

        try {
            const hash = await bcrypt.hash(password, 10);

            const [result] = await connection.query(
                `INSERT INTO uzivatel(id_mesto, meno, priezvisko, datum_narodenia, rod_cislo, email, password)
            VALUES(?, ?, ?, ?, ?, ?, ?)`, [id_mesto, meno, priezvisko, datum_narodenia, rod_cislo, email, hash]
            );

            res.status(201).json({
                message: "uzivatel vytvoreny",
                userId: result.insertId
            });
        } catch (err) {
            if (err.code === "ER_DUP_ENTRY") {
                if (err.sqlMessage.includes("email")) {
                    return res.status(400).json({
                        error: "email existuje",
                    });
                }

                if (err.sqlMessage.includes("rod_cislo")) {
                    return res.status(400).json({
                        error: "rodne cislo existuje"
                    });
                }

                return res.status(400).json({
                    error: "duplicitna hodnota"
                });
            }
            console.error(err);
            res.status(500).json({
                error: "chyba v databaze"
            });
        }
    });

    app.post("/api/login", async (req, res) => {
        const { email, password } = req.body;

        const [rows] = await connection.query(
            `SELECT * FROM uzivatel WHERE email = ?`, [email]
        );

        const uzivatel = rows[0];

        if (!uzivatel) return res.status(401).json({ error: "Neplatne udaje" });

        const valid = await bcrypt.compare(password, uzivatel.password);

        if (!valid) return res.status(401).json({ error: "Neplatne udaje" });

        req.session.userId = uzivatel.id_uzivatel;
        req.session.role = uzivatel.typ_uzivatela;

        res.json({
            message: "Login uspesny",
            userId: req.session.userId,
            role: req.session.role
        })
    });

    app.post("/api/logout", (req, res) => {
        req.session.destroy(() => {
            res.json({ message: "Uzivatel odhlaseny" })
        });
    });

    app.get("/api/zmluvy", (req, res) => { });

    app.get("/api/admin/prehlad", (req, res) => { });

    app.get("/api/klient/prehlad", (req, res) => { });

    app.post("/api/zmluva", (req, res) => { });

    app.post("/api/zmluva/nova", (req, res) => { });

    app.get("/api/faktura", (req, res) => { });

    app.post("/api/faktura/platba", (req, res) => { });



    app.use("/api", (req, res) => {
        res.status(404).json({ error: "API route not found" });
    });

    app.listen(PORT, () => {
        console.log(`Server started on port ${PORT}`);
    });
}

start().catch(err => {
    console.error("Server failed to start: ", err)
})

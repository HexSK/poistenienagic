const express = require("express");
const bcrypt = require("bcrypt");
const { auth } = require("../middleware/auth");
const { getDbConnection } = require("../config/db");

function createAuthRouter() {
    const router = express.Router();

    router.post("/register", async (req, res) => {
        const {
            typ_uzivatela,
            meno,
            priezvisko,
            datum_narodenia,
            rod_cislo,
            tel_c,
            ulica_c,
            mesto,
            PSC,
            email,
            password,
            nazov_firma,
            ICO,
            DIC,
        } = req.body;

        const connection = await getDbConnection();

        try {

            const [result] = await connection.query(
                `INSERT INTO uzivatel(typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, tel_c, ulica_c, mesto, PSC, email, password, nazov_firma, ICO, DIC)
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    typ_uzivatela,
                    meno,
                    priezvisko,
                    datum_narodenia,
                    rod_cislo || null,
                    tel_c,
                    ulica_c,
                    mesto,
                    PSC,
                    email,
                    hash,
                    nazov_firma || null,
                    ICO || null,
                    DIC || null,
                ],
            );

            res.status(201).json({
                message: "uzivatel vytvoreny",
                userId: result.insertId,
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
                        error: "rodne cislo existuje",
                    });
                }

                return res.status(400).json({
                    error: "duplicitna hodnota",
                });
            }
            console.error(err);
            res.status(500).json({
                error: "chyba v databaze",
            });
        } finally {
            connection.release();
        }
    });

    router.post("/login", async (req, res) => {
        const { email, password } = req.body;

        const connection = await getDbConnection();

        try {
            const [rows] = await connection.query(`SELECT * FROM uzivatel WHERE email = ?`, [email]);

            const uzivatel = rows[0];

            if (!uzivatel) return res.status(401).json({ error: "Neplatne udaje" });

            const valid = await bcrypt.compare(password, uzivatel.password);

            if (!valid) return res.status(401).json({ error: "Neplatne udaje" });

            req.session.userId = uzivatel.id_uzivatel;
            req.session.role = uzivatel.typ_uzivatela;
            req.session.meno_priezvisko = {
                meno: uzivatel.meno,
                priezvisko: uzivatel.priezvisko,
                nazov_firma: uzivatel.nazov_firma
            };

            res.json({
                message: "Login uspesny",
                userId: req.session.userId,
                role: req.session.role,
            });
        } finally {
            connection.release();
        }
    });

    router.get("/me", auth, (req, res) => {
        return res.status(200).json({
            userId: req.session.userId,
            role: req.session.role,
            meno_priezvisko: req.session.meno_priezvisko
        });
    });

    router.post("/logout", (req, res) => {
        req.session.destroy(() => {
            res.json({ message: "Uzivatel odhlaseny" });
        });
    });

    return router;
}

module.exports = {
    createAuthRouter,
};

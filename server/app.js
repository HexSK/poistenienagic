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
    saveUninitialized: false,
    cookie: { secure: false }
}));

function auth(req, res, next) {
    if (!req.session.userId) return res.status(401).json({ error: "Uzivatel neprihlaseny" });
    next();
}

function adminOnly(req, res, next) {
    if (req.session.role !== 'a') return res.status(403).json({ error: "Nedostatocne opravnenia" });
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
        const { typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, tel_c, ulica_c, mesto, PSC, email, password, nazov_firma, ICO, DIC } = req.body;

        try {
            const hash = await bcrypt.hash(password, 10);

            const [result] = await connection.query(
                `INSERT INTO uzivatel(typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, tel_c, ulica_c, mesto, PSC, email, password, nazov_firma, ICO, DIC)
            VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, tel_c, ulica_c, mesto, PSC, email, hash, nazov_firma, ICO, DIC]
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

    app.get("/api/prehlad", auth, async (req, res) => {
        const [
            [statistika],
            [klient_zmluvy],
            [klient_vozidla],
            [poistne_udalosti]
        ] = await Promise.all([
            connection.query(`
                SELECT
                    COUNT(*) as aktivne_zmluvy,
                    (SELECT f.datum_splatnosti 
                    FROM faktura f
                    JOIN zmluva z ON z.id_zmluva = f.id_zmluva
                    WHERE z.id_uzivatel = ? 
                    AND f.datum_zaplatenia IS NULL
                    ORDER BY f.datum_splatnosti ASC
                    LIMIT 1) AS najblizsia_splatnost,

                    (SELECT f.id_zmluva 
                    FROM faktura f
                    JOIN zmluva z ON z.id_zmluva = f.id_zmluva
                    WHERE z.id_uzivatel = ? 
                    AND f.datum_zaplatenia IS NULL
                    ORDER BY f.datum_splatnosti ASC
                    LIMIT 1) AS najblizsia_splatnost_id_zmluva,
                    (SELECT COUNT(*) FROM poistna_udalost p
                    JOIN zmluva z ON z.id_zmluva = p.id_zmluva
                    WHERE z.id_uzivatel = ? AND p.stav_udalosti = FALSE) AS otvorene_udalosti
                 FROM zmluva
                 WHERE id_uzivatel = ? AND stav_zmluvy = 'aktivna'
            `, [req.session.userId, req.session.userId, req.session.userId, req.session.userId]),
            connection.query(
                `SELECT
                    v.ECV,
                    v.VIN,
                    v.cislo_motora,
                    z.stav_zmluvy,
                    z.datum_zaciatku,
                    z.datum_konca,
                    z.cena_poistneho
                FROM zmluva z
                JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
                WHERE z.id_uzivatel = ?
                ORDER BY z.id_zmluva DESC`,
                [req.session.userId]
            ),
            connection.query(
                `SELECT
                    ECV,
                    VIN,
                    cislo_motora,
                    znacka
                FROM auto
                WHERE id_uzivatel = ?
                ORDER BY id_vozidlo DESC`,
                [req.session.userId]
            ),
            connection.query(
                `SELECT
                    v.ECV,
                    v.VIN,
                    v.cislo_motora,
                    p.datum_udalosti,
                    p.datum_vyriesenia,
                    p.stav_udalosti,
                    p.popis_udalosti
                FROM poistna_udalost p
                JOIN zmluva z ON z.id_zmluva = p.id_zmluva
                JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
                WHERE z.id_uzivatel = ?
                `,
                [req.session.userId]
            )
        ]);

        res.json({
            statistika: statistika[0],
            klient_zmluvy: klient_zmluvy,
            klient_vozidla: klient_vozidla,
            poistne_udalosti: poistne_udalosti
        })

    });

    app.get("/api/zmluvy", auth, async (req, res) => {
        const [
            [statistika],
            [klient_zmluvy]
        ] = await Promise.all([
            connection.query(
                `SELECT
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'aktivna') AS aktivne_zmluvy,
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'expirovana') AS expirovane_zmluvy,
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'zrusena') AS zrusene_zmluvy,
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'vytvorena') AS vytvorene_nezaplatene_zmluvy
                WHERE id_uzivatel = ?`,
                [req.session.userId]
            ),
            connection.query(
                `SELECT
                    v.ECV,
                    v.VIN,
                    v.cislo_motora
                    v.VIN
                    v.kat_vozidla,
                    z.datum_zaciatku,
                    z.datum_konca,
                    z.cena_poistneho,
                    z.stav_zmluvy,
                FROM zmluva
                JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo`
            )
        ]);

        res.json({
            statistika: statistika[0],
            klient_zmluvy: klient_zmluvy
        })
    });

    app.post("/api/zmluva/:id_zmluva", auth, async (req, res) => {
        const [zmluva] = await connection.query(
            `SELECT
                z.datum_zaciatku,
                z.datum_konca, 
                z.cena_poistneho,
                z.stav_zmluvy,
                v.znacka,
                v.model,
                v.kat_vozidla,
                v.ECV,
                v.VIN,
                v.cislo_motora,
                (SELECT 
                    COUNT(*) 
                FROM poistna_udalost
                WHERE pu.id_zmluva = z.id_zmluva) as pocet_udalosti
            FROM zmluva z 
            JOIN vozidlo v
            ON v.id_vozidlo = z.id_vozidlo 
            JOIN poistna_udalost pu ON pu.id_zmluva = z.id_zmluva
            WHERE z.id_uzivatel = ? AND z.id_zmluva = ?
            ORDER BY z.id_zmluva ASC`,
            [req.session.userId, req.params.id_zmluva]
        );
        res.json({
            zmluvy: zmluva
        })
    });

    app.post("/api/zmluva/nova-ziadost", auth, async (req, res) => { 
        const { typ_zmluvy, dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora } = req.body;

        const datum_zaciatku = new Date(datum_zaciatku_zmluvy)

        if (datum_zaciatku < new Date()) return res.status(400).json({ error: "Datum nesmie byt v minulosti" });
        if (dlzka_zmluvy_mesiace >25) return res.status(400).json({ error: "Zmluva moze byt dlha max 24 mesiacov (2 roky)" });

        try {
            await connection.query(
                `INSERT INTO
                ziadost_o_zmluvu (id_uzivatel, typ_zmluvy, dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [req.session.userId, typ_zmluvy, dlzka_zmluvy_mesiace, datum_zaciatku, znacka, model, kat_vozidla, ECV, VIN, cislo_motora]
            );
            return res.status(201).json({
                message: "Ziadost odoslana"
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Chyba v databaze: " + error})    
        }
     });

    app.get("/api/faktura", (req, res) => { });

    app.post("/api/faktura/platba", (req, res) => { });

     app.get("/api/admin/prehlad", auth, adminOnly, async (req, res) => {
        const [
            [statistika],
            [posledne_zmluvy],
            [nezaplatene_zmluvy],
            [otvorene_poistne_udalosti]
        ] = await Promise.all([
            connection.query("SELECT * FROM admin_prehlad_statistika"),
            connection.query("SELECT * FROM admin_prehlad_posledne_zmluvy"),
            connection.query("SELECT * FROM admin_prehlad_nezaplatene_zmluvy"),
            connection.query("SELECT * FROM admin_prehlad_otvorene_poistne_udalosti")
        ]);

        res.json({
            statistika: statistika[0],
            posledne_zmluvy: posledne_zmluvy,
            nezaplatene_zmluvy: nezaplatene_zmluvy,
            otvorene_poistne_udalosti: otvorene_poistne_udalosti
        })
    });

    app.get("/api/admin/zmluvy", auth, adminOnly, async (req, res) => {
        const [
            [statistika],
            [admin_zmluvy]
        ] = await Promise.all([
            connection.query(
                `SELECT
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'aktivna') AS aktivne_zmluvy,
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'expirovana') AS expirovane_zmluvy,
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'zrusena') AS zrusene_zmluvy,
                    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'vytvorena') AS vytvorene_nezaplatene_zmluvy`
            ),
            connection.query(
                'SELECT * FROM zmluva'
            )
        ]);

        res.json({
            statistika: statistika[0],
            admin_zmluvy: admin_zmluvy
        });
    });

    app.use("/api", (req, res) => {
        res.status(404).json({ error: "API route not found" });
    });

    app.listen(PORT, () => {
        console.log(`Server started on port ${PORT}`);
    });
}

start().catch(err => {
    console.error("Server failed to start: ", err)
});

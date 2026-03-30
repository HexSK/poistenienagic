const express = require("express");
const { auth } = require("../middleware/auth");

function createUserRouter({ connection }) {
    const router = express.Router();

    router.use(auth);

    router.get("/prehlad", async (req, res) => {
        const [[statistika], [klient_zmluvy], [klient_vozidla], [poistne_udalosti]] = await Promise.all([
            connection.query(
                `
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
            `,
                [req.session.userId, req.session.userId, req.session.userId, req.session.userId],
            ),
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
                [req.session.userId],
            ),
            connection.query(
                `SELECT
                    ECV,
                    VIN,
                    cislo_motora,
                    znacka
                FROM vozidlo
                WHERE id_uzivatel = ?
                ORDER BY id_vozidlo DESC`,
                [req.session.userId],
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
                [req.session.userId],
            ),
        ]);

        res.json({
            statistika: statistika[0],
            klient_zmluvy: klient_zmluvy,
            klient_vozidla: klient_vozidla,
            poistne_udalosti: poistne_udalosti,
        });
    });

    router.get("/zmluvy", async (req, res) => {
        const [[statistika], [klient_zmluvy]] = await Promise.all([
            connection.query(
                `SELECT
                    COUNT(CASE WHEN stav_zmluvy = 'aktivna' THEN 1 END) AS aktivne_zmluvy,
                    COUNT(CASE WHEN stav_zmluvy = 'expirovana' THEN 1 END) AS expirovane_zmluvy,
                    COUNT(CASE WHEN stav_zmluvy = 'zrusena' THEN 1 END) AS zrusene_zmluvy,
                    COUNT(CASE WHEN stav_zmluvy = 'vytvorena' THEN 1 END) AS vytvorene_nezaplatene_zmluvy
                FROM zmluva
                WHERE id_uzivatel = ?`,
                [req.session.userId],
            ),
            connection.query(
                `SELECT
                    v.ECV,
                    v.VIN,
                    v.cislo_motora,
                    v.kat_vozidla,
                    z.datum_zaciatku,
                    z.datum_konca,
                    z.cena_poistneho,
                    z.stav_zmluvy
                FROM zmluva z
                JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
                WHERE z.id_uzivatel = ?`,
                [req.session.userId],
            ),
        ]);

        res.json({
            statistika: statistika[0],
            klient_zmluvy: klient_zmluvy,
        });
    });

    router.get("/zmluva/:id_zmluva", async (req, res) => {
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
                (SELECT COUNT(*)
                FROM poistna_udalost
                WHERE id_zmluva = z.id_zmluva) as pocet_udalosti
            FROM zmluva z 
            JOIN vozidlo v
            ON v.id_vozidlo = z.id_vozidlo
            WHERE z.id_uzivatel = ? AND z.id_zmluva = ?
            ORDER BY z.id_zmluva ASC`,
            [req.session.userId, req.params.id_zmluva],
        );
        res.json({
            zmluvy: zmluva,
        });
    });

    router.get("/zmluva/:id_zmluva/faktury", async (req, res) => {
        try {
            const [faktury] = await connection.query(
                `SELECT
                f.id_faktura,
                f.cislo_faktura,
                f.datum_vystavenia,
                f.datum_splatnosti,
                f.datum_zaplatenia,
                f.suma,
                f.typ_platby,
                f.poznamka
            FROM faktura f
            JOIN zmluva z ON z.id_zmluva = f.id_zmluva
            WHERE f.id_zmluva = ? AND z.id_uzivatel = ?`,
                [req.params.id_zmluva, req.session.userId],
            );
            return res.json({ faktury: faktury });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ error: "Chyba: " + err });
        }
    });

    router.post("/faktura/:id_faktura/zaplat", async (req, res) => {
        const { typ_platby } = req.body;
        try {
            const [faktura] = await connection.query(
                `SELECT f.id_faktura FROM faktura f
            JOIN zmluva z ON z.id_zmluva = f.id_zmluva
            WHERE f.id_faktura = ? AND z.id_uzivatel = ?`,
                [req.params.id_faktura, req.session.userId],
            );
            if (!faktura[0]) return res.status(404).json({ error: "Faktura nenajdena" });

            await connection.query(
                `UPDATE faktura SET datum_zaplatenia = CURDATE(), typ_platby = ?
            WHERE id_faktura = ?`,
                [typ_platby, req.params.id_faktura],
            );
            return res.json({ message: "Faktura zaplatena" });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ error: "Chyba: " + err });
        }
    });

    router.post("/poistna-udalost", async (req, res) => {
        const { id_zmluva, popis_udalosti, datum_udalosti } = req.body;
        try {
            const [zmluva] = await connection.query(
                `SELECT id_zmluva FROM zmluva 
            WHERE id_zmluva = ? AND id_uzivatel = ? AND stav_zmluvy = 'aktivna'`,
                [id_zmluva, req.session.userId],
            );
            if (!zmluva[0]) return res.status(404).json({ error: "Zmluva nenajdena alebo nie je aktivna" });

            const [result] = await connection.query(
                `INSERT INTO poistna_udalost (id_zmluva, popis_udalosti, datum_udalosti)
            VALUES (?, ?, ?)`,
                [id_zmluva, popis_udalosti, datum_udalosti],
            );
            return res.status(201).json({ message: "Udalost zaevidovana", id: result.insertId });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ error: "Chyba: " + err });
        }
    });

    router.post("/zmluva/nova-ziadost", async (req, res) => {
        const { typ_poistenia, dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora } =
            req.body;

        const datum_zaciatku = new Date(datum_zaciatku_zmluvy);

        if (datum_zaciatku < new Date()) return res.status(400).json({ error: "Datum nesmie byt v minulosti" });
        if (dlzka_zmluvy_mesiace > 25) return res.status(400).json({ error: "Zmluva moze byt dlha max 24 mesiacov (2 roky)" });
        if (!ECV && !VIN && !cislo_motora) return res.status(400).json({ error: "Zadajte aspon ECV, VIN alebo cislo motora" });

        try {
            await connection.query(
                `INSERT INTO
                ziadost_o_zmluvu (id_uzivatel, typ_poistenia,  dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [req.session.userId, typ_poistenia, dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora],
            );
            return res.status(201).json({
                message: "Ziadost odoslana",
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Chyba v databaze: " + error });
        }
    });

    return router;
}

module.exports = {
    createUserRouter,
};


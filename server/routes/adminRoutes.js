const express = require("express");
const { auth, adminOnly } = require("../middleware/auth");

function createAdminRouter({ connection }) {
    const router = express.Router();

    router.use(auth, adminOnly);

    router.patch("/poistna-udalost/:id", async (req, res) => {
        const { datum_vyriesenia, suma_udalosti } = req.body;
        try {
            await connection.query(
                `UPDATE poistna_udalost 
            SET stav_udalosti = TRUE, datum_vyriesenia = ?, suma_udalosti = ?
            WHERE id_poistna_udalost = ?`,
                [datum_vyriesenia, suma_udalosti, req.params.id],
            );
            return res.json({ message: "Udalost vyriesena" });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ error: "Chyba: " + err });
        }
    });

    router.get("/vyhladat", async (req, res) => {
        const { q } = req.query;
        if (!q) return res.status(400).json({ error: "Zadajte hladany vyraz" });
        try {
            const [results] = await connection.query(
                `SELECT
                z.id_zmluva,
                COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno,
                v.ECV,
                v.VIN,
                z.stav_zmluvy,
                z.datum_zaciatku,
                z.datum_konca
            FROM zmluva z
            JOIN uzivatel u ON u.id_uzivatel = z.id_uzivatel
            JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
            WHERE v.ECV LIKE ?
               OR u.meno LIKE ?
               OR u.priezvisko LIKE ?
               OR u.nazov_firma LIKE ?`,
                [`%${q}%`, `%${q}%`, `%${q}%`, `%${q}%`],
            );
            return res.json({ results });
        } catch (err) {
            console.error(err);
            return res.status(500).json({ error: "Chyba: " + err });
        }
    });

    router.get("/ziadosti", async (req, res) => {
        try {
            const [ziadosti] = await connection.query(
                `SELECT
                    zz.id_ziadost,
                    u.meno,
                    u.priezvisko,
                    u.nazov_firma,
                    zz.typ_poistenia,
                    zz.dlzka_zmluvy_mesiace,
                    zz.znacka,
                    zz.model,
                    zz.kat_vozidla,
                    zz.ECV,
                    zz.VIN,
                    zz.cislo_motora,
                    zz.stav_ziadosti
                FROM ziadost_o_zmluvu zz
                JOIN uzivatel u ON u.id_uzivatel = zz.id_uzivatel
                WHERE zz.stav_ziadosti = 'cakajuca'`,
            );

            return res.status(201).json({
                ziadosti: ziadosti,
            });
        } catch (err) {
            console.error(err);
            return res.status(500).json({
                error: "Chyba: " + err,
            });
        }
    });

    router.get("/ziadost/:id_ziadost", async (req, res) => {
        try {
            const [rows] = await connection.query(
                `SELECT *
             FROM ziadost_o_zmluvu
             WHERE id_ziadost = ?`,
                [req.params.id_ziadost]
            );

            if (!rows[0]) {
                return res.status(404).json({ error: "Ziadost neexistuje" });
            }

            res.json({
                ziadost: rows[0]
            });
        } catch (err) {
            console.error(err);
            res.status(500).json({ error: "Chyba: " + err });
        }
    });

    router.post("/zmluva/prijat-ziadost/:id_ziadost", async (req, res) => {
        const zaklad_cena = {
            PZP: 8.5,
            "PZP+": 12.0,
        };

        const koeficient_ceny = {
            A: 1.0, // osobné auto
            B: 0.7, // motocykel
            C: 1.8, // nákladné
            D: 0.4, // bicykel s motorom
            E: 2.5, // bus
            F: 0.6, // príves
            G: 1.0, // iné
        };

        const { id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora } = (
            await connection.query(
                `SELECT id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora
            FROM ziadost_o_zmluvu
            WHERE id_ziadost = ?`,
                [req.params.id_ziadost],
            )
        )[0][0];

        const { datum_zaciatku_zmluvy, typ_poistenia, dlzka_zmluvy_mesiace } = (
            await connection.query(
                `SELECT datum_zaciatku_zmluvy, typ_poistenia, dlzka_zmluvy_mesiace
            FROM ziadost_o_zmluvu
            WHERE id_ziadost = ?`,
                [req.params.id_ziadost],
            )
        )[0][0];

        const cena = zaklad_cena[typ_poistenia] * koeficient_ceny[kat_vozidla] * dlzka_zmluvy_mesiace;

        await connection.beginTransaction();
        try {
            const [vozidloResult] = await connection.query(
                `INSERT INTO vozidlo
                (id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora)
                VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora],
            );
            const id_vozidlo = vozidloResult.insertId;

            const datum_zaciatku = new Date(datum_zaciatku_zmluvy);
            const datum_konca = new Date(datum_zaciatku);
            datum_konca.setMonth(datum_konca.getMonth() + dlzka_zmluvy_mesiace);

            const [zmluvaResult] = await connection.query(
                `INSERT INTO zmluva
                (id_vozidlo, id_uzivatel, datum_zaciatku, datum_konca, typ_poistenia, cena_poistneho, stav_zmluvy)
                VALUES (?, ?, ?, ?, ?, ?, ?)`,
                [id_vozidlo, id_uzivatel, datum_zaciatku_zmluvy, datum_konca, typ_poistenia, cena, "vytvorena"],
            );

            const id_zmluva = zmluvaResult.insertId;

            const cislo_faktura = `${new Date().getFullYear()}/${id_zmluva.toString().padStart(4, "0")}`;

            const datum_vystavenia = new Date();
            const datum_splatnosti = new Date(datum_vystavenia);
            datum_splatnosti.setDate(datum_splatnosti.getDate() + 14);

            await connection.query(
                `INSERT INTO faktura
                (id_zmluva, cislo_faktura, datum_vystavenia, datum_splatnosti, suma, poznamka)
                VALUES (?, ?, ?, ?, ?, ?)`,
                [id_zmluva, cislo_faktura, datum_vystavenia, datum_splatnosti, cena, null],
            );

            await connection.query(
                `UPDATE ziadost_o_zmluvu
                SET stav_ziadosti = ?
                WHERE id_ziadost = ?`,
                ["schvalena", req.params.id_ziadost],
            );
            await connection.commit();

            return res.status(201).json({
                message: "Ziadost " + req.params.id_ziadost + " uspesne prijata",
            });
        } catch (err) {
            await connection.rollback();
            console.error(err);
            return res.status(500).json({
                error: "Chyba: " + err,
            });
        }
    });

    router.post("/zmluva/odmietnut-ziadost/:id_ziadost", async (req, res) => {
        const { sprava } = req.body;
        void sprava;

        try {
            await connection.query(
                `UPDATE ziadost_o_zmluvu
                SET stav_ziadosti = 'odmietnuta'
                WHERE id_ziadost = ?`,
                [req.params.id_ziadost],
            );
            return res.status(201).json({
                message: "Ziadost " + req.params.id_ziadost + " uspesne odmietnuta",
            });
        } catch (err) {
            console.error(err);
            return res.status(500).json({
                error: "Chyba pri odmietnuti: " + err,
            });
        }
    });

    router.get("/prehlad", async (req, res) => {
        try {
            const [[statistika], [posledne_zmluvy], [nezaplatene_zmluvy], [otvorene_poistne_udalosti], [uzivatelia_zmluvy_vozidla]] =
                await Promise.all([
                    connection.query("SELECT * FROM admin_prehlad_statistika"),
                    connection.query("SELECT * FROM admin_prehlad_posledne_zmluvy"),
                    connection.query("SELECT * FROM admin_prehlad_nezaplatene_zmluvy"),
                    connection.query("SELECT * FROM admin_prehlad_otvorene_poistne_udalosti"),
                    connection.query("SELECT * FROM admin_prehlad_uzivatelia_zmluvy_vozidla"),
                ]);

            return res.status(201).json({
                statistika: statistika[0],
                posledne_zmluvy: posledne_zmluvy,
                nezaplatene_zmluvy: nezaplatene_zmluvy,
                otvorene_poistne_udalosti: otvorene_poistne_udalosti,
                uzivatelia_zmluvy_vozidla: uzivatelia_zmluvy_vozidla,
            });
        } catch (err) {
            console.error(err);
            return res.status(500).json({
                error: "Chyba: " + err,
            });
        }
    });

    router.get("/prehlad/uzivatel/:id_uzivatel", async (req, res) => {
        try {
            const [admin_prehlad_uzivatel_detaily] = await connection.query(
                `SELECT * FROM admin_prehlad_uzivatelia_zmluvy_vozidla
                 WHERE id_uzivatel = ?`,
                [req.params.id_uzivatel],
            );

            return res.status(201).json({
                admin_prehlad_uzivatel_detaily: admin_prehlad_uzivatel_detaily,
            });
        } catch (err) {
            console.error(err);
            return res.status(500).json({
                error: "Chyba: " + err,
            });
        }
    });

    router.delete("/prehlad/uzivatel/:id_uzivatel", async (req, res) => {
        try {
            await connection.query(`DELETE FROM uzivatel WHERE id_uzivatel = ?`, [req.params.id_uzivatel]);
            return res.status(201).json({
                message: "Uzivatel " + req.params.id_uzivatel + " a ich udaje boli vymazane.",
            });
        } catch (err) {
            console.error(err);
            return res.status(500).json({
                error: err,
            });
        }
    });

    router.get("/zmluvy", async (req, res) => {
        const [[statistika], [admin_zmluvy]] = await Promise.all([
            connection.query(
                `SELECT
                    COUNT(CASE WHEN stav_zmluvy = 'aktivna' THEN 1 END) AS aktivne_zmluvy,
                    COUNT(CASE WHEN stav_zmluvy = 'expirovana' THEN 1 END) AS expirovane_zmluvy,
                    COUNT(CASE WHEN stav_zmluvy = 'zrusena' THEN 1 END) AS zrusene_zmluvy,
                    COUNT(CASE WHEN stav_zmluvy = 'vytvorena' THEN 1 END) AS vytvorene_nezaplatene_zmluvy
                FROM zmluva`,
            ),
            connection.query("SELECT * FROM zmluva"),
        ]);

        res.json({
            statistika: statistika[0],
            admin_zmluvy: admin_zmluvy,
        });
    });

    return router;
}

module.exports = {
    createAdminRouter,
};


DROP VIEW IF EXISTS vw_zmluvy_klienti_inner;

CREATE VIEW vw_zmluvy_klienti_inner AS
SELECT z.id_zmluva, z.stav_zmluvy, z.datum_zaciatku, z.datum_konca, z.cena_poistneho, u.id_uzivatel, u.meno, u.priezvisko, a.ECV, a.VIN
FROM
    zmluva z
    INNER JOIN uzivatel u ON u.id_uzivatel = z.id_uzivatel
    INNER JOIN auto a ON a.id_auto = z.id_auto;

DROP VIEW IF EXISTS vw_uzivatelia_zmluvy_left;

CREATE VIEW vw_uzivatelia_zmluvy_left AS
SELECT u.id_uzivatel, u.meno, u.priezvisko, u.email, z.id_zmluva, z.stav_zmluvy, z.datum_konca
FROM uzivatel u
    LEFT JOIN zmluva z ON z.id_uzivatel = u.id_uzivatel;

DROP VIEW IF EXISTS vw_faktury_zmluvy_right;

CREATE VIEW vw_faktury_zmluvy_right AS
SELECT z.id_zmluva, z.id_uzivatel, z.stav_zmluvy, f.id_faktura, f.datum_vystavenia, f.datum_splatnosti, f.datum_zaplatenia, f.suma
FROM faktura f
    RIGHT JOIN zmluva z ON z.id_zmluva = f.id_zmluva;

CREATE VIEW admin_prehlad_statistika AS
SELECT (
        SELECT COUNT(*)
        FROM uzivatel
    ) AS pocet_uzivatelov,
    (
        SELECT COUNT(*)
        FROM zmluva
        WHERE
            stav_zmluvy = 'aktivna'
    ) AS aktivne_zmluvy,
    (
        SELECT COUNT(*)
        FROM faktura
        WHERE
            datum_zaplatenia IS NULL
    ) AS nezaplatene_faktury,
    (
        SELECT COUNT(*)
        FROM poistna_udalost
        WHERE
            stav_udalosti = FALSE
    ) AS otvorene_udalosti;

CREATE VIEW admin_prehlad_posledne_zmluvy AS
SELECT z.id_zmluva, u.meno, u.priezvisko, a.ECV, z.stav_zmluvy, z.datum_zaciatku
FROM
    zmluva z
    JOIN uzivatel u on z.id_uzivatel = u.id_uzivatel
    JOIN auto a ON z.id_auto = a.id_auto
ORDER BY z.id_zmluva DESC
LIMIT 5;

CREATE VIEW admin_prehlad_nezaplatene_zmluvy AS
SELECT z.id_zmluva, f.id_faktura, u.meno, u.priezvisko, a.ECV, f.datum_splatnosti
FROM
    zmluva z
    JOIN uzivatel u on z.id_uzivatel = u.id_uzivatel
    JOIN auto a ON z.id_auto = a.id_auto
    JOIN faktura f ON f.id_zmluva = z.id_zmluva
WHERE
    CURRENT_DATE > f.datum_splatnosti
    AND f.datum_zaplatenia IS NULL
ORDER BY z.id_zmluva ASC;

DROP VIEW IF EXISTS admin_prehlad_otvorene_poistne_udalosti;

CREATE VIEW admin_prehlad_otvorene_poistne_udalosti AS
SELECT p.id_poistna_udalost, a.ECV, p.stav_udalosti, p.datum_udalosti, p.suma_udalosti
FROM
    poistna_udalost p
    JOIN zmluva z ON z.id_zmluva = p.id_zmluva
    JOIN auto a ON a.id_auto = z.id_auto
WHERE
    p.stav_udalosti = FALSE;
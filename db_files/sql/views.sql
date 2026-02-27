DROP VIEW IF EXISTS vw_zmluvy_klienti_inner;
CREATE VIEW vw_zmluvy_klienti_inner AS
SELECT
    z.id_zmluva,
    z.stav_zmluvy,
    z.datum_zaciatku,
    z.datum_konca,
    z.cena_poistneho,
    u.id_uzivatel,
    u.meno,
    u.priezvisko,
    a.ECV,
    a.VIN
FROM zmluva z
INNER JOIN uzivatel u ON u.id_uzivatel = z.id_uzivatel
INNER JOIN auto a ON a.id_auto = z.id_auto;

DROP VIEW IF EXISTS vw_uzivatelia_zmluvy_left;
CREATE VIEW vw_uzivatelia_zmluvy_left AS
SELECT
    u.id_uzivatel,
    u.meno,
    u.priezvisko,
    u.email,
    z.id_zmluva,
    z.stav_zmluvy,
    z.datum_konca
FROM uzivatel u
LEFT JOIN zmluva z ON z.id_uzivatel = u.id_uzivatel;

DROP VIEW IF EXISTS vw_faktury_zmluvy_right;
CREATE VIEW vw_faktury_zmluvy_right AS
SELECT
    z.id_zmluva,
    z.id_uzivatel,
    z.stav_zmluvy,
    f.id_faktura,
    f.datum_vystavenia,
    f.datum_splatnosti,
    f.datum_zaplatenia,
    f.suma
FROM faktura f
RIGHT JOIN zmluva z ON z.id_zmluva = f.id_zmluva;

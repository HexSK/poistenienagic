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
SELECT z.id_zmluva, COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno, v.ECV, z.stav_zmluvy, z.datum_zaciatku
FROM
    zmluva z
    JOIN uzivatel u on z.id_uzivatel = u.id_uzivatel
    JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
ORDER BY z.id_zmluva DESC
LIMIT 5;

CREATE VIEW admin_prehlad_nezaplatene_zmluvy AS
SELECT z.id_zmluva, f.id_faktura, COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno, v.ECV, f.datum_splatnosti
FROM
    zmluva z
    JOIN uzivatel u on z.id_uzivatel = u.id_uzivatel
    JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
    JOIN faktura f ON f.id_zmluva = z.id_zmluva
WHERE
    CURRENT_DATE > f.datum_splatnosti
    AND f.datum_zaplatenia IS NULL
ORDER BY z.id_zmluva ASC;

CREATE VIEW admin_prehlad_otvorene_poistne_udalosti AS
SELECT p.id_poistna_udalost, v.ECV, p.stav_udalosti, p.datum_udalosti, p.suma_udalosti
FROM
    poistna_udalost p
    JOIN zmluva z ON z.id_zmluva = p.id_zmluva
    JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
WHERE
    p.stav_udalosti = FALSE;

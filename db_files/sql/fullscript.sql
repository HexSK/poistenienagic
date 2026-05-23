CREATE TABLE uzivatel (
    id_uzivatel INT NOT NULL AUTO_INCREMENT,
    typ_uzivatela ENUM('k', 'kf', 'a') NOT NULL DEFAULT 'k',
    meno VARCHAR(30) NOT NULL,
    priezvisko VARCHAR(60) NOT NULL,
    datum_narodenia DATE NOT NULL,
    rod_cislo VARCHAR(11) NULL,
    tel_c VARCHAR(20) NOT NULL,
    ulica_c VARCHAR(40) NOT NULL,
    mesto VARCHAR(20) NOT NULL,
    PSC VARCHAR(6) NOT NULL,
    email VARCHAR(64) NOT NULL,
    password VARCHAR(255) NOT NULL,
    datum_upravy DATE NOT NULL,
    nazov_firma VARCHAR(60) NULL,
    ICO VARCHAR(8) NULL,
    DIC VARCHAR(10) NULL,
    CONSTRAINT uzivatel_pk PRIMARY KEY (id_uzivatel),
    CONSTRAINT uzivatel_rc_uk UNIQUE (rod_cislo),
    CONSTRAINT uzivatel_email_uk UNIQUE (email),
    CONSTRAINT uzivatel_rc_chk CHECK (rod_cislo IS NULL OR rod_cislo REGEXP '^[0-9]{10}$'),
    CONSTRAINT uzivatel_ico_uk UNIQUE (ICO),
    CONSTRAINT uzivatel_dic_uk UNIQUE (DIC),
    CONSTRAINT uzivatel_typ_chk CHECK (
        (typ_uzivatela = 'k' AND rod_cislo IS NOT NULL AND ICO IS NULL) OR
        (typ_uzivatela = 'kf' AND ICO IS NOT NULL) OR
        (typ_uzivatela = 'a')
    )
);


CREATE TABLE vozidlo (
    id_vozidlo INT NOT NULL AUTO_INCREMENT,
    id_uzivatel INT NOT NULL,
    znacka VARCHAR(15) NOT NULL,
    model VARCHAR(20) NOT NULL,
    kat_vozidla ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G') NOT NULL COMMENT 'A - Osobne auto, B - Motocykel, C - Nakladne auto/tahac, D - Bicykel s pomocnym motorom, E - Bus, F - Prives, G - Ine',
    ECV VARCHAR(7) NULL,
    VIN VARCHAR(17) NULL,
    cislo_motora VARCHAR(15) NULL,
    CONSTRAINT vozidlo_pk PRIMARY KEY (id_vozidlo),
    CONSTRAINT vozidlo_ecv_uk UNIQUE (ECV),
    CONSTRAINT vozidlo_vin_uk UNIQUE (VIN),
    CONSTRAINT vozidlo_cm_uk UNIQUE (cislo_motora),
    CONSTRAINT vozidlo_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    CONSTRAINT vozidlo_ecv_chk CHECK (ECV REGEXP '[A-Z]{2}[0-9]{3}[A-Z]{2}'),
    CONSTRAINT vozidlo_identifikator_chk CHECK (
        ECV IS NOT NULL OR 
        VIN IS NOT NULL OR 
        cislo_motora IS NOT NULL
    )
);


CREATE TABLE zmluva (
    id_zmluva INT NOT NULL AUTO_INCREMENT,
    id_vozidlo INT NOT NULL,
    id_uzivatel INT NOT NULL,
    datum_zaciatku DATE NOT NULL,
    datum_konca DATE NOT NULL,
    typ_poistenia ENUM('PZP', 'PZP+') NOT NULL DEFAULT 'PZP',
    cena_poistneho DECIMAL(10, 2) NOT NULL,
    stav_zmluvy ENUM('aktivna', 'zrusena', 'expirovana', 'vytvorena') NOT NULL DEFAULT 'vytvorena',
    CONSTRAINT zmluva_pk PRIMARY KEY (id_zmluva),
    CONSTRAINT zmluva_vozidlo_fk FOREIGN KEY (id_vozidlo) REFERENCES vozidlo (id_vozidlo),
    CONSTRAINT zmluva_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    CONSTRAINT zmluva_datum_chk CHECK (datum_konca > datum_zaciatku),
    INDEX idx_zmluva_stav_koniec (stav_zmluvy, datum_konca)
);


CREATE TABLE faktura (
    id_faktura INT NOT NULL AUTO_INCREMENT,
    id_zmluva INT NOT NULL,
    cislo_faktura VARCHAR(20) NOT NULL,
    datum_vystavenia DATE NOT NULL,
    datum_splatnosti DATE NOT NULL,
    datum_zaplatenia DATE NULL,
    suma DECIMAL(10, 2) NOT NULL,
    typ_platby ENUM('prevod', 'karta', 'hotovost') NULL,
    poznamka VARCHAR(255) NULL,
    CONSTRAINT faktura_pk PRIMARY KEY (id_faktura),
    CONSTRAINT faktura_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva),
    CONSTRAINT faktura_suma_chk CHECK (suma > 0),
    CONSTRAINT faktura_datumy_chk CHECK (
        datum_splatnosti >= datum_vystavenia
        AND (datum_zaplatenia IS NULL OR datum_zaplatenia >= datum_vystavenia)
    ),
    CONSTRAINT faktura_cislo_uk UNIQUE (cislo_faktura),
    INDEX idx_faktura_zmluva_datumy (id_zmluva, datum_splatnosti, datum_zaplatenia)
);

CREATE TABLE zmluva_stav_historia (
    id_zmluva_stav_historia INT NOT NULL AUTO_INCREMENT,
    id_zmluva INT NOT NULL,
    stav_zmluvy ENUM('aktivna', 'zrusena', 'expirovana', 'vytvorena') NOT NULL,
    datum_zmeny TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT zmluva_stav_historia_pk PRIMARY KEY (id_zmluva_stav_historia),
    CONSTRAINT zmluva_stav_historia_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva),
    INDEX idx_zmluva_stav_historia_zmluva (id_zmluva, datum_zmeny)
);

CREATE TABLE faktura_stav_historia (
    id_faktura_stav_historia INT NOT NULL AUTO_INCREMENT,
    id_faktura INT NOT NULL,
    stav_faktury ENUM('nezaplatena', 'zaplatena') NOT NULL,
    datum_zaplatenia DATE NULL,
    datum_zmeny TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT faktura_stav_historia_pk PRIMARY KEY (id_faktura_stav_historia),
    CONSTRAINT faktura_stav_historia_faktura_fk FOREIGN KEY (id_faktura) REFERENCES faktura (id_faktura),
    INDEX idx_faktura_stav_historia_faktura (id_faktura, datum_zmeny)
);

CREATE TABLE poistna_udalost (
    id_poistna_udalost INT NOT NULL AUTO_INCREMENT,
    id_zmluva INT NOT NULL,
    popis_udalosti VARCHAR(255) NOT NULL,
    stav_udalosti BOOL NOT NULL DEFAULT FALSE,
    datum_udalosti DATE NOT NULL,
    datum_vyriesenia DATE NULL,
    suma_udalosti DECIMAL(10, 2) NULL,
    CONSTRAINT poistna_udalost_pk PRIMARY KEY (id_poistna_udalost),
    CONSTRAINT poistna_udalost_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva),
    CONSTRAINT poistna_udalost_suma_chk CHECK (suma_udalosti IS NULL OR suma_udalosti >= 0),
    INDEX idx_udalost_stav_datum (stav_udalosti, datum_udalosti)
);

CREATE TABLE ziadost_o_zmluvu (
    id_ziadost INT NOT NULL AUTO_INCREMENT,
    id_uzivatel INT NOT NULL,
    typ_poistenia ENUM('PZP', 'PZP+') NOT NULL DEFAULT 'PZP',
    dlzka_zmluvy_mesiace INT NOT NULL DEFAULT 6,
    datum_zaciatku_zmluvy DATE NOT NULL,
    znacka VARCHAR(15) NOT NULL,
    model VARCHAR(20) NOT NULL,
    kat_vozidla ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G') NOT NULL COMMENT 'A - Osobne auto, B - Motocykel, C - Nakladne auto/tahac, D - Bicykel s pomocnym motorom, E - Bus, F - Prives, G - Ine',
    ECV VARCHAR(7) NULL,
    VIN VARCHAR(17) NULL,
    cislo_motora VARCHAR(15) NULL,
    stav_ziadosti ENUM('cakajuca', 'schvalena', 'odmietnuta') NOT NULL DEFAULT 'cakajuca',
    poznamka VARCHAR(255) NOT NULL,
    CONSTRAINT ziadost_pk PRIMARY KEY (id_ziadost),
    CONSTRAINT ziadost_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    CONSTRAINT ziadost_ecv_chk CHECK (ECV REGEXP '[A-Z]{2}[0-9]{3}[A-Z]{2}'),
    CONSTRAINT ziadost_identifikator_chk CHECK (
        ECV IS NOT NULL OR 
        VIN IS NOT NULL OR 
        cislo_motora IS NOT NULL
    ),
    CONSTRAINT ziadost_dlzka_chk CHECK (dlzka_zmluvy_mesiace IN (3, 6, 12, 24))
);

CREATE TABLE cena_poistenia (
    id_cena INT NOT NULL AUTO_INCREMENT,
    typ_poistenia ENUM('PZP', 'PZP+') NOT NULL,
    cena DECIMAL(10, 2) NOT NULL,
    kat_vozidla ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G') NOT NULL,
    koeficient DECIMAL(10, 2) NOT NULL,
    datum_zmeny TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cena_poistenia_pk PRIMARY KEY (id_cena),
    CONSTRAINT cena_poistenia_typ_kat_uk UNIQUE (typ_poistenia, kat_vozidla),
    CONSTRAINT cena_poistenia_cena_chk CHECK (cena > 0),
    CONSTRAINT cena_poistenia_koeficient_chk CHECK (koeficient > 0)
);

-- Inicializacne data
INSERT INTO cena_poistenia (typ_poistenia, cena, kat_vozidla, koeficient) VALUES
-- PZP
('PZP', 8.5, 'A', 1.0),    -- osobne auto
('PZP', 8.5, 'B', 0.7),    -- motocykel
('PZP', 8.5, 'C', 1.8),    -- nákladné
('PZP', 8.5, 'D', 0.4),    -- bicykel s motorom
('PZP', 8.5, 'E', 2.5),    -- bus
('PZP', 8.5, 'F', 0.6),    -- príves
('PZP', 8.5, 'G', 1.0),    -- iné
-- PZP+
('PZP+', 12.0, 'A', 1.0),  -- osobne auto
('PZP+', 12.0, 'B', 0.7),  -- motocykel
('PZP+', 12.0, 'C', 1.8),  -- nákladné
('PZP+', 12.0, 'D', 0.4),  -- bicykel s motorom
('PZP+', 12.0, 'E', 2.5),  -- bus
('PZP+', 12.0, 'F', 0.6),  -- príves
('PZP+', 12.0, 'G', 1.0);  -- iné

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

CREATE VIEW admin_prehlad_uzivatelia_zmluvy_vozidla AS
SELECT
    u.id_uzivatel,
    v.id_vozidlo,
    z.id_zmluva,
    u.meno,
    u.priezvisko,
    u.nazov_firma,
    v.ECV,
    v.VIN,
    v.cislo_motora,
    v.kat_vozidla,
    z.datum_zaciatku,
    z.datum_konca,
    z.cena_poistneho,
    z.stav_zmluvy
FROM uzivatel u
JOIN zmluva z ON z.id_uzivatel = u.id_uzivatel
JOIN vozidlo v ON v.id_uzivatel = z.id_uzivatel;

DROP TRIGGER IF EXISTS uzivatel_bi_datum_upravy;
DROP TRIGGER IF EXISTS uzivatel_bu_datum_upravy;
DROP TRIGGER IF EXISTS uzivatel_bd;
DROP TRIGGER IF EXISTS vozidlo_bd;
DROP TRIGGER IF EXISTS zmluva_bi_validacia;
DROP TRIGGER IF EXISTS zmluva_bu_validacia;
DROP TRIGGER IF EXISTS zmluva_ai_historia;
DROP TRIGGER IF EXISTS zmluva_au_historia;
DROP TRIGGER IF EXISTS zmluva_bd;
DROP TRIGGER IF EXISTS faktura_ai_historia;
DROP TRIGGER IF EXISTS faktura_au_historia;
DROP TRIGGER IF EXISTS faktura_bd;
DROP TRIGGER IF EXISTS cena_poistenia_au_faktury;
DELIMITER $$

CREATE TRIGGER uzivatel_bi_datum_upravy
BEFORE INSERT ON uzivatel
FOR EACH ROW
BEGIN
    IF NEW.datum_upravy IS NULL THEN
        SET NEW.datum_upravy = CURRENT_DATE;
    END IF;
END$$

CREATE TRIGGER uzivatel_bu_datum_upravy
BEFORE UPDATE ON uzivatel
FOR EACH ROW
BEGIN
    SET NEW.datum_upravy = CURRENT_DATE;
END$$

CREATE TRIGGER vozidlo_bd
BEFORE DELETE ON vozidlo
FOR EACH ROW
BEGIN
    -- zmaz zmluvy (a ich zavisle zaznamy cez trigger zmluva_bd)
    DELETE FROM zmluva WHERE id_vozidlo = OLD.id_vozidlo;
END$$

CREATE TRIGGER zmluva_bi_validacia
BEFORE INSERT ON zmluva
FOR EACH ROW
BEGIN
    DECLARE vlastnik_vozidla INT;

    SELECT v.id_uzivatel
    INTO vlastnik_vozidla
    FROM vozidlo v
    WHERE v.id_vozidlo = NEW.id_vozidlo;

    IF vlastnik_vozidla IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Neexistujuce vozidlo pre zmluvu';
    END IF;

    IF vlastnik_vozidla <> NEW.id_uzivatel THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zmluva musi patrit rovnakej osobe ako vozidlo';
    END IF;
END$$

CREATE TRIGGER zmluva_bu_validacia
BEFORE UPDATE ON zmluva
FOR EACH ROW
BEGIN
    DECLARE vlastnik_vozidla INT;

    SELECT v.id_uzivatel
    INTO vlastnik_vozidla
    FROM vozidlo v
    WHERE v.id_vozidlo = NEW.id_vozidlo;

    IF vlastnik_vozidla IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Neexistujuce vozidlo pre zmluvu';
    END IF;

    IF vlastnik_vozidla <> NEW.id_uzivatel THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zmluva musi patrit rovnakej osobe ako vozidlo';
    END IF;
END$$

CREATE TRIGGER zmluva_ai_historia
AFTER INSERT ON zmluva
FOR EACH ROW
BEGIN
    INSERT INTO zmluva_stav_historia (id_zmluva, stav_zmluvy)
    VALUES (NEW.id_zmluva, NEW.stav_zmluvy);
END$$

CREATE TRIGGER zmluva_au_historia
AFTER UPDATE ON zmluva
FOR EACH ROW
BEGIN
    IF NEW.stav_zmluvy <> OLD.stav_zmluvy THEN
        INSERT INTO zmluva_stav_historia (id_zmluva, stav_zmluvy)
        VALUES (NEW.id_zmluva, NEW.stav_zmluvy);
    END IF;
END$$

CREATE TRIGGER zmluva_bd
BEFORE DELETE ON zmluva
FOR EACH ROW
BEGIN
    -- zmaz historia tabulky pre faktury
    DELETE fsh FROM faktura_stav_historia fsh
    JOIN faktura f ON f.id_faktura = fsh.id_faktura
    WHERE f.id_zmluva = OLD.id_zmluva;

    -- zmaz faktury
    DELETE FROM faktura WHERE id_zmluva = OLD.id_zmluva;

    -- zmaz poistne udalosti
    DELETE FROM poistna_udalost WHERE id_zmluva = OLD.id_zmluva;

    -- zmaz historia tabulky pre zmluvy
    DELETE FROM zmluva_stav_historia WHERE id_zmluva = OLD.id_zmluva;
END$$

CREATE TRIGGER faktura_ai_historia
AFTER INSERT ON faktura
FOR EACH ROW
BEGIN
    INSERT INTO faktura_stav_historia (id_faktura, stav_faktury, datum_zaplatenia)
    VALUES (
        NEW.id_faktura,
        IF(NEW.datum_zaplatenia IS NULL, 'nezaplatena', 'zaplatena'),
        NEW.datum_zaplatenia
    );
END$$

CREATE TRIGGER faktura_au_historia
AFTER UPDATE ON faktura
FOR EACH ROW
BEGIN
    IF (NEW.datum_zaplatenia IS NULL AND OLD.datum_zaplatenia IS NOT NULL)
        OR (NEW.datum_zaplatenia IS NOT NULL AND OLD.datum_zaplatenia IS NULL)
    THEN
        INSERT INTO faktura_stav_historia (id_faktura, stav_faktury, datum_zaplatenia)
        VALUES (
            NEW.id_faktura,
            IF(NEW.datum_zaplatenia IS NULL, 'nezaplatena', 'zaplatena'),
            NEW.datum_zaplatenia
        );
    END IF;

    -- aktivacia zmluvy po zaplateni (typicky prva faktura)
    IF OLD.datum_zaplatenia IS NULL AND NEW.datum_zaplatenia IS NOT NULL THEN
        UPDATE zmluva
        SET stav_zmluvy = 'aktivna'
        WHERE id_zmluva = NEW.id_zmluva
          AND stav_zmluvy = 'vytvorena';
    END IF;
END$$

CREATE TRIGGER faktura_bd
BEFORE DELETE ON faktura
FOR EACH ROW
BEGIN
    DELETE FROM faktura_stav_historia WHERE id_faktura = OLD.id_faktura;
END$$

CREATE TRIGGER uzivatel_bd
BEFORE DELETE ON uzivatel
FOR EACH ROW
BEGIN
    -- zmaz historia tabulky pre faktury
    DELETE fsh FROM faktura_stav_historia fsh
    JOIN faktura f ON f.id_faktura = fsh.id_faktura
    JOIN zmluva z ON z.id_zmluva = f.id_zmluva
    WHERE z.id_uzivatel = OLD.id_uzivatel;

    -- zmaz historia tabulky pre zmluvy
    DELETE zsh FROM zmluva_stav_historia zsh
    JOIN zmluva z ON z.id_zmluva = zsh.id_zmluva
    WHERE z.id_uzivatel = OLD.id_uzivatel;

    -- zmaz faktury
    DELETE f FROM faktura f
    JOIN zmluva z ON z.id_zmluva = f.id_zmluva
    WHERE z.id_uzivatel = OLD.id_uzivatel;

    -- zmaz poistne udalosti
    DELETE pu FROM poistna_udalost pu
    JOIN zmluva z ON z.id_zmluva = pu.id_zmluva
    WHERE z.id_uzivatel = OLD.id_uzivatel;

    -- zmaz zmluvy
    DELETE FROM zmluva WHERE id_uzivatel = OLD.id_uzivatel;

    -- zmaz vozidla
    DELETE FROM vozidlo WHERE id_uzivatel = OLD.id_uzivatel;

    -- zmaz ziadosti
    DELETE FROM ziadost_o_zmluvu WHERE id_uzivatel = OLD.id_uzivatel;
END$$

CREATE TRIGGER cena_poistenia_au_faktury
AFTER UPDATE ON cena_poistenia
FOR EACH ROW
BEGIN
    -- Aktualizuj všetky nezaplatené faktúry pre zmluvy s daným typom poistenia
    -- Nová suma = cena_poistenia * koeficient * počet mesiacov zmluvy
    UPDATE faktura f
    JOIN zmluva z ON z.id_zmluva = f.id_zmluva
    JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
    SET f.suma = NEW.cena * NEW.koeficient * TIMESTAMPDIFF(MONTH, z.datum_zaciatku, z.datum_konca)
    WHERE z.typ_poistenia = NEW.typ_poistenia
      AND v.kat_vozidla = NEW.kat_vozidla
      AND f.datum_zaplatenia IS NULL;
END$$

DELIMITER ;

INSERT INTO uzivatel(typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, tel_c, ulica_c, mesto, PSC, email, password, nazov_firma, ICO, DIC)
VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

SELECT * FROM uzivatel WHERE email = ?;

SELECT
   COUNT(*) as aktivne_zmluvy,
   (SELECT f.datum_splatnosti 
   FROM faktura f
   JOIN zmluva z ON z.id_zmluva = f.id_zmluva
   WHERE z.id_uzivatel = ? 
   AND f.datum_zaplatenia IS NULL
   ORDER BY f.datum_splatnosti ASC
   LIMIT 1) AS najblizsia_splatnost,
   (SELECT f.id_faktura
   FROM faktura f
   JOIN zmluva z ON z.id_zmluva = f.id_zmluva
   WHERE z.id_uzivatel = ? 
   AND f.datum_zaplatenia IS NULL
   ORDER BY f.datum_splatnosti ASC
   LIMIT 1) AS najblizsia_splatnost_id_faktura,
   (SELECT f.suma
   FROM faktura f
   JOIN zmluva z ON z.id_zmluva = f.id_zmluva
   WHERE z.id_uzivatel = ? 
   AND f.datum_zaplatenia IS NULL
   ORDER BY f.datum_splatnosti ASC
   LIMIT 1) AS najblizsia_splatnost_suma,
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
WHERE id_uzivatel = ? AND stav_zmluvy = 'aktivna';

SELECT
    z.id_zmluva,
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
ORDER BY z.id_zmluva DESC;

SELECT
    ECV,
    VIN,
    cislo_motora,
    znacka
FROM vozidlo
WHERE id_uzivatel = ?
ORDER BY id_vozidlo DESC;

SELECT
    p.id_poistna_udalost,
    p.id_zmluva,
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
WHERE z.id_uzivatel = ?;

SELECT
    COUNT(CASE WHEN stav_zmluvy = 'aktivna' THEN 1 END) AS aktivne_zmluvy,
    COUNT(CASE WHEN stav_zmluvy = 'expirovana' THEN 1 END) AS expirovane_zmluvy,
    COUNT(CASE WHEN stav_zmluvy = 'zrusena' THEN 1 END) AS zrusene_zmluvy,
    COUNT(CASE WHEN stav_zmluvy = 'vytvorena' THEN 1 END) AS vytvorene_nezaplatene_zmluvy
FROM zmluva
WHERE id_uzivatel = ?;

SELECT
    z.id_zmluva,
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
WHERE z.id_uzivatel = ?;

SELECT
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
ORDER BY z.id_zmluva ASC;

SELECT
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
WHERE f.id_zmluva = ? AND z.id_uzivatel = ?;

SELECT f.id_faktura FROM faktura f
JOIN zmluva z ON z.id_zmluva = f.id_zmluva
WHERE f.id_faktura = ? AND z.id_uzivatel = ?;

UPDATE faktura
SET datum_zaplatenia = CURDATE(), typ_platby = ?
WHERE id_faktura = ?;

SELECT id_zmluva
FROM zmluva 
WHERE id_zmluva = ?
    AND id_uzivatel = ?
    AND stav_zmluvy = 'aktivna';

INSERT INTO poistna_udalost (id_zmluva, popis_udalosti, datum_udalosti)
VALUES (?, ?, ?);

SELECT 
    p.id_poistna_udalost, p.stav_udalosti
FROM poistna_udalost p
JOIN zmluva z ON z.id_zmluva = p.id_zmluva
WHERE p.id_poistna_udalost = ? AND z.id_uzivatel = ?;

UPDATE poistna_udalost
SET popis_udalosti = ?, datum_udalosti = ?
WHERE id_poistna_udalost = ?;

INSERT INTO ziadost_o_zmluvu (id_uzivatel, typ_poistenia,  dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

UPDATE poistna_udalost 
SET stav_udalosti = TRUE, datum_vyriesenia = ?, suma_udalosti = ?
WHERE id_poistna_udalost = ?;

SELECT
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
    OR u.nazov_firma LIKE ?;

SELECT
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
WHERE zz.stav_ziadosti = 'cakajuca';

SELECT *
FROM ziadost_o_zmluvu
WHERE id_ziadost = ?;

SELECT id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora
FROM ziadost_o_zmluvu
WHERE id_ziadost = ?;

SELECT datum_zaciatku_zmluvy, typ_poistenia, dlzka_zmluvy_mesiace
FROM ziadost_o_zmluvu
WHERE id_ziadost = ?;

INSERT INTO vozidlo
(id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora)
VALUES (?, ?, ?, ?, ?, ?, ?);

INSERT INTO zmluva
(id_vozidlo, id_uzivatel, datum_zaciatku, datum_konca, typ_poistenia, cena_poistneho, stav_zmluvy)
VALUES (?, ?, ?, ?, ?, ?, ?);

INSERT INTO faktura
(id_zmluva, cislo_faktura, datum_vystavenia, datum_splatnosti, suma, poznamka)
VALUES (?, ?, ?, ?, ?, ?);

UPDATE ziadost_o_zmluvu
SET stav_ziadosti = ?
WHERE id_ziadost = ?;

UPDATE ziadost_o_zmluvu
SET stav_ziadosti = 'odmietnuta'
WHERE id_ziadost = ?;

SELECT * FROM admin_prehlad_uzivatelia_zmluvy_vozidla
WHERE id_uzivatel = ?;

DELETE FROM uzivatel WHERE id_uzivatel = ?;

SELECT
    COUNT(CASE WHEN stav_zmluvy = 'aktivna' THEN 1 END) AS aktivne_zmluvy,
    COUNT(CASE WHEN stav_zmluvy = 'expirovana' THEN 1 END) AS expirovane_zmluvy,
    COUNT(CASE WHEN stav_zmluvy = 'zrusena' THEN 1 END) AS zrusene_zmluvy,
    COUNT(CASE WHEN stav_zmluvy = 'vytvorena' THEN 1 END) AS vytvorene_nezaplatene_zmluvy
FROM zmluva;
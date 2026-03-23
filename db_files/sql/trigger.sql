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
DELIMITER ;

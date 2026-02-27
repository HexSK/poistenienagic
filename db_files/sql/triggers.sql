DROP TRIGGER IF EXISTS faktura_bi;
DELIMITER $$
CREATE TRIGGER faktura_bi
BEFORE INSERT ON faktura
FOR EACH ROW
BEGIN
    IF NEW.suma <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suma faktury musi byt > 0';
    END IF;
    IF NEW.datum_splatnosti < NEW.datum_vystavenia THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum splatnosti musi byt >= datum vystavenia';
    END IF;
    IF NEW.datum_zaplatenia IS NOT NULL AND NEW.datum_zaplatenia < NEW.datum_vystavenia THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum zaplatenia musi byt >= datum vystavenia';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS faktura_ai;
DELIMITER $$
CREATE TRIGGER faktura_ai
AFTER INSERT ON faktura
FOR EACH ROW
BEGIN
    INSERT INTO faktura_stav_historia (id_faktura, stary_stav, novy_stav, zmenil)
    VALUES (NEW.id_faktura, NULL, IF(NEW.datum_zaplatenia IS NULL, 'nezaplatena', 'zaplatena'), CURRENT_USER());
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS faktura_bu;
DELIMITER $$
CREATE TRIGGER faktura_bu
BEFORE UPDATE ON faktura
FOR EACH ROW
BEGIN
    IF NEW.suma <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suma faktury musi byt > 0';
    END IF;
    IF NEW.datum_splatnosti < NEW.datum_vystavenia THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum splatnosti musi byt >= datum vystavenia';
    END IF;
    IF NEW.datum_zaplatenia IS NOT NULL AND NEW.datum_zaplatenia < NEW.datum_vystavenia THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum zaplatenia musi byt >= datum vystavenia';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS faktura_au;
DELIMITER $$
CREATE TRIGGER faktura_au
AFTER UPDATE ON faktura
FOR EACH ROW
BEGIN
    DECLARE old_stav VARCHAR(12);
    DECLARE new_stav VARCHAR(12);

    SET old_stav = IF(OLD.datum_zaplatenia IS NULL, 'nezaplatena', 'zaplatena');
    SET new_stav = IF(NEW.datum_zaplatenia IS NULL, 'nezaplatena', 'zaplatena');

    IF old_stav <> new_stav THEN
        INSERT INTO faktura_stav_historia (id_faktura, stary_stav, novy_stav, zmenil)
        VALUES (NEW.id_faktura, old_stav, new_stav, CURRENT_USER());
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS poistna_udalost_bi;
DELIMITER $$
CREATE TRIGGER poistna_udalost_bi
BEFORE INSERT ON poistna_udalost
FOR EACH ROW
BEGIN
    IF NEW.stav_udalosti = 0 THEN
        IF NEW.datum_vyriesenia IS NOT NULL OR NEW.suma_udalosti IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nevyriesena udalost nemoze mat datum vyriesenia ani sumu';
        END IF;
    ELSE
        IF NEW.datum_vyriesenia IS NULL OR NEW.suma_udalosti IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vyriesena udalost musi mat datum vyriesenia a sumu';
        END IF;
        IF NEW.datum_vyriesenia < NEW.datum_udalosti THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum vyriesenia musi byt >= datum udalosti';
        END IF;
        IF NEW.suma_udalosti < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suma udalosti musi byt >= 0';
        END IF;
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS poistna_udalost_bu;
DELIMITER $$
CREATE TRIGGER poistna_udalost_bu
BEFORE UPDATE ON poistna_udalost
FOR EACH ROW
BEGIN
    IF NEW.stav_udalosti = 0 THEN
        IF NEW.datum_vyriesenia IS NOT NULL OR NEW.suma_udalosti IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nevyriesena udalost nemoze mat datum vyriesenia ani sumu';
        END IF;
    ELSE
        IF NEW.datum_vyriesenia IS NULL OR NEW.suma_udalosti IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vyriesena udalost musi mat datum vyriesenia a sumu';
        END IF;
        IF NEW.datum_vyriesenia < NEW.datum_udalosti THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum vyriesenia musi byt >= datum udalosti';
        END IF;
        IF NEW.suma_udalosti < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suma udalosti musi byt >= 0';
        END IF;
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS aktualizovat_uzivatel;
DELIMITER $$
CREATE TRIGGER aktualizovat_uzivatel
BEFORE UPDATE ON uzivatel
FOR EACH ROW
BEGIN
    SET NEW.datum_upravy = CURRENT_DATE;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS zmluva_bi;
DELIMITER $$
CREATE TRIGGER zmluva_bi
BEFORE INSERT ON zmluva
FOR EACH ROW
BEGIN
    IF NEW.datum_konca <= NEW.datum_zaciatku THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Neplatny interval zmluvy';
    END IF;
    IF NEW.cena_poistneho <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cena poistneho musi byt > 0';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM auto a
        WHERE a.id_auto = NEW.id_auto
          AND a.id_uzivatel = NEW.id_uzivatel
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zmluva musi byt viazana na vlastnika vozidla';
    END IF;
    IF NEW.stav_zmluvy = 'vytvorena' THEN
        IF CURRENT_DATE < NEW.datum_zaciatku THEN
            SET NEW.stav_zmluvy = 'vytvorena';
        ELSEIF CURRENT_DATE > NEW.datum_konca THEN
            SET NEW.stav_zmluvy = 'expirovana';
        ELSE
            SET NEW.stav_zmluvy = 'aktivna';
        END IF;
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS zmluva_ai;
DELIMITER $$
CREATE TRIGGER zmluva_ai
AFTER INSERT ON zmluva
FOR EACH ROW
BEGIN
    INSERT INTO zmluva_stav_historia (id_zmluva, stary_stav, novy_stav, zmenil)
    VALUES (NEW.id_zmluva, NULL, NEW.stav_zmluvy, CURRENT_USER());
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS zmluva_bu;
DELIMITER $$
CREATE TRIGGER zmluva_bu
BEFORE UPDATE ON zmluva
FOR EACH ROW
BEGIN
    IF NEW.datum_konca <= NEW.datum_zaciatku THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Neplatny interval zmluvy';
    END IF;
    IF NEW.cena_poistneho <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cena poistneho musi byt > 0';
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM auto a
        WHERE a.id_auto = NEW.id_auto
          AND a.id_uzivatel = NEW.id_uzivatel
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zmluva musi byt viazana na vlastnika vozidla';
    END IF;
    IF NEW.stav_zmluvy = 'vytvorena' THEN
        IF CURRENT_DATE < NEW.datum_zaciatku THEN
            SET NEW.stav_zmluvy = 'vytvorena';
        ELSEIF CURRENT_DATE > NEW.datum_konca THEN
            SET NEW.stav_zmluvy = 'expirovana';
        ELSE
            SET NEW.stav_zmluvy = 'aktivna';
        END IF;
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS zmluva_au;
DELIMITER $$
CREATE TRIGGER zmluva_au
AFTER UPDATE ON zmluva
FOR EACH ROW
BEGIN
    IF OLD.stav_zmluvy <> NEW.stav_zmluvy THEN
        INSERT INTO zmluva_stav_historia (id_zmluva, stary_stav, novy_stav, zmenil)
        VALUES (NEW.id_zmluva, OLD.stav_zmluvy, NEW.stav_zmluvy, CURRENT_USER());
    END IF;
END$$
DELIMITER ;

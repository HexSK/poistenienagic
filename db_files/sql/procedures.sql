DROP PROCEDURE IF EXISTS aktualizuj_stavy_zmluv;
DELIMITER $$
CREATE PROCEDURE aktualizuj_stavy_zmluv()
BEGIN
    UPDATE zmluva
    SET stav_zmluvy = CASE
        WHEN stav_zmluvy = 'zrusena' THEN 'zrusena'
        WHEN CURRENT_DATE < datum_zaciatku THEN 'vytvorena'
        WHEN CURRENT_DATE > datum_konca THEN 'expirovana'
        ELSE 'aktivna'
    END;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS vystav_fakturu;
DELIMITER $$
CREATE PROCEDURE vystav_fakturu(
    IN p_id_zmluva INT,
    IN p_datum_vystavenia DATE,
    IN p_datum_splatnosti DATE,
    IN p_suma DECIMAL(10,2)
)
BEGIN
    IF p_suma <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suma faktury musi byt > 0';
    END IF;

    IF p_datum_splatnosti < p_datum_vystavenia THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Datum splatnosti musi byt >= datum vystavenia';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM zmluva WHERE id_zmluva = p_id_zmluva) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zmluva neexistuje';
    END IF;

    INSERT INTO faktura (id_zmluva, datum_vystavenia, datum_splatnosti, datum_zaplatenia, suma)
    VALUES (p_id_zmluva, p_datum_vystavenia, p_datum_splatnosti, NULL, p_suma);
END$$
DELIMITER ;

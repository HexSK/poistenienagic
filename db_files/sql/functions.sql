DROP FUNCTION IF EXISTS suma_faktur_uzivatela;
DELIMITER $$
CREATE FUNCTION suma_faktur_uzivatela(p_id_zmluva INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE suma_faktur DECIMAL(12,2);

    SELECT COALESCE(SUM(suma), 0)
    INTO suma_faktur
    FROM faktura
    WHERE id_zmluva = p_id_zmluva;

    RETURN suma_faktur;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS je_zmluva_aktivna;
DELIMITER $$
CREATE FUNCTION je_zmluva_aktivna(p_id_zmluva INT)
RETURNS BOOL
DETERMINISTIC
BEGIN
    DECLARE v_active BOOL DEFAULT FALSE;

    SELECT (
        stav_zmluvy = 'aktivna'
        AND CURRENT_DATE BETWEEN datum_zaciatku AND datum_konca
    )
    INTO v_active
    FROM zmluva
    WHERE id_zmluva = p_id_zmluva;

    RETURN IFNULL(v_active, FALSE);
END$$
DELIMITER ;

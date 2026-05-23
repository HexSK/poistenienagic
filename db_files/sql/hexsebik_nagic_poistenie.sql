CREATE DATABASE IF NOT EXISTS hexsebik_nagic_poistenie;
USE hexsebik_nagic_poistenie;

DELIMITER $$

DROP FUNCTION IF EXISTS je_zmluva_aktivna$$
CREATE FUNCTION je_zmluva_aktivna (p_id_zmluva INT) RETURNS TINYINT(1) DETERMINISTIC
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

DROP FUNCTION IF EXISTS suma_faktur_uzivatela$$
CREATE FUNCTION suma_faktur_uzivatela (p_id_zmluva INT) RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
    DECLARE suma_faktur DECIMAL(12,2);

    SELECT COALESCE(SUM(suma), 0)
    INTO suma_faktur
    FROM faktura
    WHERE id_zmluva = p_id_zmluva;

    RETURN suma_faktur;
END$$

DELIMITER ;

-- --------------------------------------------------------
DROP TABLE IF EXISTS admin_prehlad_nezaplatene_zmluvy;
DROP VIEW IF EXISTS admin_prehlad_nezaplatene_zmluvy;
CREATE TABLE IF NOT EXISTS admin_prehlad_nezaplatene_zmluvy (
    id_zmluva INT(11),
    id_faktura INT(11),
    zobrazene_meno VARCHAR(91),
    ECV VARCHAR(7),
    datum_splatnosti DATE
);

-- --------------------------------------------------------
DROP TABLE IF EXISTS admin_prehlad_otvorene_poistne_udalosti;
DROP VIEW IF EXISTS admin_prehlad_otvorene_poistne_udalosti;
CREATE TABLE IF NOT EXISTS admin_prehlad_otvorene_poistne_udalosti (
    id_poistna_udalost INT(11),
    ECV VARCHAR(7),
    stav_udalosti TINYINT(1),
    datum_udalosti DATE,
    suma_udalosti DECIMAL(10,2)
);

-- --------------------------------------------------------
DROP TABLE IF EXISTS admin_prehlad_posledne_zmluvy;
DROP VIEW IF EXISTS admin_prehlad_posledne_zmluvy;
CREATE TABLE IF NOT EXISTS admin_prehlad_posledne_zmluvy (
    id_zmluva INT(11),
    zobrazene_meno VARCHAR(91),
    ECV VARCHAR(7),
    stav_zmluvy ENUM('aktivna','zrusena','expirovana','vytvorena'),
    datum_zaciatku DATE
);

-- --------------------------------------------------------
DROP TABLE IF EXISTS admin_prehlad_statistika;
DROP VIEW IF EXISTS admin_prehlad_statistika;
CREATE TABLE IF NOT EXISTS admin_prehlad_statistika (
    pocet_uzivatelov BIGINT(21),
    aktivne_zmluvy BIGINT(21),
    nezaplatene_faktury BIGINT(21),
    otvorene_udalosti BIGINT(21)
);

-- --------------------------------------------------------
DROP TABLE IF EXISTS admin_prehlad_uzivatelia_zmluvy_vozidla;
DROP VIEW IF EXISTS admin_prehlad_uzivatelia_zmluvy_vozidla;
CREATE TABLE IF NOT EXISTS admin_prehlad_uzivatelia_zmluvy_vozidla (
    id_uzivatel INT(11),
    id_vozidlo INT(11),
    id_zmluva INT(11),
    meno VARCHAR(30),
    priezvisko VARCHAR(60),
    nazov_firma VARCHAR(60),
    ECV VARCHAR(7),
    VIN VARCHAR(17),
    cislo_motora VARCHAR(15),
    kat_vozidla ENUM('A','B','C','D','E','F','G'),
    datum_zaciatku DATE,
    datum_konca DATE,
    cena_poistneho DECIMAL(10,2),
    stav_zmluvy ENUM('aktivna','zrusena','expirovana','vytvorena')
);

-- --------------------------------------------------------
DROP TABLE IF EXISTS faktura;
CREATE TABLE faktura (
    id_faktura INT(11) NOT NULL AUTO_INCREMENT,
    id_zmluva INT(11) NOT NULL,
    cislo_faktura VARCHAR(20) NOT NULL,
    datum_vystavenia DATE NOT NULL,
    datum_splatnosti DATE NOT NULL,
    datum_zaplatenia DATE DEFAULT NULL,
    suma DECIMAL(10,2) NOT NULL,
    typ_platby ENUM('prevod','karta','hotovost') DEFAULT NULL,
    poznamka VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (id_faktura),
    UNIQUE KEY faktura_cislo_uk (cislo_faktura),
    KEY idx_faktura_zmluva_datumy (id_zmluva,datum_splatnosti,datum_zaplatenia)
);

INSERT INTO faktura (id_faktura, id_zmluva, cislo_faktura, datum_vystavenia, datum_splatnosti, datum_zaplatenia, suma, typ_platby, poznamka) VALUES
    (1, 1, '2026/0001', '2026-04-16', '2026-04-30', '2026-04-16', 144.00, 'karta', NULL),
    (2, 2, '2026/0002', '2026-04-16', '2026-04-30', '2026-04-16', 102.00, 'karta', NULL),
    (3, 3, '2026/0003', '2026-04-16', '2026-04-30', '2026-04-16', 144.00, 'karta', NULL),
    (4, 4, '2026/0004', '2026-04-16', '2026-04-30', '2026-04-16', 518.40, 'hotovost', NULL),
    (5, 5, '2026/0005', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL),
    (6, 6, '2026/0006', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL),
    (7, 7, '2026/0007', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL),
    (8, 8, '2026/0008', '2026-04-16', '2026-04-30', NULL, 102.00, NULL, NULL),
    (9, 9, '2026/0009', '2026-04-16', '2026-04-30', NULL, 102.00, NULL, NULL),
    (10, 10, '2026/0010', '2026-04-16', '2026-04-30', NULL, 102.00, NULL, NULL),
    (11, 11, '2026/0011', '2026-04-16', '2026-04-30', NULL, 102.00, NULL, NULL),
    (12, 12, '2026/0012', '2026-04-16', '2026-04-30', NULL, 102.00, NULL, NULL),
    (13, 13, '2026/0013', '2026-04-16', '2026-04-30', NULL, 259.20, NULL, NULL),
    (14, 14, '2026/0014', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL),
    (15, 15, '2026/0015', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL),
    (16, 16, '2026/0016', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL),
    (17, 17, '2026/0017', '2026-04-16', '2026-04-30', NULL, 144.00, NULL, NULL);

DROP TRIGGER IF EXISTS faktura_ai_historia;
DELIMITER $$
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
DELIMITER ;

DROP TRIGGER IF EXISTS faktura_au_historia;
DELIMITER $$
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
DELIMITER ;

DROP TRIGGER IF EXISTS faktura_bd;
DELIMITER $$
CREATE TRIGGER faktura_bd
BEFORE DELETE ON faktura
FOR EACH ROW
BEGIN
    DELETE FROM faktura_stav_historia WHERE id_faktura = OLD.id_faktura;
END$$
DELIMITER ;

-- --------------------------------------------------------
DROP TABLE IF EXISTS faktura_stav_historia;
CREATE TABLE IF NOT EXISTS faktura_stav_historia (
    id_faktura_stav_historia INT(11) NOT NULL AUTO_INCREMENT,
    id_faktura INT(11) NOT NULL,
    stav_faktury ENUM('nezaplatena','zaplatena') NOT NULL,
    datum_zaplatenia DATE DEFAULT NULL,
    datum_zmeny TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (id_faktura_stav_historia),
    KEY idx_faktura_stav_historia_faktura (id_faktura,datum_zmeny)
);

INSERT INTO faktura_stav_historia (id_faktura_stav_historia, id_faktura, stav_faktury, datum_zaplatenia, datum_zmeny) VALUES
    (1, 1, 'nezaplatena', NULL, '2026-04-16 06:19:01'),
    (2, 2, 'nezaplatena', NULL, '2026-04-16 06:19:06'),
    (3, 1, 'zaplatena', '2026-04-16', '2026-04-16 06:26:07'),
    (4, 2, 'zaplatena', '2026-04-16', '2026-04-16 06:26:19'),
    (5, 3, 'nezaplatena', NULL, '2026-04-16 07:12:16'),
    (6, 4, 'nezaplatena', NULL, '2026-04-16 07:12:20'),
    (7, 3, 'zaplatena', '2026-04-16', '2026-04-16 07:13:16'),
    (8, 4, 'zaplatena', '2026-04-16', '2026-04-16 07:13:39'),
    (9, 5, 'nezaplatena', NULL, '2026-04-16 19:02:11'),
    (10, 6, 'nezaplatena', NULL, '2026-04-16 19:02:16'),
    (11, 7, 'nezaplatena', NULL, '2026-04-16 19:02:19'),
    (12, 8, 'nezaplatena', NULL, '2026-04-16 19:02:23'),
    (13, 9, 'nezaplatena', NULL, '2026-04-16 19:02:28'),
    (14, 10, 'nezaplatena', NULL, '2026-04-16 19:02:32'),
    (15, 11, 'nezaplatena', NULL, '2026-04-16 19:02:35'),
    (16, 12, 'nezaplatena', NULL, '2026-04-16 19:02:38'),
    (17, 13, 'nezaplatena', NULL, '2026-04-16 19:02:42'),
    (18, 14, 'nezaplatena', NULL, '2026-04-16 19:02:45'),
    (19, 15, 'nezaplatena', NULL, '2026-04-16 19:02:48'),
    (20, 16, 'nezaplatena', NULL, '2026-04-16 19:02:51'),
    (21, 17, 'nezaplatena', NULL, '2026-04-16 19:02:54');
-- --------------------------------------------------------
DROP TABLE IF EXISTS poistna_udalost;
CREATE TABLE poistna_udalost (
    id_poistna_udalost INT(11) NOT NULL AUTO_INCREMENT,
    id_zmluva INT(11) NOT NULL,
    popis_udalosti VARCHAR(255) NOT NULL,
    stav_udalosti TINYINT(1) NOT NULL DEFAULT 0,
    datum_udalosti DATE NOT NULL,
    datum_vyriesenia DATE DEFAULT NULL,
    suma_udalosti DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (id_poistna_udalost),
    KEY poistna_udalost_zmluva_fk (id_zmluva),
    KEY idx_udalost_stav_datum (stav_udalosti,datum_udalosti)
);

-- --------------------------------------------------------
DROP TABLE IF EXISTS uzivatel;
CREATE TABLE uzivatel (
    id_uzivatel INT(11) NOT NULL AUTO_INCREMENT,
    typ_uzivatela ENUM('k','kf','a') NOT NULL DEFAULT 'k',
    meno VARCHAR(30) NOT NULL,
    priezvisko VARCHAR(60) NOT NULL,
    datum_narodenia DATE NOT NULL,
    rod_cislo VARCHAR(11) DEFAULT NULL,
    tel_c VARCHAR(20) NOT NULL,
    ulica_c VARCHAR(40) NOT NULL,
    mesto VARCHAR(20) NOT NULL,
    PSC VARCHAR(6) NOT NULL,
    email VARCHAR(64) NOT NULL,
    password VARCHAR(255) NOT NULL,
    datum_upravy DATE NOT NULL,
    nazov_firma VARCHAR(60) DEFAULT NULL,
    ICO VARCHAR(8) DEFAULT NULL,
    DIC VARCHAR(10) DEFAULT NULL,
    PRIMARY KEY (id_uzivatel),
    UNIQUE KEY uzivatel_email_uk (email),
    UNIQUE KEY uzivatel_rc_uk (rod_cislo),
    UNIQUE KEY uzivatel_ico_uk (ICO),
    UNIQUE KEY uzivatel_dic_uk (DIC)
);

INSERT INTO uzivatel (id_uzivatel, typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, tel_c, ulica_c, mesto, PSC, email, password, datum_upravy, nazov_firma, ICO, DIC) VALUES
    (1, 'a', 'Sebastian', 'Igaz', '2000-05-21', '0905217731', '+421910521618', 'Laca Novomeskeho 2', 'Presov', '08001', 'hex.ets2@gmail.com', '$2b$10$zNjuh3pdlnCbYH7lCmgWYuFjZPwqXGLr4tqqldaUT4uu9Ij9kDTIO', '2026-04-15', NULL, NULL, NULL),
    (3, 'kf', 'Nicolas', 'Fecko', '2000-04-08', NULL, '+421918556748', 'Pecovska Nova Ves 67', 'Pecovska Nova Ves', '08526', 'nfecko9@gmail.com', '$2b$10$HP/i6Xs2jL7EeXqVnqAyWOXovgMd8KJLez7NG19Lxqkfa5TBG8ASq', '2026-04-15', 'JEEVacation', '12345678', '0123456789'),
    (5, 'kf', 'Maros', 'Cigjak', '2000-04-27', '0004276767', '+421957685492', 'Kanas 67', 'Velky Saris', '08252', 'cigjak@jeevacation.com', '$2b$10$gDWXjsQLfWUjUSiHAr4JaewE1c0t2/LE2SFjmkevF98RPH80CQAOm', '2026-04-15', 'Cigjak s.r.o.', '87654321', '0987654321'),
    (6, 'kf', 'Pavol', 'Mudrík', '2000-08-08', '0008086767', '+421957685492', 'Dulova Nova Ves 67', 'Dulova Ves', '08266', 'mudrik@jeevacation.com', '$2b$10$F4/ykAbZ8OfMYpeJaw9UHeMk9Yp8iJ1o4ZYPcmLvFRMiNeawVX9/2', '2026-04-15', 'Panavia Aircraft', '67676767', '6767676767'),
    (8, 'kf', 'Jakub', 'Zajac', '2000-06-07', '0006076748', '+421957683433', 'Gregorovce 67', 'Gregorovce', '67676', 'zajac.jakub09@jeevacation.com', '$2b$10$kha2VG9D2aDP5DjTPX3dq.NfNhg.dAo5dwQHYZR1YarEq8ZfcN01W', '2026-04-15', 'JEEVacation', '13243546', '0897867564'),
    (9, 'k', 'Patrik', 'Lech', '2000-03-27', '0003276767', '+4521951625447', 'Jantarova 6A', 'Presov', '08001', 'patriklech@jeevacation.com', '$2b$10$R5bCrp5kDzBugmmVgLstDuATcE4rqAb20N/wvVk9ABRNAapYJKzqu', '2026-04-16', NULL, NULL, NULL),
    (10, 'k', 'Brigita', 'Lakatos', '2000-03-06', '0003063748', '+421958671325', 'Stanicna 1', 'Spisska Nova Ves', '05201', 'brigitatvoja@jeevacation.com', '$2b$10$XwHRIYOwYvBEyF33gLlyTOaBIii9Exxsx.k6uz2u0SSMrXInijnFe', '2026-04-16', NULL, NULL, NULL),
    (12, 'kf', 'Kylian', 'Doutreluigne', '2000-03-11', '0003113848', '+421953687598', 'Hlavna 62', 'Presov', '08001', 'lukasm@jeevacation.com', '$2b$10$LBNlhx4ZQCUZ4o55lf4Dh.GBdoySiBQih0HhD2pgzeJnfdHkXeSO2', '2026-04-16', 'Kaelys Virtual', '76395739', '3958592093'),
    (13, 'kf', 'Iveta', 'Kovalova', '1968-02-03', '6802035839', '+421958745628', 'Hlavna 35', 'Presov', '08001', 'kovalovai67@gmail.com', '$2b$10$1oa7lauUwE0.1U7DcKTNs.L1W1A4Qiv6X.HQNKGBUQUilREPsHIXO', '2026-04-16', 'SPSE PO', '52635784', '7351495720'),
    (14, 'kf', 'Jan', 'Novak', '2001-02-04', '0102043941', '+421958478569', 'Hlavna 3', 'Kosice', '04001', 'novakj67@gmail.com', '$2b$10$e5PVhK.6sXkOg8mC8Ipq2uLktOvxIL9Nm6CDHCe.S0uW3GYqtYHi6', '2026-04-16', 'Letisko Kosice (KSC)', '35028472', '4478596587'),
    (15, 'kf', 'Peter', 'Lukas', '2002-03-08', '0203083849', '+421985632584', 'Jantarova 86', 'Humenne', '06601', 'peter.l.35@gmail.com', '$2b$10$C/mK.BJ6.Bp9KdPC1j0FEuQIdGbDx7dajkVdS9KOlxcd57uJi2IkpgW', '2026-04-16', 'KralovstvoHumenne s.r.o', '28492738', '9097429039'),
    (16, 'k', 'Pavol', 'Cigjak', '2001-09-30', '0109314892', '+421986547854', 'Kanas 48', 'Velky Saris', '08252', 'cigjakp@gmail.com', '$2b$10$QKLjdQPs6Pc1TeYnektumOpREM1ovIE4fuS0YCALvRuatUWL0e.0G', '2026-04-16', NULL, NULL, NULL),
    (17, 'k', 'Jeffrey', 'Lech', '2000-09-12', '0009122948', '+421957685687', 'Pomarancova 39', 'Presov', '08002', 'lechj.87@gmail.com', '$2b$10$wB4QE8PQj8X0VcQLNRd9MuhQyf7tm.g5OCQmo7RIfDXs4Bc3Jz22', '2026-04-16', NULL, NULL, NULL),
    (18, 'kf', 'Martin', 'Kubik', '2000-06-30', '0006302948', '+421958785456', 'Stolarska 1', 'Spisska Nova Ves', '05201', 'kubikm@gmail.com', '$2b$10$LY6yOoST2g5I6Ww2PybhvuMV8bCTAAaac3MAZ8Tq6Ic4hgOUq14I.', '2026-04-16', 'Ciganava s.r.o', '84569657', '1245874858'),
    (19, 'k', 'Maros', 'Jantar', '1999-04-28', '9904288374', '+421968598587', 'Drevena 47', 'Kosice', '04002', 'jantar.maros.99@gmail.com', '$2b$10$KxipusANUdF4u+Qor0xD1V8T0m6GivkzVVhGeYn2a1yiLnxAr4tba', '2026-04-16', NULL, NULL, NULL),
    (20, 'kf', 'Dominik', 'Kundrat', '2000-08-28', '0008288938', '+421958658452', 'Laca Novomeskeho 14', 'Presov', '08001', 'k.dominik288@gmail.com', '$2b$10$H26na7i.NxVINO0HUGF6U.OCSITRXBEz.8wIcalV8VPXtQ40VQvQO', '2026-04-16', 'KundratTrans s.r.o.', '89384758', '9829304989'),
    (21, 'kf', 'Martin', 'Peter', '2000-09-28', '0009287823', '+41986748654', 'Tomasikova 44', 'Presov', '08001', 'petermartin58@gmail.com', '$2b$10$m7gh4773DgklR.D5Y/8ztuwyxOdnoa/vhRzYSnNRlB4HvEG3/F.jW', '2026-04-16', 'STVR', '19283948', '2938476789');

DROP TRIGGER IF EXISTS uzivatel_bd;
DELIMITER $$
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

DELIMITER ;

-- --------------------------------------------------------
DROP TABLE IF EXISTS vozidlo;
CREATE TABLE vozidlo (
    id_vozidlo INT(11) NOT NULL AUTO_INCREMENT,
    id_uzivatel INT(11) NOT NULL,
    znacka VARCHAR(15) NOT NULL,
    model VARCHAR(20) NOT NULL,
    kat_vozidla ENUM('A','B','C','D','E','F','G') NOT NULL COMMENT 'A - Osobne auto, B - Motocykel, C - Nakladne auto/tahac, D - Bicykel s pomocnym motorom, E - Bus, F - Prives, G - Ine',
    ECV VARCHAR(7) DEFAULT NULL,
    VIN VARCHAR(17) DEFAULT NULL,
    cislo_motora VARCHAR(15) DEFAULT NULL,
    PRIMARY KEY (id_vozidlo),
    UNIQUE KEY vozidlo_ecv_uk (ECV),
    UNIQUE KEY vozidlo_vin_uk (VIN),
    UNIQUE KEY vozidlo_cm_uk (cislo_motora),
    KEY vozidlo_uzivatel_fk (id_uzivatel)
);

INSERT INTO vozidlo (id_vozidlo, id_uzivatel, znacka, model, kat_vozidla, ECV, VIN, cislo_motora) VALUES
    (1, 5, 'Skoda', 'Octavia', 'A', 'PO298FJ', NULL, NULL),
    (2, 5, 'Ferrari', 'SF-25', 'G', NULL, '1C4HJXDG3MW061978', NULL),
    (3, 9, 'Lada', 'Niva', 'A', 'PO398BF', '1C4HJXDG3MB482049', NULL),
    (4, 9, 'Iveco', 'Stralis 460', 'C', 'BL340WE', NULL, NULL),
    (5, 3, 'Skoda', 'Octavia', 'A', 'PO298DC', NULL, NULL, NULL),
    (6, 5, 'Renault', 'Megane', 'A', 'AA938BB', NULL, NULL),
    (7, 8, 'BYD', 'dajake urcite', 'A', 'AA493LB', NULL, NULL),
    (8, 9, 'Honda', 'Civic', 'A', 'PO239BD', NULL, NULL),
    (9, 12, 'Renault', 'Twingo', 'A', 'PO202CE', NULL, NULL),
    (10, 13, 'Volkswagen', 'Phateon', 'A', 'PO109JF', NULL, NULL),
    (11, 14, 'Renault', 'Megane Cabrio', 'A', 'KS938CD', NULL, NULL),
    (12, 15, 'Kia', 'Ceed', 'A', 'HE394BD', NULL, NULL),
    (13, 16, 'DAF', 'XF 510', 'C', 'SB393KK', NULL, NULL),
    (14, 18, 'Maserati', 'Pohrebny Voz', 'A', 'PO888HH', NULL, NULL),
    (15, 19, 'Skoda', 'Superb', 'A', 'PO239FJ', NULL, NULL),
    (16, 20, 'Skoda', 'Felicia', 'A', 'AA239FB', NULL, NULL),
    (17, 21, 'MAN', 'TGX 22.460', 'A', 'AB239DJ', NULL, NULL);

-- --------------------------------------------------------
DROP TABLE IF EXISTS ziadost_o_zmluvu;
CREATE TABLE ziadost_o_zmluvu (
    id_ziadost INT(11) NOT NULL AUTO_INCREMENT,
    id_uzivatel INT(11) NOT NULL,
    typ_poistenia ENUM('PZP','PZP+') NOT NULL DEFAULT 'PZP',
    dlzka_zmluvy_mesiace INT(11) NOT NULL DEFAULT 6,
    datum_zaciatku_zmluvy DATE NOT NULL,
    znacka VARCHAR(15) NOT NULL,
    model VARCHAR(20) NOT NULL,
    kat_vozidla ENUM('A','B','C','D','E','F','G') NOT NULL COMMENT 'A - Osobne auto, B - Motocykel, C - Nakladne auto/tahac, D - Bicykel s pomocnym motorom, E - Bus, F - Prives, G - Ine',
    ECV VARCHAR(7) DEFAULT NULL,
    VIN VARCHAR(17) DEFAULT NULL,
    cislo_motora VARCHAR(15) DEFAULT NULL,
    stav_ziadosti ENUM('cakajuca','schvalena','odmietnuta') NOT NULL DEFAULT 'cakajuca',
    poznamka VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_ziadost),
    KEY ziadost_uzivatel_fk (id_uzivatel)
);

INSERT INTO ziadost_o_zmluvu (id_ziadost, id_uzivatel, typ_poistenia, dlzka_zmluvy_mesiace, datum_zaciatku_zmluvy, znacka, model, kat_vozidla, ECV, VIN, cislo_motora, stav_ziadosti, poznamka) VALUES
    (1, 5, 'PZP+', 12, '2026-04-24', 'Skoda', 'Octavia', 'A', 'PO298FJ', NULL, NULL, 'schvalena', ''),
    (2, 5, 'PZP', 12, '2026-05-21', 'Ferrari', 'SF-25', 'G', NULL, '1C4HJXDG3MW061978', NULL, 'schvalena', ''),
    (3, 9, 'PZP+', 12, '2026-04-28', 'Lada', 'Niva', 'A', 'PO398BF', '1C4HJXDG3MB482049', NULL, 'schvalena', ''),
    (4, 9, 'PZP+', 24, '2026-05-28', 'Iveco', 'Stralis 460', 'C', 'BL340WE', NULL, NULL, 'schvalena', ''),
    (5, 3, 'PZP+', 12, '2026-05-01', 'Skoda', 'Octavia', 'A', 'PO298DC', NULL, NULL, 'schvalena', ''),
    (6, 5, 'PZP+', 12, '2026-05-02', 'Renault', 'Megane', 'A', 'AA938BB', NULL, NULL, 'schvalena', ''),
    (7, 8, 'PZP+', 12, '2026-05-21', 'BYD', 'dajake urcite', 'A', 'AA493LB', NULL, NULL, 'schvalena', ''),
    (8, 9, 'PZP', 12, '2026-05-02', 'Honda', 'Civic', 'A', 'PO239BD', NULL, NULL, 'schvalena', ''),
    (9, 12, 'PZP', 12, '2026-05-24', 'Renault', 'Twingo', 'A', 'PO202CE', NULL, NULL, 'schvalena', ''),
    (10, 13, 'PZP', 12, '2026-06-26', 'Volkswagen', 'Phateon', 'A', 'PO109JF', NULL, NULL, 'schvalena', ''),
    (11, 14, 'PZP', 12, '2026-04-29', 'Renault', 'Megane Cabrio', 'A', 'KS938CD', NULL, NULL, 'schvalena', ''),
    (12, 15, 'PZP', 12, '2026-04-28', 'Kia', 'Ceed', 'A', 'HE394BD', NULL, NULL, 'schvalena', ''),
    (13, 16, 'PZP+', 12, '2026-09-11', 'DAF', 'XF 510', 'C', 'SB393KK', NULL, NULL, 'schvalena', ''),
    (14, 18, 'PZP+', 12, '2026-06-20', 'Maserati', 'Pohrebny Voz', 'A', 'PO888HH', NULL, NULL, 'schvalena', ''),
    (15, 19, 'PZP+', 12, '2026-05-21', 'Skoda', 'Superb', 'A', 'PO239FJ', NULL, NULL, 'schvalena', ''),
    (16, 20, 'PZP+', 12, '2026-05-02', 'Skoda', 'Felicia', 'A', 'AA239FB', NULL, NULL, 'schvalena', ''),
    (17, 21, 'PZP+', 12, '2026-08-21', 'MAN', 'TGX 22.460', 'A', 'AB239DJ', NULL, NULL, 'schvalena', '');
-- --------------------------------------------------------
DROP TABLE IF EXISTS zmluva;
CREATE TABLE zmluva (
    id_zmluva INT(11) NOT NULL AUTO_INCREMENT,
    id_vozidlo INT(11) NOT NULL,
    id_uzivatel INT(11) NOT NULL,
    datum_zaciatku DATE NOT NULL,
    datum_konca DATE NOT NULL,
    typ_poistenia ENUM('PZP','PZP+') NOT NULL DEFAULT 'PZP',
    cena_poistneho DECIMAL(10,2) NOT NULL,
    stav_zmluvy ENUM('aktivna','zrusena','expirovana','vytvorena') NOT NULL DEFAULT 'vytvorena',
    PRIMARY KEY (id_zmluva),
    KEY zmluva_vozidlo_fk (id_vozidlo),
    KEY zmluva_uzivatel_fk (id_uzivatel),
    KEY idx_zmluva_stav_koniec (stav_zmluvy,datum_konca)
);

INSERT INTO zmluva (id_zmluva, id_vozidlo, id_uzivatel, datum_zaciatku, datum_konca, typ_poistenia, cena_poistneho, stav_zmluvy) VALUES
    (1, 1, 5, '2026-04-24', '2027-04-24', 'PZP+', 144.00, 'aktivna'),
    (2, 2, 5, '2026-05-21', '2027-05-21', 'PZP', 102.00, 'aktivna'),
    (3, 3, 9, '2026-04-28', '2027-04-28', 'PZP+', 144.00, 'aktivna'),
    (4, 4, 9, '2026-05-28', '2028-05-28', 'PZP+', 518.40, 'aktivna'),
    (5, 5, 3, '2026-05-01', '2027-05-01', 'PZP+', 144.00, 'vytvorena'),
    (6, 6, 5, '2026-05-02', '2027-05-02', 'PZP+', 144.00, 'vytvorena'),
    (7, 7, 8, '2026-05-21', '2027-05-21', 'PZP+', 144.00, 'vytvorena'),
    (8, 8, 9, '2026-05-02', '2027-05-02', 'PZP', 102.00, 'vytvorena'),
    (9, 9, 12, '2026-05-24', '2027-05-24', 'PZP', 102.00, 'vytvorena'),
    (10, 10, 13, '2026-06-26', '2027-06-26', 'PZP', 102.00, 'vytvorena'),
    (11, 11, 14, '2026-04-29', '2027-04-29', 'PZP', 102.00, 'vytvorena'),
    (12, 12, 15, '2026-04-28', '2027-04-28', 'PZP', 102.00, 'vytvorena'),
    (13, 13, 16, '2026-09-11', '2027-09-11', 'PZP+', 259.20, 'vytvorena'),
    (14, 14, 18, '2026-06-20', '2027-06-20', 'PZP+', 144.00, 'vytvorena'),
    (15, 15, 19, '2026-05-21', '2027-05-21', 'PZP+', 144.00, 'vytvorena'),
    (16, 16, 20, '2026-05-02', '2027-05-02', 'PZP+', 144.00, 'vytvorena'),
    (17, 17, 21, '2026-08-21', '2027-08-21', 'PZP+', 144.00, 'vytvorena');

DROP TRIGGER IF EXISTS zmluva_ai_historia;
DELIMITER $$
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
DELIMITER ;

DROP TABLE IF EXISTS zmluva_stav_historia;
CREATE TABLE zmluva_stav_historia (
    id_zmluva_stav_historia INT(11) NOT NULL AUTO_INCREMENT,
    id_zmluva INT(11) NOT NULL,
    stav_zmluvy ENUM('aktivna','zrusena','expirovana','vytvorena') NOT NULL,
    datum_zmeny TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (id_zmluva_stav_historia),
    KEY idx_zmluva_stav_historia_zmluva (id_zmluva,datum_zmeny)
);

INSERT INTO zmluva_stav_historia (id_zmluva_stav_historia, id_zmluva, stav_zmluvy, datum_zmeny) VALUES
    (1, 1, 'vytvorena', '2026-04-16 06:19:01'),
    (2, 2, 'vytvorena', '2026-04-16 06:19:06'),
    (3, 1, 'aktivna', '2026-04-16 06:26:07'),
    (4, 2, 'aktivna', '2026-04-16 06:26:19'),
    (5, 3, 'vytvorena', '2026-04-16 07:12:16'),
    (6, 4, 'vytvorena', '2026-04-16 07:12:20'),
    (7, 3, 'aktivna', '2026-04-16 07:13:16'),
    (8, 4, 'aktivna', '2026-04-16 07:13:39'),
    (9, 5, 'vytvorena', '2026-04-16 19:02:11'),
    (10, 6, 'vytvorena', '2026-04-16 19:02:16'),
    (11, 7, 'vytvorena', '2026-04-16 19:02:19'),
    (12, 8, 'vytvorena', '2026-04-16 19:02:23'),
    (13, 9, 'vytvorena', '2026-04-16 19:02:28'),
    (14, 10, 'vytvorena', '2026-04-16 19:02:32'),
    (15, 11, 'vytvorena', '2026-04-16 19:02:35'),
    (16, 12, 'vytvorena', '2026-04-16 19:02:38'),
    (17, 13, 'vytvorena', '2026-04-16 19:02:42'),
    (18, 14, 'vytvorena', '2026-04-16 19:02:45'),
    (19, 15, 'vytvorena', '2026-04-16 19:02:48'),
    (20, 16, 'vytvorena', '2026-04-16 19:02:51'),
    (21, 17, 'vytvorena', '2026-04-16 19:02:54');
-- --------------------------------------------------------
DROP VIEW IF EXISTS admin_prehlad_nezaplatene_zmluvy;
CREATE VIEW admin_prehlad_nezaplatene_zmluvy AS
SELECT
    z.id_zmluva,
    f.id_faktura,
    COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno,
    v.ECV,
    f.datum_splatnosti
FROM zmluva z
JOIN uzivatel u ON z.id_uzivatel = u.id_uzivatel
JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
JOIN faktura f ON f.id_zmluva = z.id_zmluva
WHERE
    CURRENT_DATE > f.datum_splatnosti
    AND f.datum_zaplatenia IS NULL
ORDER BY z.id_zmluva ASC;

-- --------------------------------------------------------
DROP VIEW IF EXISTS admin_prehlad_otvorene_poistne_udalosti;
CREATE VIEW admin_prehlad_otvorene_poistne_udalosti AS
SELECT
    p.id_poistna_udalost,
    v.ECV,
    p.stav_udalosti,
    p.datum_udalosti,
    p.suma_udalosti
FROM poistna_udalost p
JOIN zmluva z ON z.id_zmluva = p.id_zmluva
JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
WHERE p.stav_udalosti = 0;

-- --------------------------------------------------------
DROP VIEW IF EXISTS admin_prehlad_posledne_zmluvy;
CREATE VIEW admin_prehlad_posledne_zmluvy AS
SELECT
    z.id_zmluva,
    COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno,
    v.ECV,
    z.stav_zmluvy,
    z.datum_zaciatku
FROM zmluva z
JOIN uzivatel u ON z.id_uzivatel = u.id_uzivatel
JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
ORDER BY z.id_zmluva DESC
LIMIT 5;

-- --------------------------------------------------------
DROP VIEW IF EXISTS admin_prehlad_statistika;
CREATE VIEW admin_prehlad_statistika AS
SELECT
    (SELECT COUNT(*) FROM uzivatel) AS pocet_uzivatelov,
    (SELECT COUNT(*) FROM zmluva WHERE stav_zmluvy = 'aktivna') AS aktivne_zmluvy,
    (SELECT COUNT(*) FROM faktura WHERE datum_zaplatenia IS NULL) AS nezaplatene_faktury,
    (SELECT COUNT(*) FROM poistna_udalost WHERE stav_udalosti = 0) AS otvorene_udalosti;

-- --------------------------------------------------------
DROP VIEW IF EXISTS admin_prehlad_uzivatelia_zmluvy_vozidla;
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
JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo;


ALTER TABLE faktura
    ADD CONSTRAINT faktura_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva);

ALTER TABLE faktura_stav_historia
    ADD CONSTRAINT faktura_stav_historia_faktura_fk FOREIGN KEY (id_faktura) REFERENCES faktura (id_faktura);

ALTER TABLE poistna_udalost
    ADD CONSTRAINT poistna_udalost_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva);

ALTER TABLE vozidlo
    ADD CONSTRAINT vozidlo_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel);

ALTER TABLE ziadost_o_zmluvu
    ADD CONSTRAINT ziadost_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel);

ALTER TABLE zmluva
    ADD CONSTRAINT zmluva_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    ADD CONSTRAINT zmluva_vozidlo_fk FOREIGN KEY (id_vozidlo) REFERENCES vozidlo (id_vozidlo);

ALTER TABLE zmluva_stav_historia
    ADD CONSTRAINT zmluva_stav_historia_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva);

COMMIT;

SELECT
    z.id_zmluva,
    COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno,
    v.ECV,
    z.datum_zaciatku,
    z.datum_konca,
    z.stav_zmluvy,
    je_zmluva_aktivna(z.id_zmluva) AS je_aktivna
FROM zmluva z
JOIN uzivatel u ON z.id_uzivatel = u.id_uzivatel
JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
WHERE je_zmluva_aktivna(z.id_zmluva) = 1;

SELECT
    z.id_zmluva,
    COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno,
    v.ECV,
    z.cena_poistneho,
    suma_faktur_uzivatela(z.id_zmluva) AS suma_faktur,
    (suma_faktur_uzivatela(z.id_zmluva) - z.cena_poistneho) AS rozdiel
FROM zmluva z
JOIN uzivatel u ON z.id_uzivatel = u.id_uzivatel
JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
ORDER BY z.id_zmluva;

SELECT
    z.id_zmluva,
    COALESCE(u.nazov_firma, CONCAT(u.meno, ' ', u.priezvisko)) AS zobrazene_meno,
    v.ECV,
    z.datum_zaciatku,
    z.datum_konca,
    je_zmluva_aktivna(z.id_zmluva) AS je_aktivna,
    suma_faktur_uzivatela(z.id_zmluva) AS suma_faktur,
    CASE
        WHEN je_zmluva_aktivna(z.id_zmluva) = 1 AND suma_faktur_uzivatela(z.id_zmluva) > 0 THEN 'Aktivna s fakturami'
        WHEN je_zmluva_aktivna(z.id_zmluva) = 1 THEN 'Aktivna bez faktur'
        ELSE 'Neaktivna'
    END AS status_zmluvy
FROM zmluva z
JOIN uzivatel u ON z.id_uzivatel = u.id_uzivatel
JOIN vozidlo v ON z.id_vozidlo = v.id_vozidlo
ORDER BY z.id_zmluva;

DROP TABLE IF NOT EXISTS cena_pzp;

CREATE TABLE cena_pzp (
    id_ceny INT NOT NULL AUTO_INCREMENT,
    nazov_ceny VARCHAR(5) NOT NULL,
    cena INT NOT NULL,

    CONSTRAINT cena_pzp_pk PRIMARY KEY (id_ceny)
);

DELIMITER $$
CREATE TRIGGER cena_pzp_bu
BEFORE UPDATE ON cena_pzp
FOR EACH ROW
BEGIN
    
END$$
DELIMITER ;
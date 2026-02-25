-- Active: 1771972073117@@mysql-hexsebik.alwaysdata.net@3306@hexsebik_nagic_poistenie
CREATE TABLE mesto
(
    id_mesto INT         NOT NULL AUTO_INCREMENT,
    mesto    VARCHAR(50) NOT NULL,
    PSC      VARCHAR(6)  NOT NULL,
    CONSTRAINT mesto_pk PRIMARY KEY (id_mesto)
);

-- CREATE TABLE typ_uzivatela
-- (
    -- id_typ_uzivatela INT        NOT NULL AUTO_INCREMENT,
    -- typ_uzivatela    VARCHAR(2) NOT NULL COMMENT 'k-klient, a-admin, ka-klient/admin',
    -- CONSTRAINT typ_uzivatela_pk PRIMARY KEY (id_typ_uzivatela)
-- );

ALTER TABLE uzivatel DROP CONSTRAINT uzivatel_typ_fk;
ALTER TABLE uzivatel DROP COLUMN id_typ_uzivatela;
ALTER TABLE uzivatel ADD COLUMN typ_uzivatela ENUM('k', 'a', 'ka') NOT NULL DEFAULT 'k' AFTER id_mesto;
DROP TABLE typ_uzivatela;

CREATE TABLE uzivatel
(
    id_uzivatel      INT          NOT NULL AUTO_INCREMENT,
    id_mesto         INT          NOT NULL,
    meno             VARCHAR(30)  NOT NULL,
    priezvisko       VARCHAR(60)  NOT NULL,
    datum_narodenia  DATE         NOT NULL,
    rod_cislo        VARCHAR(11)  NOT NULL,
    email            VARCHAR(64)  NOT NULL,
    password         VARCHAR(255) NOT NULL, -- dlzka 255 z dovodu ze hesla budu neskor hashovane
    datum_upravy     DATE         NOT NULL,
    CONSTRAINT uzivatel_pk PRIMARY KEY (id_uzivatel),
    CONSTRAINT uzivatel_mesto_fk FOREIGN KEY (id_mesto) REFERENCES mesto (id_mesto),
    CONSTRAINT uzivatel_rc_uk UNIQUE (rod_cislo),
    CONSTRAINT uzivatel_email_uk UNIQUE (email)
    
    --CONSTRAINT uzivatel_typ_fk FOREIGN KEY (id_typ_uzivatela) REFERENCES typ_uzivatela (id_typ_uzivatela),
) COMMENT 'uzivatelsky ucet/klientske data v 1';

ALTER TABLE uzivatel ADD CONSTRAINT uzivatel_rc_chk CHECK (rod_cislo REGEXP '[0-9]{6}/[0-9]{4}');

CREATE TABLE znacka_auta
(
    id_znacka_auta INT         NOT NULL AUTO_INCREMENT,
    znacka         VARCHAR(20) NOT NULL,
    CONSTRAINT znacka_auta_pk PRIMARY KEY (id_znacka_auta)
);

CREATE TABLE kat_vozidla
(
    id_kat_vozidla INT                  NOT NULL AUTO_INCREMENT,
    kat_vozidla    ENUM ('L', 'M', 'N') NOT NULL,
    -- L => motorove vozidla s menej ako 4 kolesami a stvorkolky
    -- M => motorove vozidla ktore maju aspon 4 kolesa a su urcene na prepravu osob
    -- N => motorove vozidla ktore maju aspon 4 kolesa a su urcene na prepravu nakladu

    CONSTRAINT kat_vozidla_pk PRIMARY KEY (id_kat_vozidla)
);
ALTER TABLE kat_vozidla
    MODIFY COLUMN kat_vozidla ENUM ('L', 'M', 'N'); -- bolo INT, teraz na vyber len z 3 kategorii

CREATE TABLE auto
(
    id_auto        INT         NOT NULL AUTO_INCREMENT,
    id_znacka_auto INT         NOT NULL,
    id_uzivatel    INT         NOT NULL,
    id_kat_vozidla INT         NOT NULL,
    ECV            VARCHAR(7)  NOT NULL,
    VIN            VARCHAR(17) NOT NULL,
    objem_motora   INT         NOT NULL,
    CONSTRAINT auto_pk PRIMARY KEY (id_auto),
    CONSTRAINT auto_znacka_fk FOREIGN KEY (id_znacka_auto) REFERENCES znacka_auta (id_znacka_auta),
    CONSTRAINT auto_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    CONSTRAINT auto_kat_vozidla_fk FOREIGN KEY (id_kat_vozidla) REFERENCES kat_vozidla (id_kat_vozidla),
    CONSTRAINT auto_ecv_uk UNIQUE (ECV),
    CONSTRAINT auto_ecv_chk CHECK (
        ECV REGEXP '[A-Z]{2}[0-9]{3}[A-Z]{2}'
        ),
    CONSTRAINT auto_vin_uk UNIQUE (VIN)
);

ALTER TABLE auto DROP CONSTRAINT auto_kat_vozidla_fk;
DROP TABLE kat_vozidla;
ALTER TABLE auto ADD COLUMN kat_vozidla ENUM('L', 'M', 'N') NOT NULL AFTER id_uzivatel;

CREATE TABLE zmluva
(
    id_zmluva      INT                                                    NOT NULL AUTO_INCREMENT,
    id_auto        INT                                                    NOT NULL,
    id_uzivatel    INT                                                    NOT NULL,
    datum_zaciatku DATE                                                   NOT NULL,
    datum_konca    DATE                                                   NOT NULL,
    cena_poistneho DECIMAL(10, 2)                                         NOT NULL,
    stav_zmluvy    ENUM ('aktivna', 'zrusena', 'expirovana', 'vytvorena') NOT NULL DEFAULT 'vytvorena',
    CONSTRAINT zmluva_pk PRIMARY KEY (id_zmluva),
    CONSTRAINT zmluva_auto_fk FOREIGN KEY (id_auto) REFERENCES auto (id_auto),
    CONSTRAINT zmluva_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel)
);

CREATE TABLE faktura
(
    id_faktura       INT            NOT NULL AUTO_INCREMENT,
    id_zmluva        INT            NOT NULL,
    datum_vystavenia DATE           NOT NULL,
    datum_splatnosti DATE           NOT NULL,
    datum_zaplatenia DATE           NULL,
    suma             DECIMAL(10, 2) NOT NULL,
    CONSTRAINT faktura_pk PRIMARY KEY (id_faktura),
    CONSTRAINT faktura_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva)
);

CREATE TABLE poistna_udalost
(
    id_poistna_udalost INT          NOT NULL AUTO_INCREMENT,
    id_zmluva          INT          NOT NULL,
    popis_udalosti     VARCHAR(255) NOT NULL,
    stav_udalosti      BOOL         NOT NULL DEFAULT FALSE,
    datum_udalosti     DATE         NOT NULL,
    datum_vyriesenia   DATE         NULL,
    suma_udalosti      DECIMAL(10, 2),
    CONSTRAINT poistna_udalost_pk PRIMARY KEY (id_poistna_udalost),
    CONSTRAINT poistna_udalost_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva)
);


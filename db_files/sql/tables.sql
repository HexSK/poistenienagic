DROP TABLE IF EXISTS faktura_stav_historia;
DROP TABLE IF EXISTS zmluva_stav_historia;
DROP TABLE IF EXISTS poistna_udalost;
DROP TABLE IF EXISTS faktura;
DROP TABLE IF EXISTS zmluva;
DROP TABLE IF EXISTS auto;
DROP TABLE IF EXISTS uzivatel;
DROP TABLE IF EXISTS znacka_auta;
DROP TABLE IF EXISTS mesto;

CREATE TABLE mesto (
    id_mesto INT NOT NULL AUTO_INCREMENT,
    mesto VARCHAR(50) NOT NULL,
    PSC VARCHAR(6) NOT NULL,
    CONSTRAINT mesto_pk PRIMARY KEY (id_mesto)
);

CREATE TABLE znacka_auta (
    id_znacka_auta INT NOT NULL AUTO_INCREMENT,
    znacka VARCHAR(20) NOT NULL,
    CONSTRAINT znacka_auta_pk PRIMARY KEY (id_znacka_auta)
);

CREATE TABLE uzivatel (
    id_uzivatel INT NOT NULL AUTO_INCREMENT,
    id_mesto INT NOT NULL,
    typ_uzivatela ENUM('k', 'a', 'ka') NOT NULL DEFAULT 'k',
    meno VARCHAR(30) NOT NULL,
    priezvisko VARCHAR(60) NOT NULL,
    datum_narodenia DATE NOT NULL,
    rod_cislo VARCHAR(11) NOT NULL,
    email VARCHAR(64) NOT NULL,
    password VARCHAR(255) NOT NULL,
    datum_upravy DATE NOT NULL,
    CONSTRAINT uzivatel_pk PRIMARY KEY (id_uzivatel),
    CONSTRAINT uzivatel_rc_uk UNIQUE (rod_cislo),
    CONSTRAINT uzivatel_email_uk UNIQUE (email),
    CONSTRAINT uzivatel_mesto_fk FOREIGN KEY (id_mesto) REFERENCES mesto (id_mesto),
    CONSTRAINT uzivatel_rc_chk CHECK (rod_cislo REGEXP '[0-9]{6}/[0-9]{4}')
) COMMENT 'uzivatelsky ucet/klientske data v 1';

CREATE TABLE auto (
    id_auto INT NOT NULL AUTO_INCREMENT,
    id_znacka_auto INT NOT NULL,
    id_uzivatel INT NOT NULL,
    kat_vozidla ENUM('L', 'M', 'N') NOT NULL,
    ECV VARCHAR(7) NOT NULL,
    VIN VARCHAR(17) NOT NULL,
    objem_motora INT NOT NULL,
    CONSTRAINT auto_pk PRIMARY KEY (id_auto),
    CONSTRAINT auto_ecv_uk UNIQUE (ECV),
    CONSTRAINT auto_vin_uk UNIQUE (VIN),
    CONSTRAINT auto_znacka_fk FOREIGN KEY (id_znacka_auto) REFERENCES znacka_auta (id_znacka_auta),
    CONSTRAINT auto_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    CONSTRAINT auto_ecv_chk CHECK (ECV REGEXP '[A-Z]{2}[0-9]{3}[A-Z]{2}')
);

CREATE TABLE zmluva (
    id_zmluva INT NOT NULL AUTO_INCREMENT,
    id_auto INT NOT NULL,
    id_uzivatel INT NOT NULL,
    datum_zaciatku DATE NOT NULL,
    datum_konca DATE NOT NULL,
    cena_poistneho DECIMAL(10, 2) NOT NULL,
    stav_zmluvy ENUM('aktivna', 'zrusena', 'expirovana', 'vytvorena') NOT NULL DEFAULT 'vytvorena',
    CONSTRAINT zmluva_pk PRIMARY KEY (id_zmluva),
    CONSTRAINT zmluva_auto_fk FOREIGN KEY (id_auto) REFERENCES auto (id_auto),
    CONSTRAINT zmluva_uzivatel_fk FOREIGN KEY (id_uzivatel) REFERENCES uzivatel (id_uzivatel),
    CONSTRAINT zmluva_datum_chk CHECK (datum_konca > datum_zaciatku),
    INDEX idx_zmluva_stav_koniec (stav_zmluvy, datum_konca)
);

CREATE TABLE faktura (
    id_faktura INT NOT NULL AUTO_INCREMENT,
    id_zmluva INT NOT NULL,
    datum_vystavenia DATE NOT NULL,
    datum_splatnosti DATE NOT NULL,
    datum_zaplatenia DATE NULL,
    suma DECIMAL(10, 2) NOT NULL,
    CONSTRAINT faktura_pk PRIMARY KEY (id_faktura),
    CONSTRAINT faktura_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva),
    CONSTRAINT faktura_suma_chk CHECK (suma > 0),
    CONSTRAINT faktura_datumy_chk CHECK (
        datum_splatnosti >= datum_vystavenia
        AND (datum_zaplatenia IS NULL OR datum_zaplatenia >= datum_vystavenia)
    ),
    INDEX idx_faktura_zmluva_datumy (id_zmluva, datum_splatnosti, datum_zaplatenia)
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

CREATE TABLE faktura_stav_historia (
    id_historia INT NOT NULL AUTO_INCREMENT,
    id_faktura INT NOT NULL,
    stary_stav ENUM('nezaplatena', 'zaplatena') NULL,
    novy_stav ENUM('nezaplatena', 'zaplatena') NOT NULL,
    zmenene_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    zmenil VARCHAR(128) NOT NULL,
    CONSTRAINT faktura_stav_historia_pk PRIMARY KEY (id_historia),
    CONSTRAINT faktura_stav_historia_faktura_fk FOREIGN KEY (id_faktura) REFERENCES faktura (id_faktura)
);

CREATE TABLE zmluva_stav_historia (
    id_historia INT NOT NULL AUTO_INCREMENT,
    id_zmluva INT NOT NULL,
    stary_stav ENUM('aktivna', 'zrusena', 'expirovana', 'vytvorena') NULL,
    novy_stav ENUM('aktivna', 'zrusena', 'expirovana', 'vytvorena') NOT NULL,
    zmenene_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    zmenil VARCHAR(128) NOT NULL,
    CONSTRAINT zmluva_stav_historia_pk PRIMARY KEY (id_historia),
    CONSTRAINT zmluva_stav_historia_zmluva_fk FOREIGN KEY (id_zmluva) REFERENCES zmluva (id_zmluva)
);

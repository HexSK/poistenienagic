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
    CONSTRAINT uzivatel_rc_chk CHECK (rod_cislo IS NULL OR rod_cislo REGEXP '[0-9]{6}/[0-9]{4}'),
    CONSTRAINT uzivatel_ico_uk UNIQUE (ICO),
    CONSTRAINT uzivatel_dic_uk UNIQUE (DIC),
    CONSTRAINT uzivatel_typ_chk CHECK (
        (typ_uzivatela = 'k' AND rod_cislo IS NOT NULL AND ICO IS NULL) OR
        (typ_uzivatela = 'kf' AND ICO IS NOT NULL AND rod_cislo IS NULL) OR
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

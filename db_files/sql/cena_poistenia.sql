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

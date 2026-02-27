-- ============================================================
-- VEĽKÝ DATASET PRE hexsebik_nagic_poistenie
-- ============================================================

-- -------------------------------------------------------------
-- MESTÁ
-- -------------------------------------------------------------
INSERT INTO mesto (mesto, PSC) VALUES
('Bratislava', '811 01'),
('Košice', '040 01'),
('Prešov', '080 01'),
('Žilina', '010 01'),
('Banská Bystrica', '974 01'),
('Nitra', '949 01'),
('Trnava', '917 01'),
('Trenčín', '911 01'),
('Martin', '036 01'),
('Poprad', '058 01'),
('Zvolen', '960 01'),
('Liptovský Mikuláš', '031 01'),
('Michalovce', '071 01'),
('Spišská Nová Ves', '052 01'),
('Levice', '934 01'),
('Komárno', '945 01'),
('Bardejov', '085 01'),
('Rimavská Sobota', '979 01'),
('Humenné', '066 01'),
('Ružomberok', '034 01');

-- -------------------------------------------------------------
-- TYP POUŽÍVATEĽA
-- -------------------------------------------------------------
-- INSERT INTO typ_uzivatela (typ_uzivatela) VALUES
-- ('k'),
-- ('a'),
-- ('ka');

-- -------------------------------------------------------------
-- ZNAČKY ÁUT
-- -------------------------------------------------------------
INSERT INTO znacka_auta (znacka) VALUES
('Škoda'),
('Volkswagen'),
('BMW'),
('Mercedes-Benz'),
('Audi'),
('Toyota'),
('Ford'),
('Hyundai'),
('Kia'),
('Renault'),
('Peugeot'),
('Opel'),
('Seat'),
('Nissan'),
('Mazda'),
('Honda'),
('Volvo'),
('Fiat'),
('Citroën'),
('Dacia');

-- -------------------------------------------------------------
-- KATEGÓRIE VOZIDIEL
-- -------------------------------------------------------------
INSERT INTO kat_vozidla (kat_vozidla) VALUES
('L'),
('M'),
('N');

-- -------------------------------------------------------------------
-- POUŽÍVATELIA - 40 klientov, 5 adminov, 5 klient-adminov
-- HESLA MAJU FAKE HASH, HASH BUDE SPRACOVANY POCAS TVORBY WEBSTRANKY
-- -------------------------------------------------------------------
INSERT INTO uzivatel (id_mesto, typ_uzivatela, meno, priezvisko, datum_narodenia, rod_cislo, email, password, datum_upravy) VALUES
-- Klienti (typ 1)
(1, 'k','Ján',        'Novák',       '1985-03-12', '850312/1234', 'jan.novak@gmail.com',          '$2b$10$abc1hashedpw', '2024-01-10'),
(2, 'k','Iveta',      'Kovaľová',    '1890-07-25', '905725/5678', 'iveta.kovalova@gmail.com',     '$2b$10$abc2hashedpw', '2024-01-11'),
(3, 'k','Peter',      'Horváth',     '1978-11-03', '781103/9012', 'peter.horvath@gmail.com',      '$2b$10$abc3hashedpw', '2024-02-05'),
(4, 'k','Zuzana',     'Szabóová',    '1995-04-18', '955418/3456', 'zuzana.szabo@gmail.com',       '$2b$10$abc4hashedpw', '2024-02-06'),
(5, 'k','Tomáš',      'Varga',       '1982-09-30', '820930/7890', 'tomas.varga@gmail.com',        '$2b$10$abc5hashedpw', '2024-03-01'),
(6, 'k','Eva',        'Lukáčová',    '1993-01-22', '930122/2345', 'eva.lukacova@gmail.com',       '$2b$10$abc6hashedpw', '2024-03-15'),
(7, 'k','Martin',     'Takáč',       '1975-06-14', '750614/6789', 'martin.takac@gmail.com',       '$2b$10$abc7hashedpw', '2024-04-02'),
(8, 'k','Jana',       'Blahová',     '1988-12-05', '881205/0123', 'jana.blaho@gmail.com',         '$2b$10$abc8hashedpw', '2024-04-10'),
(9, 'k','Miroslav',   'Kováč',       '1970-02-28', '700228/4567', 'miroslav.kovac@gmail.com',     '$2b$10$abc9hashedpw', '2024-05-01'),
(10, 'k','Lenka',      'Mináčová',    '1997-08-09', '970809/8901', 'lenka.minac@gmail.com',        '$2b$10$abc10hashpw', '2024-05-20'),
(11, 'k','Rastislav',  'Sloboda',     '1983-05-17', '830517/2345', 'rastislav.sloboda@gmail.com',  '$2b$10$abc11hashpw', '2024-06-01'),
(12, 'k','Katarína',   'Benková',     '1991-10-31', '911031/6789', 'katarina.benk@gmail.com',      '$2b$10$abc12hashpw', '2024-06-15'),
(13, 'k','Michal',     'Oravec',      '1979-03-07', '790307/0123', 'michal.oravec@gmail.com',      '$2b$10$abc13hashpw', '2024-07-03'),
(14, 'k','Andrea',     'Čierna',      '1994-07-19', '940719/4567', 'andrea.cierna@gmail.com',      '$2b$10$abc14hashpw', '2024-07-22'),
(15, 'k','Vladimír',   'Mešťan',      '1968-11-25', '681125/8901', 'vladimir.mestan@gmail.com',    '$2b$10$abc15hashpw', '2024-08-08'),
(16, 'k','Silvia',     'Garajová',    '1986-04-03', '860403/2345', 'silvia.garaj@gmail.com',       '$2b$10$abc16hashpw', '2024-08-25'),
(17, 'k','Róbert',     'Kubíček',     '1973-09-16', '730916/6789', 'robert.kubicek@gmail.com',     '$2b$10$abc17hashpw', '2024-09-10'),
(18, 'k','Lucia',      'Adamová',     '1999-01-29', '990129/0123', 'lucia.adam@gmail.com',         '$2b$10$abc18hashpw', '2024-09-28'),
(19, 'k','Dušan',      'Palenčár',    '1981-06-11', '810611/4567', 'dusan.palencar@gmail.com',     '$2b$10$abc19hashpw', '2024-10-05'),
(20, 'k','Natália',    'Šimková',     '1996-12-23', '961223/8901', 'natalia.simk@gmail.com',       '$2b$10$abc20hashpw', '2024-10-18'),
(1, 'k','Igor',       'Červenák',    '1977-02-14', '770214/2345', 'igor.cervenak@gmail.com',      '$2b$10$abc21hashpw', '2024-11-01'),
(2, 'k','Monika',     'Baloghová',   '1989-08-27', '890827/6789', 'monika.balogh@gmail.com',      '$2b$10$abc22hashpw', '2024-11-14'),
(3, 'k','Stanislav',  'Žák',         '1965-04-02', '650402/0123', 'stanislav.zak@gmail.com',      '$2b$10$abc23hashpw', '2024-12-01'),
(4, 'k','Veronika',   'Dudová',      '1992-10-14', '921014/4567', 'veronika.duda@gmail.com',      '$2b$10$abc24hashpw', '2024-12-15'),
(5, 'k','Branislav',  'Hudák',       '1984-03-26', '840326/8901', 'branislav.hudak@gmail.com',    '$2b$10$abc25hashpw', '2025-01-03'),
(6, 'k','Petra',      'Ňachajová',   '1998-09-08', '980908/2345', 'petra.nachaj@gmail.com',       '$2b$10$abc26hashpw', '2025-01-20'),
(7, 'k','Jakub',      'Sedlák',      '1972-01-20', '720120/6789', 'jakub.sedlak@gmail.com',       '$2b$10$abc27hashpw', '2025-02-04'),
(8, 'k','Barbora',    'Krejčí',      '1987-07-03', '870703/0123', 'barbora.krejci@gmail.com',     '$2b$10$abc28hashpw', '2025-02-18'),
(9, 'k','Lukáš',      'Polák',       '1993-11-15', '931115/4567', 'lukas.polak@gmail.com',        '$2b$10$abc29hashpw', '2025-03-01'),
(10, 'k','Diana',      'Procházková', '1980-05-27', '800527/8901', 'diana.prochazk@gmail.com',     '$2b$10$abc30hashpw', '2025-03-15'),
(11, 'k','Radoslav',   'Ferko',       '1969-09-09', '690909/1234', 'radoslav.ferko@gmail.com',     '$2b$10$abc31hashpw', '2025-03-28'),
(12, 'k','Ivana',      'Haláková',    '1995-02-21', '950221/5678', 'ivana.halak@gmail.com',        '$2b$10$abc32hashpw', '2025-04-05'),
(13, 'k','Marek',      'Slobodník',   '1976-07-04', '760704/9012', 'marek.slobodnik@gmail.com',    '$2b$10$abc33hashpw', '2025-04-18'),
(14, 'k','Renáta',     'Čechová',     '1991-12-16', '911216/3456', 'renata.cechova@gmail.com',     '$2b$10$abc34hashpw', '2025-05-02'),
(15, 'k','Patrik',     'Molnár',      '1985-06-28', '850628/7890', 'patrik.molnar@gmail.com',      '$2b$10$abc35hashpw', '2025-05-16'),
(16, 'k','Soňa',       'Balážová',    '1998-03-10', '980310/2345', 'sona.balaz@gmail.com',         '$2b$10$abc36hashpw', '2025-05-29'),
(17, 'k','Ondrej',     'Chrást',      '1974-08-22', '740822/6789', 'ondrej.chrast@gmail.com',      '$2b$10$abc37hashpw', '2025-06-10'),
(18, 'k','Tereza',     'Riečanová',   '1990-01-04', '900104/0123', 'tereza.riecan@gmail.com',      '$2b$10$abc38hashpw', '2025-06-23'),
(19, 'k','Filip',      'Koník',       '1983-06-16', '830616/4567', 'filip.konik@gmail.com',        '$2b$10$abc39hashpw', '2025-07-07'),
(20, 'k','Alžbeta',    'Žilinská',    '1996-11-28', '961128/8901', 'alzbeta.zilinska@gmail.com',   '$2b$10$abc40hashpw', '2025-07-20'),
-- Admini (typ 2)
(1, 'a',  'Admin',      'Prvý',        '1980-01-01', '800101/0001', 'admin1@nagic.sk',              '$2b$10$adm1hashedpw', '2024-01-01'),
(1, 'a',  'Admin',      'Druhý',       '1981-02-02', '810202/0002', 'admin2@nagic.sk',              '$2b$10$adm2hashedpw', '2024-01-01'),
(1, 'a',  'Admin',      'Tretí',       '1982-03-03', '820303/0003', 'admin3@nagic.sk',              '$2b$10$adm3hashedpw', '2024-01-01'),
(2, 'a',  'Admin',      'Štvrtý',      '1983-04-04', '830404/0004', 'admin4@nagic.sk',              '$2b$10$adm4hashedpw', '2024-01-01'),
(2, 'a',  'Admin',      'Piaty',       '1984-05-05', '840505/0005', 'admin5@nagic.sk',              '$2b$10$adm5hashedpw', '2024-01-01'),
-- Klient-Admini (typ 3)
(1, 'ka',  'Karol',      'Superuser',   '1979-06-06', '790606/0006', 'karol.super@nagic.sk',         '$2b$10$ka1hashedpw', '2024-01-01'),
(2, 'ka',  'Iveta',      'Manažérka',   '1980-07-07', '800707/0007', 'iveta.manaz@nagic.sk',         '$2b$10$ka2hashedpw', '2024-01-01'),
(3, 'ka',  'Boris',      'Správca',     '1975-08-08', '750808/0008', 'boris.spravca@nagic.sk',       '$2b$10$ka3hashedpw', '2024-01-01'),
(4, 'ka',  'Helena',     'Vedúca',      '1983-09-09', '830909/0009', 'helena.veduca@nagic.sk',       '$2b$10$ka4hashedpw', '2024-01-01'),
(5, 'ka',  'Tibor',      'Riaditeľ',    '1970-10-10', '701010/0010', 'tibor.riaditel@nagic.sk',      '$2b$10$ka5hashedpw', '2024-01-01');

-- -------------------------------------------------------------
-- AUTÁ - ~55 vozidiel klientov
-- -------------------------------------------------------------
INSERT INTO auto (id_znacka_auto, id_uzivatel, kat_vozidla, ECV, VIN, objem_motora) VALUES
(1,  1,  'M', 'BA123AB', '1HGBH41JXMN109186', 1598),
(2,  2,  'M', 'KE456CD', '2T1BURHE0JC016372', 1984),
(3,  3,  'M', 'PO789EF', '3VWSE69M72M000001', 2998),
(4,  4,  'M', 'ZA321GH', 'WDBNG70J14A123456', 1796),
(5,  5,  'M', 'BB654IJ', 'WAUZZZ8K5BA012345', 1968),
(6,  6,  'M', 'NR987KL', 'JT2BF22K3W0089654', 1998),
(7,  7,  'M', 'TT159MN', '1FADP3F28GL306254', 1596),
(8,  8,  'M', 'TN258OP', 'KMHCG45C43U312345', 1591),
(9,  9,  'M', 'MT357QR', 'KNAFG525297123456', 1591),
(10, 10, 'M', 'PP456ST', 'VF1BB0B0H22123456', 1598),
(11, 11, 'M', 'ZV111UV', 'VF3BB9HXB90123456', 1560),
(12, 12, 'M', 'LM222WX', 'W0L000000Y2123456', 1364),
(13, 13, 'M', 'MI333YZ', 'VS6J0B2P0J5123456', 1395),
(14, 14, 'M', 'SN444AB', '1N4AL3AP5GC123456', 1597),
(15, 15, 'M', 'LC555CD', 'JM1BK343781123456', 1998),
(16, 16, 'M', 'KI666EF', '19XFC1F39HE123456', 1497),
(17, 17, 'M', 'BJ777GH', 'YV1RS612292123456', 1984),
(18, 18, 'M', 'RK888IJ', 'ZFA31200000123456', 1242),
(19, 19, 'M', 'HE999KL', 'VF7JBHZAS5J123456', 1560),
(20, 20, 'M', 'BN000MN', 'UU1LSDAA8AU123456', 1149),
(1,  21, 'M', 'BA741OP', '1HGBH41JXMN200001', 1390),
(3,  22, 'M', 'KE852QR', '1G1YZ23J9P5800001', 3001),
(4,  23, 'N', 'PO963ST', 'WDBNG70J14A654321', 2996),
(5,  24, 'M', 'ZA147UV', 'WAUZZZ8K5BA098765', 1984),
(6,  25, 'M', 'BB258WX', 'JT2BF22K3W0001234', 1796),
(7,  26, 'M', 'NR369YZ', '1FADP3F28GL400001', 1597),
(8,  27, 'M', 'TT741AB', 'KMHCG45C43U400001', 1591),
(9,  28, 'M', 'TN852CD', 'KNAFG525297400001', 1498),
(10, 29, 'M', 'MT963EF', 'VF1BB0B0H22400001', 1149),
(11, 30, 'M', 'PP147GH', 'VF3BB9HXB90400001', 1560),
(12, 31, 'N', 'ZV258IJ', 'W0L000000Y2400001', 2198),
(13, 32, 'M', 'LM369KL', 'VS6J0B2P0J5400001', 1395),
(14, 33, 'M', 'MI741MN', '1N4AL3AP5GC400001', 1997),
(15, 34, 'M', 'SN852OP', 'JM1BK343781400001', 1997),
(16, 35, 'M', 'LC963QR', '19XFC1F39HE400001', 1497),
(17, 36, 'M', 'KI159ST', 'YV1RS612292400001', 1984),
(18, 37, 'M', 'BJ258UV', 'ZFA31200000400001', 875),
(19, 38, 'M', 'RK357WX', 'VF7JBHZAS5J400001', 1199),
(20, 39, 'M', 'HE456YZ', 'UU1LSDAA8AU400001', 1149),
(1,  40, 'L', 'BN789AB', '1HGBH41JXMN300001', 125),
-- Druhé autá niektorých klientov
(2,  1,  2, 'BA222CD', '2T1BURHE0JC300001', 1796),
(5,  3,  3, 'PO333EF', 'WAUZZZ8K5BA300001', 2967),
(7,  5,  2, 'BB444GH', '1FADP3F28GL500001', 1596),
(10, 10, 2, 'PP555IJ', 'VF1BB0B0H22500001', 1332),
(3,  15, 2, 'LC666KL', '1G1YZ23J9P5900001', 2979),
(6,  20, 2, 'BN777MN', 'JT2BF22K3W0100001', 1598),
(9,  25, 2, 'BB888OP', 'KNAFG525297500001', 1248),
(12, 30, 2, 'PP999QR', 'W0L000000Y2500001', 1796),
(15, 35, 2, 'LC111ST', 'JM1BK343781500001', 1496),
(18, 40, 2, 'BN222UV', 'ZFA31200000500001', 1242);

-- -------------------------------------------------------------
-- ZMLUVY - 60 zmlúv
-- -------------------------------------------------------------
INSERT INTO zmluva (id_auto, id_uzivatel, datum_zaciatku, datum_konca, cena_poistneho, stav_zmluvy) VALUES
(1,  1,  '2023-01-01', '2024-01-01',  320.00, 'expirovana'),
(1,  1,  '2024-01-01', '2025-01-01',  335.00, 'expirovana'),
(1,  1,  '2025-01-01', '2026-01-01',  350.00, 'aktivna'),
(2,  2,  '2023-03-15', '2024-03-15',  290.00, 'expirovana'),
(2,  2,  '2024-03-15', '2025-03-15',  305.00, 'expirovana'),
(2,  2,  '2025-03-15', '2026-03-15',  320.00, 'aktivna'),
(3,  3,  '2024-06-01', '2025-06-01',  480.00, 'expirovana'),
(3,  3,  '2025-06-01', '2026-06-01',  495.00, 'aktivna'),
(4,  4,  '2025-01-10', '2026-01-10',  270.00, 'aktivna'),
(5,  5,  '2023-09-01', '2024-09-01',  360.00, 'expirovana'),
(5,  5,  '2024-09-01', '2025-09-01',  375.00, 'aktivna'),
(6,  6,  '2025-02-20', '2026-02-20',  310.00, 'aktivna'),
(7,  7,  '2024-04-01', '2025-04-01',  285.00, 'expirovana'),
(7,  7,  '2025-04-01', '2026-04-01',  300.00, 'aktivna'),
(8,  8,  '2025-03-01', '2026-03-01',  265.00, 'aktivna'),
(9,  9,  '2023-07-15', '2024-07-15',  245.00, 'expirovana'),
(9,  9,  '2024-07-15', '2025-07-15',  260.00, 'aktivna'),
(10, 10, '2025-04-01', '2026-04-01',  275.00, 'aktivna'),
(11, 11, '2024-11-01', '2025-11-01',  295.00, 'aktivna'),
(12, 12, '2025-01-20', '2026-01-20',  255.00, 'aktivna'),
(13, 13, '2024-08-10', '2025-08-10',  235.00, 'aktivna'),
(14, 14, '2025-02-01', '2026-02-01',  270.00, 'aktivna'),
(15, 15, '2024-05-15', '2025-05-15',  345.00, 'expirovana'),
(15, 15, '2025-05-15', '2026-05-15',  360.00, 'aktivna'),
(16, 16, '2025-03-10', '2026-03-10',  240.00, 'aktivna'),
(17, 17, '2024-10-01', '2025-10-01',  380.00, 'aktivna'),
(18, 18, '2025-01-15', '2026-01-15',  215.00, 'aktivna'),
(19, 19, '2024-12-01', '2025-12-01',  250.00, 'aktivna'),
(20, 20, '2025-06-01', '2026-06-01',  205.00, 'aktivna'),
(21, 21, '2023-05-01', '2024-05-01',  230.00, 'expirovana'),
(21, 21, '2024-05-01', '2025-05-01',  245.00, 'aktivna'),
(22, 22, '2025-07-01', '2026-07-01',  490.00, 'aktivna'),
(23, 23, '2024-09-20', '2025-09-20',  520.00, 'aktivna'),
(24, 24, '2025-02-10', '2026-02-10',  330.00, 'aktivna'),
(25, 25, '2024-11-15', '2025-11-15',  285.00, 'aktivna'),
(26, 26, '2025-04-20', '2026-04-20',  255.00, 'aktivna'),
(27, 27, '2024-07-01', '2025-07-01',  265.00, 'expirovana'),
(27, 27, '2025-07-01', '2026-07-01',  280.00, 'aktivna'),
(28, 28, '2025-01-05', '2026-01-05',  245.00, 'aktivna'),
(29, 29, '2025-03-25', '2026-03-25',  215.00, 'aktivna'),
(30, 30, '2024-06-15', '2025-06-15',  295.00, 'aktivna'),
(31, 31, '2025-02-28', '2026-02-28',  395.00, 'aktivna'),
(32, 32, '2024-10-10', '2025-10-10',  235.00, 'aktivna'),
(33, 33, '2025-04-05', '2026-04-05',  320.00, 'aktivna'),
(34, 34, '2024-08-20', '2025-08-20',  325.00, 'aktivna'),
(35, 35, '2025-05-10', '2026-05-10',  240.00, 'aktivna'),
(36, 36, '2024-12-15', '2025-12-15',  370.00, 'aktivna'),
(37, 37, '2025-03-01', '2026-03-01',  175.00, 'aktivna'),
(38, 38, '2024-09-05', '2025-09-05',  210.00, 'aktivna'),
(39, 39, '2025-06-15', '2026-06-15',  200.00, 'aktivna'),
(40, 40, '2025-01-01', '2026-01-01',  145.00, 'aktivna'),
(41, 1,  '2024-03-01', '2025-03-01',  310.00, 'expirovana'),
(42, 3,  '2025-07-01', '2026-07-01',  540.00, 'aktivna'),
(43, 5,  '2024-10-01', '2025-10-01',  295.00, 'aktivna'),
(44, 10, '2025-04-01', '2026-04-01',  240.00, 'aktivna'),
(45, 15, '2024-06-01', '2025-06-01',  490.00, 'expirovana'),
(46, 20, '2025-03-01', '2026-03-01',  295.00, 'aktivna'),
(47, 25, '2024-11-20', '2025-11-20',  240.00, 'aktivna'),
(48, 30, '2025-05-01', '2026-05-01',  310.00, 'aktivna'),
(50, 40, '2025-02-01', '2026-02-01',  220.00, 'aktivna'),
-- Zrušená zmluva
(4,  4,  '2025-08-01', '2026-08-01',  280.00, 'zrusena');

-- -------------------------------------------------------------
-- FAKTÚRY
-- -------------------------------------------------------------
INSERT INTO faktura (id_zmluva, datum_vystavenia, datum_splatnosti, datum_zaplatenia, suma) VALUES
-- Zmluva 1 (expirovaná)
(1,  '2023-01-01', '2023-01-15', '2023-01-12',  320.00),
-- Zmluva 2 (expirovaná)
(2,  '2024-01-01', '2024-01-15', '2024-01-10',  335.00),
-- Zmluva 3 (aktívna) - zaplatená
(3,  '2025-01-01', '2025-01-15', '2025-01-08',  350.00),
-- Zmluva 4 (expirovaná)
(4,  '2023-03-15', '2023-03-30', '2023-03-28',  290.00),
-- Zmluva 5 (expirovaná)
(5,  '2024-03-15', '2024-03-30', '2024-03-22',  305.00),
-- Zmluva 6 (aktívna) - zaplatená
(6,  '2025-03-15', '2025-03-30', '2025-03-20',  320.00),
-- Zmluva 7 (expirovaná)
(7,  '2024-06-01', '2024-06-15', '2024-06-11',  480.00),
-- Zmluva 8 (aktívna) - zaplatená
(8,  '2025-06-01', '2025-06-15', '2025-06-09',  495.00),
-- Zmluva 9 (aktívna) - zaplatená
(9,  '2025-01-10', '2025-01-25', '2025-01-20',  270.00),
-- Zmluva 10 (expirovaná)
(10, '2023-09-01', '2023-09-15', '2023-09-10',  360.00),
-- Zmluva 11 (aktívna) - zaplatená
(11, '2024-09-01', '2024-09-15', '2024-09-12',  375.00),
-- Zmluva 12 (aktívna) - nezaplatená
(12, '2025-02-20', '2025-03-07', NULL,           310.00),
-- Zmluva 13 (expirovaná)
(13, '2024-04-01', '2024-04-15', '2024-04-09',  285.00),
-- Zmluva 14 (aktívna) - zaplatená
(14, '2025-04-01', '2025-04-15', '2025-04-07',  300.00),
-- Zmluva 15 (aktívna) - zaplatená
(15, '2025-03-01', '2025-03-15', '2025-03-11',  265.00),
-- Zmluva 16 (expirovaná)
(16, '2023-07-15', '2023-07-30', '2023-07-25',  245.00),
-- Zmluva 17 (aktívna) - zaplatená
(17, '2024-07-15', '2024-07-30', '2024-07-22',  260.00),
-- Zmluva 18 (aktívna) - zaplatená
(18, '2025-04-01', '2025-04-15', '2025-04-10',  275.00),
-- Zmluva 19 (aktívna) - nezaplatená
(19, '2024-11-01', '2024-11-15', NULL,           295.00),
-- Zmluva 20 (aktívna) - zaplatená
(20, '2025-01-20', '2025-02-04', '2025-01-30',  255.00),
-- Zmluva 21 (aktívna) - zaplatená
(21, '2024-08-10', '2024-08-25', '2024-08-18',  235.00),
-- Zmluva 22 (aktívna) - zaplatená
(22, '2025-02-01', '2025-02-15', '2025-02-10',  270.00),
-- Zmluva 23 (expirovaná)
(23, '2024-05-15', '2024-05-30', '2024-05-25',  345.00),
-- Zmluva 24 (aktívna) - zaplatená
(24, '2025-05-15', '2025-05-30', '2025-05-20',  360.00),
-- Zmluva 25 (aktívna) - zaplatená
(25, '2025-03-10', '2025-03-25', '2025-03-18',  240.00),
-- Zmluva 26 (aktívna) - zaplatená
(26, '2024-10-01', '2024-10-15', '2024-10-09',  380.00),
-- Zmluva 27 (aktívna) - zaplatená
(27, '2025-01-15', '2025-01-30', '2025-01-22',  215.00),
-- Zmluva 28 (aktívna) - nezaplatená
(28, '2024-12-01', '2024-12-15', NULL,           250.00),
-- Zmluva 29 (aktívna) - zaplatená
(29, '2025-06-01', '2025-06-15', '2025-06-08',  205.00),
-- Zmluva 30 (expirovaná)
(30, '2023-05-01', '2023-05-15', '2023-05-12',  230.00),
-- Zmluva 31 (aktívna) - zaplatená
(31, '2024-05-01', '2024-05-15', '2024-05-10',  245.00),
-- Zmluva 32 (aktívna) - zaplatená
(32, '2025-07-01', '2025-07-15', '2025-07-09',  490.00),
-- Zmluva 33 (aktívna) - zaplatená
(33, '2024-09-20', '2024-10-05', '2024-09-28',  520.00),
-- Zmluva 34 (aktívna) - zaplatená
(34, '2025-02-10', '2025-02-25', '2025-02-18',  330.00),
-- Zmluva 35 (aktívna) - zaplatená
(35, '2024-11-15', '2024-11-30', '2024-11-22',  285.00),
-- Zmluva 36 (aktívna) - nezaplatená
(36, '2025-04-20', '2025-05-05', NULL,           255.00),
-- Zmluva 37 (expirovaná)
(37, '2024-07-01', '2024-07-15', '2024-07-11',  265.00),
-- Zmluva 38 (aktívna) - zaplatená
(38, '2025-07-01', '2025-07-15', '2025-07-07',  280.00),
-- Zmluva 39 (aktívna) - zaplatená
(39, '2025-01-05', '2025-01-20', '2025-01-14',  245.00),
-- Zmluva 40 (aktívna) - zaplatená
(40, '2025-03-25', '2025-04-09', '2025-04-01',  215.00),
-- Zmluvy 41-60 (faktúry)
(41, '2025-02-28', '2025-03-15', '2025-03-08',  395.00),
(42, '2024-10-10', '2024-10-25', '2024-10-19',  235.00),
(43, '2025-04-05', '2025-04-20', '2025-04-12',  320.00),
(44, '2024-08-20', '2024-09-04', '2024-08-28',  325.00),
(45, '2025-05-10', '2025-05-25', '2025-05-17',  240.00),
(46, '2024-12-15', '2024-12-30', '2024-12-22',  370.00),
(47, '2025-03-01', '2025-03-16', '2025-03-10',  175.00),
(48, '2024-09-05', '2024-09-20', '2024-09-14',  210.00),
(49, '2025-06-15', '2025-06-30', NULL,           200.00),
(50, '2025-01-01', '2025-01-16', '2025-01-10',  145.00),
(51, '2024-03-01', '2024-03-16', '2024-03-10',  310.00),
(52, '2025-07-01', '2025-07-16', '2025-07-09',  540.00),
(53, '2024-10-01', '2024-10-16', '2024-10-11',  295.00),
(54, '2025-04-01', '2025-04-16', '2025-04-09',  240.00),
(55, '2024-06-01', '2024-06-16', '2024-06-10',  490.00),
(56, '2025-03-01', '2025-03-16', '2025-03-09',  295.00),
(57, '2024-11-20', '2024-12-05', '2024-11-28',  240.00),
(58, '2025-05-01', '2025-05-16', NULL,           310.00),
(59, '2025-02-01', '2025-02-16', '2025-02-10',  220.00);

-- -------------------------------------------------------------
-- POISTNÉ UDALOSTI
-- -------------------------------------------------------------
INSERT INTO poistna_udalost (id_zmluva, popis_udalosti, stav_udalosti, datum_udalosti, datum_vyriesenia, suma_udalosti) VALUES
-- Vybavené udalosti
(3,  'Zrážka s iným vozidlom na parkovisku, poškodený nárazník a ľavý bok.', TRUE,  '2025-02-15', '2025-03-01',  850.00),
(6,  'Krádež autorádia a poškodenie zámku dverí.', TRUE,  '2025-03-10', '2025-03-25',  420.00),
(8,  'Čelné sklo prasknuté po náraze kameňa z vozovky.', TRUE,  '2025-06-20', '2025-07-05',  380.00),
(11, 'Povodňová udalosť – zatopenie vozidla, totálna škoda.', TRUE,  '2024-10-10', '2024-11-20', 12500.00),
(14, 'Vandalstvo – poškrabaná karoséria na viacerých miestach.', TRUE,  '2025-04-18', '2025-05-02',  650.00),
(17, 'Náraz do stĺpa pri parkovaní, poškodený zadný nárazník.', TRUE,  '2024-09-22', '2024-10-08',  720.00),
(20, 'Krádež celého vozidla, nájdené poškodené po 3 dňoch.', TRUE,  '2025-02-05', '2025-03-10',  8500.00),
(23, 'Požiar motorového priestoru spôsobený technickou poruchou.', TRUE,  '2024-09-30', '2024-11-01', 15800.00),
(26, 'Zrážka so zverou (srnka) na ceste I. triedy.', TRUE,  '2024-12-03', '2024-12-20',  3200.00),
(31, 'Poškodenie pneumatík a disku po jazde cez dieru.', TRUE,  '2025-04-10', '2025-04-22',  480.00),
(33, 'Havária na diaľnici, čelná zrážka, airbag vyšiel.', TRUE,  '2024-11-25', '2025-01-15', 22000.00),
(36, 'Poškodenie vozidla pri zosuve pôdy (živelná udalosť).', TRUE,  '2025-05-18', '2025-06-20',  9500.00),
(41, 'Poškodenie predného skla gradom.', TRUE,  '2024-05-22', '2024-06-05',  550.00),
(44, 'Náraz do zadného vozidla v zápche, ľahké poškodenie.', TRUE,  '2024-10-01', '2024-10-18',  1100.00),
(46, 'Poškodenie odkvapkávačov strechy garáže.', TRUE,  '2024-02-14', '2024-03-02',  320.00),
-- Otvorené / nevybavené udalosti
(3,  'Poškodenie dverí pri otvorení v tesnom priestore.', FALSE, '2025-08-10', NULL,  NULL),
(9,  'Záplava v podzemnej garáži, vozidlo stálo vo vode.', FALSE, '2025-08-20', NULL,  NULL),
(18, 'Zrážka so cyklistom, vozidlo poškodené predná časť.', FALSE, '2025-07-30', NULL,  NULL),
(24, 'Odcudzenie katalyzátora, vozidlo nespustiteľné.', FALSE, '2025-09-01', NULL,  NULL),
(38, 'Krúpy poškodili karosériu na mnohých miestach.', FALSE, '2025-08-05', NULL,  NULL),
(52, 'Výbuch pneumatiky na diaľnici, poškodenie podvozku.', FALSE, '2025-07-28', NULL,  NULL),
(56, 'Zrážka so stĺpom dopravnej značky, predný nárazník.', FALSE, '2025-08-18', NULL,  NULL),
(59, 'Poškodenie auta pri páde stromu počas búrky.', FALSE, '2025-07-12', NULL,  NULL);
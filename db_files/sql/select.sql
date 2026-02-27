SELECT * FROM mesto;
SELECT * FROM znacka_auta;
SELECT * FROM uzivatel;
SELECT * FROM auto;
SELECT * FROM zmluva;
SELECT * FROM faktura;
SELECT * FROM poistna_udalost;

-- (WHERE + LIKE + IN)
SELECT u.id_uzivatel, u.meno, u.priezvisko, u.typ_uzivatela
FROM uzivatel u
WHERE u.typ_uzivatela IN ('k', 'ka')
  AND u.priezvisko LIKE 'K%';

-- (WHERE + LIKE + IN)
SELECT z.id_zmluva, z.stav_zmluvy, a.ECV, a.kat_vozidla
FROM zmluva z
JOIN auto a ON a.id_auto = z.id_auto
WHERE z.stav_zmluvy IN ('aktivna', 'expirovana')
  AND a.ECV LIKE 'B%';

-- (WHERE + LIKE + IN)
SELECT f.id_faktura, f.id_zmluva, f.suma, f.datum_zaplatenia
FROM faktura f
JOIN zmluva z ON z.id_zmluva = f.id_zmluva
WHERE z.stav_zmluvy IN ('aktivna', 'expirovana')
  AND CAST(f.suma AS CHAR) LIKE '2%';

SELECT COUNT(*) AS pocet_zmluv FROM zmluva;
SELECT SUM(suma) AS suma_faktur FROM faktura;
SELECT AVG(cena_poistneho) AS priemerne_poistne FROM zmluva;
SELECT MIN(cena_poistneho) AS najnizsie_poistne FROM zmluva;
SELECT MAX(cena_poistneho) AS najvyssie_poistne FROM zmluva;

-- agregacne
SELECT z.stav_zmluvy, COUNT(*) AS pocet
FROM zmluva z
GROUP BY z.stav_zmluvy;

SELECT a.kat_vozidla, AVG(z.cena_poistneho) AS priemerne_poistne
FROM auto a
JOIN zmluva z ON z.id_auto = a.id_auto
GROUP BY a.kat_vozidla;

SELECT * FROM auto;
SELECT * FROM faktura;
SELECT * FROM mesto;
SELECT * FROM poistna_udalost;
SELECT * FROM uzivatel;
SELECT * FROM zmluva;
SELECT * FROM znacka_auta;

SELECT * FROM auto
WHERE kat_vozidla != 'M';

SELECT * FROM uzivatel
WHERE typ_uzivatela IN ('k', 'ka') AND meno REGEXP '^M';
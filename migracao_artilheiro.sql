-- ============================================================
-- Migração: palpites.artilheiro → nomes de camisa oficiais
-- Executar no Supabase Dashboard > SQL Editor
-- Copa do Mundo 2026 — 28/06/2026
-- ============================================================

-- Cada UPDATE converte o nome antigo (formato mix) para o
-- nome de camisa oficial (usado no novo elencos.js)

UPDATE palpites SET artilheiro = 'A. DIAO'        WHERE artilheiro = 'A. Diao';
UPDATE palpites SET artilheiro = 'KRAMARIĆ'        WHERE artilheiro = 'A. Kramaric';
UPDATE palpites SET artilheiro = 'BROBBEY'         WHERE artilheiro = 'B. Brobbey';
UPDATE palpites SET artilheiro = 'EMBOLO'          WHERE artilheiro = 'B. Embolo';
UPDATE palpites SET artilheiro = 'GAKPO'           WHERE artilheiro = 'C. Gakpo';
UPDATE palpites SET artilheiro = 'PULISIC'         WHERE artilheiro = 'C. Pulisic';
UPDATE palpites SET artilheiro = 'RONALDO'         WHERE artilheiro = 'Cristiano Ronaldo';
UPDATE palpites SET artilheiro = 'OLMO'            WHERE artilheiro = 'D. Olmo';
UPDATE palpites SET artilheiro = 'UNDAV'           WHERE artilheiro = 'D. Undav';
UPDATE palpites SET artilheiro = 'E. VALENCIA'     WHERE artilheiro = 'Enner Valencia';
UPDATE palpites SET artilheiro = 'BRAUT HAALAND'   WHERE artilheiro = 'Erling Haaland';
UPDATE palpites SET artilheiro = 'MAKGOPA'         WHERE artilheiro = 'Evidence Makgopa';
UPDATE palpites SET artilheiro = 'BALOGUN'         WHERE artilheiro = 'F. Balogun';
UPDATE palpites SET artilheiro = 'PLATA'           WHERE artilheiro = 'Gonzalo Plata';
UPDATE palpites SET artilheiro = 'ABDELKARIM'      WHERE artilheiro = 'H. Abdel Karim';
UPDATE palpites SET artilheiro = 'WRIGHT'          WHERE artilheiro = 'H. Wright';
UPDATE palpites SET artilheiro = 'KANE'            WHERE artilheiro = 'Harry Kane';
UPDATE palpites SET artilheiro = 'SAIBARI'         WHERE artilheiro = 'I. Saibari';
UPDATE palpites SET artilheiro = 'J. ARIAS'        WHERE artilheiro = 'J. Arias';
UPDATE palpites SET artilheiro = 'MANZAMBI'        WHERE artilheiro = 'J. Manzambi';
UPDATE palpites SET artilheiro = 'J. QUIÑONES'     WHERE artilheiro = 'J. Quinones';
UPDATE palpites SET artilheiro = 'WIRTZ'           WHERE artilheiro = 'J. Wirtz';
UPDATE palpites SET artilheiro = 'ADAMS'           WHERE artilheiro = 'Jayden Adams';
UPDATE palpites SET artilheiro = 'J. DAVID'        WHERE artilheiro = 'Jonathan David';
UPDATE palpites SET artilheiro = 'HAVERTZ'         WHERE artilheiro = 'K. Havertz';
UPDATE palpites SET artilheiro = 'MBAPPÉ'          WHERE artilheiro = 'K. Mbappé';
UPDATE palpites SET artilheiro = 'NAKAMURA'        WHERE artilheiro = 'K. Nakamura';
UPDATE palpites SET artilheiro = 'L. MARTINEZ'     WHERE artilheiro = 'L. Martínez';
UPDATE palpites SET artilheiro = 'TROSSARD'        WHERE artilheiro = 'L. Trossard';
UPDATE palpites SET artilheiro = 'MESSI'           WHERE artilheiro = 'Lionel Messi';
UPDATE palpites SET artilheiro = 'LUIS DÍAZ'       WHERE artilheiro = 'Luis Díaz';
UPDATE palpites SET artilheiro = 'ARNAUTOVIC'      WHERE artilheiro = 'M. Arnautovic';
UPDATE palpites SET artilheiro = 'OYARZABAL'       WHERE artilheiro = 'M. Oyarzabal';
UPDATE palpites SET artilheiro = 'SABITZER'        WHERE artilheiro = 'M. Sabitzer';
UPDATE palpites SET artilheiro = 'TOURE'           WHERE artilheiro = 'M. Toure';
UPDATE palpites SET artilheiro = 'CUNHA'           WHERE artilheiro = 'Matheus Cunha';
UPDATE palpites SET artilheiro = 'AMOURA'          WHERE artilheiro = 'Mohamed Amine Amoura';
UPDATE palpites SET artilheiro = 'M. SALAH'        WHERE artilheiro = 'Mohamed Salah';
UPDATE palpites SET artilheiro = 'OKAFOR'          WHERE artilheiro = 'N. Okafor';
UPDATE palpites SET artilheiro = 'DEMBÉLÉ'         WHERE artilheiro = 'O. Dembele';
UPDATE palpites SET artilheiro = 'MARMOUSH'        WHERE artilheiro = 'O. Marmoush';
UPDATE palpites SET artilheiro = 'MUSA'            WHERE artilheiro = 'P. Musa';
UPDATE palpites SET artilheiro = 'PROMISE'         WHERE artilheiro = 'Promise David';
UPDATE palpites SET artilheiro = 'RAFA LEÃO'       WHERE artilheiro = 'R. Leão';
UPDATE palpites SET artilheiro = 'LUKAKU'          WHERE artilheiro = 'R. Lukaku';
UPDATE palpites SET artilheiro = 'PEPI'            WHERE artilheiro = 'R. Pepi';
UPDATE palpites SET artilheiro = 'RAYAN'           WHERE artilheiro = 'Rayan';
UPDATE palpites SET artilheiro = 'MOFOKENG'        WHERE artilheiro = 'Relebohile Mofokeng';
UPDATE palpites SET artilheiro = 'RAHIMI'          WHERE artilheiro = 'S. Rahimi';
UPDATE palpites SET artilheiro = 'MANÉ'            WHERE artilheiro = 'Sadio Mané';
UPDATE palpites SET artilheiro = 'MASEKO'          WHERE artilheiro = 'Thapelo Maseko';
UPDATE palpites SET artilheiro = 'VINI JR.'        WHERE artilheiro = 'Vinicius Jr.';
UPDATE palpites SET artilheiro = 'YAN DIOMANDE'    WHERE artilheiro = 'Y. Diomande';

-- Não mapeados (não encontrado no JSON ou ambíguo):
-- "F. Torres"   → ambíguo: Felix Torres (ECU DEF camisa TORRES) ou Ferran Torres (ESP FWD camisa FERRAN)
-- "K. Benítez"  → não encontrado nas 32 seleções do JSON

-- ============================================================
-- VERIFICAÇÃO APÓS MIGRAR:
-- SELECT artilheiro, COUNT(*) FROM palpites
-- WHERE artilheiro IS NOT NULL GROUP BY artilheiro ORDER BY artilheiro;
-- ============================================================

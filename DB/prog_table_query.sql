SET search_path TO progetto_database;

-- Query 1, tutte le automobili di un modello progettato da un produttore che ha progettato almeno 3, massimo 10 modelli:
SELECT * FROM Automobili A
	WHERE A.nome_modello IN(
		SELECT nome FROM Modelli
			GROUP BY nome_produttore
			HAVING COUNT(*) BETWEEN 3 AND 10
	)

-- Query 2, Il numero medio di atti di vendita tra i privati che coinvolgono solo automobili del modello 'Fiesta':
SELECT AVG(COUNT(A.ID_registrazione)) FROM Atti_trasferimento A_T
	JOIN Automobili A ON A_T.auto_riferita = A.ID_registrazione
	WHERE A.nome_modello = 'Fiesta'
	GROUP BY A.ID_Registrazione;

-- Query 3, il numero di modelli con esattamente 100 automobili registrate:
SELECT COUNT(M.nome) FROM Modelli M
	WHERE M.nome IN(
		SELECT A.nome_modello FROM Automobili A
			GROUP BY A.nome_modello
			HAVING COUNT(*)=100
	)
	GROUP BY M.nome;

-- Query 4, tutte le automobili che abbiano 2 o più atti (oltre a quello iniziale, ossia che dal produttore siano arrivate a un privato o gruppo) e che appartengono ad un modello che abbia più di 1500cc di cilindrata:
SELECT * FROM Automobili A
JOIN Modelli M ON A.nome_modello = M.nome
WHERE A.id_registrazione IN (
    SELECT auto_riferita FROM Atti_di_fornitura
    INTERSECT
    SELECT auto_riferita FROM Atti_di_vendita
)
AND M.cilindrata > 1500

-- Query 5, il modello o i modelli che hanno il maggior numero di auto distrutte:
CREATE VIEW modelli_AutoDist(nomeModello,numAutoDist) AS 
    SELECT nome_modello, count(*) AS numAutoDist
    FROM Automobile A
    WHERE A.data_distruzione IS NOT NULL
    GROUP BY nome_modello;

SELECT nomeModello FROM modelli_AutoDist MAD
WHERE MAD.numAutoDist >= ALL(SELECT numAutoDist FROM modelli_AutoDist);

-- Query 6, il o i modelli che hanno il maggior numero di auto vendute:
SELECT nome_modello FROM (
	SELECT A.nome_modello, COUNT(A.nome_modello) AS vendite FROM Automobile A
		JOIN Atti_vendita A_V ON A.ID_registrazione = A_V.auto
		GROUP BY A.nome_modello
	)
	WHERE vendite = MAX(vendite);
SET search_path TO progetto_database;

-- Query 1, tutte le automobili di un modello progettato da un produttore che ha progettato almeno 3, massimo 10 modelli:
SELECT * FROM automobili A
	WHERE A.nome_modello IN(
		SELECT M.nome FROM modelli M
			WHERE M.nome_produttore IN(
				SELECT M2.nome_produttore FROM modelli M2
					GROUP BY M2.nome_produttore
					HAVING COUNT(*) BETWEEN 3 AND 10
			)
	);

-- Query 2, Il numero medio di passaggi di proprietà tra privati che coinvolgono solo automobili del modello 'Fiesta':
SELECT AVG(n_passaggi_tra_privati) FROM (
	SELECT A.id_registrazione, COUNT(A.id_registrazione) AS n_passaggi_tra_privati FROM automobili A
		JOIN atti_trasferimento A_T ON A_T.automobile = A.id_registrazione
		WHERE A.nome_modello = 'Fiesta'
		GROUP BY A.id_registrazione
);

-- Query 3, il numero di modelli con esattamente 100 automobili registrate:
SELECT COUNT(*) FROM (
	SELECT A.nome_modello FROM Automobili A
		GROUP BY A.nome_modello
		HAVING COUNT(*)=100
);

-- Query 4, tutte le automobili che abbiano 2 o più atti (oltre a quello iniziale, ossia che dal produttore siano arrivate a un privato o gruppo) e che appartengono ad un modello che abbia più di 1500cc di cilindrata:
SELECT * FROM automobili A
	JOIN modelli M ON A.nome_modello = M.nome
	WHERE A.id_registrazione IN (
		SELECT DISTINCT automobile FROM atti_vendita
	)
	AND M.cilindrata > 1500;

-- Query 5, il modello o i modelli che hanno il minor numero di auto distrutte:
CREATE VIEW modelli_AutoDist(nomeModello, numAutoDist) AS 
    SELECT nome_modello, count(*) AS numAutoDist
    FROM automobili A
    WHERE A.data_distruzione IS NOT NULL
    GROUP BY nome_modello;

SELECT nomeModello FROM modelli_AutoDist MAD
WHERE MAD.numAutoDist <= ALL(SELECT numAutoDist FROM modelli_AutoDist);

-- Query 6, il o i modelli che hanno il maggior numero di auto vendute:
CREATE VIEW modelli_auto_vend(nome_modello, num_auto_vend) AS 
	SELECT nome_modello, count(*) AS num_auto_vend FROM automobili A
		JOIN atti_vendita A_V ON A.id_registrazione = A_V.automobile
		GROUP BY A.nome_modello;

SELECT MAV.nome_modello FROM modelli_auto_vend MAV
	WHERE MAV.num_auto_vend >= ALL(SELECT num_auto_vend FROM modelli_auto_vend);


DROP VIEW modelli_AutoVend, modelli_AutoDist;
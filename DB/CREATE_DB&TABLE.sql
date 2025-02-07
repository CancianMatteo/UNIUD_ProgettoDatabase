-- CREATE SCHEMA progetto_database;

SET search_path TO progetto_database;

DROP TABLE IF EXISTS produttori, modelli, automobili, rivenditori, privati, atti_proprieta_iniziale, atti_fornitura, atti_vendita, atti_trasferimento;

CREATE TABLE produttori(
	nome varchar PRIMARY KEY,
	n_auto_prodotte int CHECK(n_auto_prodotte>=0)
);

CREATE TABLE modelli(
	nome varchar NOT NULL PRIMARY KEY,
	potenza int NOT NULL CHECK(potenza>=6),
	cilindrata int NOT NULL CHECK(cilindrata>=400 AND cilindrata<=3000),
	consumi_per_100km float CHECK(consumi_per_100km>=0),
	nome_produttore varchar NOT NULL,
	FOREIGN KEY (nome_produttore) REFERENCES Produttori(nome)
);

CREATE TABLE automobili(
	id_registrazione int PRIMARY KEY,
	n_serie_dal_produttore varchar NOT NULL UNIQUE,
	anno_produzione int NOT NULL,
	data_distruzione Date  CHECK(EXTRACT(YEAR FROM data_distruzione) >= anno_produzione),
	nome_modello varchar NOT NULL,
	FOREIGN KEY (nome_modello) REFERENCES Modelli(nome)
);

CREATE TABLE rivenditori(
	partita_iva varchar(11) PRIMARY KEY,
	nome varchar NOT NULL,
	indirizzo varchar NOT NULL,
	telefono varchar(10) NOT NULL UNIQUE,
	fax varchar(10)
);

CREATE TABLE privati(
	id_privato_gruppo int PRIMARY KEY,
	is_singolo_privato boolean NOT NULL,
	cf varchar(16) UNIQUE CHECK (length(cf) = 16),
	nome varchar,
	cognome varchar,
	indirizzo varchar,
	telefono varchar(10) UNIQUE,
	CONSTRAINT CHK_singolo_privato CHECK(
	  CASE WHEN is_singolo_privato=false
	  THEN (cf IS NULL AND nome IS NULL AND cognome IS NULL AND indirizzo IS NULL AND telefono IS NULL)
	  ELSE (cf IS NOT NULL AND nome IS NOT NULL AND cognome IS NOT NULL AND indirizzo IS NOT NULL AND telefono IS NOT NULL)
	  END
	)
);

CREATE TABLE atti_proprieta_iniziale(
	id_atto int PRIMARY KEY,
	data_firmato Date NOT NULL,
	automobile int NOT NULL UNIQUE,
	FOREIGN KEY (automobile) REFERENCES Automobili(ID_registrazione),
	produttore varchar NOT NULL,
	FOREIGN KEY (produttore) REFERENCES Produttori(nome)
);

CREATE TABLE atti_fornitura(
	id_atto int PRIMARY KEY,
	data_firmato Date NOT NULL,
	automobile int NOT NULL UNIQUE,
	FOREIGN KEY (automobile) REFERENCES Automobili(ID_registrazione),
	produttore varchar NOT NULL,
	FOREIGN KEY (produttore) REFERENCES Produttori(nome),
	rivenditore varchar NOT NULL,
	FOREIGN KEY (rivenditore) REFERENCES Rivenditori(partita_IVA)
);

CREATE TABLE atti_vendita(
	id_atto int PRIMARY KEY,
	data_firmato Date NOT NULL,
	automobile int NOT NULL,
	FOREIGN KEY (automobile) REFERENCES Automobili(ID_registrazione),
	rivenditore varchar NOT NULL,
	FOREIGN KEY (rivenditore) REFERENCES Rivenditori(partita_IVA),
	privato int NOT NULL,
	FOREIGN KEY (privato) REFERENCES Privati(ID_Privato_Gruppo),
	senso_rivenditore_to_privato boolean NOT NULL
);

CREATE TABLE atti_trasferimento(
	id_atto int PRIMARY KEY,
	data_firmato Date,
	automobile int NOT NULL,
	FOREIGN KEY (automobile) REFERENCES Automobili(ID_registrazione),
	vecchio_privato int NOT NULL,
	FOREIGN KEY (vecchio_privato) REFERENCES Privati(ID_Privato_Gruppo),
	nuovo_privato int NOT NULL,
	FOREIGN KEY (nuovo_privato) REFERENCES Privati(ID_Privato_Gruppo),
	CONSTRAINT CHK_privati_diversi CHECK (vecchio_privato <> nuovo_privato)
);
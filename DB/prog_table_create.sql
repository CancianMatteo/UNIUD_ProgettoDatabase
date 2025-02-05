-- CREATE SCHEMA progetto_database;

SET search_path TO progetto_database;

CREATE TABLE Produttori(
	nome varchar PRIMARY KEY,
	n_auto_prodotte int CHECK(n_auto_prodotte>=0)
);

CREATE TABLE Modelli(
	nome varchar NOT NULL PRIMARY KEY,
	potenza int NOT NULL CHECK(potenza>=6),
	cilindrata int NOT NULL CHECK(cilindrata>=400 AND cilindrata<=3000),
	consumi_per_100km float CHECK(consumi_per_100km>=0),
	nome_produttore varchar NOT NULL,
	FOREIGN KEY (nome_produttore) REFERENCES Produttori(nome)
);

CREATE TABLE Automobili(
	ID_registrazione int PRIMARY KEY,
	n_serie_dal_produttore varchar NOT NULL UNIQUE,
	anno_produzione int NOT NULL,
	data_registrazione Date NOT NULL CHECK(YEAR(data_registrazione)>=anno_produzione),
	data_distruzione Date NULLABLE CHECK(data_distruzione>=data_registrazione),
	nome_modello varchar NOT NULL,
	FOREIGN KEY (nome_modello) REFERENCES Modelli(nome)
);

CREATE TABLE Rivenditori(
	partita_IVA varchar(11) PRIMARY KEY,
	nome varchar NOT NULL,
	indirizzo varchar NOT NULL,
	telefono varchar(10) NOT NULL UNIQUE,
	fax varchar
);

CREATE TABLE Privati(
	ID_Privato_Gruppo int PRIMARY KEY,
	is_singolo_privato bit NOT NULL,
	cf varchar(16) UNIQUE CHECK (length(cf) = 16),
	nome varchar,
	cognome varchar,
	indirizzo varchar,
	telefono varchar(10) UNIQUE,
	CONSTRAINT CHK_Singolo_Privato CHECK(
	  IF is_singolo_privato=0
	  THEN (cf IS NULL) AND (nome IS NULL) AND (cognome IS NULL) AND (indirizzo IS NULL) AND (telefono IS NULL)
	)
);

CREATE TABLE Atti_proprieta_iniziale(
	ID_atto int PRIMARY KEY,
	data_firma Date,
	auto int NOT NULL,
	FOREIGN KEY (auto_riferita) REFERENCES Automobili(ID_registrazione),
	produttore varchar NOT NULL,
	FOREIGN KEY (produttore) REFERENCES Produttori(nome)
);

CREATE TABLE Atti_fornitura(
	ID_atto int PRIMARY KEY,
	data_firma Date,
	auto int NOT NULL,
	FOREIGN KEY (auto_riferita) REFERENCES Automobili(ID_registrazione),
	produttore varchar NOT NULL,
	FOREIGN KEY (produttore) REFERENCES Produttori(nome),
	rivenditore varchar NOT NULL,
	FOREIGN KEY (rivenditore) REFERENCES Rivenditori(partita_IVA)
);

CREATE TABLE Atti_vendita(
	ID_atto int PRIMARY KEY,
	data_firma Date,
	auto int NOT NULL,
	FOREIGN KEY (auto) REFERENCES Automobili(ID_registrazione),
	rivenditore varchar NOT NULL,
	FOREIGN KEY (rivenditore) REFERENCES Rivenditori(partita_IVA),
	privato int NOT NULL,
	FOREIGN KEY (privato) REFERENCES Privati(ID_Privato_Gruppo),
	senso_rivenditore_to_privato boolean NOT NULL
);

CREATE TABLE Atti_trasferimento(
	ID_atto int PRIMARY KEY,
	data_firma Date,
	auto int NOT NULL,
	FOREIGN KEY (auto_riferita) REFERENCES Automobili(ID_registrazione),
	vecchio_privato int NOT NULL,
	FOREIGN KEY (vecchio_privato) REFERENCES Privati(ID_Privato_Gruppo),
	nuovo_privato int NOT NULL,
	FOREIGN KEY (nuovo_privato) REFERENCES Privati(ID_Privato_Gruppo)
);
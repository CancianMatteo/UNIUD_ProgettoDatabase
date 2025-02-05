SET search_path TO progetto_database;

INSERT INTO Produttori VALUES
('Ford',0),
('FIAT',0),
('Ferrari',0),
('Opel',0),
('Toyota',0),
('Alfa Romeo',0),
('Mercedes',0),
('Volkswagen',0),
('BMW',0),
('Mazda',0);

INSERT INTO Modelli VALUES
('Fiesta', 69, 1250, 5.882, 'Ford'),
('Puma', 120, 1600, 6.3, 'Ford'),
('Punto', 65, 1200, 5.737, 'FIAT'),
('Tipo', 110, 1600, 5.9, 'FIAT'),
('Giulietta', 120, 1700, 5.3, "Alfa Romeo"),
('SF90', 1030, 3000, 6.1, 'Ferrari');	-- la cilindrata sarebbe più di 3000 ma c'è il vincolo imposto dal testo

insert into Automobili values
(1, 00001, '2007-6-1', 2007, NULL, 'Fiesta'),
(2, 10001, '2007-9-4', 2007, NULL, 'Punto'),
(3, 00002, '2009-12-9', 2010, NULL, 'Puma'),
(4, 00003, '2011-7-23', 2011, NULL, 'Fiesta'),
(5, 20001, '2019-4-7', 2019, NULL, 'SF90'),
(6, 10002, '2013-5-21', 2013, NULL, 'Tipo');

insert into Rivenditori values
('11111111111', 'R1', 'via a, Udine', '0987654321', 'fax1'),
('22222222222', 'R2', 'via b, Codroipo', '1987654321'),
('33333333333', 'R3', 'via c, Vittorio Veneto', '2987654321');

INSERT INTO Privati VALUES
(1, 1, '1111111111111111', 'via b, Latisana', '1234567891'),
(2, 1, '2222222222222222', 'via c, Cappella Maggiore', '1234567892'),
(3, 1, '3333333333333333', 'via d, Refrontolo', '1234567893'),
(4, 0),
(5, 1, '4444444444444444', 'via e, Sedegliano', '1234567894');

INSERT INTO Atti_di_proprieta_iniziale VALUES
(1, '2007-01-16', 1, 'Ford');

INSERT INTO Atti_di_fornitura VALUES
(1, '2007-02-9', 1, 'Ford', '33333333333');

INSERT INTO Atti_di_vendita VALUES
(1, '2007-04-17', 1, '33333333333', 4, 1);

INSERT INTO Atti_di_trasferimento VALUES
(1, '2023-03-22', 1, 4, '22222222222');
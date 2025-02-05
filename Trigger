CREATE OR REPLACE FUNCTION check_car_act()
RETURNS TRIGGER AS $$
DECLARE
    data_distruzione_automobile DATE;
BEGIN
    SELECT data_distruzione INTO data_distruzione_automobile
    FROM Automobili
    WHERE ID_registrazione = NEW.auto_riferita;

    IF data_distruzione_automobile IS NOT NULL THEN
        RAISE EXCEPTION 'Errore: Non è possibile stipulare un atto riferito a un''auto distrutta';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_car_act
BEFORE INSERT ON Atti_di_fornitura (basta cambiare atto)
FOR EACH ROW
EXECUTE FUNCTION check_car_act();



CREATE OR REPLACE FUNCTION check_maker()
RETURNS TRIGGER AS $$
DECLARE
    auto_produttore VARCHAR;
BEGIN
    SELECT m.nome_produttore INTO auto_produttore
    FROM Automobili a
    JOIN Modelli m ON a.nome_modello = m.nome
    WHERE a.ID_registrazione = NEW.auto_riferita;

    IF auto_produttore IS NULL THEN
        RAISE EXCEPTION 'Errore: L''auto specificata nell''atto non esiste!';
    ELSIF auto_produttore <> NEW.produttore THEN
        RAISE EXCEPTION 'Errore: Il produttore che firma l''atto non corrisponde al produttore del modello dell''auto!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_maker
BEFORE INSERT ON Atti_di_proprieta_iniziale
FOR EACH ROW
EXECUTE FUNCTION check_maker();





ALTER TABLE Privati
ADD CONSTRAINT check_privato_singolo_gruppo
CHECK (
    (is_singolo_privato = TRUE AND nome IS NOT NULL AND cognome IS NOT NULL AND cf IS NOT NULL AND indirizzo IS NOT NULL AND telefono IS NOT NULL) OR
    (is_singolo_privato = FALSE AND nome IS NULL AND cognome IS NULL AND cf IS NULL AND indirizzo IS NULL AND telefono IS NULL)
);

ALTER TABLE Atti_di_trasferimento
ADD CONSTRAINT check_privates_transfer
CHECK (vecchio_privato <> nuovo_privato);

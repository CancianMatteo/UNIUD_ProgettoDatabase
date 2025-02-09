-- Trigger: quando viene aggiunta un auto viene incrementato il numero di auto prodotte dal produttore
CREATE OR REPLACE FUNCTION incrementa_auto_prodotte()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Produttori
        SET n_auto_prodotte = n_auto_prodotte + 1
        WHERE nome = (SELECT nome_produttore FROM modelli WHERE nome=NEW.nome_modello);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementa_auto_prodotte
AFTER INSERT ON Automobili
FOR EACH ROW
EXECUTE FUNCTION incrementa_auto_prodotte();


-- Trigger: un qualunque atto non può essere riferito a un'auto distrutta
CREATE OR REPLACE FUNCTION check_auto_distruzione()
RETURNS TRIGGER AS $$
DECLARE auto_distruzione DATE;
BEGIN
    SELECT data_distruzione INTO auto_distruzione
        FROM Automobili
        WHERE ID_registrazione = NEW.automobile;

    IF auto_distruzione IS NOT NULL AND auto_distruzione <= NEW.data_firmato
        THEN RAISE EXCEPTION 'Errore: L''auto specificata nell''atto è stata distrutta!';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_auto_distruzione
BEFORE INSERT ON atti_proprieta_iniziale, atti_fornitura, atti_vendita, atti_trasferimento
FOR EACH ROW
EXECUTE FUNCTION check_auto_distruzione();


-- Trigger: un produttore che firma un atto di proprietà iniziale deve effettivamente essere il produttore di quell'auto
CREATE OR REPLACE FUNCTION check_maker()
RETURNS TRIGGER AS $$
DECLARE auto_produttore VARCHAR;
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
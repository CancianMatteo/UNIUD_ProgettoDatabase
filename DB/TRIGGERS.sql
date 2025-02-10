-- Trigger1: quando viene aggiunta un auto viene incrementato il numero di auto prodotte dal produttore
CREATE FUNCTION incrementa_auto_prodotte()
RETURNS TRIGGER AS $$
DECLARE n_auto INT;
BEGIN
    SELECT n_auto_prodotte INTO n_auto
        FROM produttori
        WHERE nome = (SELECT nome_produttore FROM modelli WHERE nome=NEW.nome_modello);

    UPDATE produttori
        SET n_auto_prodotte = n_auto_prodotte + 1
        WHERE nome = (SELECT nome_produttore FROM modelli WHERE nome=NEW.nome_modello);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementa_auto_prodotte
AFTER INSERT ON automobili
FOR EACH ROW
EXECUTE FUNCTION incrementa_auto_prodotte();


-- Triggers2: un qualunque atto non può essere riferito a un'auto già distrutta
CREATE FUNCTION check_auto_distruzione()
RETURNS TRIGGER AS $$
DECLARE auto_distruzione DATE;
BEGIN
    SELECT data_distruzione INTO auto_distruzione
        FROM Automobili
        WHERE ID_registrazione = NEW.automobile;

    IF (auto_distruzione IS NOT NULL AND auto_distruzione < NEW.data_firmato)
        THEN RAISE EXCEPTION 'Errore: L''auto specificata nell''atto è stata distrutta!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_auto_distruzione_proprieta_iniziale
BEFORE INSERT ON atti_proprieta_iniziale
FOR EACH ROW
EXECUTE FUNCTION check_auto_distruzione();

CREATE TRIGGER trg_check_auto_distruzione_fornitura
BEFORE INSERT ON atti_fornitura
FOR EACH ROW
EXECUTE FUNCTION check_auto_distruzione();

CREATE TRIGGER trg_check_auto_distruzione_vendita
BEFORE INSERT ON atti_vendita
FOR EACH ROW
EXECUTE FUNCTION check_auto_distruzione();

CREATE TRIGGER trg_check_auto_distruzione_trasferimento
BEFORE INSERT ON atti_trasferimento
FOR EACH ROW
EXECUTE FUNCTION check_auto_distruzione();


-- Trigger3: un produttore che firma un atto di proprietà iniziale deve effettivamente essere il produttore di quell'auto
CREATE FUNCTION check_produttore()
RETURNS TRIGGER AS $$
DECLARE produttore VARCHAR;
BEGIN
    SELECT m.nome_produttore INTO produttore
        FROM automobili A
        JOIN modelli M ON A.nome_modello = M.nome
        WHERE A.ID_registrazione = NEW.automobile;

    IF produttore <> NEW.produttore
    THEN
        RAISE EXCEPTION 'Errore: Il produttore che firma l''atto non corrisponde al produttore del modello dell''auto!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_produttore
BEFORE INSERT ON atti_proprieta_iniziale
FOR EACH ROW
EXECUTE FUNCTION check_produttore();


-- Trigger4: il vecchio proprietario di un auto deve esserne il proprietario prima della firma dell'atto
CREATE OR REPLACE FUNCTION check_car_ownership_privato()
RETURNS TRIGGER AS $$
DECLARE proprietario_attuale INT;
BEGIN
    -- Cerca il proprietario attuale nel più recente atto di trasferimento
    SELECT nuovo_privato INTO proprietario_attuale
        FROM atti_trasferimento
        WHERE automobile = NEW.automobile
        ORDER BY data_firmato DESC
        LIMIT 1;

    -- Se non ci sono atti di trasferimento per quell'auto, cercalo nel più recente atto di vendita
    IF (proprietario_attuale IS NULL) 
    THEN
        SELECT privato INTO proprietario_attuale
            FROM atti_vendita
            WHERE automobile = NEW.automobile AND senso_rivenditore_to_privato = TRUE
            ORDER BY data_firmato DESC
            LIMIT 1;
    END IF;

    IF proprietario_attuale <> NEW.vecchio_privato THEN
        RAISE EXCEPTION 'Errore: Il vecchio_proprietario(%) specificato nell''atto non corrisponde al proprietario dell''auto (%)!
        Atto trasferimento fallito: %', NEW.vecchio_privato, proprietario_attuale, NEW;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_check_car_ownership_privato
BEFORE INSERT ON atti_trasferimento
FOR EACH ROW
EXECUTE FUNCTION check_car_ownership_privato();


-- Trigger5.1: Assicura che esista un'atto di proprietà iniziale prima che venga stipulato un'atto di fornitura per quell'auto
CREATE FUNCTION check_fornitura_dopo_proprieta_iniziale()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM atti_proprieta_iniziale A
        WHERE A.automobile = NEW.automobile
    ) THEN
        RAISE EXCEPTION 'Errore: Non è possibile stipulare un atto di fornitura senza un atto di proprietà iniziale per l’auto';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_fornitura_dopo_proprieta_iniziale
BEFORE INSERT ON atti_fornitura
FOR EACH ROW
EXECUTE FUNCTION check_fornitura_dopo_proprieta_iniziale();

-- Trigger5.2: Assicura che esista un'atto di fornitura prima che venga stipulato un'atto di vendita per quell'auto
CREATE FUNCTION check_vendita_dopo_fornitura()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM atti_fornitura A
        WHERE A.automobile = NEW.automobile
    ) THEN
        RAISE EXCEPTION 'Errore: Non è possibile stipulare un atto di vendita se l''auto non è mai stata fornita ad un rivenditore';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_vendita_dopo_fornitura
BEFORE INSERT ON atti_vendita
FOR EACH ROW
EXECUTE FUNCTION check_vendita_dopo_fornitura();

-- Trigger5.3: Assicura che esista un'atto di vendita prima che venga stipulato un'atto di trasferimento per quell'auto
CREATE FUNCTION check_trasferimento_dopo_vendita()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM atti_vendita A
        WHERE A.automobile = NEW.automobile
    ) THEN
        RAISE EXCEPTION 'Errore: Non è possibile stipulare un atto di trasferimento tra privati se l''auto non è mai stata venduta';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_trasferimento_dopo_vendita
BEFORE INSERT ON atti_trasferimento
FOR EACH ROW
EXECUTE FUNCTION check_trasferimento_dopo_vendita();
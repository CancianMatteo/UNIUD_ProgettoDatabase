-- Trigger1: quando viene aggiunta un auto viene incrementato il numero di auto prodotte dal produttore
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


-- Trigger2: un qualunque atto non può essere riferito a un'auto distrutta
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


-- Trigger3: un produttore che firma un atto di proprietà iniziale deve effettivamente essere il produttore di quell'auto
CREATE OR REPLACE FUNCTION check_produttore()
RETURNS TRIGGER AS $$
DECLARE produttore VARCHAR;
BEGIN
    SELECT m.nome_produttore INTO produttore
        FROM automobili A
        JOIN modelli M ON A.nome_modello = M.nome
        WHERE A.ID_registrazione = NEW.auto_riferita;

    IF produttore <> NEW.produttore THEN
        RAISE EXCEPTION 'Errore: Il produttore che firma l''atto non corrisponde al produttore del modello dell''auto!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_produttore
BEFORE INSERT ON atti_proprieta_iniziale
FOR EACH ROW
EXECUTE FUNCTION check_produttore();


-- Trigger4: il vecchio proprietario di un auto deve esserne il priprietario prima della firma dell'atto
CREATE OR REPLACE FUNCTION check_car_ownership_privato()
RETURNS TRIGGER AS $$
DECLARE proprietario_attuale VARCHAR;
BEGIN
    -- Cerca il proprietario attuale nel più recente atto di trasferimento
    SELECT nuovo_privato INTO proprietario_attuale
        FROM atti_trasferimento A_T1
        WHERE automobile = NEW.automobile AND NOT EXISTS (
            --Atti di trasferimento che riguardano la stessa auto con data_firmato successiva al primo
            SELECT * FROM atti_trasferimento A_T2
            WHERE A_T2.automobile = NEW.automobile AND A_T1.data_firmato < A_T2.data_firmato
        )

    -- Se non ci sono atti di trasferimento per quell'auto, cercalo nel più recente atto di vendita
    IF proprietario_attuale IS NULL THEN
        SELECT privato INTO proprietario_attuale
            FROM atti_vendita A_V1
            WHERE automobile = NEW.automobile AND senso_rivenditore_to_privato = TRUE AND NOT EXISTS (
                --Atti di riacquisto da parte della concessionaria che riguardano la stessa auto con data_firmato successiva alla vendita
                SELECT * FROM atti_vendita A_V2
                WHERE A_V2.automobile = NEW.automobile AND A_V2.senso_rivenditore_to_privato = FALSE AND A_V1.data_firmato < A_V2.data_firmato
            )

    IF proprietario_attuale <> NEW.vecchio_proprietario THEN
        RAISE EXCEPTION 'Errore: Il vecchio proprietario specificato nell''atto non corrisponde al proprietario dell''auto!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_car_ownership_privato
BEFORE INSERT ON atti_trasferimento
FOR EACH ROW
EXECUTE FUNCTION check_car_ownership_privato();


-- Trigger5.1: Assicura che esista un'atto di proprietà iniziale prima che venga stipulato un'atto di fornitura per quell'auto
CREATE TRIGGER trg_check_fornitura_dopo_proprietà_iniziale
BEFORE INSERT ON atti_fornitura
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM atti_proprieta_iniziale A
        WHERE A.automobile = NEW.automobile
    ) THEN
        SIGNAL SQLSTATE '45000';
        SET MESSAGE_TEXT 'Errore: Non è possibile stipulare un atto di fornitura senza un atto di proprietà iniziale per l’auto';
    END IF;
END;

-- Trigger5.2: Assicura che esista un'atto di fornitura prima che venga stipulato un'atto di vendita per quell'auto
CREATE TRIGGER trg_check_vendita_dopo_fornitura
BEFORE INSERT ON atti_vendita
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM atti_fornitura A
        WHERE A.automobile = NEW.automobile
    ) THEN
        SIGNAL SQLSTATE '45000';
        SET MESSAGE_TEXT 'Errore: Non è possibile stipulare un atto di vendita se l\'auto non è mai stata fornita ad un rivenditore';
    END IF;
END;

-- Trigger5.3: Assicura che esista un'atto di vendita prima che venga stipulato un'atto di rivendita per quell'auto
CREATE TRIGGER trg_check_trasferimento_dopo_vendita
BEFORE INSERT ON atti_vendita
FOR EACH ROW
WHEN NEW.senso_rivenditore_to_privato = FALSE       -- Solo per atti di rivendita
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM atti_vendita A
        WHERE A.automobile = NEW.automobile
    ) THEN
        SIGNAL SQLSTATE '45000';
        SET MESSAGE_TEXT 'Errore: Non è possibile stipulare un atto di trasferimento tra privati se l\'auto non è mai stata venduta';
    END IF;
END;

-- Trigger5.4: Assicura che esista un'atto di vendita prima che venga stipulato un'atto di trasferimento per quell'auto
CREATE TRIGGER trg_check_trasferimento_dopo_vendita
BEFORE INSERT ON Atti_trasferimento
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Atti_vendita A
        WHERE A.automobile = NEW.automobile
    ) THEN
        SIGNAL SQLSTATE '45000';
        SET MESSAGE_TEXT 'Errore: Non è possibile stipulare un atto di trasferimento tra privati se l\'auto non è mai stata venduta';
    END IF;
END;
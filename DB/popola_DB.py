import random
import datetime
import os
import copy

modello_produttore = {'Fiesta': 'Ford', 'Puma': 'Ford', 'Focus': 'Ford', 'Mondeo': 'Ford', 'Kuga': 'Ford', 'EcoSport': 'Ford', 'Ka': 'Ford', 'Mustang': 'Ford', 'GT': 'Ford', 'Explorer': 'Ford', 'Edge': 'Ford', 'Escape': 'Ford', 'Expedition': 'Ford', 'Ranger': 'Ford', 'Bronco': 'Ford', 'Maverick': 'Ford', 'Transit': 'Ford', 'F-150': 'Ford', 'Fusion': 'Ford', 'Punto': 'FIAT', 'Tipo': 'FIAT', '500': 'FIAT', '500X': 'FIAT', '500L': 'FIAT', 'Panda': 'FIAT', '500E': 'FIAT', 'Panda Cross': 'FIAT', 'Ducato': 'FIAT', 'Qubo': 'FIAT', 'Doblo': 'FIAT', 'Fiorino': 'FIAT', 'Freemont': 'FIAT', 'Ulysse': 'FIAT', 'Scudo': 'FIAT', 'Sedici': 'FIAT', 'Multipla': 'FIAT', 'SF90': 'Ferrari', '812': 'Ferrari', 'Portofino': 'Ferrari', 'Roma': 'Ferrari', 'GTC4Lusso': 'Ferrari', 'F8 Tributo': 'Ferrari', '488 Pista': 'Ferrari', 'LaFerrari': 'Ferrari', 'Enzo': 'Ferrari', 'F40': 'Ferrari', 'Corsa': 'Opel', 'Astra': 'Opel', 'Insignia': 'Opel', 'Grandland': 'Opel', 'Crossland': 'Opel', 'Yaris': 'Toyota', 'Corolla': 'Toyota', 'Camry': 'Toyota', 'RAV4': 'Toyota', 'Land Cruiser': 'Toyota', 'Supra': 'Toyota', 'Giulietta': 'Alfa Romeo', 'Giulia': 'Alfa Romeo', 'Stelvio': 'Alfa Romeo', 'Tonale': 'Alfa Romeo', 'A-Class': 'Mercedes', 'B-Class': 'Mercedes', 'C-Class': 'Mercedes', 'E-Class': 'Mercedes', 'S-Class': 'Mercedes', 'G-Class': 'Mercedes', 'GLA': 'Mercedes', 'GLB': 'Mercedes', 'GLC': 'Mercedes', 'GLE': 'Mercedes', 'GLS': 'Mercedes', 'AMG GT': 'Mercedes', 'SLC': 'Mercedes', 'CLA': 'Mercedes', 'CLS': 'Mercedes', 'GLK': 'Mercedes', 'Polo': 'Volkswagen', 'Golf': 'Volkswagen', 'Passat': 'Volkswagen', 'Tiguan': 'Volkswagen', 'Touareg': 'Volkswagen', 'Arteon': 'Volkswagen', 'up!': 'Volkswagen', 'T-Cross': 'Volkswagen', 'T-Roc': 'Volkswagen', 'Atlas': 'Volkswagen', 'Taos': 'Volkswagen', 'Serie 1': 'BMW', 'Serie 2': 'BMW', 'Serie 3': 'BMW', 'Serie 4': 'BMW', 'Serie 5': 'BMW', 'Serie 6': 'BMW', 'CX-3': 'Mazda', 'CX-5': 'Mazda', 'MX-5': 'Mazda', 'Mazda3': 'Mazda', 'Mazda6': 'Mazda'}
#produttori = list(set(modello_produttore.values()))
produttori = ['Ford', 'FIAT', 'Ferrari', 'Opel', 'Toyota', 'Alfa Romeo', 'Mercedes', 'Volkswagen', 'BMW', 'Mazda']
n_automobili = [0] * len(produttori)
rivenditori = ['11111111111','22222222222','33333333333','44444444444','55555555555','66666666666','77777777777','43068644461','37972004040','66748199734','79501275215','43423398934','57032042240','88152805385','66225905223','68204811818','46299983233','59112298478','36963750947','80133866781','10170233836','78907899332','13785604853','45552607053','19042328901','15071573885','27245888045','21149376734','33871025572','87779464988','29440293042','51361014320','89416408682','38666611358','37992681944','56145895601','77322857844','50813373966','71165993603','90325266641','29587095433','96315136403','12814199753','12216459983','30587113997','51322952314','76342970102','73754700264','13188253646','79098213320']
privati = [i for i in range(1, 11001)]


def generate_automobili():
    automobili = []
    for i in range(1, 50001):
        modello, produttore = random.choice(list(modello_produttore.items()))
        pos_produttore = produttori.index(produttore)
        id_registrazione = i
        n_automobili[pos_produttore] += 1
        n_serie_dal_produttore = pos_produttore * 10000 + n_automobili[pos_produttore]
        anno_produzione = random.randint(1970, 2020)
        data_distruzione = None if random.random() > 0.1 else (datetime.date(anno_produzione, 1, 1) + datetime.timedelta(days=random.randint(366, 6000)))
        automobili.append((id_registrazione, n_serie_dal_produttore, anno_produzione, str(data_distruzione), str(modello)))
    return automobili


def generate_atti_proprieta_iniziale(automobili:list):
    atti_proprieta_iniziale = []
    for i in range(1, 50001):
        automobile = automobili.pop(0)
        id_atto = i
        data_firmato = datetime.date(automobile[2], random.randint(1, 12), random.randint(1, 28))
        id_auto = automobile[0]
        produttore = modello_produttore.get(automobile[4])
        atti_proprieta_iniziale.append((id_atto, str(data_firmato), id_auto, str(produttore)))
    return atti_proprieta_iniziale


def generate_atti_fornitura(atti_proprieta_iniziale:list, rivenditori):
    atti_fornitura = []
    for i in range(1, 47001):
        atto_iniziale = atti_proprieta_iniziale.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_iniziale[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(0, 365))
        id_auto = atto_iniziale[2]
        produttore = atto_iniziale[3]
        rivenditore = random.choice(rivenditori)
        atti_fornitura.append((id_atto, str(data_firmato), id_auto, str(produttore), str(rivenditore)))
    return atti_fornitura


def generate_atti_vendita_riv_to_priv(atti_fornitura:list, privati):
    atti_vendita = []
    for i in range(1, 45001):
        atto_fornitura = atti_fornitura.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_fornitura[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(1, 1000))
        id_auto = atto_fornitura[2]
        rivenditore = atto_fornitura[4]
        privato = random.choice(privati)
        senso_rivenditore_to_privato = True
        atti_vendita.append((id_atto, str(data_firmato), id_auto, str(rivenditore), privato, senso_rivenditore_to_privato))
    return atti_vendita

def generate_atti_vendita_priv_to_riv(atti_vendita:list):
    atti_riacquisto = []
    for i in range(45001, 53001):
        atto_vendita = atti_vendita.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_vendita[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(10, 3000))
        id_auto = atto_vendita[2]
        rivenditore = atto_vendita[3]
        privato = atto_vendita[4]
        senso_rivenditore_to_privato = False
        atti_riacquisto.append((id_atto, str(data_firmato), id_auto, str(rivenditore), privato, senso_rivenditore_to_privato))
    return atti_riacquisto

def generate_atti_vendita_riv_to_priv2(atti_riaquisto:list, privati):
    atti_rivendita = []
    for i in range(53001, 60001):
        atto_riaquisto = atti_riaquisto.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_riaquisto[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(10, 300))
        id_auto = atto_riaquisto[2]
        rivenditore = atto_riaquisto[3]
        privato = random.choice(privati)
        senso_rivenditore_to_privato = True
        atti_rivendita.append((id_atto, str(data_firmato), id_auto, str(rivenditore), privato, senso_rivenditore_to_privato))
    return atti_rivendita


def generate_atti_trasferimento1(atti_vendita:list, privati):
    atti_trasferimento1 = []
    for i in range(1, 40001):
        atto_vendita = atti_vendita.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_vendita[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(10, 3000))
        id_auto = atto_vendita[2]
        vecchio_privato = atto_vendita[4]
        nuovo_privato = random.choice(privati)
        while nuovo_privato == vecchio_privato:
            nuovo_privato = random.choice(privati)
        atti_trasferimento1.append((id_atto, str(data_firmato), id_auto, vecchio_privato, nuovo_privato))
    return atti_trasferimento1

def generate_atti_trasferimento2(atti_trasferimento1:list, privati):
    atti_trasferimento2 = []
    for i in range(40001, 65001):
        atto_trasferimento1 = atti_trasferimento1.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_trasferimento1[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(100, 1000))
        id_auto = atto_trasferimento1[2]
        vecchio_privato = atto_trasferimento1[4]
        nuovo_privato = random.choice(privati)
        while nuovo_privato == vecchio_privato:
            nuovo_privato = random.choice(privati)
        atti_trasferimento2.append((id_atto, str(data_firmato), id_auto, vecchio_privato, nuovo_privato))
    return atti_trasferimento2

def generate_atti_trasferimento3(atti_trasferimento2:list, privati):
    atti_trasferimento3 = []
    for i in range(65001, 76001):
        atto_trasferimento2 = atti_trasferimento2.pop(0)
        id_atto = i
        data_firmato = datetime.datetime.strptime(atto_trasferimento2[1], '%Y-%m-%d').date() + datetime.timedelta(days=random.randint(100, 1000))
        id_auto = atto_trasferimento2[2]
        vecchio_privato = atto_trasferimento2[4]
        nuovo_privato = random.choice(privati)
        while nuovo_privato == vecchio_privato:
            nuovo_privato = random.choice(privati)
        atti_trasferimento3.append((id_atto, str(data_firmato), id_auto, vecchio_privato, nuovo_privato))
    return atti_trasferimento3


def write_inserts_to_file(filename, table_name, hcolumns, rows:list[list]):
    with open(filename, 'a') as file:
        file.write(f"INSERT INTO {table_name} ({', '.join(hcolumns)}) VALUES\n\t")
        for row in rows[:-1]:
            row = list(row)
            # for each item of the list row
            for i in range(len(row)):
                # that is of type string and not NULL, add single quotes
                if isinstance(row[i], str) and row[i] != 'None':
                    row[i] = f"\'{row[i]}\'"
                # if the item is None, replace it with the string 'NULL'
                elif row[i] == 'None':
                    row[i] = 'NULL'
            file.write(f"({', '.join(map(str, row))}),\n\t")
        # for the last row
        last_row = list(rows[-1])
        for i in range(len(last_row)):
                # that is of type string and not NULL, add single quotes
                if isinstance(last_row[i], str) and last_row[i] != 'None':
                    last_row[i] = f"\'{last_row[i]}\'"
                # if the item is None, replace it with the string 'NULL'
                elif last_row[i] == 'None':
                    last_row[i] = 'NULL'
        file.write(f"({', '.join(map(str, last_row))});\n\n")


def main():
    automobili = generate_automobili()
    produzione = [(produttore, n_auto_prodotte) for produttore, n_auto_prodotte in zip(produttori, n_automobili)]

    automobili_deep_copy = copy.deepcopy(automobili)
    atti_proprieta_iniziale = generate_atti_proprieta_iniziale(automobili_deep_copy)

    atti_proprieta_iniziale_deep_copy = copy.deepcopy(atti_proprieta_iniziale)
    atti_fornitura = generate_atti_fornitura(atti_proprieta_iniziale_deep_copy, rivenditori)

    atti_fornitura_deep_copy = copy.deepcopy(atti_fornitura)
    atti_vendita = generate_atti_vendita_riv_to_priv(atti_fornitura_deep_copy, privati)
    atti_vendita_deep_copy = copy.deepcopy(atti_vendita)
    # per praticità le concessionarie riaquistano solo le auto vendute da loro che non hanno avuto altri proprietari oltre all'acquirente
    atti_riacquisto = generate_atti_vendita_priv_to_riv(atti_vendita_deep_copy)
    atti_riaquisto_deep_copy = copy.deepcopy(atti_riacquisto)
    atti_rivendita = generate_atti_vendita_riv_to_priv2(atti_riaquisto_deep_copy, privati)
    atti_vendita_TOT = atti_vendita + atti_riacquisto + atti_rivendita
    
    atti_rivendita_deep_copy = copy.deepcopy(atti_rivendita)
    atti_trasferimento1 = generate_atti_trasferimento1(atti_vendita_deep_copy+atti_rivendita_deep_copy, privati)
    atti_trasferimento1_deep_copy = copy.deepcopy(atti_trasferimento1)
    atti_trasferimento2 = generate_atti_trasferimento2(atti_trasferimento1_deep_copy, privati)
    atti_trasferimento2_deep_copy = copy.deepcopy(atti_trasferimento2)
    atti_trasferimento3 = generate_atti_trasferimento3(atti_trasferimento2_deep_copy, privati)
    atti_trasferimento_TOT = atti_trasferimento1 + atti_trasferimento2 + atti_trasferimento3

    write_inserts_to_file('DB/popolazione_DB_py.sql', 'produttori', ['nome', 'n_auto_prodotte'], produzione)
    write_inserts_to_file('DB/popolazione_DB_py.sql', 'automobili', ['id_registrazione', 'n_serie_dal_produttore', 'anno_produzione', 'data_registrazione', 'data_distruzione', 'nome_modello'], automobili)
    write_inserts_to_file('DB/popolazione_DB_py.sql', 'atti_proprieta_iniziale', ['id_atto', 'data_firmato', 'automobile', 'produttore'], atti_proprieta_iniziale)
    write_inserts_to_file('DB/popolazione_DB_py.sql', 'atti_fornitura', ['id_atto', 'data_firmato', 'automobile', 'produttore', 'rivenditore'], atti_fornitura)
    write_inserts_to_file('DB/popolazione_DB_py.sql', 'atti_vendita', ['id_atto', 'data_firmato', 'automobile', 'rivenditore', 'privato', 'senso_rivenditore_to_privato'], atti_vendita_TOT)
    write_inserts_to_file('DB/popolazione_DB_py.sql', 'atti_trasferimento', ['id_atto', 'data_firmato', 'automobile', 'vecchio_privato', 'nuovo_privato'], atti_trasferimento_TOT)

if __name__ == "__main__":
    main()
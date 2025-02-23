# create connection
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="esercitazione1", host="localhost", port=5432, user="matteocancian", password="postgres")

# set schema to "progetto_database"
dbGetQuery(con, "SET search_path TO progetto_database;")

# pie chart: percentuale auto prodotte per ogni produttore
df_produzioni <- dbGetQuery(con, "SELECT nome, n_auto_prodotte FROM produttori;")
pie(df_produzioni$n_auto_prodotte, labels = df_produzioni$nome, main = "Percentuale auto prodotte per ogni produttore")

# barplot: distribuzione auto vendute per anno
date_vendita <- dbGetQuery(con, "SELECT data_firmato FROM atti_vendita WHERE senso_rivenditore_to_privato=TRUE;")
# estraggo l'anno dalle date di vendita
date_vendita$anno <- as.numeric(format(as.Date(date_vendita$data_firmato), "%Y"))
barplot(table(date_vendita$anno), main = "Distribuzione auto vendute per anno", xlab = "Anno", ylab = "N auto vendute", ylim = c(0, 1200))

# boxplot: distribuzione durata delle automobili distrutte
auto_produzione <- dbGetQuery(con, "SELECT automobile AS id_auto, data_firmato AS data_produzione FROM atti_proprieta_iniziale;")
auto_distruzione <- dbGetQuery(con, "SELECT id_registrazione AS id_auto, data_distruzione FROM automobili;")
vita_auto <- merge(auto_produzione, auto_distruzione, by="id_auto", all.x=TRUE)
vita_auto$durata <- as.numeric(difftime(as.Date(vita_auto$data_distruzione), as.Date(vita_auto$data_produzione), units = "days"))
boxplot(vita_auto$durata, main = "Distribuzione durata delle automobili", ylab = "Durata [giorni]")

# boxplot: numero di passaggi di proprietà di ogni auto tra privati (~query 2)
trasferimenti_per_auto <- dbGetQuery(con, "
    SELECT A.id_registrazione, COUNT(A_T.automobile) AS n_passaggi_tra_privati FROM automobili A
		    LEFT JOIN atti_trasferimento A_T ON A.id_registrazione = A_T.automobile
		    WHERE A.nome_modello = 'Fiesta'
        GROUP BY A.id_registrazione;
    ")
print(median(trasferimenti_per_auto$n_passaggi_tra_privati))
boxplot(trasferimenti_per_auto$n_passaggi_tra_privati, main = "n Trasferimenti tra privati per auto", ylim = c(0, 4))

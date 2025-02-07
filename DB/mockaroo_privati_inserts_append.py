import os
import re

def extract_insert_values(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    # Find all insert values using regex
    values = re.findall(r"insert into privati .*? values (.*?);", content, re.IGNORECASE | re.DOTALL)
    return values

def combine_insert_values(values_list):
    combined_values = ",\n\t".join(values_list)
    combined_insert = f"INSERT INTO privati (id_privato_gruppo, is_singolo_privato, cf, nome, cognome, indirizzo, telefono) VALUES\n\t{combined_values};"
    return combined_insert

def main(input_folder, output_file):
    all_values = []
    counter = 1
    for filename in os.listdir(input_folder):
        if filename.startswith("privati") and filename.endswith(".sql"):
            file_path = os.path.join(input_folder, filename)
            values = extract_insert_values(file_path)
            # before joining, check that for each value you want to append the value in the column if CF is unique
            CFs = set()
            for value in values:
                if value.split(", ")[2] not in CFs:
                    CFs.add(value.split(", ")[2])
                    # recreate the ID primary key cause mockaroo doesn't allow to generate more than 1000 rows for free
                    v = f"({counter}"+value[value.index(","):]
                    all_values.append(v)
                    counter += 1
                else:
                    print(f"CF \"{value}\", already exists in the combined insert")
    for i in range(10001, 11001):
        all_values.append(f"({i}, false, NULL, NULL, NULL, NULL, NULL)")
    
    combined_insert = combine_insert_values(all_values)
    
    with open(output_file, 'w') as file:
        file.write(combined_insert)

if __name__ == "__main__":
    input_folder = "DB/downloads/"  # Files downloaded from mockaroo
    output_file = "DB/combined_privati_inserts.sql"
    main(input_folder, output_file)
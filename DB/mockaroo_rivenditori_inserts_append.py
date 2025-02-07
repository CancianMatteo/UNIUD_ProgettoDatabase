import os
import re

def extract_insert_values(file_path):
    with open(file_path, 'r') as file:
        content = file.read()
    # Find all insert values using regex
    values = re.findall(r"insert into rivenditori .*? values (.*?);", content, re.IGNORECASE | re.DOTALL)
    return values

def combine_insert_values(values_list):
    combined_values = ",\n\t".join(values_list)
    combined_insert = f"INSERT INTO rivenditori (partita_iva, name, indirizzo, telefono, fax) VALUES\n\t{combined_values};"
    return combined_insert

def main(input_folder, output_file):
    all_values = []
    counter = 1
    for filename in os.listdir(input_folder):
        if filename.startswith("rivenditori") and filename.endswith(".sql"):
            file_path = os.path.join(input_folder, filename)
            values = extract_insert_values(file_path)
            all_values.extend(values)
    
    combined_insert = combine_insert_values(all_values)
    
    with open(output_file, 'w') as file:
        file.write(combined_insert)

if __name__ == "__main__":
    input_folder = "DB/downloads/"  # Files downloaded from mockaroo
    output_file = "DB/combined_rivenditori_inserts.sql"
    main(input_folder, output_file)
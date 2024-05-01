import pandas as pd
import numpy as np
import re
import sys

#just adds very basic last-minute data (which cannot need reconstructing/ancestral) to the metadata
#before export for colouring/filtering etc
#ONLY SHOULD BE USED FOR TRAITS THAT DO NOT NEED RECONSTRUCTING!!

#Is purely to add metadata when something new comes in last-minute without re-running everything
#Format of the file:
#column 1: 'strain' or 'accession' to indicate how to indicate the record to be changed
#column 2: the strain name or accession number of the record
#column 3: the name of the column to be changed
#column 4: the value to be inserted for the column

#EX: to modify a strain called "SE02-21-01" so that the column 'symptom' has the value 'TM':
#strain	SE02-21-01	symptom	TM

if __name__ == '__main__':
    import argparse

    parser = parser = argparse.ArgumentParser(description='add additional metadata',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--new-meta-in', help="tsv file with new data, format: 'column1 value1 column2 value2'. Column1 needs to be strain or accession")
    parser.add_argument('--meta-in', help="input meta file")
    parser.add_argument('--meta-out', help="output meta file")
    args = parser.parse_args()

    new_data = pd.read_csv(args.new_meta_in, sep='\t', header=None)
    meta = pd.read_csv(args.meta_in, sep='\t', index_col=False)
    
    for i, row in new_data.iterrows():
        meta_key = None

        if row[0] != "strain" and row[0] != "accession":
            sys.exit(f"First column must be 'strain' or 'accession' but it was '{row[0]}'.")

        if row[2] not in meta.columns:
            sys.exit(f"Third column must be a column in metadata, but '{row[2]}' was not found.")
        
        if row[2] == "strain" or row[2] == "accession":
            sys.exit(f"Third column must not be 'strain' or 'accession'!")

        #assuming the first column is what we want & third column is valid
        if row[1] in meta.accession.values:
            meta_key = meta.accession == row[1]
        elif row[1] in meta.strain.values:
            meta_key = meta.strain == row[1]

        if meta_key is None:
            print(f"Second column (key) was not found: \n{row}. \nNo changes made due to this column\n")
            #print(meta.loc[meta_key])
        else:
            meta.loc[meta_key, row[2]] = row[3]

    meta.to_csv(args.meta_out, sep='\t', index=False)
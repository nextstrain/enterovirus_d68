import pandas as pd
import re
from dateutil.parser import parse
import re, os
import shutil
from augur.parse import prettify 
from word2number import w2n
from parse_ages import *  #when running in ipython, cd to 'scripts', do this, then go back

#at the moment I have 1024 entries for age in vp1 meta. See how compares.

def parse_ages(host):
    #get age in months, and decimal years
    """
    Age formats possible:
    4     39    --> re.search('^[0-9.]+$', host)   I ASSUME THESE ARE YEAR!

    4M  0.75Y   3.12Y   --> re.search('[0-9.]+[A-Z]', host)    m.group(0)

    age 5   --> re.search('age [0-9]+$', host)

    1,92 years --> re.search('[0-9]+[,][0-9]+ year', host)

    4 years 1 year  3.4 years   --> re.search('[0-9.]+ year', host)

    5 y/o   2 y/o  -->  re.search(' [0-9.]+ y/o', host)
    BE AWARE of <1 y/o - don't want to process these.

    4 months    1 months    1 month  --> re.search('[0-9.]+ month', host)

    ALSO:
    ranges!
    ex: 0-18, 18-200, <1 year - will be handled later by parse_ages.py

    """
    #This stores age_year (decimal) and age_month, but only age_year is passed back currently
    # note that for ranges there is no age_month value - would need to add this!!
    # ORDER YOU LOOK FOR THESE PATTERNS MATTERS!

    if re.search('-|>|<', host): #special case, with ranges

        host = re.sub("Years|years|Year|year|Yr|yr", "y", host)
        host = re.sub("Months|months|Month|month", "m", host)
        host = re.sub("Days|days|Day|day", "d", host)

        if re.search('-', host):
            parts = re.split('-', host)
            age_year = str(convert_to_year(parts[0])) + '-' + str(convert_to_year(parts[1]))
        #is range with <
        elif re.search('<', host):
            age_year = '0-' + str(convert_to_year(host.replace("<", "")))
        #is range with >
        elif re.search('>', host):
            age_year = str(convert_to_year(host.replace(">", ""))) + '-200'

    else: #is an age not with a range

        if re.search('[0-9.]+[A-Z]', host):
            m = re.search('[0-9.]+[A-Z]', host).group(0)
            if 'Y' in m:
                age_month = round(12*float(m.replace("Y", "")), 2)
                age_year = float(m.replace("Y", ""))
            else:
                age_month = float(m.replace("M", ""))
                age_year = round(float(m.replace("M", ""))/12, 2)

        elif re.search('^[0-9.]+$', host): # ASSUME these are year! number only
            m = re.search('^[0-9.]+$', host).group(0)
            age_month = round(12*float(m), 2)
            age_year = float(m)

        elif re.search('age [0-9]+$', host): # these are always year
            m = re.search('age [0-9]+$', host).group(0)
            age_month = round(12*float(m.replace("age ","")), 2)
            age_year = float(m.replace("age ",""))

        elif re.search('[0-9]+[,][0-9]+ year', host): #these are always year, with european decimal
            m = re.search('[0-9]+[,][0-9]+ year', host).group(0)
            m = m.replace(",",".") #replace m with . and process as below
            age_month = round(12*float(m.replace(" year","")), 2)
            age_year = float(m.replace(" year",""))

        elif re.search('[0-9.]+ year', host): #these are always year
            m = re.search('[0-9.]+ year', host).group(0)
            age_month = round(12*float(m.replace(" year","")), 2)
            age_year = float(m.replace(" year",""))

        elif re.search(' [0-9.]+ y/o', host): #these are always year
            m = re.search(' [0-9.]+ y/o', host).group(0)
            age_month = round(12*float(m.replace(" y/o","")), 2)
            age_year = float(m.replace(" y/o",""))

        elif re.search('[0-9.]+ month', host):
            m = re.search('[0-9.]+ month', host).group(0)
            age_month = float(m.replace(" month",""))
            age_year = round(float(m.replace(" month", ""))/12, 2)

        else:
            age_month = ''
            age_year = ''

    return age_year

#input_meta = "BVBRC_genome.csv"
#output_meta = "parsed_meta.csv"
#regions_file = "config/geo_regions.tsv"

######Information on the columns I read in from the data file:

#examples of 'Taxon Lineage Names' for those Rhino 87 and EV-D68
#Viruses;Riboviria;Orthornavirae;Pisuviricota;Pisoniviricetes;Picornavirales;Picornaviridae;Enterovirus;Enterovirus D;enterovirus D68;Human rhinovirus 87
#Viruses;Riboviria;Orthornavirae;Pisuviricota;Pisoniviricetes;Picornavirales;Picornaviridae;Enterovirus;Enterovirus D;enterovirus D68

#Host Name
#Note that as of 4 Sept 22 - "Host Name" sometimes contains age & gender, but a check shows all these ages & genders were present in the correct columns - no action needed

#Isolation source
#These also sometimes have age & gender in them - they are NOT in the age & gender columns - we need to parse them!
#"of a four years old girl" "of an eleven month old male" "of a 3 year old male" "from a 62 year old female"
# Then needs to be cleaned extensively before is useful  - have tried to do that to some extent

#Host Group
# Is either empty, 'Human' or 'lab' - renamed to 'viral_source'

#Host Gender
# Is either empty, 'male' or 'female' - renamed to 'sex'

#Age
# Complicated! In particular as French numbers '0,11 years' have been turned into '0 11 years' :/ 

#Geography 
# Isolation Country seems to be just country
# Geographic Group seems to be Region - but may not match our own, we should probably just DIY
# Geographic Location is 'country:region/city' - would be nice to parse these out, we might use them later (would need standardizing!) #TODO



if __name__ == '__main__':
    import argparse

    parser = parser = argparse.ArgumentParser(description='parse data from BVBRC',
                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--input', help="input meta file")
    parser.add_argument('--output', help="output meta")
    parser.add_argument('--regions', help="file to specify regions")
    parser.add_argument('--length', help="specify if VP1 or genome run (VP1 makes new strain names w/accession #)")
    args = parser.parse_args()

    input_meta = args.input #"data/allEntero-3Oct18.tsv"
    output_meta = args.output #"data/20181003_GenBank.tsv"

    # any country names to replace (happens later)
    country_replace = {'Viet Nam': 'Vietnam'}

    #these are the columns we'll read in (leave the rest)
                                                                #length        #sometimes contains age         #Human, lab, "" #date released GB  #swab, etc - sometimes age
    cols = ['Strain', "Taxon Lineage Names", "GenBank Accessions", "Contig N50", "Host Name", "Collection Date", "Host Group", "Completion Date",   "Isolation Source", "Host Gender", "Host Age", "Isolation Country","Geographic Group","Geographic Location"]
    dtype={"Host Name": str}
    meta = pd.read_csv(input_meta, sep=',', index_col=False, usecols=cols, dtype=dtype).fillna(value="")

    #Host Name sometimes has age & gender
    #Host Age has age
    #Isolation Source sometimes has age & gender

    # Get strain from taxon names -- just take whatever's last - insight into categorization? (they must all be D68)
    virus_name = meta["Taxon Lineage Names"].apply(lambda x: x.split(";")[-1])

    #Get host name & simplify -- reduce "Homo sapiens 1 year old girl" to "Homo sapiens". The age/gender are already in the correct columns (also ..."10 months old boy")
    meta["Host Name"] = meta["Host Name"].apply(lambda x: re.sub(r" [0-9]+ [a-z]+ old [a-z]+", "", x))
    meta["Host Name"] = meta["Host Name"].apply(lambda x: re.sub(r"Human", "Homo sapiens", x))

    #Isolation Source
    #get the age/gender values out of Isolation Source & store
    regex1 = r"[from]+ [an]+ [A-z0-9]+ [a-z]+ old [a-z]+"
    regex2 = r"child"
    regex3 = r"adult"
    regex4 = r"pediatric"

    recovered_ag = meta["Isolation Source"].apply(lambda x: "".join(re.findall("|".join([regex1, regex2, regex3, regex4]), x)))
    meta["Isolation Source"] = meta["Isolation Source"].apply(lambda x: re.sub(regex1, "", x))

    #Need to now remove gender & age so they can go into the correct columns
    #separate out genders to merge into genders, then remove
    reparsed_genders = recovered_ag.apply(lambda x: "".join(re.findall(r"boy|Boy|girl|Girl|male|Male|Female|female", x))) # 132 of these
    recovered_ag = recovered_ag.str.replace(r"boy|Boy|girl|Girl|male|Male|Female|female", "", regex=True)
    #tidy
    recovered_ag = recovered_ag.str.replace(r" old ", "", regex=True)
    #now parse ages down to something the later script can handle
    #child = 0-18
    #adult = 18-200
    reparsed_ages = recovered_ag.apply(lambda x: "0-18" if "child" in x else "0-18" if "pediatric" in x else "18-200" if "adult" in x else x) #these are ranges that will be interpreted as <18y and >=18y by parse_ages.py
    #tidy
    reparsed_ages = reparsed_ages.str.replace(r"of (a|an) |from (a|an) ", "", regex=True)
    #try to convert words (two) to numbers (2)
    # this checks split length, if >1, tries to w2n the first element, then joins it to the rest of the split elements (ex: "years")
    recovered_ages = reparsed_ages.apply(lambda x: " ".join([str(w2n.word_to_num(x.split()[0])), " ".join(x.split()[1:])]) if len(x.split())>1 else x)
    #there are 213
    #(recovered_ages.values!="").sum()


    #How to keep isolation source updated?
    # This is pretty manual and step-by-step in order to try and capture the most & also to allow flexibility
    # in the future if we want to change labels, add things, etc, etc

    #create something empty to put the final isolations in. Using Gender cuz easy to 'clean' :)
    new_iso_source = meta["Host Gender"].apply(lambda x: x)
    #remove everything in it
    new_iso_source = new_iso_source.str.replace(r"Male|male|m|M|boy|Boy|Man|man|Female|female|f|F|girl|Girl|Woman|woman", "", regex=True)
    new_iso_source = new_iso_source.rename("New Isolation Source")

    #respiratory swabs
    np_swab = meta["Isolation Source"].apply(lambda x: x if 
        (bool(re.search(r"nasal|throat|mouth|naso|phary|resp|NP|TS|nose", x)) and bool(re.search(r"swab", x))) or bool(re.search(r"NP|TS|RS|NS", x))
        else "")
    new_iso_source[np_swab.values!=""] = "respiratory swab"

    #respiratory unspecified
    res_samp = meta["Isolation Source"].apply(lambda x: x if 
        bool(re.search(r"^throat$|^nasal$|^nose$|^nasopharyngeal$|^nasopharynx$|tracheal secretion$|bronchoalveolar-fluid$|respiratory tract$|^respiratory$|^upper respiratory$", x))
        or bool(re.search(r"^respiratory sample|respiratory sample$|nasopharyngeal secretion", x))
        else "")
    new_iso_source[np_swab.values!=""] = "respiratory unspecified"

    #respiratory aspirates
    np_asp = meta["Isolation Source"].apply(lambda x: x if 
        bool(re.search(r"aspirate", x)) or bool(re.search(r"NPA", x))
        else "")
    new_iso_source[np_asp.values!=""] = "respiratory aspirate"

    #respiratory washes/lavages
    np_lav = meta["Isolation Source"].apply(lambda x: x if 
        bool(re.search(r"lavage|wash", x)) or bool(re.search(r"NW|TW|BAL", x))
        else "")
    new_iso_source[np_lav.values!=""] = "respiratory wash/lavage"

    #CSF/spinal
    csf = meta["Isolation Source"].apply(lambda x: x if 
        bool(re.search(r"spin|cerebro", x)) or bool(re.search(r"CSF|csf", x))
        else "")
    new_iso_source[csf.values!=""] = "CSF"

    #stool/rectal swab -- not included: "gastrointestinal"
    fae = meta["Isolation Source"].apply(lambda x: x if bool(re.search(r"stool|Stool|Faec|faec|fecal|Fecal|rect|Rect|gastrointestinal", x)) else "")
    new_iso_source[fae.values!=""] = "gastrointestinal/stool/rectal swab"

    #sewage
    sew = meta["Isolation Source"].apply(lambda x: x if bool(re.search(r"Sewage|sewage|sewer|Sewer|wastewater|Wastewater", x)) else "")
    new_iso_source[sew.values!=""] = "sewage"

    #sputum
    spu = meta["Isolation Source"].apply(lambda x: x if bool(re.search(r"sputum", x)) else "")
    new_iso_source[spu.values!=""] = "sputum"

    #cell culture
    cell = meta["Isolation Source"].apply(lambda x: x if bool(re.search(r"cell", x)) else "")
    new_iso_source[cell.values!=""] = "cell culture"

    #output a file so one can check which have a source & which don't etc.
    #meta["Isolation Source"].loc[meta["Isolation Source"]!="" and new_iso_source==""]
    iso_matching = pd.concat([meta["Isolation Source"], new_iso_source], axis=1)
    iso_matching.to_csv("check_iso.tsv", sep='\t', index=False)

    # Host Gender
    # seems to be standardized but let's ensure, esp as added values from Isolation source
    genders = meta["Host Gender"].apply(lambda x: x)
    # add the genders from Isolation source -- there are 4507 empty cells before adding, and 4375 after - diff of 132, as expected! #(meta["Host Gender"].values=="").sum()
    genders[reparsed_genders.values!=""] = reparsed_genders[reparsed_genders.values!=""]
    #standardize
    genders = genders.str.replace(r"Male|male|m|M|boy|Boy|Man|man", "male", regex=True)
    genders = genders.str.replace(r"Female|female|f|F|girl|Girl|Woman|woman", "female", regex=True)



    # Host Age
    # Need to push EU numbers 'back together' (where , missing), add ages from Isolation Source, and then parse via existing age script
    # First, put French numbers back together
    #ags = meta["Host Age"].apply(lambda x: re.sub(r"([0-9]+) ([0-9]+)", r'\1,\2', x)) #method below is very slightly faster (only on 1000 scale)
    new_ages = meta["Host Age"].str.replace(r"([0-9]+) ([0-9]+)", r'\1,\2', regex=True)

    # Add in the ages recovered from Isolation source -- there are 311 to begin with, plus 213 recovered -- those should be 524 but are 486, simplying some overwriting.
    # The overwrites are happening where I've taken info from things like 'child' from Isolation source, yet there's a true age... so don't overwrite!
    # Take real age over recovered age
    ages_recov = pd.concat([new_ages, recovered_ages], axis=1)
    ages_recov = ages_recov.rename(columns={"Host Age":"new_ages", "Isolation Source":"recovered_ages"})
    ages_recov.loc[ages_recov["new_ages"]=="",'new_ages'] = ages_recov.loc[ages_recov["new_ages"]=="",'recovered_ages']
    #(ages_recov["new_ages"].values!="").sum() 
    #ages_recov.to_csv("check_recov_ages.tsv", sep='\t', index=False)  #print to check -- see particularly around 4747 that real ages not overwritten

    # call script to parse ages into decimal years or ranges regardless of format
    dec_ages = ages_recov["new_ages"].apply(lambda x: parse_ages(x))

    #Output file to check ages? #TODO
    ages_comp = pd.concat([meta["Host Age"], dec_ages], axis=1)
    ages_comp.to_csv("check_ages.tsv", sep='\t', index=False)


    #Geography
    # Isolation Country seems clean & go straight to being country
    # Geographic Group is region - we will assign this ourself
    # Geographic Location is 'country:division/city' - parse out for later #TODO fully parse

    #replace a few countries specifically (list at top of script)
    meta["Isolation Country"] = meta["Isolation Country"].replace(to_replace=country_replace)

    #attach regions
    #get region if supplied #TODO --- this should work with args but rewire args
    if args.regions:
        regions = {}
        with open(args.regions) as f:
            regs = f.readlines()
        regs = regs[1:] #remove first line

        for x in regs:
            x = x.strip()
            pair = x.split("\t")
            if len(pair) > 1:
                regions[pair[0]] = pair[1]

    newregion = []
    for coun in meta["Isolation Country"]:
        reg = "NA"
        if coun != "" and coun != "na" and coun != "Na":
            if coun not in regions:
                print("No region found for {}! Setting to NA".format(coun))
            else:
                reg = regions[coun]
        newregion.append(reg)
    newregion = pd.Series(newregion, name="region")

    #try to parse out division - not fully parsed, can add this later
    locations = meta["Geographic Location"].apply(lambda x: "".join(re.findall(r": .+$", x)))
    locations = locations.str.replace(r": ", "", regex=True)

    #Completion Date
    # put time/date into the right format ex: 2019-01-22T00:00:00Z
    meta["Completion Date"] = meta["Completion Date"].str.replace(r"T[0:]+Z", "", regex=True)

    #Bring together all the columns, and rename how we want.

    #Strain             strain and/or orig_strain (depending on genome or vp1) 
    #Genbank Accessions accession
    #Contig N50         seq_len
    #Collection Date    date
    #dec_ages           age
    #genders            sex
    #new_iso_source     isolation_method
    #Isolation Country  country
    #newregion          region
    #locations          division
    #Host Group         viral_source
    #virus_name         virus
    #Completion Date    release_date
    #Host Name          host_name




    new_metadata = pd.concat([meta["Strain"], meta["GenBank Accessions"], meta["Contig N50"], meta["Collection Date"], 
                            dec_ages, genders, new_iso_source, meta["Isolation Country"], newregion, locations,
                            meta["Host Group"], meta["Host Name"], meta["Completion Date"], virus_name], axis=1)

    rena = {"Strain":"strain", "GenBank Accessions":"accession", 
            "Contig N50":"seq_len", "Collection Date":"date", 
            "new_ages":"age", "Host Gender":"sex", "New Isolation Source":"isolation_method", 
            "Isolation Country":"country", "Geographic Location":"division", 
            "Host Group":"viral_source", "Host Name":"host", "Completion Date":"release_date", "Taxon Lineage Names":"virus"}

    #do the renaming
    new_metadata.rename(rena, axis='columns', inplace=True)

    #if strain is empty, make it the accession number
    new_metadata.loc[new_metadata["strain"]=="",'strain'] = new_metadata.loc[new_metadata["strain"]=="",'accession']


    #if genome, find mouse-adapted strain with same name as human, and re-name so no duplicate names
    if args.length=="genome":
        mouse_samp = new_metadata.loc[new_metadata["accession"] == "MH708882"]
        new_metadata.loc[new_metadata["accession"] == "MH708882", "strain"] = mouse_samp["strain"]+"-Mouse"

    #if VP1, rename strain to include accession so that strain is unique
    if args.length=="vp1":
        new_metadata["orig_strain"] = new_metadata["strain"].apply(lambda x: x)
        new_metadata["strain"] = new_metadata["orig_strain"] + "__" + new_metadata["accession"]
    else:
        meta["orig_strain"] = ""

    #print file out
    new_metadata.to_csv(output_meta, sep='\t', index=False)

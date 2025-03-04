# Example run call:
#   source activate entero
#   module load BLAST+   #IF DOING VP1 DATABASE BUILD ON SCICORE
#   nohup snakemake default_vp1 --jobscript submit.sh --jobs 4 --cluster sbatch 1>log &

### min_len
# allows users to set the min sequence length in 'filter' through the file name.
# It must be either nothing or preceeded by an underscore.
# *** It DOES NOT CHANGE what's downloaded from GenBank/INSDC ***
# This is to include 'manual' or 'personal' sequences that are shorter, in a 700bp background tree
#Ex: "vp1/auspice/enterovirus_d68_vp1_300_tree.json" will do a VP1 run with min-length 300

### max_year
# allows users to set the max year in 'filter' through the file name.
# It must be either nothing or an underscore followed by 4-digit year (starting 20-- or 19--) followed by 'y'
# (This allows it to be distinguished from min_length by snakemake)
# NOTE:
#   THIS MAY NOT WORK HOW YOU THINK. '_2018y' will include sequences UP TO 2019.0 (aka all of 2018)
#   This is because I think the file name '2018y' *including* samples up to 2018 is more intuitive.

import datetime

wildcard_constraints:
    length="vp1|genome",
    min_len="|_[0-9]+",
    max_year="|_20[0-9]{2}[y]|_19[0-9]{2}[y]",
    gene="|-vp4|-vp2|-vp3|-vp1|-2A|-2B|-2C|-3A|-3B|-3C|-3D",
    date="|-[0-9]{2}[A-z]+[0-9]{2,4}"
    #from: https://bitbucket.org/snakemake/snakemake/issues/910/empty-wildcard-assignment-works-only-if

###EXAMPLE RUNS:
#To run a default (700bp, all avail years) VP1 run:
# snakemake "vp1/auspice/enterovirus_d68_vp1.json"
# or
# snakemake default_vp1

#To run a default (no filter length, all avail years) genome run:
# snakemake "genome/auspice/enterovirus_d68_genome.json"
# or
# snakemake default_genome

#To run a VP1 run with all years but 300bp filter step (for 2019 seq analysis):
# snakemake "vp1/auspice/enterovirus_d68_vp1_300.json"

#To run a vp1 run with only sequences up to 2018 (for paper)
# snakemake "vp1/auspice/enterovirus_d68_vp1_2018y.json"

#To run a genome run with only sequences up to 2018 (for paper)
# snakemake "genome/auspice/enterovirus_d68_genome_2018y.json"

#To combine two things (300bp filter and 2018 sequences):
# snakemake "vp1/auspice/enterovirus_d68_vp1_300_2018y.json"

#To date a run at the end, so it's distingishable in the auspice folder:
# snakemake "genome/auspice/enterovirus_d68_genome-15Feb22.json" 
# or
# snakemake "genome/auspice/enterovirus_d68_genome-15Feb2022.json"

#To run all genes in genome: (some are too short and will fail) with default settings
# snakemake genome_genes

rule all: #essentially runs 'default_vp1' and 'default_genome' rules
    input:
        #auspice_tree = expand("{seg}/auspice/enterovirus_d68_{seg}_tree.json", seg=["vp1","genome"]),
        #auspice_meta = expand("{seg}/auspice/enterovirus_d68_{seg}_meta.json", seg=["vp1","genome"])
        auspice_out = expand("{seg}/auspice/enterovirus_d68_{seg}.json", seg=["vp1","genome"]),
        tip_freq_out = expand("{seg}/auspice/enterovirus_d68_{seg}_tip-frequencies.json", seg=["vp1","genome"])

rule vp1:
    input:
        #auspice_tree = "{length}/auspice/enterovirus_d68_vp1{gene}{min_len}{max_year}_tree.json",
        #auspice_meta = "{length}/auspice/enterovirus_d68_vp1{gene}{min_len}{max_year}_meta.json"
        auspice_out = "{length}/auspice/enterovirus_d68_vp1{gene}{min_len}{max_year}{date}.json",
        tip_freq_out = "{length}/auspice/enterovirus_d68_vp1{gene}{min_len}{max_year}{date}_tip-frequencies.json"

rule genome:
    input:
        #auspice_tree = "{length}/auspice/enterovirus_d68_genome{gene}{min_len}{max_year}_tree.json",
        #auspice_meta = "{length}/auspice/enterovirus_d68_genome{gene}{min_len}{max_year}_meta.json"
        auspice_out = "{length}/auspice/enterovirus_d68_genome{gene}{min_len}{max_year}{date}.json",
        tip_freq_out = "{length}/auspice/enterovirus_d68_genome{gene}{min_len}{max_year}{date}_tip-frequencies.json"

GENES = ["-vp4","-vp2","-vp3","-vp1","-2A","-2B","-2C","-3A","-3B","-3C","-3D"]
rule genome_genes:
    input:
        #auspice_tree = expand("genome/auspice/enterovirus_d68_genome{genes}_tree.json", genes=GENES),
        #auspice_meta = expand("genome/auspice/enterovirus_d68_genome{genes}_meta.json", genes=GENES)
        auspice_out = expand("genome/auspice/enterovirus_d68_genome{genes}.json", genes=GENES),
        tip_freq_out = expand("genome/auspice/enterovirus_d68_genome{genes}_tip-frequencies.json", genes=GENES)

rule default_vp1:
    input:
        #auspice_tree = "vp1/auspice/enterovirus_d68_vp1_tree.json",
        #auspice_meta = "vp1/auspice/enterovirus_d68_vp1_meta.json"
        auspice_out = "vp1/auspice/enterovirus_d68_vp1.json",
        tip_freq_out = "vp1/auspice/enterovirus_d68_vp1_tip-frequencies.json",
        root_seq = "vp1/auspice/enterovirus_d68_vp1_root-sequence.json"

rule default_genome:
    input:
        #auspice_tree = "genome/auspice/enterovirus_d68_genome_tree.json",
        #auspice_meta = "genome/auspice/enterovirus_d68_genome_meta.json",
        auspice_out = "genome/auspice/enterovirus_d68_genome.json",
        tip_freq_out = "genome/auspice/enterovirus_d68_genome_tip-frequencies.json",
        root_seq = "genome/auspice/enterovirus_d68_genome_root-sequence.json"

rule default_vp1_date:
    input:
        auspice_out = "vp1/auspice/enterovirus_d68_vp1{date}.json",
        tip_freq_out = "vp1/auspice/enterovirus_d68_vp1{date}_tip-frequencies.json"

rule files:
    input:
        #files downloaded from INSDC
        #raw_vipr_genome = "genome/data/genomeEntero-03Sep22.tsv", #raw VIPR download!
        raw_insdc_genome = "genome/data/sequences-NCBIVirus-2025-02-09.tsv", #modified download from NCBIVirus
        raw_insdc_vp1 = "vp1/data/sequences-NCBIVirus-2025-02-09.tsv", #modified download from NCBIVirus
        
        ### Here one can insert data not on INSDC - ensure file formats are correct and all fastas end in an empty line
        ### Most of this data should now be on INSDC
        ### Be sure to include any of this in the 'find_new' rule to avoid re-downloading (if has an accession)
        #samples sequenced in Sweden
        swedish_seqs = "data/20190611_Karolinska_25Jul19_{length}.fasta",
        swedish_meta = "data/20190611_Karolinska.csv",
        #samples added manually via other routes - not from INSDC
        manual_seqs = "{length}/data/manual-seqs-ages.fasta",
        manual_meta = "{length}/data/manual-meta-ages.csv",
        #add 2021/2 data from ENPEN - should all be on INSDC now
        enpen_meta_2021 = "data/ENPEN_seq2021-meta.csv",
        enpen_seqs_2021 = "data/ENPEN_seq2021-seqs.fasta",

        #add historic data? Currently not used!
        hist_meta = "data/others_from_adam.csv", #"data/all_hist.csv",
        hist_seqs = "data/others_from_adam.fst", #"data/all_hist.fasta",

        #other data files (common to both runs)
        extra_meta = "data/age-data.tsv",

        #config files
        dropped_strains = "{length}/config/dropped_strains.txt",
        kept_strains = "{length}/config/kept_strains.txt",
        kept_strains_300 = "{length}/config/kept_strains_300.txt",
        align_annot_ref = "{length}/config/ev_d68_reference_{length}.gb",
        clades = "{length}/config/clades.tsv",
        auspice_config = "{length}/config/auspice_config.json",
        colors = "{length}/config/colors.tsv",
        lat_long = "config/lat_longs.tsv",
        regions = "config/geo_regions.tsv",
        blast_ref = "vp1/config/ev_d68_reference_vp1.fasta"

files = rules.files.input

import os.path
RERUN = True if os.path.isfile("{length}/genbank/current_insdc_download.tsv") else False

# This function checks for presence of a file to determine if a rerun!
def is_rerun(wildcards):
    #print("{}/genbank/current_vipr_download.tsv".format(wildcards))
    #print(os.path.isfile("{}/genbank/current_vipr_download.tsv".format(wildcards)))
    return os.path.isfile("{}/genbank/current_insdc_download.tsv".format(wildcards))

# This figures out which INSDC file to use depending on whether calling genome or vp1 run
INSDC_FILES = {"genome": files.raw_insdc_genome, "vp1": files.raw_insdc_vp1}

##############################
# Parse metadata from INSDC
# adds a column 'orig_strain' - adds accession to new 'strain' for VP1, blank for genome
###############################
rule parse_insdc_meta:
    input:
        meta = lambda wildcards: INSDC_FILES[wildcards.length],
        regions = ancient(files.regions)
    output:
        out = "{length}/temp/current_insdc_download.tsv"
    params:
        rerun = lambda wildcards: is_rerun(wildcards.length)
    #messages do not work with calling lambda functions....
    #message:
    #    "This {wildcards.length} rerun will use existing GenBank files! Only new accession numbers will be downloaded" if (lambda wildcards: is_rerun(wildcards.length)) else "Starting new {wildcards.length} run from scratch. All VIPR samples will be downloaded."
    shell:
        """
        # Figure out message to show user.
        rrun={params.rerun}
        if [ $rrun == "True" ]; then
            echo "This {wildcards.length} rerun will use existing GenBank files! Only new accession numbers will be downloaded"
        else
            echo "Starting new {wildcards.length} run from scratch. All INSDC samples will be downloaded."
        fi

        python scripts/vipr_parse.py --input {input.meta} --output {output.out} \
            --regions {input.regions} \
            --length {wildcards.length}
        """

##############################
# FIND NEW
# find only new seqs to download - exclude those in 'Swedish' or 'manual'
# Send possible link to current download file - if empty (newrun) will be ignored.
# If not empty (rerun), these will also be ignored
###############################
rule find_new:
    input:
        swed_meta = ancient(files.swedish_meta), #do not rerun if other meta changes - won't influence genbank!
        man_meta = ancient(files.manual_meta),
        enpen_meta = ancient(files.enpen_meta_2021),
        new_meta = rules.parse_insdc_meta.output.out
    params:
        old_meta = ancient("{length}/genbank/current_insdc_download.tsv")
    output:
        "{length}/temp/meta_to_download.tsv" 
    shell:
        """
        python scripts/find_new.py --input-new {input.new_meta} \
            --exclude {input.swed_meta} {input.man_meta} {input.enpen_meta} {params.old_meta} \
            --output {output}
        """


##############################
# Download from Genbank only new and non-duplicate sequences
###############################
rule download_seqs:
    input:
        meta = "{length}/temp/meta_to_download.tsv"
    output:
        sequences = "{length}/temp/downloaded_seqs.fasta",
        meta = "{length}/temp/downloaded_meta.tsv"
    run:
        import pandas as pd
        import os
        from Bio import Entrez, SeqIO
        from dotenv import load_dotenv, find_dotenv
        from augur.parse import forbidden_characters
        from datetime import datetime

        load_dotenv(find_dotenv())
        Entrez.email = os.environ.get("EMAIL")
        #email address should be stored in an .env file in the base directory, in the format EMAIL=user@email.com

        print(input.meta)
        meta = pd.read_csv(input.meta, sep='\t')
        originalMetaLen = len(meta)
        additional_meta = {}
        len_cutoff = 6400 if wildcards.length=="genome" else 300
        print("Downloading only {} sequences with length >= {}".format(wildcards.length, len_cutoff))

        tooShort = []
        didntWork = []
        with open(output.sequences, 'w') as fh:
            for ri, row in meta.iterrows():
                try:
                    handle = Entrez.efetch(db="nucleotide", id=row.accession, rettype="gb", retmode="text")
                except:
                    print(row.accession, "did not work")
                    didntWork.append("{}\t{}".format(row.strain, row.accession))
                    meta.drop(ri, inplace=True)
                    continue
                print(row.strain, row.accession)
                rec = SeqIO.read(handle, 'genbank')
                if len(rec.seq) - rec.seq.count("N") < len_cutoff:
                    print(row.strain, row.accession, "is too short when Ns removed!")
                    tooShort.append("{}\t{}".format(row.strain, row.accession))
                    meta.drop(ri, inplace=True)
                    continue
                try:
                    authors = rec.annotations['references'][0].authors
                    title = rec.annotations['references'][0].title
                except:
                    authors = ''
                    title = ''

                url = 'https://www.ncbi.nlm.nih.gov/nuccore/'+row.accession
                add_date = datetime.today().strftime('%Y-%m-%d')
                additional_meta[ri] = {'url':url, 'authors':authors, 'title':title, 'date_added':add_date}
                tmp = row.strain
                tmp = tmp.translate(forbidden_characters)
                rec.id = tmp
                rec.name = tmp
                rec.description = ''
                SeqIO.write(rec, fh, 'fasta')

        print("\n")
        print(len(tooShort), "sequences were too short after Ns were removed, and were excluded.")
        shortFile = "{}/temp/too_short.txt".format(wildcards.length)
        if tooShort:
            with open(shortFile, 'w') as f:
                for item in tooShort:
                    f.write("%s\n" % item)
            print("You can see those excluded as too short in '{}'".format(shortFile))

        print(len(didntWork), "sequences weren't able to be downloaded and were excluded.")
        didntFile = "{}/temp/didnt_work.txt".format(wildcards.length)
        if didntWork:
            with open(didntFile, 'w') as f:
                for item in didntWork:
                    f.write("%s\n" % item)
            print("You can see those that failed to download in '{}'".format(didntFile))

        print("\nOf {} files we tried to download, {} were downloaded.".format(originalMetaLen,len(meta)))
        add_meta = pd.DataFrame(additional_meta).transpose()
        all_meta = pd.concat((meta, add_meta), axis=1)
        all_meta.to_csv(output.meta, sep='\t', index=False)


#####################################################################################################
#    BLAST - or not
#       If VP1, need to BLAST. if genome, do not, but must rename files.
#####################################################################################################

##############################
# If VP1 - BLAST
###############################
rule blast:        
    input:
        blast_db_file = files.blast_ref,
        seqs_to_blast =  "vp1/temp/downloaded_seqs.fasta" #from rule download.seqs output
    output:
        blast_out = "vp1/temp/blast_out.csv"
    run:
        from subprocess import call
        import os
        comm = ["makeblastdb -in", input.blast_db_file, "-out vp1/temp/entero_db_vp1 -dbtype nucl"]
        cmd = " ".join(comm)
        os.system(cmd)
        comm2 = ["blastn -task blastn -query", input.seqs_to_blast, "-db vp1/temp/entero_db_vp1 -outfmt '10 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qcovs' -out", output.blast_out, "-evalue 0.0005"]
        cmd2 = " ".join(comm2)
        os.system(cmd2)

        #blast output is specified by the call - here is what the columns are:
        #(query is the Genbank seq we are looking for a match in, subject is the reference VP1 alignment)
        ##First 7 columns:
        #10     qseqid  sseqid  pident  length      mismatch    gapopen 
        #csv    queryID subjID  %match  alignLen    #mismatch   #gap    

        ##Next 4 columns
        #qstart                     qend                    sstart                  send 
        #start of align in query    end of align in query   start of align in subj  end of align in subj

        ##Last 3 columns
        #evalue         bitscore    qcovs
        #Expect value   Bit score   Querty coverage per subject

##############################
# If VP1 - after BLAST, take only those that match
###############################
rule blast_sort:
    input:
        blast_result = rules.blast.output.blast_out,
        input_meta = "vp1/temp/downloaded_meta.tsv", #from rule download.seqs output
        input_seqs = "vp1/temp/downloaded_seqs.fasta" #from rule download.seqs output
    output:
        out_seqs = "vp1/temp/add_sequences.fasta" if (is_rerun("vp1")) else "vp1/temp/genbank_sequences.fasta",
        out_meta = "vp1/temp/add_meta.tsv" if (is_rerun("vp1")) else "vp1/temp/genbank_meta.tsv"
    params:
        matchLen = 300,
        dups = "vp1/temp/duplicates.tsv"
    shell:
        """
        python scripts/blast_sort.py --blast {input.blast_result} \
            --meta {input.input_meta} \
            --seqs {input.input_seqs} \
            --out_seqs {output.out_seqs} \
            --out_meta {output.out_meta} \
            --match_length {params.matchLen} \
            --dup_file {params.dups}
        """

##############################
# If genome, just change file name - no need to blast
###############################
rule rename_genome:
    input:
        sequences = "genome/temp/downloaded_seqs.fasta",
        meta = "genome/temp/downloaded_meta.tsv"
    output:
        sequences = "genome/temp/add_sequences.fasta" if (is_rerun("genome")) else "genome/temp/genbank_sequences.fasta",
        meta = "genome/temp/add_meta.tsv" if (is_rerun("genome")) else "genome/temp/genbank_meta.tsv"
    shell:
        """
        cp {input.sequences} {output.sequences}
        cp {input.meta} {output.meta}
        """



#####################################################################################################
#    Bring together old and new files & create database
#####################################################################################################

##############################
# Concat meta and sequences to existing Genbank
###############################
rule add_meta:
    input:
        metadata = [ancient("{length}/genbank/genbank_meta.tsv"), "{length}/temp/add_meta.tsv"]
    output:
        metadata = "{length}/temp/genbank_meta.tsv"
    run:
        import pandas as pd
        from augur.parse import fix_dates, forbidden_characters
        md = []
        for fname in input.metadata:
            tmp = pd.read_csv(fname, sep='\t' if fname.endswith('tsv') else ',')
            tmp_name = []
            for x in tmp.strain:
                f = x
                f = f.translate(forbidden_characters)
                tmp_name.append(f)
            tmp.strain = tmp_name
            md.append(tmp)
        all_meta = pd.concat(md)
        all_meta.to_csv(output.metadata, sep='\t', index=False)
#concat sequences
rule add_sequences:
    input:
        ancient("{length}/genbank/genbank_sequences.fasta"), "{length}/temp/add_sequences.fasta"
    output:
        "{length}/temp/genbank_sequences.fasta"
    shell:
        '''
        cat {input} > {output}
        '''

##############################
# If all has gone well - make a new Database!
###############################
rule make_database:
    input:
        gen_seqs = "{length}/temp/genbank_sequences.fasta",
        gen_meta = "{length}/temp/genbank_meta.tsv",
        download = "{length}/temp/current_insdc_download.tsv"
    output:
        gen_seqs = "{length}/genbank/genbank_sequences.fasta",
        gen_meta = "{length}/genbank/genbank_meta.tsv",
        download = "{length}/genbank/current_insdc_download.tsv",
    params:
        rerun = lambda wildcards: is_rerun(wildcards.length)
    #messages do not work with calling lambda functions
    #message:
        #"Genbank files updated with new sequences!" if (lambda wildcards: is_rerun(wildcards.length)) else "Genbank files stored. Reruns will only download new accession numbers."
    shell:
        '''
        cp {input.gen_seqs} {wildcards.length}/genbank
        cp {input.gen_meta} {wildcards.length}/genbank
        cp {input.download} {wildcards.length}/genbank
        mv {input.gen_meta} "{wildcards.length}/temp/genbank_meta_old.tsv"
        mv {input.gen_seqs} "{wildcards.length}/temp/genbank_sequences_old.fasta"

        mv {wildcards.length}/temp/downloaded_meta.tsv {wildcards.length}/temp/downloaded_meta_old.tsv 
        mv {wildcards.length}/temp/downloaded_seqs.fasta {wildcards.length}/temp/downloaded_seqs_old.fasta 

        #count number of genbank sequences (minus 1 for header)
        totalSeqs=$(($(cat {wildcards.length}/genbank/genbank_meta.tsv | wc -l)-1))

        # Figure out message to show user.
        rrun={params.rerun}
        if [ $rrun == "True" ]; then
            #count number of new sequences added (minus 1 for header)
            newSeq=$(($(cat {wildcards.length}/temp/add_meta.tsv | wc -l)-1))
            echo "Existing Genbank files updated with $newSeq new sequences!"
            echo "There is now a total of $totalSeqs Genbank sequences"
        else
            echo "$totalSeqs Genbank sequences stored in database. Reruns will only download new accession numbers."
        fi
        '''

rule make_database_genome:
    input:
        "genome/genbank/genbank_sequences.fasta",
        "genome/genbank/genbank_meta.tsv"

rule make_database_vp1:
    input:
        "vp1/genbank/genbank_sequences.fasta",
        "vp1/genbank/genbank_meta.tsv"


#####################################################################################################
#####################################################################################################
#    Bring together INSDC/Genbank and own samples
#####################################################################################################
#####################################################################################################


##############################
# Concatenate genbank data with Swedish and Manual
# We want this to run if changes to Swedish/Manual, even if not new Genbank!
###############################
rule concat_meta:
    input:
        metadata = [files.swedish_meta, files.manual_meta, files.enpen_meta_2021, #files.hist_meta,
            "{length}/genbank/genbank_meta.tsv"]
    output:
        metadata = "{length}/results/metadata.tsv"
    run:
        import pandas as pd
        from augur.parse import fix_dates, forbidden_characters
        md = []
        for fname in input.metadata:
            tmp = pd.read_csv(fname, sep='\t' if fname.endswith('tsv') else ',')
            tmp_name = []
            for x in tmp.strain:
                f = x
                f = f.translate(forbidden_characters)
                tmp_name.append(f)
            tmp.strain = tmp_name
            md.append(tmp)
        all_meta = pd.concat(md, sort=True)
        all_meta.to_csv(output.metadata, sep='\t', index=False)

#concatenate genbank seqs with Swedish & manual
rule concat_sequences:
    input:
        files.swedish_seqs, files.manual_seqs, files.enpen_seqs_2021, #files.hist_seqs,
            "{length}/genbank/genbank_sequences.fasta"
    output:
        "{length}/results/sequences.fasta"
    shell:
        '''
        cat {input} > {output}
        '''


##############################
# add age data! (and other metadata)
###############################
rule add_age:
    input:
        metadata = rules.concat_meta.output.metadata, #"{length}/results/metadata.tsv",
        ages = files.extra_meta,
    output:
        age_out = "{length}/results/metadata-raw-ages.tsv",
        meta = "{length}/results/metadata-ages.tsv"
    shell:
        """
        python scripts/parse_ages.py --ages-in {input.ages} --meta-in {input.metadata} \
            --meta-out-ages {output.age_out} --meta-out {output.meta}
        """

##############################
# now run usual augur analysis
###############################

def _use_300_include(wildcards):
    if wildcards.length == "vp1" and wildcards.min_len == "_300":
        return files.kept_strains_300
    else:
        return files.kept_strains

def _subsample_amount_per_group(wildcards):
    if wildcards.length == "vp1":
        if rules.filter.params.categories == "country year month": #doing by year and month
            return 20
        else: #doing by just year - multiply month amount by 12
            return 20*12
    else:
        if rules.filter.params.categories == "country year month": #doing by year and month
            return 200
        else: #doing by just year - multiply month amount by 12
            return 200*12

def _minimum_filter_length(wildcards):
    if wildcards.min_len: #if specify a length, use it
        return wildcards.min_len.replace("_","")
    else: #otherwise use the defaults
        if wildcards.length == "vp1":
            return "700"
        else:
            return "6000"

def _filter_length_message(wildcards):
    if wildcards.min_len: #if specify a length, use it
        minl = wildcards.min_len.replace("_","")
        return f"Filtering with minimum length argument of {minl}"
    else: #otherwise use the defaults
        if wildcards.length == "vp1":
            return "Filtering with default VP1 minimum length of 700"
        else:
            return "Filtering with default full-genome minimum length of 6000"

def _max_year_argument(wildcards):
    if wildcards.max_year: #if specified, use it
        maxyr = int(wildcards.max_year.replace("_","").replace("y",""))
        realmaxyr = maxyr + 1 #increment by 1 to include the whole year specified
        return f"--max-date {realmaxyr}"
    else: #otherwise, don't
        return ""

def _max_year_message(wildcards):
    if wildcards.max_year: #if specified, use it
        maxyr = int(wildcards.max_year.replace("_","").replace("y",""))
        realmaxyr = maxyr + 1 #increment by 1 to include the whole year specified
        return f"Filtering with a max year argument of {maxyr} (This is passed to augur as {realmaxyr})"
    else: #otherwise, don't
        return "Filtering without maximum year argument"

rule filter:
    message:
        """
        WARNING SUBSAMPLING BY GROUP BY FOR MONTHS IS CURRENTLY TURNED OFF!
        UNTIL CAN RE-IMPLEMENT MISSING DATE FILTERING!

        Subsample sequences:
            {params.filter_message}
            Using categories '{params.categories}'
            Subsampling by {params.sequences_per_category} per category
            Minimum date is {params.min_date}
            {params.maxyear_message}

        Parameters:
        --min-length {params.min_length}
        --group-by {params.categories}
        --include {input.include}
        --sequences-per-group {params.sequences_per_category}
        --min-date {params.min_date}
        {params.max_year}

        Reasons for filtering are output to {output.reasons}
        """
    input:
        sequences = rules.concat_sequences.output, #"{length}/results/sequences.fasta",
        metadata = rules.add_age.output.meta,
        exclude = files.dropped_strains,
        include = _use_300_include
        #include = files.kept_strains,
        #include_300 = files.kept_strains_300 #special include for 300bp run, until do better filtering
    output:
        sequences = "{length}/results/filtered{min_len}{max_year}.fasta",
        reasons = "{length}/results/filtering{min_len}{max_year}_reasons.tsv"
    params:
        filter_message = _filter_length_message,
        maxyear_message = _max_year_message,
        sequences_per_category = _subsample_amount_per_group,
        min_length = _minimum_filter_length,
        max_year = _max_year_argument,
        #categories = "country year month",  #off until can figure out how to include those without month
        categories = "country year", 
        min_date = 1990, #change to 1950 to include 1962 seq
    shell:
        """
        augur filter --sequences {input.sequences} --metadata {input.metadata} \
            --output {output.sequences} \
            --exclude {input.exclude} \
            --min-date {params.min_date} \
            --group-by {params.categories} \
            --sequences-per-group {params.sequences_per_category} \
            {params.max_year} \
            --include {input.include} \
            --min-length {params.min_length} \
            --output-log {output.reasons}
        """


rule align:
    input:
        sequences = rules.filter.output.sequences,
        reference = files.align_annot_ref
    output:
        alignment = "{length}/results/prealigned{min_len}{max_year}.fasta"
    shell:
        """
        augur align --sequences {input.sequences} --output {output.alignment} \
            --reference-sequence {input.reference} --remove-reference
        """

rule fix_align_codon:
    input:
        sequences = rules.align.output.alignment
    output:
        alignment = "{length}/results/aligned{min_len}{max_year}.fasta"
    shell:
        """
        Rscript scripts/fixAlignmentGaps.R {input.sequences} {output.alignment}
        """

rule sub_alignments:
    input:
        rules.fix_align_codon.output.alignment
    output:
        alignment = "{length}/results/aligned{gene}{min_len}{max_year}.fasta"
    run:
        real_gene = wildcards.gene.replace("-","",1)
        boundaries = {
            'vp4':(732,939),    'vp2':(939,1683),
            'vp3':(1683,2388),  'vp1':(2388,3315),
            '2A':(3315,3756),   '2B':(3756,4053),
            '2C':(4053,5043),   '3A':(5043,5310),
            '3B':(5310,5376),   '3C':(5376,5925),
            '3D':(5925,7296)}
        b = boundaries[real_gene]
        from Bio import SeqIO
        alignment = SeqIO.parse(input[0], "fasta")
        with open(output.alignment, "w") as oh:
            for record in alignment:
                sequence = record.seq.tomutable()
                # sequence = Bio.Seq.MutableSeq(record.seq) ##this has been depreciated, see https://github.com/biopython/biopython/blob/master/DEPRECATED.rst (search tomutable)
                gene_keep = sequence[b[0]:b[1]]
                sequence[0:len(sequence)] = len(sequence)*"N"
                sequence[b[0]:b[1]] = gene_keep
                record.seq = sequence
                SeqIO.write(record, oh, "fasta")


rule tree:
    input:
        alignment = rules.sub_alignments.output.alignment #"{length}/results/aligned{gene}{min_len}{max_year}.fasta" #[rules.align.output.alignment]
    output:
        tree = "{length}/results/raw_tree{gene}{min_len}{max_year}.nwk"
    shell:
        """
        augur tree --alignment {input.alignment} --output {output.tree}
        """

rule refine:
    input:
        tree = rules.tree.output.tree,
        alignment = rules.sub_alignments.output.alignment,
        metadata = rules.add_age.output.meta
    output:
        tree = "{length}/results/tree{gene}{min_len}{max_year}.nwk",
        node_data = "{length}/results/branch_lengths{gene}{min_len}{max_year}.json"
    params:
        clock_filter_iqd = 5
    shell:
        """
        augur refine --tree {input.tree} --alignment {input.alignment} \
            --metadata {input.metadata} \
            --output-tree {output.tree} --output-node-data {output.node_data} \
            --timetree --date-confidence --date-inference marginal --coalescent opt \
            --clock-filter-iqd {params.clock_filter_iqd}
        """
        # Have set --branch-length-inference to 'marginal' on recommendation of TreeTime warning when ran on auto
        # --branch-length-inference marginal \  #removed on 1 may 2024

rule ancestral:
    input:
        tree = rules.refine.output.tree,
        alignment = rules.sub_alignments.output.alignment,
    output:
        nt_data = "{length}/results/nt_muts{gene}{min_len}{max_year}.json"
    params:
        inference = "joint"
    shell:
        """
        augur ancestral --tree {input.tree} --alignment {input.alignment} \
            --output-node-data {output.nt_data} --inference {params.inference} \
            --keep-ambiguous
        """

rule translate:
    input:
        tree = rules.refine.output.tree,
        node_data = rules.ancestral.output.nt_data,
        reference = files.align_annot_ref
    output:
        aa_data = "{length}/results/aa_muts{gene}{min_len}{max_year}.json"
    params:
        gene_alignment = "{length}/results/aa_alignment{gene}{min_len}{max_year}_%GENE.fasta"
    shell:
        """
        augur translate --tree {input.tree} --ancestral-sequences {input.node_data} \
            --alignment-output {params.gene_alignment} \
            --output-node-data {output.aa_data} --reference-sequence {input.reference}
        """

rule clades:
    input:
        tree = rules.refine.output.tree,
        aa_muts = rules.translate.output.aa_data,
        nuc_muts = rules.ancestral.output.nt_data,
        clades = files.clades
    output:
        clade_data = "{length}/results/clades{gene}{min_len}{max_year}.json"
    shell:
        """
        augur clades --tree {input.tree} \
            --mutations {input.nuc_muts} {input.aa_muts} \
            --clades {input.clades} \
            --output-node-data {output.clade_data}
        """

rule traits:
    input:
        tree = rules.refine.output.tree,
        metadata = rules.add_age.output.meta
    output:
        node_data = "{length}/results/traits{gene}{min_len}{max_year}.json",
    params:
        columns = "country region"
    shell:
        """
        augur traits --tree {input.tree} --metadata {input.metadata} \
            --output-node-data {output.node_data} --confidence --columns {params.columns}
        """

def _get_max_date_for_frequencies(wildcards):
    # Allow to censor the N most recent days to minimize effects of
    # uneven recent sampling.
    recent_days_to_censor = 30
    offset = datetime.timedelta(days=recent_days_to_censor)

    return numeric_date(
        datetime.date.today() - offset
    )

def numeric_date(dt=None):
    """
    Convert datetime object to the numeric date.
    The numeric date format is YYYY.F, where F is the fraction of the year passed
    Parameters
    ----------
     dt:  datetime.datetime, None
        date of to be converted. if None, assume today
    """
    from calendar import isleap

    if dt is None:
        dt = datetime.datetime.now()

    days_in_year = 366 if isleap(dt.year) else 365
    try:
        res = dt.year + (dt.timetuple().tm_yday-0.5) / days_in_year
    except:
        res = None

    return res

rule tip_frequencies:
    message: "Estimating censored KDE frequencies for tips"
    input:
        tree = rules.refine.output.tree,
        metadata=rules.add_age.output.meta,
    output:
        tip_frequencies_json = "{length}/auspice/enterovirus_d68_{length}{gene}{min_len}{max_year}{date}_tip-frequencies.json"
    params:
        min_date = "1987-01-01",
        max_date = _get_max_date_for_frequencies,
        # number of months between pivots
        pivot_interval = 3,
        #can specify weeks or months
        pivot_interval_units = "months",
        # KDE bandwidths in proportion of a year to use per strain.
        # using 15 day bandwidth is 0.041
        # using 90 day bandwidth is 0.25 
        narrow_bandwidth = 0.16,
        proportion_wide = 0
    resources:
        # Memory use scales primarily with the size of the metadata file.
        mem_mb=12000
    shell:
        """
        augur frequencies \
            --method kde \
            --metadata {input.metadata} \
            --tree {input.tree} \
            --min-date {params.min_date} \
            --max-date {params.max_date} \
            --pivot-interval {params.pivot_interval} \
            --pivot-interval-units {params.pivot_interval_units} \
            --narrow-bandwidth {params.narrow_bandwidth} \
            --proportion-wide {params.proportion_wide} \
            --output {output.tip_frequencies_json}
        """

## This will only run for VP1 runs!!
rule epitopes:
    input:
        anc_seqs = rules.ancestral.output.nt_data, #"results/nt_muts_vp1.json",
        tree = rules.refine.output.tree #"results/tree_vp1.nwk"
    output:
        node_data = "{length}/results/epitopes{gene}{min_len}{max_year}.json"
    params:
        epitopes = {'BC':[89,91,94,96,97,102], 'DE':[139,140,141,142,143,144,145,146,147],
                    'CTERM':[279,282,283,287,289,296,298,300,303,304,305,307]},
        min_count = 7
    run:
        import json
        from collections import defaultdict
        from augur.translate import safe_translate
        from Bio import Phylo

        manyXList = ["XXXXXXXXXXXX", "KEXXXXXXXXXX", "KERANXXXXXXX", "KERXXXXXXXXX", "KERAXXXXXXXX"]
        with open(input.anc_seqs) as fh:
            anc = json.load(fh)["nodes"]

        T = Phylo.read(input.tree, 'newick')
        for node in T.find_clades(order='preorder'):
            for child in node:
                child.parent = node

        nodes = {}
        epitope_counts = {epi: defaultdict(int) for epi in params.epitopes}

        for node in T.find_clades(order='preorder'):
            n = node.name
            aa = safe_translate(anc[n]["sequence"])
            nodes[n] = {}
            for epi,pos in params.epitopes.items():
                nodes[n][epi] = "".join([aa[p] for p in pos])
                if epi == 'CTERM':
                    if nodes[n]['CTERM'] in manyXList:
                        nodes[n]['CTERM'] = "many x"
                    elif 'X' in nodes[n]['CTERM']:
                        nodes[n]['CTERM'] = nodes[node.parent.name]['CTERM']
                if not n.startswith('NODE_'):
                    epitope_counts[epi][nodes[n][epi]] += 1

        for node in nodes:
            for epi,seq in nodes[node].items():
                min_count2 = params.min_count if epi != "CTERM" else 6
                if epi == "CTERM" and seq in manyXList:
                    nodes[node][epi]='many X'
                elif epitope_counts[epi][seq]<min_count2:#params.min_count:
                    nodes[node][epi]='other'

        with open(output.node_data, 'w') as fh:
            json.dump({"epitopes": params.epitopes, "nodes":nodes}, fh)


#this rule will generate new sequence and metadata file with the subgenogroup (clade)
#that was assigned by 'clades' for each sequence - easier for analysis!
#The output files also ONLY CONTAIN sequences that are IN 'clades' - so only those
#in the final Nextstrain tree
rule add_subgeno:
    input:
        meta = rules.add_age.output.meta,
        clades = rules.clades.output.clade_data,
        seqs = rules.sub_alignments.output.alignment,
    output:
        new_meta = "{length}/results/metadata_subgenotype{gene}{min_len}{max_year}.tsv",
        new_seqs = "{length}/results/sequences_subgenotype{gene}{min_len}{max_year}.fasta"
    shell:
        """
        python scripts/add_subgeno.py --seqs-in {input.seqs} --meta-in {input.meta} --clades {input.clades} \
            --meta-out {output.new_meta} --seqs-out {output.new_seqs}
        """


#########################
#  EXPORT
#########################

# Adds the sequence length (corrected without - or N) to the subgeno metadata
#currently only called for VP1 runs (since this will have more variation)
rule add_seq_len:
    input:
        seqs = rules.sub_alignments.output.alignment,
        metadata = rules.add_subgeno.output.new_meta
    output:
        new_meta = "{length}/results/metadata_subgeno_seqlen{gene}{min_len}{max_year}.tsv"
    shell:
        """
        python scripts/add_seq_len.py --seqs-in {input.seqs} \
            --meta-in {input.metadata} \
            --meta-out {output.new_meta} \
        """

# Adds another column duplicating country to allow more distinct colours for zoomed figures
rule duplicate_country:
    input:
        metadata = rules.add_seq_len.output.new_meta
    params:
        column = "country",
        new_column = "focal_country"
    output:
        new_meta = "{length}/results/metadata_subgeno_seqlen_dupcol{gene}{min_len}{max_year}.tsv"
    shell:
        """
        python scripts/duplicate_column.py \
            --meta-in {input.metadata} \
            --meta-out {output.new_meta} \
            --column-to-dup {params.column} \
            --dup-column-name {params.new_column}
        """

#This really should be done in the first stage, but anything that needs to be added
#without causing a full re-run (only things that aren't inferred) can be added here
#This needs to be already in the final format accepted (no parsing)
rule add_extra_meta:
    input:
        metadata = rules.duplicate_country.output.new_meta, 
        new_data = "data/last_minute_data.tsv"
    output:
        meta = "{length}/results/metadata_subgeno_seqlen_dupcol_extramet{gene}{min_len}{max_year}.tsv"
    shell:
        """
        python scripts/add_last_minute_data.py --new-meta-in {input.new_data} --meta-in {input.metadata} \
            --meta-out {output.meta}
        """

rule export_vp1:
    input:
        tree = rules.refine.output.tree,
        metadata = rules.add_extra_meta.output.meta, #rules.add_age.output.meta, 
        branch_lengths = rules.refine.output.node_data,
        nt_muts = rules.ancestral.output.nt_data,
        aa_muts = rules.translate.output.aa_data,
        epis = rules.epitopes.output.node_data,
        clades = rules.clades.output.clade_data,
        colors = files.colors,
        lat_lon = files.lat_long,
        auspice_config = files.auspice_config,
        subgeno_meta = rules.add_subgeno.output.new_meta #this is just here to force the rule to run!
    output:
        #auspice_tree = rules.vp1.input.auspice_tree,
        #auspice_meta = rules.vp1.input.auspice_meta
        auspice = rules.vp1.input.auspice_out
    shell:
        """
        augur export v2 --tree {input.tree} --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.nt_muts} \
                {input.aa_muts} {input.clades} {input.epis} \
            --auspice-config {input.auspice_config} \
            --output {output.auspice} \
            --include-root-sequence \
            --colors {input.colors} \
            --minify-json \
            --lat-longs {input.lat_lon}
        """
        #--output-tree {output.auspice_tree} --output-meta {output.auspice_meta} \

rule export_genome:
    input:
        tree = rules.refine.output.tree,
        metadata = rules.add_age.output.meta, #"results/metadata-ages-src.tsv",
        branch_lengths = rules.refine.output.node_data,
        nt_muts = rules.ancestral.output.nt_data,
        aa_muts = rules.translate.output.aa_data,
        colors = files.colors,
        clades = rules.clades.output.clade_data,
        auspice_config = files.auspice_config, #"config/auspice_config_source.json"
        lat_lon = files.lat_long,
        subgeno_meta = rules.add_subgeno.output.new_meta #this is just here to force the rule to run!
    output:
        #auspice_treev1 = "auspice/enterovirus_d68_{seg}v1_tree.json",
        #auspice_metav1 = "auspice/enterovirus_d68_{seg}v1_meta.json"
        #auspice_tree = rules.genome.input.auspice_tree,
        #auspice_meta = rules.genome.input.auspice_meta
        auspice = rules.genome.input.auspice_out
    shell:
        """
        augur export v2 --tree {input.tree} --metadata {input.metadata} \
            --node-data {input.branch_lengths} {input.nt_muts} {input.aa_muts} {input.clades}\
            --colors {input.colors} --auspice-config {input.auspice_config} \
            --output {output.auspice} \
            --include-root-sequence \
            --minify-json \
            --lat-longs {input.lat_lon}
        """
        #--output-tree {output.auspice_tree} --output-meta {output.auspice_meta} \

def date():
    return datetime.date.today().strftime("%Y-%m-%d")

# This rule only works for default builds for VP1 and genome! Do not use if other runs have been done.
# This rules copies dated versions of the auspice files to the auspice folder to preserve them
rule archive_jsons:
    input:
        genome = rules.default_genome.input, #in order json, tip-freq, then root-seq
        vp1 = rules.default_vp1.input
    output:
        expand("auspice/enterovirus_d68_genome-{date}.json", date=date()),
        expand("auspice/enterovirus_d68_genome-{date}_tip-frequencies.json", date=date()),
        expand("auspice/enterovirus_d68_genome-{date}_root-sequence.json", date=date()),
        expand("auspice/enterovirus_d68_vp1-{date}.json", date=date()),
        expand("auspice/enterovirus_d68_vp1-{date}_tip-frequencies.json", date=date()),
        expand("auspice/enterovirus_d68_vp1-{date}_root-sequence.json", date=date())

    shell:
        """
        cp {input.genome[0]} {output[0]} && 
        cp {input.genome[1]} {output[1]} &&
        cp {input.genome[2]} {output[2]}
        cp {input.vp1[0]} {output[3]} &&
        cp {input.vp1[1]} {output[4]} &&
        cp {input.vp1[2]} {output[5]}
        """


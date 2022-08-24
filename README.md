# Add reference annotation gene IDs to a novel annotation
The script is desined to take the ID tag of the "gene" feature entry from a LiftOff reference annotation lift over gff3 file and add the gene ID as a note to a novel gene annotation from e.g. PASA

## Install
Easiest way to install is via miniconda. First clone the repository:

```
git clone https://github.com/Daniel-Ze/add_refgene_name.git
```

Change to the scripts directory:

```
cd add_refgene_name
```
You might need to make the scripts executeable:

```
chmod +x add_refgene_names.py && chmod +x add_refgene_names.sh
```

Install the necessary dependencies via conda:

```
conda install mamba (you thank me later ;))
mamba env create -f conda_env.yml
```

This will install the dependies specified in the .yml file and create a conda environment called "add_refgene_names".
This conda environment will be automaticaly activated and deactivated during the script run.

If you want to access this from everywhere consider putting the folder in your $PATH.

## What the script does
The script uses the "bedtools intersect" tool which generates intersections of annotation files.
Only the "gene" feature from the gff3 files will be compared. The intersected reference gene annotations will then be added to the new annotation file as "Note" to column 9.

A run produces the following commandline output:
```
(base) 💻 daniel:add_ref_gene_name $ add_refgene_names.sh -i EVM_PASA_update.gff3 -l pnv4_reg.liftoff.adj_name.gff3_polished 
/Users/daniel/miniconda3/etc/profile.d/conda.sh exists.
[info]  No conda environment name supplied. Defaulting to: add_refgene_names
[info]  Activating conda environment add_refgene_names:
[info]   - Found bedtools in your path.
[info]   - Found add_refgene_names.py in your add_vitvi_names.sh home.
[info]  EVM gff3:       EVM_PASA_update.gff3
[info]  LiftOff gff3:   pnv4_reg.liftoff.adj_name.gff3_polished
[info]  Working dir:    ./
[info]     71282 ./EVM_pasa_update.gene.gff3
[info]     67189 ./LiftOff.gene.gff3
[info]  Reading in the bedtools intersect ./EVM_pasa_update_LiftOff.intersect_adj.txt
[info]  Preparing dictonary of ./EVM_PASA_update.clean.gff3
[info]  Grouping one to many reference gene annotations.
[info]  Annoted genes with reference gene ID: 61678

   one_to_many  counts
0            1   56054
1            2    4948
2            3     517
3            4     112
4            5      28
5            6      13
6            7       4
7            9       1
8            8       1


[info]  Iterate over grouped intersect list and add them to the gff dictonary.
[info]  Write output to file EVM_PASA_update.cleanfinal.gff3
[info]  Success.
```

GFF3 file Before:
```
chr13_Chambourcin	EVM	gene	22154413	22158422	.	-	.	ID=evm.TU.chr13_Cham.1393;Name=EVMpred_chr13_Cham.1393
chr13_Chambourcin	EVM	mRNA	22154413	22158422	.	-	.	ID=evm.model.chr13_Cham.1393;Parent=evm.TU.chr13_Cham.1393;Name=EVMpred_chr13_Cham.1393
chr13_Chambourcin	EVM	exon	22158420	22158422	.	-	.	ID=evm.model.chr13_Cham.1393.exon1;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	CDS	22158420	22158422	.	-	0	ID=evm.model.chr13_Cham.1393.cds.1;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	exon	22158181	22158322	.	-	.	ID=evm.model.chr13_Cham.1393.exon2;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	CDS	22158181	22158322	.	-	0	ID=evm.model.chr13_Cham.1393.cds.2;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	exon	22154803	22154890	.	-	.	ID=evm.model.chr13_Cham.1393.exon3;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	CDS	22154803	22154890	.	-	2	ID=evm.model.chr13_Cham.1393.cds.3;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	exon	22154625	22154701	.	-	.	ID=evm.model.chr13_Cham.1393.exon4;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	CDS	22154625	22154701	.	-	1	ID=evm.model.chr13_Cham.1393.cds.4;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	exon	22154413	22154528	.	-	.	ID=evm.model.chr13_Cham.1393.exon5;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	CDS	22154413	22154528	.	-	2	ID=evm.model.chr13_Cham.1393.cds.5;Parent=evm.model.chr13_Cham.1393
chr13_Chambourcin	EVM	gene	18497327	18497740	.	-	.	ID=evm.TU.chr13_Cham.1185;Name=EVMpred_chr13_Cham.1185
chr13_Chambourcin	EVM	mRNA	18497327	18497740	.	-	.	ID=evm.model.chr13_Cham.1185;Parent=evm.TU.chr13_Cham.1185;Name=EVMpred_chr13_Cham.1185
chr13_Chambourcin	EVM	exon	18497327	18497740	.	-	.	ID=evm.model.chr13_Cham.1185.exon1;Parent=evm.model.chr13_Cham.1185
chr13_Chambourcin	EVM	CDS	18497327	18497740	.	-	0	ID=evm.model.chr13_Cham.1185.cds.1;Parent=evm.model.chr13_Cham.1185
```

GFF3 file After:
```
chr13_Chambourcin	EVM	gene	22154413	22158422	.	-	.		ID=evm.TU.chr13_Cham.1393;Name=EVMpred_chr13_Cham.1393;Note=cham_Vitvi06g01843;
chr13_Chambourcin	EVM	mRNA	22154413	22158422	.	-	.		ID=evm.model.chr13_Cham.1393;Parent=evm.TU.chr13_Cham.1393;Name=EVMpred_chr13_Cham.1393;
chr13_Chambourcin	EVM	exon	22158420	22158422	.	-	.		ID=evm.model.chr13_Cham.1393.exon1;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	CDS	22158420	22158422	.	-	0		ID=evm.model.chr13_Cham.1393.cds.1;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	exon	22158181	22158322	.	-	.		ID=evm.model.chr13_Cham.1393.exon2;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	CDS	22158181	22158322	.	-	0		ID=evm.model.chr13_Cham.1393.cds.2;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	exon	22154803	22154890	.	-	.		ID=evm.model.chr13_Cham.1393.exon3;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	CDS	22154803	22154890	.	-	2		ID=evm.model.chr13_Cham.1393.cds.3;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	exon	22154625	22154701	.	-	.		ID=evm.model.chr13_Cham.1393.exon4;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	CDS	22154625	22154701	.	-	1		ID=evm.model.chr13_Cham.1393.cds.4;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	exon	22154413	22154528	.	-	.		ID=evm.model.chr13_Cham.1393.exon5;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	CDS	22154413	22154528	.	-	2		ID=evm.model.chr13_Cham.1393.cds.5;Parent=evm.model.chr13_Cham.1393;
chr13_Chambourcin	EVM	gene	18497327	18497740	.	-	.		ID=evm.TU.chr13_Cham.1185;Name=EVMpred_chr13_Cham.1185;Note=cham_Vitvi03g00850;
chr13_Chambourcin	EVM	mRNA	18497327	18497740	.	-	.		ID=evm.model.chr13_Cham.1185;Parent=evm.TU.chr13_Cham.1185;Name=EVMpred_chr13_Cham.1185;
chr13_Chambourcin	EVM	exon	18497327	18497740	.	-	.		ID=evm.model.chr13_Cham.1185.exon1;Parent=evm.model.chr13_Cham.1185;
chr13_Chambourcin	EVM	CDS	18497327	18497740	.	-	0		ID=evm.model.chr13_Cham.1185.cds.1;Parent=evm.model.chr13_Cham.1185;
```

## Dependencies
Please refer to the conda_env.yml file for a detailed list of dependencies.

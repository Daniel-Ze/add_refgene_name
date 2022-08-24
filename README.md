# Add reference annotation gene IDs to your new annotation
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

Install the necessary dependencies via conda:

```
conda install mamba (you thank me later ;))
mamba env create -f conda_env.yml
```

This will install the dependies specified in the .yml file and create a conda environment called "add_refgene_names".
This conda environment will be automaticaly activated and deactivated during the script run.

## What the script does
The script uses the "bedtools intersect" tool which generates intersections of annotation files.
Only the "gene" feature from the gff3 files will be compared. The intersected reference gene annotations will then be added to the new annotation file as "Note" to column 9.

## Dependencies
Please refer to the conda_env.yml file for a detailed list of dependencies.

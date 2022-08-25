#!/bin/bash

# Check if miniconda is installed
miniconda=~/miniconda3/etc/profile.d/conda.sh

if [[ -f $miniconda ]]; then
	echo "$miniconda exists."
	source $miniconda
else
	echo -e "[error]\tCould not find miniconda install."
	exit 1
fi

# Get the scripts directory
ADD_VITVI_NAME_HOME="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/

# Get a variable for the python helper script
python_helper_script=${ADD_VITVI_NAME_HOME}"add_refgene_names.py"
plot_otm=${ADD_VITVI_NAME_HOME}"plot_1tomany.R"
# Help to be printed
helpFunction()
{
	echo ""
	echo -e "\tAdd LiftOff lift over gene annotation to EVM pasa updated gff3"
	echo ""
	echo "Usage: $(basename -- "$0") -i EVM_pasa_update.gff3 -l LiftOff.gff3 -b bedtools"
	echo -e "\t-i EVM pasa updated gff3 file"
	echo -e "\t-l LiftOff liftover gff3 file"
	echo -e "\t-b name of bedtools conda env (default: add_refgene_names)"
	echo ""
	exit 1 # Exit script after printing help				    
}

# Get options
while getopts "i:l:b:" opt
do
   case "$opt" in
      i ) parameterI="$OPTARG" ;;
      l ) parameterL="$OPTARG" ;;
      b ) parameterB="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Check if there is an alternative conda environment name
if [ -z "$parameterB" ]
then
    echo -e "[info]\tNo conda environment name supplied. Defaulting to: add_refgene_names"
    parameterB=add_refgene_names
    echo -e "[info]\tActivating conda environment $parameterB:"
else
    echo -e "[info]\tActivating conda environment $parameterB:"
fi

# Check if bedtools is in the conda environment
conda activate $parameterB
which bedtools > /dev/null
if [ $? -eq 0 ]; then
    echo -e "[info]\t - Found bedtools in your path."
else
    echo -e "[error]\tDind't find bedtools in your path."
    helpFunction
fi

# Check if the python helper script is there
python ${python_helper_script} > /dev/null
if [ $? -eq 0 ]; then
    echo -e "[info]\t - Found add_refgene_names.py in your add_vitvi_names.sh home."
else
    echo -e "[error]\tDind't find add_refgene_names.py in your add_vitvi_names.sh home."
    helpFunction
fi

if [ -z "$parameterI" ]
then
	echo -e "[error]\tPASA updated EVM gff3 file missing."
	helpFunction
fi

if [ -z "$parameterL" ]
then
	echo -e "[error]\tLiftOff lift over gff3 file missing."
	helpFunction
fi

WD=$(dirname $parameterI)/

echo -e "[info]\tEVM gff3:\t$parameterI"
echo -e "[info]\tLiftOff gff3:\t$parameterL"
echo -e "[info]\tWorking dir:\t$WD"

# Extracting only the gene feature tracks from the gff3 files
awk '{if($3 == "gene") {print $0}}' $parameterI > ${WD}EVM_pasa_update.gene.gff3 2>> ${WD}add_ref_gene_name.log
echo -e "[info]\t$(wc -l ${WD}EVM_pasa_update.gene.gff3)"

awk '{if($3 == "gene") {print $0}}' $parameterL > ${WD}LiftOff.gene.gff3 2>> ${WD}add_ref_gene_name.log
echo -e "[info]\t$(wc -l ${WD}LiftOff.gene.gff3)"

# Intersecting the gff3 files 
bedtools intersect -wb \
				   -a ${WD}EVM_pasa_update.gene.gff3 \
				   -b ${WD}LiftOff.gene.gff3 \
				   > ${WD}EVM_pasa_update_LiftOff.intersect.txt \
				   2>> ${WD}add_ref_gene_name.log

# Assuming that the ID tag is the first in column 9 of the second gff3 file
awk '{split($18, a, ";"); split(a[2], b, "="); print $9"\t"b[2]}' \
				   ${WD}EVM_pasa_update_LiftOff.intersect.txt \
				   > ${WD}EVM_pasa_update_LiftOff.intersect_adj.txt \
				   2>> ${WD}add_ref_gene_name.log

# Clean out the PASA gff3 file:
#  - remove all comments indicated by "#"
#  - remove all empty lines
parameterI_clean=${WD}$(basename $parameterI .gff3).clean.gff3
grep -v '^#' $parameterI | grep -v '^$' > $parameterI_clean

# Run the python helper script:
#  - group one to many refrence gene IDs 
#  - add reference gene IDs to the end of column 9 with the tag "Note"
parameterI_final=${WD}$(basename $parameterI .gff3).final.gff3
python $python_helper_script -i ${WD}EVM_pasa_update_LiftOff.intersect_adj.txt \
						 	 -g $parameterI_clean \
						 	 2>> ${WD}add_ref_gene_name.log

# Run Rscript to plot the results of the refrence gene ID groupings
Rscript $plot_otm -i ${WD}1tomany_overview.tsv 2>> ${WD}add_ref_gene_name.log > /dev/null

conda deactivate

# Houskeeping
mkdir ${WD}add_ref_gene_name_results

#  - remove
rm ${WD}EVM_pasa_update.gene.gff3
rm ${WD}LiftOff.gene.gff3
rm ${WD}EVM_pasa_update_LiftOff.intersect.txt
#  - move
mv ${WD}add_ref_gene_name.log ${WD}add_ref_gene_name_results
mv ${WD}EVM_pasa_update_LiftOff.intersect_adj.txt ${WD}add_ref_gene_name_results
mv $parameterI_clean ${WD}add_ref_gene_name_results
mv ${WD}$(basename $parameterI .gff3).cleanfinal.gff3 ${WD}add_ref_gene_name_results
mv ${WD}1tomany_overview.tsv ${WD}add_ref_gene_name_results
mv ${WD}1tomany_overview.tsv_plot.png ${WD}add_ref_gene_name_results
mv ${WD}gff3_intersect_1tomany_sort.tsv ${WD}add_ref_gene_name_results

# Goodbye
echo -e "[info]\tSuccess."

exit 0

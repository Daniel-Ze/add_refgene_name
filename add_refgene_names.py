#!/usr/bin/env python
import pandas as pd
import sys
import getopt
import os


def eprint(*args, **kwargs):
    '''
    Error message handling. Print to stderr.
    '''
    print(*args, file=sys.stderr, **kwargs)


def usage():
	print("concat_gene_names.py -i bedtools_intersect.txt (processed)")
	sys.exit()


def return_dict(line, line_index):
	'''
	Create a dictonary of the gff line passed to the function.

		line = gff file line
		line_index = gff file line index

	Column 9 will be split and also added to the dictornary.
	'''
	gff3_line_dict = {}
	col_9_dict = {}

    # Create an Index key
	gff3_line_dict["Index"] = line_index

    # Create the standard gff keys
	gff3_line_dict["Sequence"] = line[0]
	gff3_line_dict["Source"] = line[1]
	gff3_line_dict["Feature"] = line[2]
	gff3_line_dict["Start"] = line[3]
	gff3_line_dict["Stop"] = line[4]
	gff3_line_dict["Score"] = line[5]
	gff3_line_dict["Strand"] = line[6]
	gff3_line_dict["Phase"] = line[7]

    # Split columne 9 and create keys
	col_9 = line[8].split(";")
	f = 0
	for f in range(len(col_9)):
		if col_9[f] != '':
			col_9_dict[col_9[f].split("=")[0]] = col_9[f].split("=")[1]

    # add column 9 to line dictonary
	gff3_line_dict.update(col_9_dict)
	return gff3_line_dict


def input_data():
	# If command line input is of length 1 quit
	if len(sys.argv) == 1:
		usage()
	
	# Define the possible input flags
	try:
		opts, args = getopt.getopt(sys.argv[1:], "i:g:", ["input=", "gff="])
	except getopt.GetoptError as err:
		eprint(err)
		usage()

	# Try to get the input
	for o, a in opts:
		if o in ("-i", "--input"):
			input_file = a
		if o in ("-g", "--gff"):
			gff_input_file = a

	# If there is no input for -i and -l quit
	if input_file == "":
		eprint("[error]\tNo input. Nothing to do here.")
		sys.exit(2)
	if gff_input_file == "":
		eprint("[error]\tNo path to gff annotation.\n")
		sys.exit(3)
	
	# Get the file path of the input file -i if in directory of script use ./
	file_path = os.path.dirname(input_file)
	if file_path == "":
		file_path = "./"
	
	# Read in the formatted bedtools intersect file with pandas read_csv()
	print("[info]\tReading in the bedtools intersect {}".format(input_file))
	df = pd.read_csv(input_file, delimiter="\t", header=None)
	
	# Get the basename of the gff file and add the final output extension
	out_file = os.path.splitext(os.path.basename(gff_input_file))[0]+"final.gff3"

	# Read in the gff file
	with open(gff_input_file, 'r') as file:
		gff_file = [line.rstrip().split("\t") for line in file]
	
	# Create a dictonary of dictonaries from the read in gff3 file for faster parsing
	print("[info]\tPreparing dictonary of {}".format(gff_input_file))
	gff_dict = {}
	count = 0

	# Use the ID tag as key for the dictonaries in the dictonary
	# gff_dict = {gff_entry_ID : { Index : Line_index
	# 							   Sequence : Sequence_name,
	#                              Source : Annotation_source,
	#                              Frature : Feature_type,
	#							   Start : Start_pos,
	#							   Stop : Stop_pos,
	#							   Score : Assigned_score,
	#							   Strand : +_or_-,
	#							   Phase : CDS_phase,
	#							   ID : GFF_entry_ID,
	#							   Name : GFF_entry_Name,
	#                              Parent : GFF_entry_Parent,
	#							   ... (column 9 is completely expanded) }
	#			 ... (continue for every line in gff3 file)
	# 			}
	for f in gff_file:
		gff_dict[return_dict(f, count)["ID"]]=return_dict(f, count)
		count = count + 1

	return df, gff_dict, out_file, file_path


def main():
	# Get the input data
	df, gff_dict, out_file, file_path = input_data()

	# Open the output file
	output = open(out_file, 'w')

	# Group the one to many reference gene annotation
	print("[info]\tGrouping one to many reference gene annotations.")
	df[3] = df.groupby([0])[1].transform(lambda x: ','.join(x))

	df = df.drop(columns=1)
	df = df.drop_duplicates()

	df[["Type","ID"]] = df[0].str.split(';', expand=True)[0].str.split('=', expand=True)

	df = df.drop(columns="Type")
	df[4] = df[3].str.count(",")
	df[4] = df[4] + 1
	df.sort_values(by=[4], ascending=False)
	df.columns = ["Col_9", "ref_gene_ID", "anno_gene_ID", "count_ref_gene_ID"]

	df.to_csv(file_path+"/gff3_intersect_1tomany_sort.tsv", sep='\t',index=False, columns=["anno_gene_ID", "ref_gene_ID", "count_ref_gene_ID"])

	one_to_many = pd.DataFrame(data=df["count_ref_gene_ID"].value_counts())
	one_to_many = one_to_many.reset_index()
	one_to_many.columns = ["one_to_many", "counts"]
	
	one_to_many.to_csv(file_path+"/1tomany_overview.tsv", sep="\t", index=False)
	
	print("[info]\tAnnoted genes with reference gene ID: {}\n".format(len(df.index)))
	print(one_to_many)
	print("\n")

	# Add the reference annotation gene IDs to the last column of the new 
	# annotation with the flag Note; Adjust this if you want another flag 
	# column 9 for that
	print("[info]\tIterate over grouped intersect list and add them to the gff dictonary.")
	for index, row in df.iterrows():
		gff_dict[row["anno_gene_ID"]]["Note"]=row["ref_gene_ID"]
	
	# Format the dictonary content to propper gff3 format and write to file
	# This works only if the 
	print("[info]\tWrite output to file {}".format(out_file))
	for f_id, f_info in gff_dict.items():
		col_9 = ""
		col_18 = ""
		for key in f_info:
			if key == "Index":
				pass
			if key == "Sequence":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Source":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Feature":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Start":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Stop":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Score":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Strand":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "Phase":
				col_18 = col_18 + f_info[key]+"\t"
			if key == "ID" or key == "Name" or key == "Parent" or key == "Note":
				col_9 = col_9 + str(key+"="+f_info[key]+";")
		
		output.write(col_18+"\t"+col_9+"\n")
	output.close()


if __name__ == '__main__':
	main()

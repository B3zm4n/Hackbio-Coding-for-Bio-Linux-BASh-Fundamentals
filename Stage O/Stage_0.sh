# Project 1: BASH Basic
# pring your name
echo 'Bezaleel Akinbami'

# create a folder titled your name
mkdir bezaleel_akinbami/

# Create another new directory titled biocomputing and change to that directory with one line of command
mkdir biocomputing && cd biocomputing

# Download these 3 files:
wget https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.fna && https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.gbk
wget https://raw.githubusercontent.com/josoga2/dataset-repos/main/wildtype.gbk

# Move the .fna file to the folder titled your name
mv *.fna bezaleel_akinbami

# Delete the duplicate gbk file
rm *.gbk.1

# Confirm if the .fna file is mutant or wild type (tatatata vs tata) and If mutant, print all matching lines into a new file
fna_file='wildtype.fna'
mutant_pattern="tatatata"
wild_type_pattern="tata"
output_file="${fna_file%.*}_mutant_lines.txt"

# Search for the mutant pattern
grep_mutant_result=$(grep -n "$mutant_pattern" "$fna_file")

# 7. Confirm if the .fna file is mutant or wild type
if [ -n "$grep_mutant_result" ]; then
    echo "The file '$fna_file' is mutant."
# 8. If mutant, print all matching lines into a new file.
    echo "$grep_mutant_result" > "$output_file"
    echo "Matching lines saved to '$output_file'."
else
# Search for the wild type pattern if no mutant is found
    grep_wild_type_result=$(grep -q "$wild_type_pattern" "$fna_file" && echo "found")
        if [ -n "$grep_wild_type_result" ]; then
            echo "The file '$fna_file' is wild type."
        else
            echo "The file '$fna_file' is neither mutant nor wild type."
        fi
fi
# Count number of lines (excluding header) in the .gbk file
sed '1,/^ORIGIN/d' your_file.gbk | wc -l

# Print the sequence length of the .gbk file. (Use the LOCUS tag in the first line)
grep -m 1 '^LOCUS' your_file.gbk | awk '{print $3}'

# Print the source organism of the .gbk file. (Use the SOURCE tag in the first line)
grep -m 1 '^SOURCE' your_file.gbk | awk '{$1=""; print $0}' | sed 's/^ //g'

# List all the gene names of the .gbk file. Hint {grep '/gene='}
grep -o '/gene="[^"]*"' your_file.gbk | sed 's/\/gene="//g;s/"//g'

# Clear your terminal space and print all commands used today
clear
history

# List the files in the two folders
ls bezaleel_akinbami
ls biocomputing 




# Project 2: Conda
# Activate your base conda environment
conda activate base

# Create a conda environment named funtools
conda create -n funtools

# Activate the funtools environment
conda activate funtools

# Install Figlet using conda or apt-get
conda install figlet

# Run figlet <your name>
figlet bezaleel

# Install bwa, blast, samtools, bedtools, spades.py, bcftools,fastp, multiqc through the bioconda channel
conda install bwa blast samtools bedtools spades.py bcftools fastp multiqc

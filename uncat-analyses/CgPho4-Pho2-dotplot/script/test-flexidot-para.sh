# Title: Test parameter combinations for flexidot
# Reason: 
#     flexidot doesn't have a scoring matrix for amino acid sequences. rather it only scores match/no-match, and uses two hard cutoffs, i.e. wordsize (-k) and mismatch (-S) to decide where to draw a dot. this script is designed to systematically test a range of parameter combinations.
# Author: Bin He
# Date: 2019-11-28
# Usage: sh ./test-flexidot-para.sh INPUT-FASTA kmin kmax Smin Smax
#   e.g. sh ./test-flexidot-para.sh ../data/ScPho4-CgPho4.faa 8 15 

# collect command variables
name=$1
base=$(basename -s .faa $name)
kmin=$2
kmax=$3
Smin=$4
Smax=$5

if [ ! -d "../output/$base" ]; then
	mkdir ../output/$base # create the output directory if it doesn't already exist
fi

# perform dotplot
for i in $(seq $kmin $kmax); do
	for j in $(seq $Smin $Smax); do
		python flexidot_v1.06.py -i $name -p 2 -c N -t N -k $i -S $j -g ../data/ScPho4_annot.gff -g ../data/CgPho4_annot.gff -g ../data/ScPho2_annot.gff -G ../data/flexidot-gff.config -o ../output/${base}/${base}
	done;
done;

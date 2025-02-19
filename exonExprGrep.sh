#!/bin/bash
##This is the step for unzip the files
GENE1="uc001pgs.2|uc001pgt.2|uc001pgu.2|uc001pgv.2|uc001pgw.2|uc010ruo.1|uc010rup.1"
GENE2="MLL"

# GENE3="uc003cwo.2|uc003cwp.2|uc003cwq.2|uc003cwr.2" #USP4
# GENE4="C3orf62"

# GENE5="DPH2L"
# GENE6="CIC" #in AS182_1

# GENE7="PAFAH1B3"
# GENE8="KNDC1"

# GENE9="HTR4" #PEC13
# GENE10="ST3GAL1" #PEC13


# GENE11="CREM" #in ME8_2
# GENE12="EWSR1"

# GENE13="NRBP1" #in ME330
# GENE14="MYOM2"

# GENE15="LTK" #inMYO7
# GENE16="MYH10|MYH10"

# GENE17="ARID1A|ARID1A" #SA69
# GENE18="PRKD1"

# GENE19="DVL2" # PEC25_2
# GENE20="TFE3|DKFZp761J1810"


echo $GENE1; echo $GENE2; echo $GENE3; echo $GENE4; echo $GENE5
# echo $GENE6; echo $GENE7; echo $GENE8; echo $GENE9; echo $GENE10
# echo $GENE11; echo $GENE12; echo $GENE13; echo $GENE14; echo $GENE15
# echo $GENE16; echo $GENE17; echo $GENE18; echo $GENE19; echo $GENE20

for i in $(ls -d *)
do
	cd $i
    CURRENT=$(pwd); echo $CURRENT
    cd "$i"_MRFfile
    zgrep -P "\t$(echo $GENE1)\t" "$i"_exonGeneExpr_Info.txt.gz |cut -f 3,5 |sort -k1 -n >> ~/GeneExpr/"$i"_"YAP1"
    zgrep -P "\t$(echo $GENE2)\t" "$i"_exonGeneExpr_Info.txt.gz |cut -f 3,5 |sort -k1 -n >> ~/GeneExpr/"$i"_"KMT2A"
   #grep -P "\t$(echo $GENE3)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n >> ~/GeneExpr/"$i"_"USP4"
   #grep -P "\t$(echo $GENE4)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE4"
    #grep -P "\t$(echo $GENE5)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE5"
# #echo $GENE6;
#     grep -P "\t$(echo $GENE6)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE6"
# #echo $GENE7;
#     grep -P "\t$(echo $GENE7)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE7"
# #echo $GENE8;
#     grep -P "\t$(echo $GENE8)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE8"
# #echo $GENE9;
#     grep -P "\t$(echo $GENE9)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE9"
#     grep -P "\t$(echo $GENE10)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE10"
#     grep -P "\t$(echo $GENE11)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE11"
#     grep -P "\t$(echo $GENE12)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE12"
#     grep -P "\t$(echo $GENE13)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE13"
#     grep -P "\t$(echo $GENE14)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE14"
#     grep -P "\t$(echo $GENE15)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE15"
#     grep -P "\t$(echo $GENE16)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE16"
#     grep -P "\t$(echo $GENE17)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE17"
#     grep -P "\t$(echo $GENE18)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE18"
#     grep -P "\t$(echo $GENE19)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE19"
#     grep -P "\t$(echo $GENE20)\t" "$i"_exonGeneExpr_Info.txt |cut -f 3,5 |sort -k1 -n>> ~/GeneExpr/"$i"_"$GENE20"
	cd ..
    cd ..
done
wait

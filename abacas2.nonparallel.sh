#!/bin/bash
# Copyright (c) 2011-2015 Genome Research Ltd.
# Author: Thomas D. Otto <tdo@sanger.ac.uk>
#
# This file is part of ABACAS2.
#
# ABACAS2 is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

reference=$1
contig=$2
ABA_MIN_LENGTH=$3
ABA_MIN_IDENTITY=$4
doBlast=$5
MemBig=$6

if [ -z "$contig" ] ; then
	echo "

                 *** Abacas II. ***       For any distrubation with this program, please don't blame Sammy!

usage:
abacas2.nonparallel.sh <reference> <Contig to order> optinal: <min aligment length> <Identity cutoff> <doblast: 0/1>

reference:           Fasta (or multi-fasta) against which the contigs should be ordered
contig:              Contigs or query that should be ordered
Min aligment length: Alignment length significance threshold (default 200)
Identity cutoff:     Threshold for identity to place contigs (default 95)
Do Blast:            Does a BLAST run for ACT inspection (default 0)

Further parameters:
ABA_CHECK_OVERLAP=1; export ABA_CHECK_OVERLAP # this will try to overlap contigs
ABA_splitContigs=1; export ABA_splitContigs # this parameter will split contigs. This is good to split the orign, and to find rearrangement. A split contigs has the suffix _i (i the part)
ABA_WORD_SIZE  # sets the word size. This is critical for speed issues in nucmer. default is 20
"

exit;
fi

if [ -z "$ABA_MIN_LENGTH" ] ; then
	ABA_MIN_LENGTH=200;
fi
if [ -z "$ABA_MIN_IDENTITY" ] ; then
	ABA_MIN_IDENTITY=95;
fi
if [ -z "$ABA_CHECK_OVERLAP" ] ; then
        ABA_CHECK_OVERLAP=0;
	export ABA_CHECK_OVERLAP
fi

if [ -z "$MemBig" ]; then
   MemBig=6000
fi

if [ "$ABA_MIN_IDENTITY" -gt "99" ] ; then
	echo "Your identity might be too high $ABA_MIN_IDENTITY > 99 "
	exit ;
fi
tmp=$$
sed 's/|/_/g' $reference > Ref.$tmp
reference=Ref.$tmp
ln -s $contig Contigs.$tmp
contig=Contigs.$tmp

export ABA_MIN_LENGTH ABA_MIN_IDENTITY contig reference

tmp=$$

abacas2.runComparison.sh $reference $contig

for x in `grep '>' $reference | perl -nle '/>(\S+)/;print $1' ` ; do
	abacas2.doTilingGraph.pl $x.coords  $contig Res
done

abacas2.bin.sh $contig Res.abacasBin.fna && grep -v '>'  Res.abacasBin.fna | awk 'BEGIN {print ">Bin.union"} {print}' > Res.abacasBin.oneSeq.fna_ && cat Res*fna > Genome.abacas.fasta && bam.correctLineLength.sh Genome.abacas.fasta  &> /dev/null && mv  Res.abacasBin.fna_ Res.abacasBin.fna

ref=$reference
pre=Res

if [ -z "$pre" ] ; then
   echo "usage <reference> Res"

fi

tmp=$$

ln -s $ref REF.$tmp

mkdir Reference
cd Reference
SeperateSequences.pl  ../REF.$tmp
cd ..
mkdir comp

count=0
for nameRes in `grep '>' $ref | perl -nle 's/\|/_/g;/>(\S+)/; print $1'` ; do
	let count++;
	if [ $count -gt 200 ] ; then
		echo "too many contigs to bsub!\n";
		exit
	fi
	formatdb -p F -i Reference/$nameRes;

	megablast -F T -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast

#if [ -z "$Other" ] ; then
#echo  " bsub -o blast.$nameRes.o -e blast.$nameRes.e -R \"select[type==X86_64 && mem > 6000] rusage[mem=6000]\" -M6000000  blastall -p blastn -F F -W 15 -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast"
#megablast -F T -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast
 #else

 #blastall -p blastn  $Other -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast

done




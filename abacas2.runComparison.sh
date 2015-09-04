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


ref=$1
contigs=$2
splitit=$3

minLength=100
minIdentity=90
wordSize=20
###
ABA_CHECK_OVERLAP=0; export ABA_CHECK_OVERLAP


if [ -z "$contigs" ] ; then
   echo "Please use: $0 <reference file> <contigs>";
   exit 1
fi

if [ ! -z "$ABA_MIN_LENGTH" ] ; then
   echo "Modified minLength for hit... $ABA_MIN_LENGTH";
   minLength=$ABA_MIN_LENGTH
fi

if [ ! -z "$ABA_MIN_IDENTITY" ] ; then
   echo "Modified minIdentity for hit... $ABA_MIN_IDENTITY";
   minIdentity=$ABA_MIN_IDENTITY
fi

if [ ! -z "$ABA_WORD_SIZE" ] ; then
   echo "Modified word size for hit... $ABA_WORD_SIZE";
   wordSize=$ABA_WORD_SIZE
fi

echo "The contigs of file $contig will be compared on $ref using achor hits of at least $minLength bp and $minIdentity % of identity";

if [ "$ABA_COMPARISON" = "promer" ] ; then
	echo "Running promer... promer -l $wordSize  -p $contigs $ref $contigs"
	promer -l $wordSize  -p $contigs $ref $contigs
else
	echo "nucmer -l $wordSize -p $contigs $ref $contigs"
	nucmer  -l $wordSize -p $contigs $ref $contigs
fi

echo "delta-filter -i $minIdentity -l $minLength -r $contigs.delta > $contigs.delta.filter"
delta-filter -i $minIdentity -l $minLength -o 10 -r $contigs.delta > $contigs.delta.filter
echo "show-coords -dTlqo -I $minIdentity -L $minLength  $contigs.delta.filter > $contigs.coords"
show-coords -dTlqo -I $minIdentity -L $minLength  $contigs.delta.filter > $contigs.coords


if [ "$ABA_splitContigs" == "1" ] ; then
   abacas2.sortOrsplitContigs.pl $contigs.coords $contigs 1

   contigsOld=$contigs
   contigs=$contigs".splitted"

   echo "I am going to split the contigs!\n";

   # redo the comparison

   if [ "$ABA_COMPARISON" = "promer" ] ; then
	   promer -p $contigs $ref $contigs
   else
	   nucmer  -l $wordSize  -p $contigs $ref $contigs
   fi
   delta-filter  -i $minIdentity -l $minLength -q $contigs.delta > $contigs.delta.filter
   show-coords -dTlqo  -I $minIdentity -L $minLength  $contigs.delta.filter > $contigs.coords

   # also do the ordering
   abacas2.sortOrsplitContigs.pl $contigs.coords $contigs 0 $ABA_COMPARISON
fi
if [ "$splitit" == "2" ] ; then
   abacas2.sortOrsplitContigs.pl $contigs.coords $contigs 1

fi


### the coord file must be ordered
abacas2.sortOrsplitContigs.pl $contigs.coords $contigs 0 $ABA_COMPARISON

### split the file for each chromosome
if [ "$ABA_COMPARISON" = "promer" ] ; then
	awk '{ print > $14".coords" }' $contigs.coords.ordered
else
	awk '{ print > $12".coords" }' $contigs.coords.ordered
fi

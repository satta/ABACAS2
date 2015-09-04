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
pre=$2
Other=$3

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

if [ -z "$Other" ] ; then
echo  " blastall -p blastn -F F -W 15 -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast"
   blastall -p blastn -W 25 -F T -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast
 else

echo  " blastall -p blastn  $Other -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast"
   blastall -p blastn  $Other -m 8 -e 1e-20 -d Reference/$nameRes -i $pre.$nameRes.fna -o comp/comp.$nameRes.blast
fi
done

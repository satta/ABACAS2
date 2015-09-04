# ABACAS2

ABACAS2 is a tool to order and orientate a set of input sequences along a reference sequence, based on high confidence local alignments as generated by MUMmer.

### Software dependencies

 - Perl 5
 - MUMmer version 3
 - NCBI BLAST (needs `blastall`)

### Installation
To run ABACAS2, just clone this repo into a directory of your choosing and make sure all dependencies are installed and available in your `$PATH`. Also, please make sure that the ABACAS2 installation directory is both in `$PATH`  and `$PERL5LIB`:
```bash
export PERL5LIB=<installation directory>:$PERL5LIB
export PATH=<installation directory>:$PATH
```
(example for bash)

### Running ABACAS2

Usage:
```
abacas2.nonparallel.sh <reference> <Contig to order> <min aligment length> <Identity cutoff> <doblast: 0/1>

reference:           Fasta (or multi-fasta) against which the 
                     contigs should be ordered
contig:              Contigs or query that should be ordered
Min aligment length: Alignment length significance threshold (default 200)
Identity cutoff:     Threshold for identity to place contigs (default 95)
Do Blast:            Does a BLAST run for ACT inspection (default 0)
```
The options for `min alignment length`, `identity cutoff` and `doblast` are optional.

###Results
Results are all files beginning with `Res.*` -- this includes GFF files for contig placements, coverage plots to be loaded into Artemis, FASTA sequences for each contiguated pseudochromosome and the `Res.abacasBin.fna` file for all input sequences that could not be mapped to the reference (the 'bin').

### License
ABACAS2 is released under GPL3.


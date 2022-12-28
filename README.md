# subread-pipeline

The nextflow pipeline consists of four steps.

## 1. subread-index
First process will create an index from a reference genome file 

## 2. subread-align
Alignment process will use the index file created from the reference and align fastq samples and create binary sam files for every sample

## 3. samtools-sort
Samtools will be used to created sorted bam files from sam files

## 4. featureCounts
Quantification of the samples will be calculated and annotated count and FPKM matrix files will be created
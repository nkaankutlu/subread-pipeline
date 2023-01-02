#! /usr/bin/env nextflow

nextflow.enable.dsl = 1

/*
 * pipeline input parameters
 */
params.outdir = "$PWD/results"
params.indexDir = "$PWD/index"
params.refGenome = "$PWD/GENCODE/GRCh38.primary_assembly.genome.fa"
params.forRead = "$PWD/data/ER1_1.fastq"
params.revRead = "$PWD/data/ER1_2.fastq"
params.gtfFile = "$PWD/GENCODE/gencode.v39.primary_assembly.annotation.gtf"
params.threads = 4

/*Building index file for alignment using hisat2 */
process buildindex {
    publishDir params.indexDir, mode: 'copy'
    echo true
    input:
    path refGenome from params.refGenome

    output:
    path 'GRCh38*' into index_ch

    """
    echo "Building Indices"
    subread-buildindex ${refGenome} -o GRCh38
    """
}
/*Aligning the reads to the index database */
process align {
    publishDir params.outdir, mode: 'copy'
    echo true
    input:
    path forRead from params.forRead
    path revRead from params.revRead
    file indices from index_ch.collect()

    output:
    path "ER1.sam" into sam_ch

    script:
    index_base = indices[0].toString() - ~/.\d.GRCh38/

    """
    echo "Aligning Reads"
   subread-align -T $params.threads -t 0 -i ${index_base} -r ${forRead} -R ${revRead} -o ER1.bam
    """

}
/*creating a binary compression of Sam file */
process create_bam {
    publishDir params.outdir, mode: 'copy'
    echo true
    input:
    path samFile from sam_ch
    output:
    path "ER1_sorted.bam" into bam_ch

    """
    echo "Creating bam file"
    samtools view -bh ${samFile} | samtools sort - -o ER1_sorted.bam; samtools index ER1.bam
    """

}
/*Quantification from Bam files */
process feature counts {
    publishDir params.outdir, mode: 'copy'
    echo true
    input:
    path bamFile from bam_ch
    path gtfFile from params.gtfFile
    output:
    path "counts.tsv" into tsv_ch
    
    """
    echo "Creating count matrix"
    featureCounts -p --countReadPairs -t exon -g gene_id -a ${gtfFile} -0 counts.tsv ${bamFile}
    """
}



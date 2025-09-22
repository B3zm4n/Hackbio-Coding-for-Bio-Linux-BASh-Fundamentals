#!/bin/bash

# -------------------------------
# 1. Data Acquisition
# -------------------------------
# Make directories
mkdir -p raw_data qc_results trimmed alignments variants reports

# Example SRR IDs (replace with your own)
SRR_IDS=("SRR32764071" "SRR32764072" "SRR7135493" "SRR7135521")

# Download FASTQ from NCBI SRA
for ID in "${SRR_IDS[@]}"; do
    fasterq-dump $ID -O raw_data --split-files
done

# -------------------------------
# 2. Quality Control
# -------------------------------
# Run FastQC
fastqc raw_data/*.fastq -o qc_results

# Aggregate QC report
multiqc qc_results -o qc_results

# -------------------------------
# 3. Trimming (adapter removal & quality filtering)
# -------------------------------
for fq in raw_data/*_1.fastq; do
    base=$(basename $fq _1.fastq)
    fastp -i raw_data/${base}_1.fastq \
          -I raw_data/${base}_2.fastq \
          -o trimmed/${base}_1.trimmed.fastq \
          -O trimmed/${base}_2.trimmed.fastq \
          --html trimmed/${base}_fastp.html \
          --json trimmed/${base}_fastp.json
done

# -------------------------------
# 4. Alignment
# -------------------------------
# Reference genome (FASTA file required)
REF="reference_genome.fa"
bwa index $REF

for fq in trimmed/*_1.trimmed.fastq; do
    base=$(basename $fq _1.trimmed.fastq)
    bwa mem -t 8 $REF trimmed/${base}_1.trimmed.fastq trimmed/${base}_2.trimmed.fastq \
        | samtools view -bS - \
        | samtools sort -o alignments/${base}.sorted.bam
    samtools index alignments/${base}.sorted.bam
done

# -------------------------------
# 5. Variant Calling
# -------------------------------
# Option 1: GATK HaplotypeCaller (GVCF mode)
for bam in alignments/*.bam; do
    base=$(basename $bam .sorted.bam)
    gatk HaplotypeCaller \
        -R $REF \
        -I $bam \
        -O variants/${base}.g.vcf.gz \
        -ERC GVCF
done

# Joint genotyping
gatk CombineGVCFs -R $REF -V variants/*.g.vcf.gz -O variants/combined.g.vcf.gz
gatk GenotypeGVCFs -R $REF -V variants/combined.g.vcf.gz -O variants/raw_variants.vcf.gz

# Variant filtering
gatk VariantFiltration \
   -R $REF \
   -V variants/raw_variants.vcf.gz \
   -O variants/filtered_variants.vcf.gz \
   --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
   --filter-name "FAIL"

# -------------------------------
# 6. Variant QC
# -------------------------------
bcftools stats variants/filtered_variants.vcf.gz > variants/variant_stats.txt

# -------------------------------
# 7. Species ID / Differentiation
# -------------------------------
# (Placeholder — could use PCA or phylogenetic clustering of SNPs)
# e.g. using plink
plink --vcf variants/filtered_variants.vcf.gz --make-bed --out variants/plink_data
plink --bfile variants/plink_data --pca --out variants/pca

# -------------------------------
# 8. Trait Association & Annotation
# -------------------------------
# Annotate variants (requires snpEff or VEP)
snpEff ann reference_db variants/filtered_variants.vcf.gz > variants/annotated.vcf

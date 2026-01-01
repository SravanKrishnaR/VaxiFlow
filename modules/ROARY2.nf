process ROARY_2 {
    label 'light'

    publishDir "${params.outdir}/ROARY", mode: 'copy'

    input:
    path summary_statistics
    path gene_presence_absence
    path pan_genome_reference

    output:
    path("protein_sequences.fasta"), emit: protein_sequences

    script:
    """
    awk '/^Core genes/ {core=\$NF} END {print core}' ${summary_statistics} | \
    xargs -I{} awk -F',' -v max={} 'NR > 1 && NR <= (max + 1) {print \$1}' ${gene_presence_absence} | \
    sed 's/"//g' | \
    awk 'NR==FNR {genes[\$1]; next} /^>/ {keep=0; split(\$0,a," "); if (a[2] in genes) keep=1} keep' - ${pan_genome_reference} > matched.fa

    transeq -sequence matched.fa -outseq tmp_proteins.fasta -trim
    awk '/^>/ {print; next} {gsub("\\\\*",""); gsub("X",""); print}' tmp_proteins.fasta > protein_sequences.fasta
    """
}

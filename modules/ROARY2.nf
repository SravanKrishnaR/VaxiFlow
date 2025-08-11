process ROARY_2 {
    label 'light'

    publishDir "Results/ROARY", mode: 'copy'

    input:
    path summary_statistics
    path gene_presence_absence
    path pan_genome_reference

    output:
    path("protein_sequences.fasta"), emit: protein_sequences

    script:
    """
    awk '/^Core genes/ {core=\$NF} END {print core}' summary_statistics.txt | \
    xargs -I{} awk -F',' -v max={} 'NR > 1 && NR <= (max + 1) {print \$1}' gene_presence_absence.csv| \
    sed 's/"//g' | \
    awk 'NR==FNR {genes[\$1]; next} /^>/ {keep=0; split(\$0, a, " "); if (a[2] in genes) keep=1} keep' - pan_genome_reference.fa > matched.fa
    transeq -sequence matched.fa -outseq protein_sequences.fasta
    """

}

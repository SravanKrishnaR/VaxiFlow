process PHOBIUS {
    container 'phobius:latest'

    publishDir "${params.outdir}/PHOBIUS/${name}", mode: "copy"

    errorStrategy {
    task.exitStatus == 100 ? 'ignore' : 'terminate'
}

    input:
    tuple val(name), path(non_toxins), path(toxinpred_csv)

    output:
    tuple val(name), path("phobius_output.txt"), emit: phobius_output
    tuple val(name), path("PHOBIUS.ids"), emit: PHOBIUS_ids
    tuple val(name), path("PHOBIUS.fasta"), emit: PHOBIUS_fasta
    tuple val(name), path("phobius.csv"), emit: phobius_csv

    stub:
    """
    mkdir -p biolib_results
    echo '##gff-version 3' > biolib_results/TMRs.gff3
    """

    script:
    """
    if [[ '${params.mode}' == 'filtered' && ! -s "${non_toxins}" ]]; then
    echo "DEEPTHMMM: Input file non_toxins is empty."
    exit 100
fi

    #RUN the phobius command
    perl /app/phobius.pl ${non_toxins} > phobius_output.txt

    #Get the ids from phobius_output.txt
    awk '
    \$1 == "ID" {
        id = \$2
        gsub(/^sp\\|[^|]+\\|/, "", id)
        tm = 0
        next
    }

    \$1 == "FT" && \$2 == "TRANSMEM" {
        tm++
        next
    }

    \$1 == "//" {
        if (tm <= 1 && id != "")
            print id
        id = ""
        tm = 0
    }
    ' phobius_output.txt > PHOBIUS.ids

    #Get the sequences from PHOBIUS.ids
    seqkit grep -r -f PHOBIUS.ids ${non_toxins} > PHOBIUS.fasta 

    # Ensure clean line endings
    tr -d '\\r' < ${toxinpred_csv} > tox.tmp && mv tox.tmp ${toxinpred_csv}


    # Extend CSV: 1 = has TMR, 0 = no TMR
    awk 'BEGIN {
    FS=OFS=","
    casefile = ARGV[1]
    n = split(casefile, parts, "/")
    base = parts[n]
    sub(/\\.[^.]*\$/, "", base)
    CASENAME = base
}
FILENAME == casefile {
    case_count++
    dict[\$1]=1
    next
}
FNR==1 {
    print \$0, CASENAME
    next
}
{
    print \$0, (case_count ? (\$1 in dict ? 1 : 0) : 0)
}' PHOBIUS.ids ${toxinpred_csv} > phobius.csv
    """
}

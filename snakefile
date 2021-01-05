
rule merge: 
    input:
        "test/{sample}/"        
        
    output:
        "merged/{sample}.fastq"     
        
    shell:
        "cat {input}/*.fastq > {output}"

rule nano_index:
    input:
        "test/fast5/",
        "merged/{sample}.fastq"
    output:
        "merged/{sample}.fastq.index", "merged/{sample}.fastq.index.fai",
        "merged/{sample}.fastq.index.gzi", "merged/{sample}.fastq.index.readdb"
    shell:
        "nanopolish index --directory {input}"

rule mini_align:
    input:
        ref="/home/max/Recommendref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",
        fa="merged/{sample}.fastq"
    output:
        "input/{sample}.aln.sam"
    shell:
        "minimap2 -L -ax  map-ont {input.ref} {input.fa} > {output}" 

rule sam_to_bam:
    input:
        "input/{sample}.aln.sam"
    output:
        "input/{sample}.aln.bam
    shell:
        "samtools view -S -b {input} > {output}"

rule sorting:
    input:
        "input/{sample}.aln.bam"
    output:
        "input/{sample}.aln.sorted.bam"
    shell:
        "samtools sort -f {input} {output}"

rule sam_index:
    input:
        "input/{sample}.aln.sorted.bam"
    output:
        "input/{sample}.aln.sorted.bam.bai"
    shell:
        "samtools index {input}"

rule call_meth:
    input:
        "input/{sample}.aln.sorted.bam.bai",
        "merged/{sample}.fastq.index", "merged/{sample}.fastq.index.fai",
        "merged/{sample}.fastq.index.gzi", "merged/{sample}.fastq.index.readdb",
        r="merged/{sample}.fastq",
        b="input/{sample}.aln.sorted.bam",
        g="/home/max/Recommendref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna"
    output:
        "{sample}_methylation_calls.tsv"
    shell:
        "nanopolish call-methylation -t 8 -r {input.r} -b {input.b} -g {input.g} > {output}"

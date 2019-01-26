ALL.extend([expand('{directory}{sample}{extension}',
                  directory = BIOTYPE_DIR,
                  sample = SAMPLE_NAMES,
                  extension = ['_screen.html','_screen.txt'])])

rule fastq_screen_biotype:
    input:
        fastq = FASTQ_DIR + '{sample}.fastq',
    output:
        html = BIOTYPE_DIR + '{sample}_screen.html',
        txt = BIOTYPE_DIR + '{sample}_screen.txt',
    params:
        output_dir = BIOTYPE_DIR,
        subset = config['fastq_screen']['subset'],
        aligner = config['fastq_screen']['aligner'],
        config_file = config['fastq_screen']['biotype']
    conda:
        'envs/fastqscreen_env.yml'
    threads: config['thread_info']['fastqc']
    shell:
        """
        fastq_screen \
        --aligner {params.aligner} \
        --subset {params.subset} \
        --conf {params.config_file} \
        --outdir {params.output_dir} \
        --threads {threads} \
        {input}
        """

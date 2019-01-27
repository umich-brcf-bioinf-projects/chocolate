#ChIP-seq
#Christopher Sifuentes cjsifuen@umich.edu

from __future__ import print_function, absolute_import, division
from argparse import Namespace
import collections
from collections import defaultdict
import csv
from functools import partial
from functools import reduce
import glob
import hashlib
import os
from os.path import basename
from os.path import isfile
from os.path import join
from os.path import splitext
import shutil
import sys
import subprocess
import yaml
import datetime
import time
import snakemake
import pandas as pd


#email
EMAIL = config.get('email_address')

#get parameters from config file
TODAY = datetime.date.today()
DEFAULT_JOB_SUFFIX = 'analysis_{:02d}_{:02d}/'.format(TODAY.month, TODAY.day)
SUFFIX = config['analysis_dir_suffix']

#pjdir
if not SUFFIX:
    PJ_SUFFIX = DEFAULT_JOB_SUFFIX
else:
    PJ_SUFFIX = SUFFIX

PJ_DIR = config.get('project_dir')

#make other dir names
ANALYSIS_DIR = PJ_DIR + PJ_SUFFIX
REF_DIR = ANALYSIS_DIR + 'references/'
FASTQ_DIR = ANALYSIS_DIR + 'fastq/'
QC_DIR = ANALYSIS_DIR + 'fastq_qc/'
MULTI_DIR = QC_DIR + 'multi_species/'
BIOTYPE_DIR = QC_DIR + 'biotype/'
TRIM_DIR = ANALYSIS_DIR + 'fastq_trimmed/'
ALN_DIR = ANALYSIS_DIR + 'aligned/'
MD_DIR = ANALYSIS_DIR + 'mark_duplicates/'
PEAKS_DIR = ANALYSIS_DIR + 'peaks/'
DEEP_DIR = ANALYSIS_DIR + 'deeptools/'
PHANTOM_DIR = ANALYSIS_DIR + 'phantompeak/'
NGS_DIR = ANALYSIS_DIR + 'ngsplot/'
LOG_DIR = ANALYSIS_DIR + 'logs/'
BENCH_DIR = ANALYSIS_DIR + 'benchmark/'


#make pjdir
if not os.path.exists(ANALYSIS_DIR):
    os.makedirs(ANALYSIS_DIR)

#organism base names
ORG = config['genome']

#get sample base names
SAMPLE_NAMES = os.listdir(config['input_dir']['fastq'])
SAMPLE_ID = [(x).split('_')[1] for x in SAMPLE_NAMES]

#read extensions (paired)
READS = config['read_info']['paired_ext']

#set empty all list
ALL = []

#run phantompeakqual?
RUN_PHANTOM = config['phantompeakqual']['run']

#load rules
include: 'rules/get_fastq.smk'
include: 'rules/fastqc.smk'
include: 'rules/fastq_screen_multi.smk'
include: 'rules/fastq_screen_biotype.smk'
include: 'rules/trim.smk'
include: 'rules/get_refs.smk'
include: 'rules/bwa_index.smk'
include: 'rules/bwa_align.smk'
include: 'rules/sort_index_bam.smk'
include: 'rules/mark_duplicates.smk'
include: 'rules/filter_bam.smk'
if RUN_PHANTOM.upper() == 'Y':
    include: 'rules/phantompeak_qual.smk'
#     include: 'rules/multiqc_phantom.smk'
# else:
#     include: 'rules/multiqc.smk'
include: 'rules/calculateNSCRSC.smk'
include: 'rules/plotFingerprint.smk'
include: 'rules/bamCoverage.smk'
include: 'rules/multiBamSummary.smk'
include: 'rules/plotCorrelationScatter.smk'
include: 'rules/plotCorrelationHeatmap.smk'
include: 'rules/plotPCA.smk'
include: 'rules/ngsplot.smk'
# include: 'rules/macs2.smk'

#rule all
rule all:
    input:
        ALL,

#email success
onsuccess:
    syscmd2 = "echo -e 'chocolate(chip-seq): workflow complete.' | mutt -s 'Workflow finished, no error' " + EMAIL
    os.system(syscmd2)

onerror:
    syscmd2 = "echo -e 'chocolate(chip-seq): workflow error.' | mutt -s 'Workflow failed with error' " + EMAIL
    os.system(syscmd2)
#!usr/bin/env bash

plotCoverage -b input/barcode05.aln.sorted.bam \
    -o out.png \
    --BED input/targets.bed \
    --centerReads \
    --outRawCounts coverage.tab

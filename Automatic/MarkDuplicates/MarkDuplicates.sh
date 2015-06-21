#!/bin/bash -e
#$ -cwd -V 
#$ -pe smp 2
#$ -l h_rt=24:00:00
#$ -l h_vmem=18G
#$ -R y
#$ -q all.q,bigmem.q

# Matthew Bashton 2012-2015
# Runs MarkDuplicates, note that -XX:ParallelGCThreads=2 is needed to prevent
# Picard using all the threads on a node.  Default runtime is 24hrs.

set -o pipefail
hostname
date

source ../GATKsettings.sh

B_NAME=`basename $G_NAME.$SGE_TASK_ID.bam .bam`

echo "** Variables **"
echo " - BASE_DIR = $BASE_DIR"
echo " - B_NAME = $B_NAME"
echo " - PWD = $PWD"

echo "Copying input $BASE_DIR/SamToSortedBam/$G_NAME.$SGE_TASK_ID.ba* to $TMPDIR"
/usr/bin/time --verbose cp -v $BASE_DIR/SamToSortedBam/$G_NAME.$SGE_TASK_ID.bam $TMPDIR
/usr/bin/time --verbose cp -v $BASE_DIR/SamToSortedBam/$G_NAME.$SGE_TASK_ID.bai $TMPDIR

echo "Running MarkDuplicates for $B_NAME.bam will also generate .bai on the fly"
/usr/bin/time --verbose $JAVA -Xmx16g -XX:ParallelGCThreads=2 -jar $PICARD MarkDuplicates \
INPUT=$TMPDIR/$B_NAME.bam \
OUTPUT=$TMPDIR/$B_NAME.dedup.bam \
TMP_DIR=$TMPDIR \
METRICS_FILE=$B_NAME.MD.metrics.txt \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=4000000

echo "Copying $TMPDIR/$B_NAME.dedup.ba* to $PWD"
/usr/bin/time --verbose cp -v $TMPDIR/$B_NAME.dedup.bam $PWD
/usr/bin/time --verbose cp -v $TMPDIR/$B_NAME.dedup.bai $PWD

echo "Deleting $TMPDIR/$B_NAME.*"
rm $TMPDIR/$B_NAME.*

date
echo "END"
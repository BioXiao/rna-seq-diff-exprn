#!/bin/sh

BED_DIR=/home/obot/bed_and_gtf

KGALIAS=$BED_DIR/hg19_aliases.tab
BED=$BED_DIR/hg19_ucsc-genes.bed
GTF=$BED_DIR/hg19_ucsc-genes.gtf

OUT_BED=$BED_DIR/hg19_ucsc-genes_merged-isoforms.bed
TMP_BED=$BED_DIR/hg19_ucsc-genes_merged-isoforms.tmp

for SYMBOL in `sed 1d $KGALIAS | cut -f 8 | uniq`
do
    echo "SYMBOL:" $SYMBOL
    UCSC_ALIAS=$BED_DIR/symbol_ucsc_alias.tmp
    SYMBOL_BED=$BED_DIR/symbol.bed
    awk -v SYMBOL=$SYMBOL \
	'{if ( $8 == SYMBOL ) print $0 }' $KGALIAS \
	| cut -f 1 >$UCSC_ALIAS
    grep -f $UCSC_ALIAS $BED | \
	sortBed -i >$SYMBOL_BED

    # Find all the chromosomes that this gene spans
    CHR=`cut -f 1 $SYMBOL_BED | uniq`
    NUM_CHR=`echo $CHR | awk ' { print NR } ' `
    
    # If the gene spans more than one chromosome,
    # don't count it
    if [ "$NUM_CHR" -gt 1 ] ; then
	echo $SYMBOL "has transcripts spanning several chromosomes, skipping"
	continue
    fi

    # Find minimum chromosome start and maximum end
    # BED file is sorted in chromosome position order,
    # So can just take the first start as the minimum.
    MIN_CHR_START=`head -1 $SYMBOL_BED | cut -f 2`
    MAX_CHR_STOP=`awk ' { if ($3 > MAX) MAX = $3 } END { print MAX} ' $SYMBOL_BED`
    NEW_CHR_START_STOP=`echo -e $MIN_CHR_START"\t"$MAX_CHR_STOP`

    MIN_THICK_START=`awk ' BEGIN { MIN = 1e10 } { if ($7 < MIN) MIN = $7 } END { print MIN} ' $SYMBOL_BED`
    MAX_THICK_STOP=$MIN_THICK_START #`awk ' { if ($8 > MAX) MAX = $8 } END { print MAX} ' $SYMBOL_BED`
    NEW_THICK_START_STOP=`echo -e $MIN_THICK_START"\t"$MAX_THICK_STOP`
    
    # Merge exons
    # Check if the start of this exon is different,
    # then subtract the difference so these exons start
    # at the right place
    # For testing:
    # cd ~/bed_and_gtf ; SYMBOL_BED=wash7p.genes.grep-f.sorted
    # MIN_CHR_START=`head -1 $SYMBOL_BED | cut -f 2` ; MAX_CHR_STOP=`awk ' { if ($3 > MAX) MAX = $3 } END { print MAX} ' $SYMBOL_BED` ; NEW_CHR_START_STOP=`echo -e $MIN_CHR_START"\t"$MAX_CHR_STOP` ; MIN_THICK_START=`awk ' BEGIN { MIN = 1e10 } { if ($7 < MIN) MIN = $7 } END { print MIN} ' $SYMBOL_BED` ; MAX_THICK_STOP=$MIN_THICK_START #`awk ' { if ($8 > MAX) MAX = $8 } END { print MAX} ' $SYMBOL_BED` ; NEW_THICK_START_STOP=`echo -e $MIN_THICK_START"\t"$MAX_THICK_STOP`
    # LINE=`head -n 1 $SYMBOL_BED ; THIS_CHR_START=`echo $LINE | cut -d" " -f 2` ; THIS_CHR_START_STOP=`echo $LINE | cut -d" " -f 2,3` ; THIS_THICK_START_STOP=`echo $LINE | cut -d" " -f 7,8`

    SYMBOL_EXON_STARTS=$OUT_DIR/symbol_exon_starts.bed
    while read LINE
    do
	THIS_CHR_START=`echo $LINE | cut -d" " -f 2`
	THIS_CHR_START_STOP=`echo $LINE | cut -d" " -f 2,3`
	THIS_THICK_START_STOP=`echo $LINE | cut -d" " -f 7,8`

	if [ $THIS_CHR_START -gt $MIN_CHR_START ]; then
	    # Adjust exon starts
	    # Length of exons (column 11) stays the same
	    DIFF=`expr $THIS_CHR_START - $MIN_CHR_START`
	    EXON_STARTS=""
	    EXON_STARTS_ORIG=`echo $LINE | cut -d" " -f 12 `
	    for i in `echo $EXON_STARTS_ORIG | tr "," " "`
	    do
		EXON_START=`expr $i - $DIFF`
		EXON_STARTS=$EXON_STARTS,$EXON_START
	    done
	    EXON_STARTS_FINAL=`echo $EXON_STARTS | tr "^," "" | tr "$" ","`
	    NEW_LINE=`echo $LINE | tr $EXON_STARTS_ORIG $EXON_STARTS_FINAL`
	else
	    NEW_LINE=$LINE
	fi
	echo `echo $NEW_LINE | tr "$THIS_CHR_START_STOP" "$NEW_CHR_START_STOP" | tr "$THIS_THICK_START_STOP" "$NEW_THICK_START_STOP" | sed 's: :\t:'`
    done < $SYMBOL_BED >$SYMBOL_EXON_STARTS

    ## Now need to merge exons to make a mega-isoform that
    ## just overlaps all the exons together
    # Set the mega-isoform as the first line of the
    # adjusted exon file
    MEGA_ISOFORM=`head -n 1 $SYMBOL_EXON_STARTS`
    SYMBOL_COLLAPSED_BED=$OUT_DIR/symbol_collapsed.bed
    while read LINE
    do
	
    done < sed 1d $SYMBOL_EXON_STARTS >$SYMBOL_COLLAPSED_BED

    cat $SYMBOL_COLLAPSED_BED >> $OUT_BED
#    mv $TMP_BED $OUT_BED
done
pdf('/Users/olgabotvinnik/workspace/rna-seq-diff-exprn/test-results/rseqc/LNCaP_4/rseqc.DupRate_plot.pdf')
par(mar=c(5,4,4,5),las=0)
seq_occ=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,29,31,32,33,37,39,41,48,49,50,53,56,57,58,67,70,75,76,94,699)
seq_uniqRead=c(56396,3186,650,225,121,62,38,26,24,13,12,8,7,5,5,1,9,1,1,2,2,6,1,3,1,2,3,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1)
pos_occ=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,27,28,30,31,32,34,40,41,43,45,50,55,56,57,59,61,63,66,72,77,79,90,115,728)
pos_uniqRead=c(52150,4129,881,324,149,103,47,37,27,23,13,12,12,8,6,4,3,1,5,5,2,2,3,4,3,2,2,2,6,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
plot(pos_occ,log10(pos_uniqRead),ylab='Number of Reads (log10)',xlab='Frequency',pch=4,cex=0.8,col='blue',xlim=c(1,500),yaxt='n')
points(seq_occ,log10(seq_uniqRead),pch=20,cex=0.8,col='red')
ym=floor(max(log10(pos_uniqRead)))
legend(300,ym,legend=c('Sequence-base','Mapping-base'),col=c('red','blue'),pch=c(4,20))
axis(side=2,at=0:ym,labels=0:ym)
axis(side=4,at=c(log10(pos_uniqRead[1]),log10(pos_uniqRead[2]),log10(pos_uniqRead[3]),log10(pos_uniqRead[4])), labels=c(round(pos_uniqRead[1]*100/sum(pos_uniqRead)),round(pos_uniqRead[2]*100/sum(pos_uniqRead)),round(pos_uniqRead[3]*100/sum(pos_uniqRead)),round(pos_uniqRead[4]*100/sum(pos_uniqRead))))
mtext(4, text = "Reads %", line = 2)
dev.off()
# Run whole file with Source, or Rscript run.R. Base R only.
sf<-tryCatch(sys.frame(1)$ofile,error=function(e)NULL)
if(is.null(sf)){a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))sf<-sub('^--file=','',a[1])}
root<-if(is.null(sf))getwd()else dirname(normalizePath(sf))
source(file.path(root,'R/model.R'));out<-file.path(root,'output');dir.create(out,showWarnings=FALSE)
write_table<-function(x,name)write.csv(x,file.path(out,name),row.names=FALSE)
weapons<-read.csv(file.path(root,'data/weapons.csv'));ps<-seq(.05,1,.01);hs<-c(150,175,200,225)
rows<-list();j<-0
for(i in seq_len(nrow(weapons))){vs<-variants(weapons[i,])
 for(h in hs)for(p in ps)for(v in 1:4){w<-vs[v,];z<-metrics(w,h,p);j<-j+1
 rows[[j]]<-data.frame(weapon=w$weapon,variant=w$variant,health=h,p=p,as.list(z),
 score_5=score(5,w,h,p),score_8=score(8,w,h,p),score_10=score(10,w,h,p),score_15=score(15,w,h,p))}}
results<-do.call(rbind,rows);write_table(results,'performance.csv')
base<-results[results$variant=='baseline',];gains<-list()
for(v in c('damage_plus1','magazine_plus2','gap_minus02')){
 z<-results[results$variant==v,];stopifnot(all(z$weapon==base$weapon),all(z$health==base$health),all(z$p==base$p))
 g<-z[,1:4];g$time_saved<-base$mean_ttk-z$mean_ttk;g$one_mag_gain_pp<-100*(z$one_mag-base$one_mag)
 for(t in c(5,8,10,15))g[[paste0('score_gain_',t)]]<-z[[paste0('score_',t)]]-base[[paste0('score_',t)]]
 gains[[v]]<-g}
gains<-do.call(rbind,gains);stopifnot(all(as.matrix(gains[,5:10])>=-1e-9));write_table(gains,'gains.csv')
corr<-list();j<-0
for(i in 1:nrow(weapons))for(h in hs)for(p in ps)for(rho in c(0,.05,.1)){
 w<-weapons[i,];b<-w;b$damage<-b$damage+1;j<-j+1
 corr[[j]]<-data.frame(weapon=w$weapon,health=h,p=p,rho=rho,gain_pp=100*(one_mag_correlated(b,h,p,rho)-one_mag_correlated(w,h,p,rho)))}
corr<-do.call(rbind,corr);write_table(corr,'correlation_sensitivity.csv')
cols<-c('#00749a','#168353','#b35b22');ids<-c('damage_plus1','magazine_plus2','gap_minus02');labs<-c('Damage +1','Magazine +2','Reload gap -0.2s')
png(file.path(out,'score_sensitivity.png'),1800,1050,res=150);par(mfrow=c(2,3),mar=c(4,4,3,1),oma=c(2,0,2,0))
for(h in c(175,200))for(w in weapons$weapon){z<-gains[gains$weapon==w & gains$health==h,]
 plot(NA,xlim=range(ps),ylim=c(0,max(z$score_gain_10)*1.15),xlab='Within-weapon hit probability',ylab='Score gain (points)',main=paste(w,'/',h,'HP'))
 for(i in 1:3){a<-z[z$variant==ids[i],];lines(a$p,a$score_gain_10,col=cols[i],lwd=2)}
 legend('topleft',labs,col=cols,lwd=2,bty='n',cex=.65)}
mtext('Separate changes; uniform deadline in 0-10s; provisional historical parameters',outer=TRUE,side=3,cex=.9);dev.off()
png(file.path(out,'time_curves.png'),1600,1000,res=150);par(mfrow=c(2,2),mar=c(4,4,3,1),oma=c(2,0,2,0))
vs<-variants(weapons[1,]);cc<-c('#555555',cols)
for(p in c(.1,.2,.3,.7)){plot(NA,xlim=c(0,15),ylim=c(0,100),xlab='Seconds from first shot',ylab='Knockdown probability (%)',main=paste('R-301 / p =',p))
 for(i in 1:4){w<-vs[i,];tt<-sort(unique(c(0,shot_time(1:shots_by(15,w),w),15)));lines(tt,100*cdf_ttk(tt,w,200,p),type='s',col=cc[i],lwd=2)}
 legend('topleft',c('Baseline',labs),col=cc,lwd=2,bty='n',cex=.65)}
mtext('200 HP / independent hits / no healing, cover or switching',outer=TRUE,side=3);dev.off()
source(file.path(root,'tests/checks.R'))
writeLines(capture.output(sessionInfo()),file.path(out,'sessionInfo.txt'))
message('Complete: ',out)

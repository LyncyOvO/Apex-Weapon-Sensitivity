set.seed(20261026);B<-100000L;checks<-list();j<-0
for(i in 1:nrow(weapons))for(h in c(175,200))for(p in c(.1,.3,.7,1)){
 vs<-variants(weapons[i,])
 for(v in 1:4){w<-vs[v,];n<-ceiling(h/w$damage);k<-n+rnbinom(B,n,p);tt<-shot_time(k,w)
 a<-metrics(w,h,p);se<-sd(tt)/sqrt(B)
 stopifnot(abs(mean(tt)-a['mean_ttk'])<=6*se+1e-8)
 sample_score<-100*pmax(10-tt,0)/10
 kk<-seq_len(shots_by(10,w));mass<-dnbinom(kk-n,n,p);reward<-100*pmax(10-shot_time(kk,w),0)/10
 scse<-sqrt(max(0,sum(reward^2*mass)-score(10,w,h,p)^2)/B)
 stopifnot(abs(mean(sample_score)-score(10,w,h,p))<=6*scse+1e-8)
 # Independent interval integration of the survival function.
 cuts<-sort(unique(c(0,shot_time(1:shots_by(10,w),w),10)));mid<-(head(cuts,-1)+tail(cuts,-1))/2
 restricted<-sum(diff(cuts)*(1-cdf_ttk(mid,w,h,p)))
 stopifnot(abs(score(10,w,h,p)-100*(1-restricted/10))<1e-8)
 if(p==1)stopifnot(abs(a['mean_ttk']-shot_time(n,w))<1e-8)
 j<-j+1;checks[[j]]<-data.frame(weapon=w$weapon,health=h,p=p,variant=w$variant,analytic_time=a['mean_ttk'],simulation_time=mean(tt),time_se=se,analytic_score=score(10,w,h,p),simulation_score=mean(sample_score),score_se=scse)
 }
 a<-metrics(vs[1,],h,p);b<-metrics(vs[4,],h,p)
 stopifnot(abs(a['mean_ttk']-b['mean_ttk']-.2*a['reloads'])<1e-9)
}
for(rho in c(.05,.1)){
 p<-.7;w<-weapons[1,];q<-rbeta(B,p*(1/rho-1),(1-p)*(1/rho-1));x<-rbinom(B,w$magazine,q);y<-as.numeric(x>=ceiling(200/w$damage))
 stopifnot(abs(mean(y)-one_mag_correlated(w,200,p,rho))<=6*sd(y)/sqrt(B)+1e-8)
}
write_table(do.call(rbind,checks),'simulation_checks.csv')
writeLines(c(paste('PASS:',j,'IID scenarios;',B,'trials each.'),'PASS: mean time and score within six simulation standard errors.','PASS: independent interval integral; deterministic p=1; reload identity.','PASS: two beta-binomial simulation checks.','These checks verify implementation, not empirical validity.'),file.path(out,'validation.txt'))

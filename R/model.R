# gap: last shot of an exhausted magazine to first shot of next magazine.
shot_time <- function(k,w) (k-1)*60/w$rpm + floor((k-1)/w$magazine)*(w$gap-60/w$rpm)
validate <- function(w,h,p) stopifnot(h>0,p>0,p<=1,w$damage>0,w$rpm>0,w$magazine>=1,w$magazine==floor(w$magazine),w$gap>=60/w$rpm)
metrics <- function(w,h,p) {
 validate(w,h,p);n<-ceiling(h/w$damage)
 J<-ceiling((n+qnbinom(1-1e-14,n,p))/w$magazine)+5
 er<-sum(pbinom(n-1,seq_len(J)*w$magazine,p))
 c(hits=n,mean_ttk=(n/p-1)*60/w$rpm+(w$gap-60/w$rpm)*er,
 one_mag=pbinom(n-1,w$magazine,p,lower.tail=FALSE),reloads=er)
}
shots_by <- function(t,w) {
 dt<-60/w$rpm;cycle<-(w$magazine-1)*dt+w$gap
 full<-floor((t+1e-10)/cycle);rem<-t-full*cycle
 full*w$magazine+pmin(w$magazine,pmax(0,floor((rem+1e-10)/dt)+1))
}
cdf_ttk <- function(t,w,h,p) {
 validate(w,h,p);stopifnot(all(t>=0))
 pbinom(ceiling(h/w$damage)-1,shots_by(t,w),p,lower.tail=FALSE)
}
# Exact finite-time sum: no distribution-tail approximation for score.
score <- function(tau,w,h,p) {
 validate(w,h,p);stopifnot(tau>0)
 n<-ceiling(h/w$damage);last<-shots_by(tau,w)
 if(last<n)return(0)
 k<-seq.int(n,last)
 100*sum(pmax(tau-shot_time(k,w),0)*dnbinom(k-n,n,p))/tau
}
one_mag_correlated <- function(w,h,p,rho=0) {
 validate(w,h,p);stopifnot(rho>=0,rho<1)
 n<-ceiling(h/w$damage);m<-w$magazine
 if(rho==0 || p==1)return(pbinom(n-1,m,p,lower.tail=FALSE))
 if(n>m)return(0)
 a<-p*(1/rho-1);b<-(1-p)*(1/rho-1);k<-n:m
 sum(exp(lchoose(m,k)+lbeta(k+a,m-k+b)-lbeta(a,b)))
}
variants <- function(w) {
 z<-w[rep(1,4),];z$variant<-c('baseline','damage_plus1','magazine_plus2','gap_minus02')
 z$damage[2]<-z$damage[2]+1;z$magazine[3]<-z$magazine[3]+2;z$gap[4]<-z$gap[4]-.2;z
}

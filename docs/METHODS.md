# Mathematical specification

## 1. Shot process

Let X_i be independent Bernoulli(p) hits; a hit always deals d body damage. Set n=ceil(H/d) and K=inf{k:sum_{i=1}^k X_i>=n}. For k>=n:

P(K=k)=choose(k−1,n−1) p^n (1−p)^(k−n).

Thus E[K]=n/p. Full magazines contain m rounds. All shots and reloads occur at a deterministic cadence, with first shot at zero:

t(k)=(k−1)/r+floor((k−1)/m)(g−1/r), T=t(K).

Assume g>=1/r so shot times are increasing and adding magazine capacity does not perversely lengthen the firing timeline.

## 2. Mean time and one-mag probability

The number of reloads is R=floor((K−1)/m). By the tail-sum identity:

E[R]=sum_{j>=1} P(K>jm)=sum_{j>=1}P(Binomial(jm,p)<n).

E[T]=(n/p−1)/r+(g−1/r)E[R].

The implementation truncates this sum beyond a negative-binomial 1−1e−14 quantile plus five magazines. This is a numerical approximation, not a symbolic exact infinite sum; no uniform rigorous tail-error bound is claimed. Tested parameter range p>=0.05.

P(one magazine)=P(Binomial(m,p)>=n).

Reducing g by c saves exactly c E[R] in mean time, with no effect on one-mag probability. If d changes but n does not, every outcome in this body-hit-only model is unchanged.

## 3. Time CDF

Let N(t) count available shots at or before t. With cycle length C=(m−1)/r+g and q=floor(t/C):

N(t)=qm+min(m, floor((t−qC)r)+1), t>=0.

P(T<=t)=P(Binomial(N(t),p)>=n).

Code uses 1e−10 seconds tolerance for floating-point boundary counting. No reaction delay, projectile travel time or initial ADS animation is included.

## 4. Primary conditional score

S_tau(p)=100/tau integral_0^tau F_T(t)dt
=100/tau E[(tau−T)_+]
=100[1−E[min(T,tau)]/tau].

Compute using the finite sum over n<=k<=N(tau):

S_tau=100/tau sum_k (tau−t(k))_+ P(K=k).

There is no negative-binomial tail cutoff error in this finite-window score. It measures both timeliness and completion probability. It does not measure utility for partial damage, assists or survival.

Equivalently S_tau/100=P(T<=D) when D is independent Uniform(0,tau). Independence and uniform weighting are deliberate assumptions. A future measured deadline distribution G could replace the uniform weighting, but observed kill durations alone would be biased toward completed kills and are not sufficient to estimate an exogenous deadline distribution.

Report delta S_tau=S_tau(adjusted)−S_tau(baseline), in points. Do not average across p unless an explicit, justified population distribution is supplied. Do not compare different weapons as if their p distributions were equal.

## 5. Encounter heterogeneity sensitivity

For each encounter draw Q~Beta(a,b); conditional on Q, hits are independent Bernoulli(Q). Set a=p(1/rho−1), b=(1−p)(1/rho−1). Then E[Q]=p and distinct shots within the encounter have correlation rho. The hit count X in m rounds is beta-binomial:

P(X=x)=choose(m,x) B(x+a,m−x+b)/B(a,b).

The implementation sums x=n..m for one-mag probability. rho=0 uses the independent model. This exchangeable model describes encounter-level heterogeneity; it does not encode shot order, recoil growth or a Markov run-length process.

This extension is deliberately restricted to one-mag probability. If the same Q persists indefinitely, E[K]=n E[1/Q] can diverge when a<=1. Therefore the independent mean-TTK formula must not be reused for this mixture, and low-p mixture mean times are not reported.

## 6. Validation design

96 IID scenarios = 3 weapons × 2 health values × 4 accuracies × 4 variants. Each uses 100,000 negative-binomial draws. Mean TTK and finite-window score must lie within six simulation standard errors (sample-based for mean time, analytical variance for the bounded score) of analytical values (plus numerical tolerance). This tolerance is a diagnostic, not a confidence interval for real-world outcomes.

Analytical score variance avoids a zero estimated standard error when rare successes are absent from a finite simulation. An independent interval integration of the CDF verifies the score identity. Deterministic p=1, the reload identity and nonnegative gains are checked. Two beta-binomial cases are compared against explicit beta-plus-binomial sampling. A fixed seed makes runs reproducible within an R environment; session information is recorded.

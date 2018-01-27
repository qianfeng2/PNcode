args <- commandArgs(trailingOnly = TRUE)

require(seqinr,quietly=TRUE)  # install.packages("seqinr")
require(Matrix,quietly=TRUE)

# read first sequence in fasta file into character vector
readfasta = function(filename)
{
                                        # get string,read.fasta("homo.fasta")
    seq = read.fasta(filename,seqonly=TRUE, as.string=TRUE)[[1]]
                                        # get characters
    seq = strsplit(seq,split="")[[1]]
}

# convert character vector to vector of integers
tonumbers = function(letters)
{
    letters = as.numeric(factor(letters,levels=c('A','T','G','C')))
}

# show the first or second sequence, where state S corresonds to a '-' in this sequence
show.one = function(letters,path,S)
{
    row = c()
    x = 1
    for(i in 1:length(path))
    {
        if (path[i] == S)
        {
            row=c(row,'-')
        }
        else
        {
            row=c(row,letters[x])
            x = x + 1
        }
    }
    paste(row,collapse="")
}

# convert a sequence of states (path) into a readable alignment with letters
draw.a = function(letters1,letters2,path)
{
    paste(show.one(letters1,path,I),"\n",show.one(letters2,path,D),"\n",sep="",collapse="")
}


# wrap x on the range [0,b]
wrap0 = function(x, b)
{
    x = x %% (2*b)
    if (x > b) {
        x = 2*b - x
    }
    x
}

# wrap x on range [a,b]
wrap = function(x, a, b)
{
    a + wrap0(x-a,b-a)
}


# choose the 1st, 2nd, 3rd, etc. element of pr in proportion to their magnitude
choose = function(pr)
{
    pr = pr/sum(pr)
    u = runif(1)
    total = 0.0
    for(i in 1:length(pr))
    {
        total = total + pr[i]
        s = i
        if (u < total) {
            break
        }
    }
    s
}

# Choose integers for the states Match, Delete, Insert, Start, End
M = 1
D = 2 # + -
I = 3 # - +
S = 4
E = 5  

# Create the matrix of transition probabilities between states M,D,I
pairhmm = function(d,e)
{
    T = matrix(nrow=3,ncol=5)
    
    T[M,I] = d
    T[M,D] = d
    T[M,M] = 1-2*d
    T[M,E] = 1
    
    T[I,M] = (1-e)*(1-2*d)
    T[I,I] = e + (1-e)*d
    T[I,D] = (1-e)*d
    T[I,E] = 1
    
    T[D,M] = (1-e)*(1-2*d)
    T[D,I] = (1-e)*d
    T[D,D] = e + (1-e)*d
    T[D,E] = 1

    T
}

# jukes-cantor rate matrix
jc = function()
{
                                        # jukes cantor rate matrix
    matrix( c(-3,1,1,1,
              1,-3,1,1,
              1,1,-3,1,
              1,1,1,-3), nrow=4)/3
}

# perform the forward algorithm to compute the dynamic programming matrix
forwardmatrix = function(seq1,seq2,T,P,pi)
{
    X = 1+length(seq1)
    Y = 1+length(seq2)

    FM = array(rep(0,X*Y*3), dim=c(X,Y,3))

    # don't over-write this later
    FM[1,1,M] = 1

    for(x in 1:X) {
        for(y in 1:Y) {
            lx = seq1[x-1]
            ly = seq2[y-1]

                                        # + +
            if (x > 1 && y > 1) {
                x2 = x-1
                y2 = y-1
                FM[x,y,M] = FM[x2,y2,M]*T[M,M] +
                            FM[x2,y2,D]*T[D,M] +
                            FM[x2,y2,I]*T[I,M]

                FM[x,y,M] = FM[x,y,M] * pi[lx] * P[lx,ly]
            }

                                        # + -
            if (x > 1) {
                x2 = x-1
                y2 = y
                FM[x,y,D] = FM[x2,y2,M]*T[M,D] +
                            FM[x2,y2,D]*T[D,D] +
                            FM[x2,y2,I]*T[I,D]
                FM[x,y,D] = FM[x,y,D] * pi[lx]
            }

                                        # - +
            if (y > 1) {
                x2 = x
                y2 = y-1
                FM[x,y,I] = FM[x2,y2,M]*T[M,I] +
                            FM[x2,y2,D]*T[D,I] +
                            FM[x2,y2,I]*T[I,I]
                FM[x,y,I] = FM[x,y,I] * pi[ly]
            }
        }
    }
    
    FM
}

# find the total probability of all alignments, from the forward matrix
total.prob = function(FM)
{
    XX = dim(FM)[1]
    YY = dim(FM)[2]

    FM[XX,YY,M] + FM[XX,YY,D] + FM[XX,YY,I]
}

# perform backwards sampling to sample a random alignment in proportion to its probability
backsample = function(FM,T)
{
    X = dim(FM)[1]
    Y = dim(FM)[2]

    # Start with emitting everying in x, everything in y, in the End state
    x = X
    y = Y
    s = E

    states = c()
    while(x > 1 || y > 1)
    {
#       Select a previous state s2 proportional to FM[x,y,s2] * T[s2,s]
        s = choose(FM[x,y,]*T[,s])
#        print(FM[x,y,])
#        print(c(x,y,s))
        states = c(s,states)
        if (s == M)
        {
            x = x - 1
            y = y - 1
        }
        else if (s == D)
        {
            x = x - 1
        }
        else if (s == I)
        {
            y = y - 1
        }
#        print(c(x,y,-1))
    }
    states
}

# read the input sequences
seq1letters = readfasta(args[1])
seq2letters = readfasta(args[2])
# how many iterations of MCMC
niter = args[3]

# convert the sequence strings to integers
seq1 = tonumbers(seq1letters)
seq2 = tonumbers(seq2letters)

Q = jc()
t = 0.25
P = expm(Q*t)
d=0.05
e=0.5

pi = rep(0.25, 4)
FM = forwardmatrix(seq1, seq2, pairhmm(d,e), P,pi)
path = backsample(FM,pairhmm(d,e))
write(draw.a(seq1letters,seq2letters,path), stderr())

# Compute the full probability Pr(data,d,t)
# * Here d is the probability of deletions/insertions,gap open prob,P(M-I)=P(M-D)
# * t is the branch length between the sequence pair
fullprob = function(d,t)
{
    total.prob(forwardmatrix(seq1,seq2,pairhmm(d,e),expm(Q*t), pi)) * dexp(t, rate=2.0)
}
    
# print the header (Tracer format)
cat("iter\tt\td\tpr\n")

# count the number of proposed changes to t and d that were rejected
rej.t = 0
rej.d = 0
pp=rep(0,niter+1)

# start the iterations of MCMC by "for" loop
for(iter in 0:niter)
{
    p = fullprob(d,t)
    pp[iter+1]= log(p)
# print a tab-delimited line of iterations (iter), branch length (t), gap opening probability (d), and log probability
    cat(sprintf("%i\t%f\t%f\t%f\n",iter,t,d,log(p)))
    {
        # propose a new branch length t2
        t2 = abs(rnorm(1,mean=t,sd=0.20))

        # accept or reject
        p2 = fullprob(d,t2)
        if (p2 > p || runif(1) < p2/p)
        {
            p = p2
            t = t2
        }
        else
        {
            rej.t = rej.t + 1
        }
    }

    {
        # propose a new gap open probability d2
        d2 = wrap(rnorm(1,mean=d,sd=0.07),0,0.49)

        # accept or reject
        p2 = fullprob(d2,t)
        if (p2 > p || runif(1) < p2/p)
        {
            p = p2
            d = d2
        }
        else
        {
            rej.d = rej.d + 1
        }
    }
}
plot(pp,bty="o",type="o",pch=17,col="blue")
# write the number of reject moves to stderr
write(c(rej.t,rej.d),stderr())

# write a final alignment to stderr, pay attention: the t and d is the 100th iteration value. 
path = backsample(forwardmatrix(seq1, seq2, pairhmm(d,e), P, pi), pairhmm(d,e))
write(draw.a(seq1letters,seq2letters,path), stderr())
save.image("align.RData")
load("align.RData")



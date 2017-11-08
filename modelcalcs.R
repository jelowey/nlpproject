calcDiscount <- function(dt) {
  
  require(data.table)
  dt$discount <- rep(1,nrow(dt))
  n <- 5
  for(i in n:1){
    currentcount <- i
    nextcount <- currentcount +1 
    none <- length(which(dt$total == 1))
    nnone <- length(which(dt$total == n+1))
    
    currentn <- length(which(dt$total == currentcount))
    nextn <- length(which(dt$total == nextcount))
    
    goodturing <- (nextcount/currentcount)*(nextn/currentn)
    currentdisc <- (goodturing -((n+1)*(nnone)/(none)))/(1-((n+1)*(nnone)/(none)))
    
    dt[total == currentcount, discount:= currentdisc]
  }
  return(dt)
}
cleanSample<-function(source, smpsize=0.5) {
  
  l <- length(source)
  
  smp <- sample(1:l, l * smpsize)
  
  s.smp <- source[smp] #get a random smaller sample
  
  s.smp <- tolower(s.smp)
  
  s.clean <- gsub("[^a-z']+", " ", s.smp) #remove all non-alphabetic characters, except for "'"
  
  s.clean <- gsub("'{2,}", "'", s.clean)
  
  s.clean <- gsub("' | '|' '", " ", s.clean) #remove "'" that are not between two letters
  
  s.clean <- gsub("^'|'$", "", s.clean) #remove "'" that are at the beginning or end of a sentence
  
  
  return(s.clean)
}

calcLeftOvers <- function(lastTerm, total, discount){
  alltotal <- sum(total)
  return(1-sum((discount*total)/alltotal))
}

katzBackoffprob <- function(string){
  require(stringr)
  if(length(string)==1){input <- unlist(str_split(string, boundary("word")))}
  else{input<- string}
  n <- length(input)
  probability <- -1
  if(n > 3){
    katzBackoffprob(input[(n-2):n])
  }
  if(n == 2){
    matched <- bigrams[firstTerm == input[1] & lastTerm == input[2]]
    wordmatch <- unigrams[word == input[1]]
    if(nrow(matched)>0){
      probability <- (matched$discount*matched$total)/wordmatch$total
      return(probability)
    }
    else{
      matched <- bigrams[firstTerm == input[1]]
      alpha <- sum(matched$discount/wordmatch$total)
      mlmatch <-  wordmatch$total/wordtotal
      inversematch <- unigrams[!(word %in% matched$lastTerm)]
      mlnotmatch <- sum(inversematch$total/wordtotal)
      probability <- alpha*(mlmatch/mlnotmatch)
      return(probability)
    }
  if(n==3){
    bigrammed <- paste(input[1],input[2], " ")
    matched <- trigrams[firstTerm == bigrammed & lastTerm == input[3]]
    if(nrow(matched)>0){
    }
  }
    
    }
}
getLastWords <- function(string, words) {
  pattern <- paste("[a-z']+( [a-z']+){", words - 1, "}$", sep="")
  return(substring(string, str_locate(string, pattern)[,1]))
}

knserNey <- function(ngrams, d){
  n<- length(unlist(str_split(ngrams[1,1],boundary("word"))))
  if(n==1){
    unigramsprob <- NULL
    for(x in ngrams$lastTerm){
      matched <- bigrams[x == lastTerm]
      unigramsprob <- c(unigramsprob, (sum(matched$total)/bigramstotal))
    }
    return(unigramsprob)
  }
}


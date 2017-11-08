con1 <- file("en_US.twitter.txt", "r")
con2 <- file("en_US.news.txt", "r")
con3 <- file("en_US.blogs.txt", "r")

tweets <- readLines(con1)
news <- readLines(con2)
blogs <- readLines(con3)

close(con1); close(con2); close(con3)/

set.seed(50)
samplelines <- c(sample(tweets, length(tweets) * 0.1),
                 sample(news, length(news) * 1),
                 sample(blogs, length(blogs) * 0.1))

set.seed(50)
samplelines <- sample(samplelines)
validationIndex <- floor(length(samplelines) * 0.8)
testingIndex <- floor(length(samplelines) * 0.9)

training <- samplelines[1:validationIndex]
validation <- samplelines[(validationIndex+1):testingIndex]
testing <- samplelines[(testingIndex+1):length(samplelines)]

tokenizer <- function(lines) {
  lines <- tolower(lines)
  lines <- gsub("'", "'", lines)
  lines <- gsub("[.!?]$|[.!?] |$", " ''split'' ", lines)
  lines <- gsub("[^a-z' ]+", "", lines)
  lines <- gsub("dont", "don't", lines)
  lines <- gsub("youve", "you've", lines)
  lines <- gsub("youre", "you're", lines)
  lines <- gsub("ive", "i've", lines)
  lines <- gsub("cant", "can't", lines)
  lines <- gsub("shouldnt", "shouldn't", lines)
  lines <- gsub("shouldve", "should've", lines)
  lines <- gsub("didnt", "didn't", lines)
  lines <- gsub("doesnt", "doesn't", lines)
  lines <- gsub("havent", "haven't", lines)
  lines <- gsub("d ''split'' c", "dc", lines)
  lines <- gsub("wasnt", "wasn't", lines)
  lines <- gsub("isnt", "isn't", lines)
  lines <- gsub("couldnt", "couldn't", lines)
  lines <- gsub("hadnt", "hadn't", lines)
  tokens <- unlist(strsplit(lines, "[^a-z']"))
  tokens <- tokens[tokens != ""]
  return(tokens)
}

tokens <- tokenizer(training)
vtokens <- tokenizer(validation)
ttokens <- tokenizer(testing)

tokens2 <- c(tokens[-1], ".")
tokens3 <- c(tokens2[-1], ".")
tokens4 <- c(tokens3[-1], ".")
tokens5 <- c(tokens4[-1], ".")
tokens6 <- c(tokens5[-1], ".")

unigrams <- tokens
bigrams <- paste(tokens, tokens2)
trigrams <- paste(tokens, tokens2, tokens3)
quadgrams <- paste(tokens, tokens2, tokens3, tokens4)
fivegrams <- paste(tokens, tokens2, tokens3, tokens4, tokens5)
sixgrams <- paste(tokens, tokens2, tokens3, tokens4, tokens5, tokens6)

unigrams <- unigrams[!grepl("''split''", unigrams)]
bigrams <- bigrams[!grepl("''split''", bigrams)]
trigrams <- trigrams[!grepl("''split''", trigrams)]
quadgrams <- quadgrams[!grepl("''split''", quadgrams)]
fivegrams <- fivegrams[!grepl("''split''", fivegrams)]
sixgrams <- sixgrams[!grepl("''split''", sixgrams)]

unigrams <- sort(table(unigrams), decreasing=T)
bigrams <- sort(table(bigrams), decreasing=T)
trigrams <- sort(table(trigrams), decreasing=T)
quadgrams <- sort(table(quadgrams), decreasing=T)
fivegrams <- sort(table(fivegrams), decreasing=T)
sixgrams <- sort(table(sixgrams), decreasing=T)

library(stringr)

getLastWords <- function(string, words) {
  pattern <- paste("[a-z']+( [a-z']+){", words - 1, "}$", sep="")
  return(substring(string, str_locate(string, pattern)[,1]))
}

removeLastWord <- function(string) {
  sub(" [a-z']+$", "", string)
}

kneserNay <- function(ngrams, d) {
  n <- length(strsplit(names(ngrams[1]), " ")[[1]])
  
  # Special case for unigrams
  if(n==1) {
    noFirst <- unigrams[getLastWords(names(bigrams), 1)]
    pContinuation <- table(names(noFirst))[names(unigrams)] / length(bigrams)
    return(pContinuation)
  }
  
  # Get needed counts
  nMinusOne <- list(unigrams, bigrams, trigrams, quadgrams, fivegrams, sixgrams)[[n-1]]
  noLast <- nMinusOne[removeLastWord(names(ngrams))]
  noFirst <- nMinusOne[getLastWords(names(ngrams), n-1)]
  
  # Calculate discounts, lambda and pContinuation
  discounts <- ngrams - d
  discounts[discounts < 0] <- 0
  lambda <- d * table(names(noLast))[names(noLast)] / noLast
  if(n == 2) pContinuation <- table(names(noFirst))[names(noFirst)] / length(ngrams)
  else pContinuation <- kneserNay(noFirst, d)
  
  # Put it all together
  probabilities <- discounts / noLast + lambda * pContinuation / length(ngrams)
  return(probabilities)
}


unigramProbs <- kneserNay(unigrams, 0.75)
bigramProbs <- kneserNay(bigrams, 0.75)
trigramProbs <- kneserNay(trigrams, 0.75)
quadgramProbs <- kneserNay(quadgrams, 0.75)
fivegramProbs <- kneserNay(fivegrams, 0.75)
sixgramProbs <- kneserNay(sixgrams, 0.75)

library(data.table)
unigramDF <- as.data.table(data.frame("Words" = (names(unigrams)), "Probability" = as.vector(unigramProbs), stringsAsFactors=F))

bigramsDF <- as.data.table(data.frame("FirstWords" = removeLastWord(names(bigrams)),
                                      "LastWord" = getLastWords(names(bigrams), 1),
                                      "Probability" = as.vector(bigramProbs), stringsAsFactors=F))

trigramsDF <- as.data.table(data.frame("FirstWords" = removeLastWord(names(trigrams)),
                                       "LastWord" = getLastWords(names(trigrams), 1),
                                       "Probability" = as.vector(trigramProbs), stringsAsFactors=F))

quadgramsDF <- as.data.table(data.frame("FirstWords" = removeLastWord(names(quadgrams)),
                                        "LastWord" = getLastWords(names(quadgrams), 1),
                                        "Probability" = as.vector(quadgramProbs), stringsAsFactors=F))

library(dplyr)
unigramDF <- (unigramDF %>% arrange(desc(Probability)))
bigramsDF <- bigramsDF %>% arrange(desc(Probability)) %>% filter(Probability > 0.0001)
trigramsDF <- trigramsDF %>% arrange(desc(Probability)) %>% filter(Probability > 0.0001)
quadgramsDF <- quadgramsDF %>% arrange(desc(Probability)) %>% filter(Probability > 0.0001)

unigramDF <- as.data.table(unigramDF)
bigramsDF <- as.data.table(bigramsDF)
trigramsDF <- as.data.table(trigramsDF)
quadgramsDF <- as.data.table(quadgramsDF)
predictor <- function(input) {
  n <- length(strsplit(input, " ")[[1]])
  prediction <- c()
  if(n >= 3 && length(prediction)<3)
    prediction <- c(prediction, quadgramsDF[FirstWords == getLastWords(input,3)]$LastWord)
  if(n >= 2 && length(prediction)<3)
    prediction <- c(prediction, trigramsDF[FirstWords == getLastWords(input,2)]$LastWord)
  if(n >= 1 && length(prediction)<3)
    prediction <- c(prediction, bigramsDF[FirstWords == getLastWords(input,1)]$LastWord)
  if(length(prediction)<3 ) prediction <- c(prediction, unigramDF$Words)
  
  return(unique(prediction)[1:3])
}

predictor("this is a")

# General helper functions used for emnist text data analysis


asc <- function(x) { strtoi(charToRaw(x),16L) } # character to ascii code
asci <- function(n) { rawToChar(as.raw(n)) } # ascii code to charcater 


EMNIST_read <- function()
{  
  
  #  emnist <- readMat('emnist-byclass.mat') # read matlab format and conver to R 
  #  save(emnist, file='emnist-byclass.RData')
  load(file='emnist-byclass.RData') # load emnist data from file in R format (after converting from matlab format)
  
  x_train <- emnist$dataset[[1]][[1]] # too large to reshape !! 
  y_train <- emnist$dataset[[1]][[2]]
  x_test <- emnist$dataset[[2]][[1]]
  y_test <- emnist$dataset[[2]][[2]]
  z_map <- emnist$dataset[[3]] # map labels to asci codes 
  
  x_train <- (x_train / 255) # keep only 0-1. Lose gray-scale information
  x_test <- (x_test / 255)
  
  return(list(x_train=x_train, y_train=y_train, x_test=x_test, y_test=y_test, z_map=z_map))
}

# Compute frequency of each character in text file 
# 
# Input: 
# text_file_name - name of text file to use
# z_map - array with characters whose frequency we want to find
# 
GetTextStatistics <- function(text_file_name, z_map)
{
  s <- readChar(textfileName, file.info(textfileName)$size)
  r <- unlist(strsplit(s, ""))
  
  T <- table(strsplit(s, split = "")[[1]])
  T <- T / sum(T) # normalize to get probabilities 
  
  # Match labels from text file to input map of characters 
  common_inds <- match((strsplit(asci(z_map[,2]),""))[[1]], labels(T)[[1]])
  freq <- T[common_inds]
  T <- NULL
  T$z_map <- z_map
  T$freq <- freq
  return(T)
}


# Generate words of given length: both text and images 
GenerateRandomWords <- function(n_words, x_train, y_train, z_map, s, L) # generate text and image 
{
  X_words <- matrix(data=0, nrow=28*L, ncol=28*n_words) # get images 
  y_words <- vector("list", length=n_words) # get text 
  
  w <- strsplit(s, split = " ")# first choose words 
  I <- which(nchar(w[[1]]) == L) # find words of specified length 
  
  good_inds <- rep(0, length(I))
  for(i in 1:length(I))
  {
    good_inds[i] <- (length(setdiff(asc(w[[1]][I[i]]), z_map[,2]))==0)
  }
  I <- I[as.logical(good_inds)]  
  y_words <- sample(w[[1]][I], n_words, replace = FALSE)
  for(i in 1:n_words)
  {
    X_words[,((i-1)*28+1):(i*28)] <- TextToImage(y_words[i], x_train, y_train, z_map) 
  }
  
  return(list(X=t(X_words), y=y_words))
}

# Compute prediction error. We use 0/1 loss for words - with/without ignoring lowercase upper case 
EvaluateModelWords <- function(y, y_hat)  
{
  n_words <- length(y)
  L <- nchar(y[1])
  accuracy <- NULL
  accuracy$char <- 0
  accuracy$char.case <- 0
  accuracy$word <- 0
  accuracy$word.case <- 0
  for(i in 1:n_words)
  {
    accuracy$char <- accuracy$char + L-adist(tolower(y[i]),tolower(y_hat[i]))  # uses approximate distance
    accuracy$char.case <- accuracy$char.case + L-adist(y[i],y_hat[i])  # uses approximate distance
    accuracy$word <- accuracy$word + (tolower(y[i])==tolower(y_hat[i]))  
    accuracy$word.case <- accuracy$word.case + (y[i]==y_hat[i])  
  }
  accuracy$char <- accuracy$char / (L*n_words)
  accuracy$char.case <- accuracy$char.case / (L*n_words)
  accuracy$word <- accuracy$word / n_words 
  accuracy$word.case <- accuracy$word.case / n_words 
  
  return(accuracy)
}  

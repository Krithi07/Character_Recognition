#Install necessary datasets
install.packages("devtools")
devtools::install_github("rstudio/keras")

setwd('....')
source("EMNIST_general_functions.R")

library(keras)
library(tensorflow)
library(tm)

#install_keras()
#install_tensorflow() #CPU version of Tensorflow

data <- list()
data <- EMNIST_read()

train_x <- data$x_train
train_y <- data$y_train
test_x <- data$x_test
test_y <- data$y_test

rm(data)

#converting the target variable to once hot encoded vectors using keras inbuilt function
train_y <- to_categorical(train_y,62)
test_y <- to_categorical(test_y,62)

#defining a keras sequential model
model <- keras_model_sequential()

model %>% 
  layer_dense(units = 512, activation = 'relu', input_shape = 784) %>% 
  layer_dropout(rate = 0.1) %>%
  layer_dense(units = 256, activation = 'relu') %>%
  layer_dropout(rate = 0.1) %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.1) %>%
  layer_dense(units = 62, activation = 'softmax')

#compiling the defined model with metric = accuracy and optimiser as adam.
model %>% compile(
  optimizer = 'adam',
  loss = 'categorical_crossentropy',
  metrics = c('accuracy') 
)

#fitting the model on the training dataset
model %>% fit(train_x, train_y, epochs = 10, batch_size = 256, validation_split = 0.1, 
              callbacks = callback_early_stopping(monitor = "val_acc", patience = 5, mode = "min"))

#Evaluating model on the cross validation dataset
loss_and_metrics <- model %>% keras::evaluate(test_x, test_y, batch_size = 256)

m.image <- model

save_model_hdf5(m.image, file = "EMNIST_Model_Champ.h5")

#--------------------------------------------------TEXT ANALYTICS------------------------------------------------------#

# Text Corpus: http://www.anc.org/data/oanc/download/
# Download the dataset from here to train your model on and save it in the 'Text' object
# I used the files from fiction folder in OANC_GrAF_Corpus\OANC-GrAF\data\written_1
# One can use any english text corpus for training. 
# I have uploaded a sample file which can be directly used as corpus 
# That is, if you do not want to go through all the hassles of downloading a file yourself

TextRead <- function(Text) {
  Corpus <- read.csv(Text, header = F, sep = " ", stringsAsFactors = F)
  Corpus <- unlist(Corpus)
  Corpus <- removePunctuation(Corpus)
  Corpus <- Corpus[which(sapply(Corpus, nchar) == 5)]
  Corpus <- tolower(Corpus)
  Corpus <- Corpus[grepl("^[a-z]+$", Corpus)]
  Corpus <- unique(Corpus)
  return(Corpus)
}

FreqN <- function(Words, n1, n2) {
  # Frequency table of substrings in words from n1 to n2
  table(sapply(Words, function(x) substring(x, n1, n2)))}

# Using Hidden Markov Model for building a text analytics model 

HMMTrain <- function(Text) {
  
  # Model <- vector(length = 2, mode = "list")
  # Freq <- prop.table(FreqN(Text, 1, 1)) # Get the frequency table of the first letters
  # Model$NC <- rep(0,26)
  # Index <- sapply(names(Freq), asc) - 96 # Get the locations of each letter, so "a" will be turned to the vector 1
  # Model$NC[Index] <- Freq

  PrbMat <- vector(length = 4, mode = "list")
  for (i in 1:4) { # Compute P(X_{i+1} | X_{i})
    Freq <- FreqN(Text, i, i + 1) # Frequency table of two letters
    Index <- sapply(names(Freq), asc) - 96 # Get the locations of each pair, so "ab" will be turned to the vector (1, 2)
    FrqMat <- matrix(0, nrow = 26, ncol = 26) # Let's turn the frequency table to a matrix
    FrqMat[t(Index)] <- Freq # Fill the matrix
    PrbMat[[i]] <- apply(FrqMat, 2, function(x) x / ifelse(rowSums(FrqMat) == 0, 1, rowSums(FrqMat)))} #Make sure we're not dividng by 0.
#  Model$PrbMat <- PrbMat
  return(PrbMat)}

#Prep m.text
Text <- TextRead("English_corpus.txt")
m.text <- HMMTrain(Text)
save(m.text, file="TEXT_Model_Champ.Rdata")

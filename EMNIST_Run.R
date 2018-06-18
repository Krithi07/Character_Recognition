# Analyze emnist dataset using tensorflow with neural networks in R 
library(R.utils)
library(keras)

rm(list=ls())
source("EMNIST_general_functions.R")


load(file='emnist_words.Rdata') # load test word data 

outfile <- '../Out/emnist-solutions.RData'
out_name <- 'GrayScale_EMNIST_Results'

# Go over all solutions in directory
solution_files <- list.files(pattern = "^[W]")
n_sol <- length(solution_files)
ID_vec <- myls <- vector("list", length = n_sol)

accuracy <- matrix(0, n_sol, 4)
for(i in 1:n_sol) # loop on solutions 
{
  source(solution_files[i])
  ID_vec[[i]] <- ID; rm(ID)
  team_name <- strsplit(strsplit(solution_files[i], '_')[[1]][3], '[.]')[[1]][1]
  load(file=paste('Text_Model_', team_name, '.RData', sep='')) # load m.text: text model 
  m.image <- load_model_hdf5(paste('EMNIST_Model_', team_name, '.h5', sep='')) # load m.image: image model 
  
  words$y_hat <- PredictModelWord(words$X, m.image, m.text)
  
  accuracy[i,] <- unlist(EvaluateModelWords(words$y, words$y_hat)) # compute accuracy at word and character level
}  

ID <- 203667464

#X is a matrix of size 28nx28L where n is the number of input samples and L is the length
#of words (for example, for 100 words of length 5, X will be of size 2800 x 140).

PredictModelWord <- function(X, m.image, m.text){
  input <- X 
  image_pix = 28
  word_len <- dim(X)[2] / image_pix
  word_cnt <- dim(X)[1] / image_pix
  image_model  <- m.image
  text_model <- matrix(unlist(m.text), ncol = 4, byrow = TRUE)
  
  # Reshaping the input matrix to (nxl, 784)
  
  trans_input <- matrix(0,word_cnt*word_len,image_pix*image_pix)
  
  for (i in 1:word_cnt) {
    a <- i*28
    g <- matrix(apply(t(input[(a-27):a,]), 1, rev),, image_pix*image_pix, byrow=T)
    
    for (j in 1:5) {
      k<-i*5
      trans_input[(k-5)+j,] <- g[j,]
    }
  }
  
  # predict probabilities using m.image model
  image_predictions <- predict_proba(image_model, trans_input)
  
  case_ins_predictions <- image_predictions[,11:36]+image_predictions[,37:62]
  
  # getting first letter in each word only by neural network probabilities
  y_hat_p <- numeric(word_cnt*word_len)
  
  for (i in 1:word_cnt) {
    i5 <- (i*word_len)-(word_len-1)   #ID index of first characters
    y_hat_p[i5] <- which.max(case_ins_predictions[i5,])   #Get maximum prob character 
  }
  
  # guessing the other letters in each word by neural network Weights and text analysis
  for (j in 1:(word_len-1)) {
    
    t<-c((word_len-1):1)
    for (i in 1:word_cnt) {
      
      a= i*5-t[j] #Index of the character used as prior
  
      r <- y_hat_p[a] #The character itself in numeric. e.g., 1 for a, 14 for n and 18 for s
      
      next_char_list <- r+26*(0:25) #Probability of all characters wrt. r as first character
      
      next_wrd<- a+1 #Next Character index

      y_hat_p[next_wrd] <- which.max(case_ins_predictions[next_wrd,]*(text_model[next_char_list,j]+0.17)) #Ensuring text_model's 0 prob doesn't affect prediction
      
    }
  }

  # Converting numbers to letters
  y_hat <-letters[y_hat_p]
  
  # Converting list of letters to words
  words_hat <-numeric(word_cnt)
  for (i in 1:word_cnt) {
    w <-  i*word_len
    letters  <- y_hat[(w-(word_len-1)):w]
    words_hat[i] <-paste(letters, collapse = '')
  }
  return(words_hat)
}

# Word Predictor from Handwritten English Text Images

This is an implementation of image to word predictor in R. 

There are 2 models created in order for us to reach to the goal. First will be word predictor which will take in an image and guess what is written in the image. The second will be text model which we will use to supplement the image model. This model with give the probability of next character based on the English vocabulary. Using both these models together will give us a great implementation of image to word predictor.

## Table of Contents -
[Data](#data)  
[Repository Files](#repository-files)  
[Code Execution](#code-execution)  
[Model Improvements](#model-improvements)  

## Data
The training and testing sets are both created using the letter images from EMNIST dataset. The EMNIST dataset contains 697; 932 labeled images of size 28 x 28 in the training set and 116; 323 labeled images in the test set. The images are represented in gray-scale,where each pixel value, from 0 to 255, represents its darkness level.There are multiple datasets in the file (see EMNIST documentation for explanations)

### Import data: 
Here's the dataset [link](https://www.nist.gov/itl/iad/image-group/emnist-dataset). Follow the steps below -
  1. 'Matlab format dataset'
  2. 'Matlab.zip' (unzip it) 
  3. Read it in R the first time using the 'R.matlab' library
  4. Save the dataset in R format (Rdata) after you load it

### Input data format 
X is a matrix of size 28n x 28L where n is the number of input samples and L is the length of words (for example, for 100 words of length 5, X will be of size 2800 x 140)

### Test Set 
'emnist words.Rdata'- The file contains example of 1000 words of length 5. The variable X contains the images of words, the variable y contains the true words (labels), and the variable y_hat contains predictions by a 2 layers neural network, combined with a 2-nd order Markov model. Example Image -

![image](https://user-images.githubusercontent.com/9217362/41533189-90cd51fe-7317-11e8-9bb0-79b121cf88dd.png)

## Repository files

1. **'Word_Predictor_Champ.R'** - This file contains a function PredictModelWord 
This function takes as input a 2D array X of word images, and learned model for images m:image, a learned text model m:text. The function returns a 1D array of string labels y, where each element of the array is a string of length L.

2. **'EMNIST_Model_Champ.h5'** - This file contains a variable called m:image. This variable represents the image model (including parameters) that we learned to represent the distribution of hand-written images for English text characters - We use a simple neural network learned using keras. The 'h5' format is used to save models learned using keras which are not saved correctly using R's 'save' command.

3. **'TEXT_Model_Champ.Rdata'** - with a variable called m:text. This variable represents a text model (including parameters) that we learned to represent natural English text distribution.

4. **'Code_image_text'** - This is the code for training the image and text models. The files mentioned on point 2 and 3 are created using this code. To imporve the model, this is the file you play with 

5. **'EMNIST_general_functions.R'** - This file has helper functions to allow accessing the EMNIST dataset

6. **'EMNIST_run.R'**- This is the code testing file

## Code Execution
Put all the files mentioned above in a directory of your choice, and run the 'EMNIST_run.R' file. This will give out the character accuracy and the word accuracy to evaluate the model

## Model Improvements
This is a basic model which gives ~95% accuracy at character level. Below are a few ideas you can try to improve this model:

1. Use a huge text corpus to improve upon the text model. You can use [Wikipedia](https://www.wikipedia.org) corpus to train a better text model. Or, use a pre-trained model from the web

2. Improve the MLP model by adding more hidden layers/hidden units. Or, use more sophisticated image models like CNNs

3. Generalize the model by editing the Code_image_text file. Currently, the code has some restrictions as mentioned below. By editing some hard-coded parts in this file, the model can be made more general purpose. 
  a. Only predicts on 28 x 28 pixel images from the EMNIST dataset
  b. Only predicts and gets trained on 5 letter words
EMNIST_general_functions file contains function that helps you create word images from the EMNIST dataset. This function can be used to create different training/testing sets eliminating the restrictions of 5 word length



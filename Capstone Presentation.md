Capstone Presentation
========================================================
author: Jacob Lowey
date: 11/7/2017
autosize: true

Introduction
========================================================
This [application](https://jelowey.shinyapps.io/Capstone/) was built for John Hopkins Data Science Capstone course. The application attempts to guess the next word to be typed based on the words already typed. 

Model Creation
========================================================
The basic idea was to use a Markov Chain model along with a smoothing algorithim to help predict the next word based on a sample of text already typed. Essentially, we would like to separate the sampled text into discrete chunks known as n-grams made up of one, two, three, etc. words and use the frequency of those to build a model of the language. The idea behind a Markov chain is that we don't necessarily need every single word typed before to build the sentence; we only need a little bit of information to make a decent prediction. 

There are many different smoothing algorithims, but the one that I chose to implement was the Kneser-Nay smoothing algorithim. The Kneser-Nay uses the concept of absolute discounting to "spread" the probability from higher frequency terms to the lower ones in a consistent manner to make sure they actually show up while predicting. 

Kneser-Nay
========================================================

The actual formula for this is:

$$ p_{kn}(w_n|w_{n-1}) = \frac{max(count(w_{n-1},w_{n})-d,0)}{\sum_{w'}count(w_{n-1},w')}+\lambda_{w_{n-1}}p_{kn}(w_n)$$

While this equation is a bit intimidating, essentially what it says is that the probability of any given ngram is the total count of that ngram, minus your chosen discounting factor, divided by the number of n-grams that start with the first part of your chosen n-gram, added to the probability that the word shows up in other ngrams discounted by another factor. The discounting can get a bit complex, but for the purposes of this presentation assume that you could find a decent discount factor through trial and error.

Application Guide
=======================================================
The application, found here: https://jelowey.shinyapps.io/Capstone/ is fairly simple to use. First, you must wait a moment for it to load. I've found this takes 10-20 seconds which is admittedly a bit slow to start. When the application has loaded, show "READY" below the input box. From there, you just type your phrase into the input box, and press submit and it will guess the next word. The process takes a little longer the longer the phrase you submit, but should not take longer than 4-5 seconds at absolute max. Submitting a couple of them can help the application "Warm up" so to speak and it will go a bit faster from there. 

Some constraints do exist; a very long phrase or multiple sentences can crash the application. In addition, if you leave a trailing space at the end, the program will interpret that as the only thing you are submitting, and try and guess the start of your sentence. 

Improvements
======================================================
<small>I will concede that the accuracy of the model built is not particularly accurate, and the front end implementation of it could use some improvement. Some things to work on or think about as far as improvement:

* A better discount factor. Modified Kneser-Nay, a slightly modified model I found late in the project, has a better discount factor and leads to more accurate predictions.

* Reviewing a larger sample size, or cleaning up the sample in a different way. Essentially, more practice with text mining would probably lead to a more accurate corpus. 

* More practice with Shiny apps and reactivity in particular. The front end and back end of the app I'm sure could be written more efficiently and pleasant for the user experience. 

* Compressing the vocabulary down. The predictor is not making any actual calculations "on the fly" in this app; it is using preloaded tables (hence the loading). There could be a more efficent way to do this.

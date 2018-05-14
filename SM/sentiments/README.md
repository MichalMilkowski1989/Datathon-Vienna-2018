# Sentiment Classification

Sentiment classification describes the process of extracting the general
sentiment as well as emotions of a text. For the datathon's social media
challenge, the sentiments in both tweets and YouTube comments were extracted,
using two approaches detailed below.

Using the identified sentiments, a descriptive analysis revealed strong
differences between countries (actually, tweet languages).

For the remainder of this document, the theoretical approach is described, the
script file's contents and the data requirements are presented.


# Approach

For the classification of the prevalent sentiments and emotions of a message two
approaches were pursued:

1. Sentiment classification based on emojis contained in a message
2. Emotion extraction based on a pre-trained deep learning recurrent neural
   network using Facebook reactions.

## Emoji sentiments

In social media, the use of emojis is widespread to quickly convey emotions that
otherwise would require extensive wording to formulate. Using a dataset compiled
from an extensive set of manually classified messages and emojis occuring
therein [^1], the probability of positive, neutral, and negative sentiment for
each message was discerned.

## Deep Learning emotions

Facebook introduced the possibility to react to a post not only with a like, but
with a set of five different emotions: wow, haha, sad, angry, and love. Using a
constructivist epistemiology, it is possible to link these reactions to the
emotions innate to a message. As described in [^2], it is possible to train
a deep learning network [^3], that allows to classify any text along the
relative probability of eliciting any of these emotions as a reaction. Using the
implementation in [^4], all tweets and youtube comments were classified in that
way.

## Files

The following R script files were created during the datathon, containing all
code pertaining to applying sentiment classification and emotion extraction:

* `classify-emotions-emoji.R`
* `classify-emotions-fb-rnn.R`

# Data

The data set used was the harvested Twitter data and YouTube comments.

All processing was done locally in R. Note, using the deep learning approach
requires a working TensorFlow/Keras installation (and Python of course).


# References

[^1]: <http://kt.ijs.si/data/Emoji_sentiment_ranking/index.htm>
[^2]: <http://minimaxir.com/2016/06/interactive-reactions/>
[^3]: Hochreiter, Sepp; Schmidhuber, Jürgen (1997). Long Short-Term Memory.
      Neural Computation. 9 (8): 1735--1780.
[^4]: <https://github.com/minimaxir/reactionrnn>

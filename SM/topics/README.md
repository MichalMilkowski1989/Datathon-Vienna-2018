# Topic Modelling

Topic modelling is used to identify topics in texts. For the SM challenge at the
datathon, modelling topics was restricted to the harvested tweets.
Unfortunately, tweets are quite short (140 characters, including URLS,
hashtags, and mentions), therefore offering any algorithm very little to go on.
Hence, the produced models proved rather inconclusive.

For the remainder of this document, the theoretical approach is described, the
script file's contents and the data requirements are presented. Finally, some 
pointers towards improvements and further research questions are provided.


# Approach

As all data science tasks, topic modelling requires first some data preparation
and then the application of an appropriate topic modelling algorithm. Data
preparation requires the normalization of text:

* Tokenization, that is the breaking up of text into individual words.
* Removal of stop words, that is words that occur frequently, but convey little
  meaning with respect to the identification of topics, e.g. `and`, `or`.
* For some languages words should be stemmed to remove e.g. pluralization,
  flectations, and similar modifications to word roots.

After data preparation, the actual topic modelling can take place. The algorithm
chosen is Latent Dirichlet allocation (LDA) [^1]. Apache Spark comes out of the
box with rudimentary tokenization [^2], stopword removal [^3] and LDA [^4]
implementations. More sophisticated natural language processing facilities are
available as extension packages [^5], but they were not available for the
programming languages used during the datathon (Python, R).


## Files

The following Jupyter notebook was created during the datathon. It contains all
code to retrieve the data from Hive and execute the data processing and topic
modelling steps outlined above.

* `topic-modelling.ipynb`

For an introduction on how to work with Jupyter notebooks, see e.g. [^6].

# Data

The data used for topic modelling is the translated tweets as stored in the Hive
database. In order to use the topic modelling script introduced above, the data
needs to be stored in a Hive database and processing needs to be done in Spark.


# Suggestions for Improvements and Further Research

Due to time constraints during the datathon, topic modelling did not progress
beyond initial exploration. This section describes pointers towards further
research.

## Improve topic identification

Due to length constraints, tweets provide very little information for the
information of topics. Hence, improvement of data preparation would be
paramount to increase the quality and usability of generated topics.

As mentioned above, Spark does not support stemming of words out of the box.
However, stemming would significantly improve the quality of the topic models.

## Linking with other data and features

Once topics have been reliably identified, a myriad of possibilities open up for
the identification of polarized debates:

### Sentiments

A key indicator for the polarization of a debate is the employed sentiments.
Research questions that would come to mind are:

* Which topics elicit which emotions?
* Are there any differences in sentiment in an original tweet and in the
  reactions to that tweet?

### Social network analysis

In order to aptly describe the polarization of a debate, the interaction network
of actors needs to be taken into consideration as well. This would allow
tackling the following research questions:

* Which topics lead to a large number of different actors to involve themselves
  in the debate?
* How do topics differ in terms of the shape of the network that is engaged?

### Temporal component

Topics in debates follow a pattern that is similar to e.g. fashion trends and
innovation cycles. Therefore, an interesting aspect inherent to debates is the
evolution of topics over time. This is also an aspect that can be linked to
news. Some suggestions for additional research questions:

* For which Twitter topics can classical innovation cycles be observed?
* Which topics are being led by classical media, which topics occur first on
  Twitter and are only later picked up by news media?

### NGO metadata

It stands to reason that NGOs differ in their discoursive strategies, based on
the type and composition of the NGO.

* Which topics are relevant for international NGOs, which topics are only
  picked up by NGOs with a local scope?
* Does the funding mix of an NGO influence the choice of topics they are
  engaging in?


# References

[^1]: Blei, David M.; Ng, Andrew Y.; Jordan, Michael I (2003). Latent Dirichlet
Allocation. Journal of Machine Learning Research. 3 (4--5): pp. 993--1022.
[^2]: <https://spark.apache.org/docs/2.0.1/ml-features.html#tokenizer>
[^3]: <https://spark.apache.org/docs/2.0.1/ml-features.html#stopwordsremover>
[^4]: <https://spark.apache.org/docs/2.0.1/ml-clustering.html#latent-dirichlet-allocation-lda>
[^5]: <http://nlp.johnsnowlabs.com/>
[^6]: <https://jupyter-notebook-beginner-guide.readthedocs.io/en/latest/>

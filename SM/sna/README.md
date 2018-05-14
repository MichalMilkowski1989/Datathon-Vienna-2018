# Social Network Analysis

Social Network Analysis was used to understand how actors in a debate interact,
and which type of actor engage how with an NGO. To this end, tweet mentioning
was used as the prime indicator.

From SNA, distinct clusters of media, politics and NGOs as well as their
interactions became apparent.

For the remainder of this document, the theoretical approach is described, the
script file's contents and the data requirements are presented. Finally, some
pointers towards improvements and further research questions are provided.


# Approach

The basis of SNA is a graph, that connects nodes (Twitter accounts) with
edges (mentions). The edges can have edge weights associated with them,
indicating the strength of the relationship. If relationships are not
necessarily reciprocal, there can be up to two edges connecting any two nodes,
reflecting the direction of the relationship.

In data preparation, the data must be transformed to allow for visualization and
analysis of the graph's properties. Data preparation was executed in Spark and
R; visualization took place in Gephi [^1].

The edges were constructed from mentions in tweets. The more often an account
mentioned another account, the higher the edge weight was. The direction of the
mentioning was captured as well, yielding a weighted, directed not
fully-connected graph.

Selfmentions were allowed, but disregarded in the analysis.

The nodes were described in terms of follower count and prevalent average
emotions.

## Files

The following R script file was created during the datathon, containing all code
pertaining to data transformations and enrichment:

* `sna.R`

# Data

The data set used was the harvested Twitter data. It was enriched with sentiment
data (see there) and the followers count of each account (which was retrieved)
live during the datathon.

Most processing was undertaken in local R sessions; however, the Spark interface
to Hive was used for some data aggregation.

# Suggestions for Improvements and Further Research

Due to time constraints during the Datathon, SNA efforts focused on data
preparation and exploratory analyses. A more systematic analysis could prove
fruitful. Pointers to further research questions would be:

* Can central actors be identified using classical SNA metrics like centrality
  and connectedness?
* Focus non-professional actors on single topics, or are they jacks of all
  trades?

# References

[^1]: <https://gephi.org/>

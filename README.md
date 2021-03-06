---
output:
  pdf_document: default
  html_document: default
---
# NETs-Fast
Repository for the paper: 

[Fast growing research on negative emissions](https://dx.doi.org/10.1088/1748-9326/aa5ee5)

Jan C Minx William F Lamb Max W Callaghan Lutz Bornmann Sabine Fuss
Environmental Research Letters vol. 12 issue 3 (2017) pp: 035007 https://dx.doi.org/10.1088/1748-9326/aa5ee5

To reproduce the results in the paper, follow these steps.

## Download data
- Enter the query in `input/queries/NETS_query_v7.txt` into the advanced
 search of Web of Science, and save the results to "Other file formats" 
 in a folder named `input/queries/NETS_query_v7`
 
## Run analysis
The scripts in `scripts/R` read the data and run the analysis and should be
run in the following order

- `project_setup.R` installs all necessary packages (in the versions current at
 the time of writing this paper) - This may take some time...
- `topic_model.R` reads the abstracts, runs a topic model and saves the results in 
 `output/LDA_19_098`
- The file `output/LDA_19_098/index.html` is a mini-site which allows you to explore
 the topics. The online version in this repository is [here](https://mcc-apsis.github.io/NETs-Fast/output/LDA_19_098)
 This is used to inform the topic naming - to do this, add an extra column
 in `output/LDA_19_098/LDA_19_098_topic_terms.csv` and name the topics in this column
- `post_topic_model` reads the new topic names, and calculates correlation networks
 in `output/LDA_19_098/LDA_19_098_topic_correlations.graphml` and
 `output/LDA_19_098/LDA_19_098_document_correlations.graphml`. The topic correlations
 file was imported into gephi for aesthetic work to produce the final figure in the paper
- `figures.R` produces Figure 2 in the paper
- `growth.R` produces a table of growth by discipline in `discipline_growth.csv`
- `search.R` searches the corpus for mentions of Integrated Assessment Models (IAMs)

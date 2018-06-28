# arcticfunding

### 1) a table of the number of data sets in the Arctic Data Center (only count one version for each data set) for each NSF award number?  

```
summary <- readr::read_csv("funding_summary.csv")
```
![](images/summary_full.png)

```
summary_simple <- readr::read_csv("funding_summary_simple.csv")
```
![](images/summary_simple.png)

### 2) a graph showing number of NSF awards represented in the ADC over time?

Using the `pubDate` field in the EML:

![](images/awards_over_time.png)

Using the `dateUploaded` field associated with the EML file: 

![](images/awards_dateUploaded.png)
# Wearable-Health-Insights
This repository documents an ongoing learning and research project in wearable health data analysis.

The project focuses on applying statistical methods and data-processing techniques to wearable health measurements, with an emphasis on understanding how variables are measured, derived, and interpreted.

## Project Overview
The project is organized into two analytical components:
- **Part I: Exploratory Analysis of Activity and Energy Expenditure** [Completed]
- **Part II: Analysis of Sleep Characteristics and Heart Rate Responses Using Wearable Data** [Ongoing]

## About the Data
This project utilizes the **Fitabase dataset**, which contains wearable device measurements collected from Fitbit users at different temporal resolutions, including hourly, minute-level, and 5-second-level records.

* Data Source: [Kaggle: FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit)
* Device: Fitbit wearable devices

## **Part I: Exploratory Analysis of Activity and Energy Expenditure**
Status: Completed

**Purpose**<br>
To explore Fitbit-derived activity data and practice statistical analysis.

**Analyses**<br>
* Hourly patterns of physical activity and calorie expenditure
* Relationship between step count, activity intensity, and estimated calorie expenditure
* Simple and multiple linear regression

**Interpretation**<br>
The analysis identified a positive association between activity measures and Fitbit-estimated calorie expenditure. For example, the simple linear regression between hourly step count and calorie expenditure produced an adjusted R^2 of approximately 0.664.

However, this result should be interpreted cautiously.

Fitbit calorie expenditure is a **device-derived estimate**, and activity-related information is part of the underlying measurement context. Therefore, the observed association between activity measures and estimated calorie expenditure should not be interpreted as an independent validation or prediction of energy expenditure.

**What I Learned**<br>
This analysis led me to recognize that statistical modeling should not begin with simply identifying a strong association in the data.

Understanding **how a variable is measured or generated**, what information contributes to that measurement, and whether the research question is scientifically meaningful are equally important when interpreting statistical results.

This consideration motivated the subsequent analysis of sleep characteristics and heart rate responses, which focuses more directly on deriving meaningful physiological features from wearable data.


## **Part II: Analysis of Sleep Characteristics and Heart Rate Responses Using Wearable Data**
Status: Ongoing

**Research Focus**<br>
To derive sleep-related characteristics and heart rate features from wearable device data and explore their relationships.

The analysis uses:
* Minute-level sleep records
* 5-second-level heart rate records

Sleep records are processed to identify individual sleep sessions and derive sleep-related characteristics, including:
* Total time in bed
* Total sleep time
* Sleep latency
* Awake/restless events
* Main Sleep vs. nap

Continuous sleep-state periods are converted into time intervals to allow temporal alignment with heart rate measurements.

Heart rate measurements are then aligned with sleep periods and sleep-related events to derive features including:
* Average heart rate during sleep
* Minimum and maximum heart rate during sleep
* Morning resting heart rate
* Heart rate around awakening
* Average heart rate during awake and restless periods

**Next Steps**<br>
Focus on exploratory statistical analysis of the derived features and evaluate appropriate methods for examining the relationships.


## Tech Stack
* **Programming Language:** R 
* **Data Manipulation & Visualization:** tidyverse, ggplot2, lubridate 

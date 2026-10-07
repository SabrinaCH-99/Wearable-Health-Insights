# Wearable-Health-Insights
This repository documents an ongoing learning and research project in wearable health data analysis.

Statistical analysis of wearable device using Fitbit data from the Fitabase dataset.

The project is organized into two analytical components:
- **Part I: Exploratory Analysis of Activity and Energy Expenditure** [Completed]
- **Part II: Analysis of Sleep Characteristics and Heart Rate Responses Using Wearable Data** [Ongoing]

## About the Data
This project utilizes the **Fitabase dataset**, which consists of minute-level, hourly, and daily physiological records collected from Fitbit users.

* Data Source: [Kaggle: FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit)

## Part I: Energy Expenditure Estimation
Status: Completed

**Purpose**
This analysis was conducted as an exploratory exercise to understand and structure of Fitbit-derived activity data and practice statistical data analysis using wearable device measurements.

The analysis examined:
* Hourly patterns of physical activity
* The relationship between step count and device-estimated calorie expenditure
* The relationship between activity intensity and device-estimated calorie expenditure

**Interpretation**
The analysis identified a positive association between activity measures and Fitbit-estimated calorie expenditure. For example, the simple linear regression between hourly step count and calorie expenditure produced an adjusted R^2 of approximately 0.664.

However, this result should be interpreted cautiously.

Fitbit calorie expenditure is a **device-derived estimate**, and activity-related information is part of the underlying measurement context. Therefore, the observed association between activity measures and estimated calorie expenditure should not be interpreted as an independent validation or prediction of energy expenditure.

**What I Learned**



## Part II: Analysis of Sleep Characteristics and Heart Rate Responses Using Wearable Data
Status: Ongoing

**Research Focus**

## Tech Stack
* **Programming Language:** R 
* **Data Manipulation & Visualization:** tidyverse, ggplot2, lubridate 

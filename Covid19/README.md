## Project Background
The Coronavirus disease 2019 (COVID-19) pandemic has had a profound global impact, both economically and socially, affecting millions of lives worldwide. The dataset used in this project was collected by the [World Health Organization](https://ourworldindata.org/covid-deaths). Data from 31 December 2019 to 21 March 2020 was sourced through official communications under the International Health Regulations (IHR, 2005), supplement by verified reports from ministries of health and their official social media accounts. Begining 22 March 2020, the dataset was compiled through WHO region-specific dashboards and direct country reporting mechanism. 

This project involved cleaning, processing, and analyzing the raw data to provide a comprehensive overview of the pandemic's impact across regions. The main objective is to understing the magnitude of COVID-19's effect on human lives and identify which continents and countries were most affected. Through exploratory data analysis, this project seeks to uncover disparities in pandemic response and offer insights into the relative healthcare capacity of different regions.

The interactive dashboard can be downloaded [here](https://public.tableau.com/app/profile/anh.ng5326/viz/Book2_17563327591560/Dashboard3).

The Python scripts used for initial data inspection and preparing data can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Covid19/covid19_InitialCheck.ipynb).

The SQL queries utilized for data loading can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Covid19/covid19_Loading.sql).

Target SQL queries exploring key insights can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Covid19/covid19_EDA.sql).

## Data Structure Overview
The COVID-19 dataset comprises 61 columns and 530,291 records. Each record represents a unique country-date observation, allowing for detailed temporal and geographical analysis of key COVID-19 metrics. For the purpose of this analysis, the focus was narrowed to asubset of 13 relevant columns that provide an essential information for understanding infection trends, confirmed deaths and vaccination progress across regions. 

![Dashboard](https://github.com/hna778/SQL-Porfoio/blob/main/Covid19/covid19_Visualization.png)

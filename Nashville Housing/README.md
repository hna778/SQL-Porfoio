## Nashville Housing Market (2013-2019)

### Project Background

This report presents comprehensive analysis of real estate transactions across Tennesee, with a particular focus on the dynamic housing market of Nashville. The primary goal of this analysis is to understand the distribution of property prices and uncover the market trends that reflect inventory levels, pricing dynamics, and the impact of property charateristics, from there the report can extract insights and deliver recommendations to improve performance across sales, product, and marketing teams.

### Executive Summary

The [dataset](https://www.kaggle.com/datasets/swsw1717/nashville-housing-sql-project?select=Nashville+Housing.csv.) covers 56K property transactions recorded between Jan 02, 2013 and Dec 13, 2019, capturing a period of significant growth and market activity in the region. During this period, the annual sale values keep increase ..%, in which Nashville contributes .. %. Among property types in Nashville, Residential Condo and Single Family account for ... % of sale transactions. Based on the number of transactions throughout the course of 7 years, active inventory jumps ..% compared to previous years and vacant homes also increases. On the other hand, the home selling activity shows the slow down in the recent years. 

### Insights Deep-Dive

The primary goal of this analysis is to understand the distribution of property prices and uncover the market trends that reflect inventory levels, pricing dynamics, and the impact of property charateristics. Specifically, the study investigates: 
- Examine the distribution of property prices across different regions and property types.
- Identify market trends reflecting housing inventory dynamics, including the proportion of vacant property sales.
- Assess whether home prices exhibited upward trends over the study period.
- Evaluate how property characteristics, such as square footage and year built, influence sale prices.

The SQL queries utilized to load and organize the data can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Nashville%20Housing/housing_Loading.sql).

The SQL queries utilized to clean, perform quality checks, and prepare data can be found [here](https://github.com/hna778/SQL-Porfoio/tree/main/Nashville%20Housing).

Target SQL queries exploring key insights can be found here.


## Data Structure Overview
The dataset consits of 19 columns and 56,310 records of transaction detail of each property in Nashville, TN such as UniqueID, ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant, OwnerName, OwnerAddress, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath

https://www.kaggle.com/code/lucyallan/sql-nashville-housing

https://www.kaggle.com/code/pablozanotti/nashville-housing-data-cleaning-in-sql

## Tech Layoffs in the U.S. (Mar 11, 2020 - Sep 16, 2025)

### Project Background

Layoffs have become a major topic of discussion worldwide, driven by economic uncertainty and the rapid adoption of artificial intelligence.  The main goal is to understand the post COVID-19 labor market and identify which industries and companies have been most affected. Through exploratory data analysis, this project aims to highlight the patterns behind the U.S. workforce reductions and provide a data-driven view of how the tech landscape continues to evolve.

### Executive Summary

The [dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022) consolidates publicly available data on workforce reductions across the global tech sector.  The dataset includes 2,8282 records spanning from **March 11, 2020** - the date COVID-19 was officially declared a pandemic - **up to the present**. Since 2022, the technology industry has experienced significant restructuring, with 529,635 employees laid off in the US. Layoffs surged in 2023, reaching their peak with 178,745 reported job cuts, following 108,546 in 2022. The San Francisco Bay Area (Silicon Valley) absorbed the greatest impact, accounting for 45.42% of total U.S. layoffs, followed by Seattle at 13.67%. By industry, hardware technology led the reductions with 15.85%, trailed by the consumer sector at 12.24%.

While the pace of layoffs has begun to ease, the effects remain widespread across nearly all segments of the tech ecosystem as companies continue to adjust to shifting market conditions and economic uncertainty.


### Insights Deep-Dives
#### Layoffs Trends
- 2023 recorded the highest layoffs, with ~178K employees affected across U.S. companies.
- Layoffs began in 2020 during the COVID-19 outbreak, but dropped sharply by 80% in 2021 as companies ramped up hiring to support the surge in remote work, digital services, and online commerce.
- A second major wave occurred between Sep 2022 – Mar 2023, driven by post-pandemic restructuring and economic adjustments.
- After 2023, layoff volumes declined steadily through 2024–2025, signaling a period of market correction and operational balance.

#### Impacted Industries and Companies
- When the Covid-19 announced in 2020, layoffs surged in Transportation and Retail sectors as lockdowns and social distancing halted mobility and in-person commerce.
- In 2021, The Real Estate and Construction industries were hit hardest due to a slowdown in new projects and reduced housing demand.
- During 2022-2023: After rapid digital growth during the pandemic, the market correction led to mass layoffs at major firms like Meta and Amazon in late 2022 through early 2023, primarily within Consumer and Retail industries.
- In 2024-2025, as the AI revolution gained traction and the economy unstabilized, demand for tech hiring slowed. This shift resulted in large-scale layoffs in Hardware and Transportation sectors — especially at Intel, Tesla, and Cisco.
- In the first 9 months of 2025, Intel, Microsoft, and Salesforce led the hardware-related layoffs, concentrated in Silicon Valley, Seattle, and Sacramento.
- Over the five years following the pandemic, Hardware and Consumer industries accounted for the majority of layoffs, dominated by tech giants headquartered in the SF Bay Area and Seattle.
<img width="1319" height="769" alt="Layoffs Dashboard" src="https://github.com/user-attachments/assets/af46a5c8-29d3-4148-bc31-fc9a95987541" />


### Recommendation
- AI and hardware hiring trend should be closely observed as automation and chip demand will continue to reshape tech role,
- Upskilled in AI, data and cloud fields will help to mitigate the layoff vulnerability.
- Post-2025 scenarios should consider that rapid AI expansion may continue to suppress traditional tech hiring through automation, while lower interest rates could stimulate renewed investment and rehiring as technology spending rebounds..

### Clarifying Questions, Assumptions, and Caveats
- There might be missing data from private sectors or undisclosed cases.
- The dataset include both SF Bay Area which usually includes San Jose.
- Some companies have multiple industries, the dataset could include their primary segment.
- The tech layoffs does not influenced only by the AI booming but other factors such as interest rates, supply chain, inflation.

#

The SQL queries utilized to load and organize the data can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Layoffs/layoffs_Loading.sql).

The SQL queries utilized to clean, perform quality checks, and prepare data can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Layoffs/layoffs_DataCleaning.sql).

Target SQL queries exploring key insights can be found [here](https://github.com/hna778/SQL-Porfoio/blob/main/Layoffs/layofss_targetQuestions.sql).

Tableau Dashboard can be found [here](https://public.tableau.com/views/Book2_17615238901260/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

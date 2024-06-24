# Driver Data Telematics
## **Overview**
The task is to analyse the "Driver Telematics" sample dataset containing aggregated data for 335 drivers and some of their personal, policy and driving details.
The aim is to uncover meaningful insights from the provided dataset, with a focus on relationships relevant to the insurance industry. Key areas of investigation include:
1. Distribution of driving scores
2. Trends in tracked mileage over time
3. Average premium patterns
4. Correlations between driver characteristics (e.g., gender, age) and driving scores

The analysis will explore these aspects to identify patterns and relationships that could inform insurance-related decision-making processes.

### **Dataset Overview**
This dataset included information related to driver telematics which gives information about premium charged on a driver based on all the telematics around driver. This data contains aggregated information of 335 drivers along with their personal information in addition to the type of car they drive, distances travelled, driving score, speeding events, and risk events.

Information Related to each column:
1. **Policy Number**: Unique policy identification number related to each individual driver
2. **Inception Date**: Starting date of a policy
3. **Months since Inception**: Number of months since the policy has started.
4. **Gender**: Gender information for each driver
5. **Age**: Age information for each driver
6. **Vehicle**: Type of Vehicle each driver drives
7. **Postcode**: Postal address of each driver
8. **Premium Charged**: Amount charged for each policy
9. **Distance**: Total distance travelled by each individual driver
10. **Journeys**: Total number of trips a driver has made
11. **Overall Risk %**: Overall driving risk associated with a driver
12. **High Risk Event**: Number of high risking event a driver has been in
13. **High Risk Event%**: Percentage of high risk event a driver has been in
14. **Medium Risk Event**: Number of medium risking event a driver has been in
15. **Medium Risk Event%**: Percentage of medium risk event a driver has been in
16. **Speeding Events**: Number of speeding events a driver has been in
17. **Speeding Events per Mile**: Number of speeding events per mile a driver has being in
18. **Driver Score**: Overall driver score associated with each driver

## Data Preparation

1. The data was loaded from the CSV file 'driver_stats_sample.csv' using pandas.
2. The *Inception Date* column was converted from 'object' to 'datetime' format.
3. *Overall Risk %*, *High Risk event %*, and *Medium Risk Event %* columns were converted to numeric, removing the % symbol from the data
4. *Distance*, *Journeys* and *Speeding Events* columns were converted to numeric, removing commas from the values.

### Basic Statistics
The analysis was started by generating basic descriptive statistics for the dataset using *df.describe()*. This provided an overview of the central tendencies, dispersions, and shapes of the dataset's distributions.

## Data Analysis
### 1. Distribution Analysis
#### 1.1 Driver Score Distribution
A histogram was created to visualise the distribution of driver scores:
1. The scores range from approximately 62 to 100.
2. The distribution appears to be left-skewed, with a majority of scores clustered towards the higher end.
3. This indicates that most drivers in the sample exhibit relatively safe driving behaviors.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/9eeb8cb0-2de0-409c-9b81-811ed78df196)


#### 1.2 Premium Charged Distribution
A histogram was created to visualise the distributiion of premium charged to the drivers:
1. The premium range from 0 to more than 4000.
2. The dsitribution appers to be bell-shaped, with majority of premiums lying in the range of 1000-3000.
3. A point to note that a major part of the premiums are seen as '0' which could indicate that there are special promotions involved or issue with the data entry.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/8d13aab0-3c38-4d09-b063-65d0a42a6869)


#### 1.3 Distance and Journey Distribution
A histogram was created to visualise the distribution of Distance, Journeys and Average Distance per journeys:
1. Majority of distance travelled by the driver appears to be not more than 4000 miles with a right-skewed histogram
2. Majority of journeys taken appears to be below 1000.
3. The Average distance per journey histogram indicates a right-skewed bell shaped curve, which entails nature of trips.
This can help build a comprehensive picture of driving behaviour.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/af10776a-4092-4ca1-b782-b75fe68352cd)


### 2. Relationship Analysis and Correlations
#### 2.1 Age vs Driver Score
A line plot and box plot was used to examine the relationship between age and driver score:
1. There is a slight positive correlation between age and driver score.
2. Younger drivers (17-21) tend to start with a better driving scores, in the range of 80s and 90s.
3. Older drivers (20-21) show a wider range of scores, from very low (62.36) to very high (98.35), generally getting lower.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/deb2816f-f362-4348-9706-5b8c589e7e4f)


#### 2.2 Months Since Inception 
A line plot and box plot was used to examine the relationship between months since inception of the policy and driver score:
There appears to be a less to no correlation between the driver score and months since the policy has started, which does not make it a determinant factor.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/f4ca8d6d-72a6-4fec-afbe-25773caf73f8)

#### 2.3 Gender vs Driver Score
A histogram and box plot was created to compare driver scores between genders:
1. Female drivers show a slightly higher median score compared to male drivers.
2. Male drivers exhibit a wider range of scores, including some of the lowest scores in the dataset.
3. The difference is not dramatic, however can suggest gender being a factor in risk assessment..
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/c1922b83-e77b-4d60-a560-f1774841a26c)

#### 2.4 Vehicle Type vs Driver Score
A box plot was used to visualize the relationship between vehicle type and driver score:
1. Luxury and high-performance vehicles (e.g., BMW, Land Rover) tend to have lower median scores and wider score ranges.
2. More common vehicles (e.g., Ford, Renault, VW) generally show higher median scores and narrower ranges.
3. This suggests a potential correlation between vehicle type and driving behavior.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/42fe2338-2fe2-4dce-ba42-da00776c1724)

#### 2.5 Vehicle Type and Premium Charged
Vehicle type doesn't seem to correlate with premium charged:
1. Luxury and high performance cars are charged less than some common cars but have a wider range compared to others.
2. Even the premium ranges differently for every car type.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/4261c3ea-0a60-4e73-a9b4-820826cba2a3)

#### 2.6 Age vs Premium
A scatter plot was created to examine the relationship between age and premium:
1. The premiums charged are spread out for each age group, with some clustering at specific premium amounts (like around 2000 and 3000).
2. Younger drivers (17-19) are generally charged higher premiums.
3. Premiums tend to decrease as age increases, with some exceptions.
However, the data suggests discrete premium categories rather than a continuous relationship.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/49b0c7b8-a3a4-4355-b50b-8d50a1971688)

#### 2.7 Premium Charged and Driver Score
1. There are a significant number of data points where the premium charged is zero, despite varying driving scores. Beyond zero, the premiums range widely up to around 4000, while driving scores tend to be higher (mostly above 85).
2. The data shows a weak to no clear linear correlation between the premium charged and driving score. The cluster at zero premiums suggests a potential outlier or different category.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/567896a1-dda4-4d12-ab28-ca15fdf4cb31)

#### 2.8 Distance Travellled and Driving Score
1. Driver scores are generally high (mostly above 85) regardless of the distance traveled. Most of the distances are clustered below 2000.
2. There appears to be a weak negative correlation, where higher driver scores correspond slightly to shorter distances traveled, but overall, the correlation is not strong.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/ab80738f-e46b-4a4d-9477-270e25e745e9)

#### 2.9 Risk Events
1. High-risk events are relatively rare, with many drivers having 0-5 such events.
2. Medium-risk events are more common but still relatively low for most drivers.
3. There's a clear correlation between the number of risk events and lower driver scores.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/61a9ba3b-914b-4c23-8997-e79dbd1bf9b4)

#### 2.10 Speeding Events
Speeding events per mile show a strong inverse correlation with driver scores. Drivers with higher rates of speeding events tend to have lower overall scores.
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/b254b223-0f3e-4a06-88fc-0b3dbbe2a35c)

#### 2.11 Correlation Heat Map
![image](https://github.com/nikitgoku/allianz_data_assesment/assets/114753615/04df8231-45f4-41a8-ad6b-40deb4b35756)
A correlation heatmap was generated to visualize the relationships between key numeric variables:
1. Age shows a moderate positive correlation with premium charged and a negative correlation with driver score.
2. Total risk events and speeding events per mile show strong negative correlations with driver score.
3. This heatmap provides a quick overview of the most significant relationships in the dataset.

## Conclusion and Recommendations
Recommendations for Insurers
1. **Age-based pricing**: Continue to charge higher premiums for younger drivers, but consider individual driving scores for more personalized pricing.
2. **Vehicle-based risk assessment**: Pay special attention to drivers of luxury and high-performance vehicles, as they tend to have lower scores.
3. **Gender considerations**: While gender differences exist, they should be considered alongside other factors for fair pricing.
4. **Reward good behavior**: Implement a system to reward drivers with consistently high scores and low risk events.
5. **Speeding focus**: Develop targeted interventions or incentives to reduce speeding, as it strongly correlates with overall risk.
6. **Personalized pricing**: Use the driver score as a key factor in determining premiums, as it appears to be a good proxy for claim likelihood.
7. **Monitor high-risk drivers**: Implement additional monitoring or interventions for drivers with scores below a certain threshold (e.g., 85).

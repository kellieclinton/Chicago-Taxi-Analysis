# Analyzing Operational Factors and Tipping Etiquette in Chicago Taxi Trips

An empirical statistical analysis exploring the predictability of taxi fares using multiple linear regression and verifying real-world tipping behaviors against common US customs with student's t-tests. 

---

## 📌 Project Overview
Using a data footprint provided by Chicago’s Department of Business Affairs and Consumer Protection, this project analyzes operational benchmarks across **3,343 unique ride observations** from the first quarter of 2019. 

The investigation splits into two analytical paths:
1. **Fare Predictability:** Modeling pricing dynamics based on distance, ride duration, and speed while controlling for mathematical multicollinearity.
2. **Tipping Behaviors:** Validating if corporate/rider credit transaction tips follow the standard US 15% tipping norm and checking if behavioral trends drift between weekdays and weekends.

---

## 🛠️ Data Attributes & Transformations
The underlying data tracking engine aggregates the following core attributes:
* `date`: Calendar baseline tracking weekly ride distribution.
* `daytype`: Dichotomous tracking separating `weekday` from `weekend`.
* `fare` / `totalAmount`: Pricing indices measured in USD ($).
* `distance`: Travel lengths recorded in miles.
* `duration`: Trip durations recorded in seconds.
* `speed`: Calculated travel velocity in mph ($speed = \frac{distance}{duration}$).
* `tipPercent`: Standardized target feature ($\frac{tip}{fare + tip}$) isolated solely to customers with explicit digital records (credit transactions).

### Data Engineering Steps
Because physical parameters like distance and time are heavily right-skewed, the variables were adjusted using a natural log transformation ($ln$) to satisfy linearity, homoscedasticity, and normal distribution residual profiles. 

---

## 📈 Methodology & Models

### 1. Multiple Linear Regression (OLS)
Initial structural testing mapped price dynamics via an additive model:
$$\widehat{fare} = 7.62 + 3.03(Distance) + 0.00082(Duration) - 0.22(Speed)$$
* **Variance Explained:** Adjusted $R^2 = 86.34\%$.
* **Diagnostic Failure:** This baseline setup violated key constant variance and Q-Q distribution parameters, prompting the need for variable transformations.

### 2. Transformed Ridge Regression Model (Final Model)
Log-transformations introduced severe parameter inflation ($VIF > 25,000$). To counteract this, a Ridge Regression configuration was trained across various parameters ($k = 0$ to $0.005$). 

An optimal shrinkage parameter of **$\lambda = 0.002$** was chosen, lowering Variance Inflation Factors safely below $5.0$ and yielding a stable model:
$$\widehat{ln(fare)} = -0.6542 + 0.30 \cdot ln(Distance) + 0.49 \cdot ln(Duration) - 0.06 \cdot ln(Speed)$$

### 3. Student's T-Test Profiles
* **One-Sample Test ($H_0: \mu = 15\%$):** Evaluated recorded tips against typical US hospitality expectations.
* **Two-Sample Pooled Variance Test:** Evaluated mean tip percentage variance across structural operational calendars (`weekday` vs `weekend`).

---

## 📊 Key Findings & Conclusions
* **Fare Stabilization:** Trip length and duration are the principal anchors of Chicago cab fare predictability. A $1\%$ increase in distance yields a $\sim0.30\%$ pricing lift, while a $1\%$ duration increase yields a $\sim0.49\%$ gain. 
* **Tipping Anomaly:** The empirical average tipping index sits at **$15.98\%$** ($\sigma = 4.24\%$). A t-value of $9.3$ ($p < 0.0001$) systematically rejects standard $15\%$ etiquette, showing that riders tip significantly higher on digital payment transactions.
* **Calendar Consistency:** Tipping behavior stays stable across the weekly calendar ($p = 0.6918$). No significant behavioral distinction exists between weekday operations and weekend taxi rides.

---

## 💻 SAS Implementation
The analytics engine driving this repository is written in **SAS (Statistical Analysis System)**. The automation codebase includes routines covering:
```sas
PROC REG DATA=taxi; /* Baseline & Ridge diagnostics */
PROC UNIVARIATE DATA=taxi; /* Structural curve evaluation */
PROC TTEST DATA=taxi H0=0.15; /* Etiquette hypothesis tracking */
```
*To inspect the exact runtime pipelines or baseline parameter estimates, review the compilation files inside the repository.*

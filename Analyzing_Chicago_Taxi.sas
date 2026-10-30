/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* STAT 403: Final Project Analyzing Chicago Taxi                        */
/* Coded by: Ammar Al-Zuhairi and Kellie Clinton                         */
/* Group Name: The Last Semicolon                                        */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* --------------------------------------------------------------------- */
/* Loading The Data                                                      */
/* --------------------------------------------------------------------- */
data taxi;
	infile "/home/u64426032/Project/Data/chicago_taxi.csv" dlm="," firstobs=2;
	input date DDMMYY10. daytype $ duration distance tip fare payment_type $ speed;
	format tip dollar8.2 fare dollar8.2 distance 5.2 speed 5.2 date DDMMYY10.;
run;

/* --------------------------------------------------------------------- */
/* Modifing The Data                                                     */
/* --------------------------------------------------------------------- */
data taxi;
	set taxi;
	where '01JAN2019'd <=date <='31MAR2019'd;
	totalAmount=fare + tip;
	format totalAmount dollar8.2;

	if tip > 0 then
		tipped="Yes";
	else
		tipped="No";
	tipPercent=tip / totalAmount;
run;

/* --------------------------------------------------------------------- */
/* Fitting a Multiple Linear Regression.                                  */
/* --------------------------------------------------------------------- */
/* Figure 1 & 2.                                                          */
/* --------------------------------------------------------------------- */
proc reg data=taxi;
model fare = distance duration speed / vif;
run;

/* --------------------------------------------------------------------- */
/* Checking variables distruption.                                        */
/* --------------------------------------------------------------------- */
/* Figure 3.                                                             */
/* --------------------------------------------------------------------- */
PROC UNIVARIATE DATA=taxi noprint;
   VAR fare distance duration speed;
   HISTOGRAM fare distance duration speed / NORMAL;
RUN;

/* --------------------------------------------------------------------- */
/* Creating new log transformed variables.                               */
/* --------------------------------------------------------------------- */
data taxi;
set taxi;
lnFare = log(fare);
lnDistance = log(distance);
lnDuration = log(duration);
lnSpeed = log(speed);
run;

/* --------------------------------------------------------------------- */
/* Fitting a Multiple Linear Regression With log transformed varibles    */
/* --------------------------------------------------------------------- */
/* Figure 4.                                                             */
/* --------------------------------------------------------------------- */
proc reg data=taxi;
model lnFare = lnDistance lnDuration lnSpeed  / vif;
run;

/* --------------------------------------------------------------------- */
/* Selecting best Lambda for Ridge                                       */
/* --------------------------------------------------------------------- */
/* Figure 5.                                                             */
/* --------------------------------------------------------------------- */
proc reg data=taxi
	outvif 
	plots=ridge(unpack)
	outest=taxi2
	ridge = 0 to 0.005 by 0.001;
model lnFare = lnDistance lnDuration lnSpeed / vif;
run;

proc print data=taxi2;
run;

/* --------------------------------------------------------------------- */
/* Fitting Ridge Model                                                   */
/* --------------------------------------------------------------------- */
/* Figure 6 & 7.                                                         */
/* --------------------------------------------------------------------- */
proc reg data=taxi
	outest=taxi3;
model lnFare = lnDistance lnDuration lnSpeed /ridge = 0.002 outseb cli;
run;

proc print data=taxi3;
run;

/* --------------------------------------------------------------------- */
/* Distribution of Tip Percentage Across Tipping customers               */
/* --------------------------------------------------------------------- */
/* Figure 8.                                                             */
/* --------------------------------------------------------------------- */
proc univariate data=taxi noprint;
 	where tipped="Yes";
 	var tipPercent;
 	histogram tipPercent / vscale=count vaxislabel="Ride Count" midpoints=0 to .35  
      	by .05 normal;
 	Inset mean="Average" std="St. Deviation" /position=NE;
 	title "Distribution of Tip Percentage Across Tipping customers";
run;

/* --------------------------------------------------------------------- */
/* Running a TTest for the tip percent                                   */
/* --------------------------------------------------------------------- */
/* Figure 9.                                                             */
/* --------------------------------------------------------------------- */
proc ttest data=taxi h0=0.15;
where tipped = "Yes";
var tipPercent;
Run;

/* --------------------------------------------------------------------- */
/* Running a TTest for the tip percent With day type class               */
/* --------------------------------------------------------------------- */
/* Figure 10.                                                             */
/* --------------------------------------------------------------------- */
proc ttest data=taxi;
where tipped = "Yes";
class daytype;
var tipPercent;
Run;


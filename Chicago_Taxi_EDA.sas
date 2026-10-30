/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* STAT 403: Chicago Taxi Explantory Data Analysis                       */
/* Coded by: Ammar Al-Zuhairi and Kellie Clinton                         */
/* Group Name: The Last Semicolon                                        */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* --------------------------------------------------------------------- */
/* 						   Reading Dataset file                          */
/* --------------------------------------------------------------------- */
data taxi;
	infile "/home/u64426032/Project/Data/chicago_taxi.csv" dlm="," firstobs=2;
	input date DDMMYY10. daytype $ duration distance tip fare payment_type $ speed;
	format tip dollar8.2 fare dollar8.2 distance 5.2 speed 5.2 date DDMMYY10.;
run;

/* --------------------------------------------------------------------- */
/* 						     Modifing The Data                           */
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

proc contents data=taxi;
run;

proc print data=taxi;
run;

/* --------------------------------------------------------------------- */
/* 						Date and weekday vs weekend                      */
/* --------------------------------------------------------------------- */
proc freq data=taxi;
	tables daytype / out=daytype_counts;
	title "Frequency Table of The Number of Trips By Day Type";
run;

proc univariate data=taxi noprint;
	var date;
	histogram date / vscale=count midpoints='01JAN2019'd to '31MAR2019'd by 7 
		normal;
	title "Weekly Trip Volume Distribution";
run;

proc univariate data=taxi noprint;
	class daytype;
	var date;
	histogram date / vscale=count midpoints='01JAN2019'd to '31MAR2019'd by 7 
		normal;
	title "Weekly Trip Volume Distribution By Day Type";
run;

/* --------------------------------------------------------------------- */
/*            Distance vs speed - correlation and scatterplot            */
/* --------------------------------------------------------------------- */
proc corr data=work.taxi plots(maxpoints=none)=matrix;
	var fare distance duration tip;
	title "Correlation Matrix: Fare, Distance, Duration, and Tip";
run;

proc sgplot data=taxi;
	scatter x=distance y=totalAmount / group=daytype 
		markerattrs=(symbol=circlefilled size=4) transparency=0.3;
	title "Total Amount vs. Trip Distance by Day Type";
	xaxis label="distance" max=40;
	yaxis label="Total Amount" valuesformat=dollar8.2 max=150;
run;

/* --------------------------------------------------------------------- */
/*                      Tip Count & Distribution                         */
/* --------------------------------------------------------------------- */
proc freq data=taxi;
	tables tipped*payment_type;
	title "Tipping Status by Payment Type";
run;

proc means data=taxi;
	class payment_type;
	var tip;
	Title "Summary Statistics for Tip Amount by Payment Type";
run;

proc sgplot data=taxi;
	hbar tipped / group=payment_type stat=percent groupdisplay=stack;
	title "Tipping Rate by Payment Type (% of Tips)";
run;

proc univariate data=taxi noprint;
	where tipped = "Yes";
	var tipPercent;
	histogram tipPercent / vscale=count vaxislabel="Ride Count" midpoints=0 to .35 
		by .05 normal;
	Inset mean="Average" std="St. Deviation" /position=NE;
	title "Distribution of Tip Percentage Across Tipping customers";
run;




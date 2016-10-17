******************************* 
*	STATA INTENSIVE: WORKSHOP 1
*	FALL 2016, D-LAB
*	SAIKA BELAL
*	OCT 12, 2016
********************************


****************************** 
*         SETTING UP   		 *
******************************
* Clear all data, variables, labels, matrices, memory, etc., and close all open files, graph windows, etc.
// It's good practice to make sure all previous work has been cleared
clear all

* Set a project directory.
cd "/Users/SSB/Box Sync/Fall 2016/D-lab/Stata workshop/Workshop 1" 
// this is my directory, yours will look different
// use menu bar: File > Change Working Directory


* Check the current working diretory.
pwd
// confirm that it is the directory you chose above


* Load our dataset.
use nlsw88.dta, clear
// Data: U.S. National Longitudinal Study of Young Women (NLSW, 1988 extract)
// The "clear" here is just an extra precaution and is usually included with the use command.
//  It ensures that all previous data that was open are closed.


* Disable the "more" (pause) feature.
set more off 




****************************** 
*         COMMENTING   		 *
****************************** 


// There are a bunch of ways to comment your .do file.

* You can also just put an asterisk at the beginning of a line
* You can use * to comment out lines of code that you want to suspend
// you can use double slash to make comments at the end of a command line or just as a line by itself (like this one)
// asterisk (*) cannot be placed at the end of a command line

des // describes the variables in the data
*des *  describes the variables in the data // <-- this is wrong!
* des // this suspended this line!


/* But then say you wanted to write a really long
and super informative comment that you didn't want 
to have all on one line, like this one we're typing
right now. */


/* You can also use this to suspend a bunch of commands*/


des
sum
list







****************************** 
*            LOG    		 *
******************************

* Start a log file.
// File -> Log -> Begin
log using stata_intro.log, replace
// the log is saved in your working directory
// Understand why we replace or append



* Close a log file (Usually done at the end of the do file.)
log close


/**

If you try using the previous log file by writing:

log using stata_intro.log  

then stata will return error: "file...already exists" 

To use a previously created log file, you need to use either
"replace" or "append" after the comma



**/



* We may want to close any existing log files first.
capture log close // this is a good command to include at the beginning of your do-file
log using stata_intro.log, replace







****************************** 
*          OPERATORS    	 *
******************************



/*

Very quick rundown of operators in Stata

+	plus
-	minus
* 	multiply
/	divide 
^	exponent

&	and
|	or
>	greater than
>=	greater than or equal to
=	equal
!	not (also ~)
!=	not equal to (also ~=)
==	test for equality (usually follows "if", very useful for defining variables)

*/






****************************** 
*       DATA ANALYSIS    	 *
******************************


* Missing values
sum // look at observation numbers
misstable summarize //


// Let's look at how missing variables can affect results:

// Suppose we want to summarize wages for those individuals who are in unions (union=1)

/* A */ sum wage if union>0 
/* B */ sum wage if union!=0
/* C */ sum wage if union!=0 & union!=.
/* D */ sum wage if union!=0 & union<.
/* E */ sum wage if union==1

// Are these the same? Which is/are correct?




* Basic descriptive statistics
sum wage if married==1
sum wage if collgrad==1
sum wage if married==1 | collgrad==1 // married graduate
sum wage if married==1 | collgrad!=1 // married non-graduate
sum wage if married!=1 | collgrad==1 // unmarried graduate
sum wage if married!=1 | collgrad==1 // unmarried non-graduate




*Tables and Cross-tables 
tab race
tab married
tab collgrad
 


* Difference between Tab1 and Tab
tab1 married collgrad
tab married collgrad


* Twoway tables 
tab married collgrad, col 
tab married collgrad, row
tab married collgrad, col row





* Summary statistics of one variable with respect to others 
// What is the average wage for married/non-married OR college graduates/non-graduates
tab married, summarize(wage) means
tab collgrad, summarize(wage) means
tab married collgrad, summarize(wage) means



// How does wage differ by industry?
tab industry, summarize(wage) 



// Let's explore the mining wage...
// Browse observations that belong to those in mining
// first we have to find the industry code that belongs to mining
br if industry==mining
tab industry
tab industry, nolabel
br if industry==2









*************************************************************************************
*									CHALLENGE 1										*						
*************************************************************************************
/*

    *** Write your answer commands after the asterisk line below. (why?) ***

(1) What is the average number of hours worked in the sample?


(2) How many observations in this dataset fall into each race group?


(3) What is the average number of hours worked by each race group?

(4) Find the average wage for those workers that work more hours than 
	the average hours worked in the sample. 
	
(5)	Find the average wage for non-white workers. Give this a try before looking below:
	
	
(6) For the above question, which option(s) is/are correct?
	/* A */ sum wage if race>1
	/* B */ sum wage if race!=1
	/* C */ sum wage if race!=1 & race!=.
	/* D */ sum wage if race>1 & race<.
	/* E */ sum wage if race==2 | race==3
	
*/
*************************************************************************************







* CREATE VARIABLES

// create a variable that indicates highschool graduate
// Be careful to think about (1) missing values (2) what should =1 and what should =0 for your variable

//let's first look at grade
codebook grade

// method 1
gen hs1 = 1 if grade>=12 & grade!=. 
replace hs1 = 0 if grade<12


// method 2
gen hs2 = (grade>=12 & grade!=.) 
// this assigns 1 to the observations meeting the condition in the () and 0 to all else


// method 3
gen hs3 = .
replace hs3 = 1 if grade>=12 & grade!=. 
replace hs3 = 0 if grade<12
// this method is more careful when missing values are involved (the variable "grade" has 2 missing values)


//method 4
recode grade (0/11 = 0) (12/18 = 1), gen(hs4) 



//check all 4 versions
sum hs1 hs2 hs3 hs4
sum hs*



// Why is hs2 different?
br grade hs* if hs2!=. & hs1==.



// drop extraneous versions
drop hs2 hs3 hs4




*** VALUE LABELS ***

// Rename and label the remaining variable and its values
rename hs1 hs
label variable hs "high school graduate" 
label define YN 1 "YES" 0 "NO" // this command creates the label "YN"
label values hs YN // this command assigns "YN" to variable hs
tab hs // to see that the label has been applied




* Create a variable for some college 
gen somecollege = (grade>12 & grade<16)
replace somecollege = . if grade==.
la var somecollege "attended some (not all) years of college" //Notice the shorthands for the commands
la val somecollege YN // applying the same label "YN" that was created above for another variable
tab somecollege


* more recode experience
recode married (0=1) (1=0), gen(unmarried)
tab1 married unmarried
la def unmarried_lbl 1 "single" 0 "married" // value label 
la val unmarried unmarried_lbl 
tab1 married unmarried







*************************************************************************************
*									CHALLENGE 2										*						
*************************************************************************************
/* 

(1) Create another version of the some college variable (call it somecollege3)
	using a method similar to method 3 used for creating hs above.
 
*/
*************************************************************************************



/* 
Two possible answers (there are several ways to write this):

gen somecollege3 = .
replace  somecollege3 = 1 if (grade>12 & grade<16) 
replace somecollege3 = 0 if (grade<=12 | grade>=16) & & grade!=. // notice the use of "or"
replace somecollege3 = 0 if grade>=16 & grade!=.


gen somecollege3 = .
replace  somecollege3 = 1 if grade>12 & grade!=.
replace somecollege3 = 0 if grade<=12
replace somecollege3 = 0 if grade>=16 & grade!=.

*** (takeaway: be careful of missing values anytime you use ">" or ">=")

*/






* Re-ordering how variables appead in the dataset
order hs somecollege , before(collgrad)




* Save changes to a NEW file
save "nlsw88_clean" , replace
// why don't we want to save changes to the original file?




* Export data for use with other programs
export delimited using "nlsw88_clean.csv", replace
export delimited using "nlsw88_clean.tsv", delimiter(tab) replace 
export excel using "nlsw88_clean.xlsx", firstrow(variables) replace







****************************** 
*       	GRAPHS    	 	 *
******************************



* Histogram and Density Graphs
hist wage
twoway (kdensity wage if collgrad==1) (kdensity wage if collgrad==0), ///
legend(label(1 "College Grad") label(2 "Non Grad"))

// did you notice the use of "///"? how is it different from "//"?

* Scatter Plots and Linear Graphs
twoway (scatter wage grade) (lfit wage grade )
twoway (lfit wage grade if race==1 )(lfit wage grade  if race==2), legend(label(1 "White") label(2 "Black"))
twoway (lfit wage grade if married==1 )(lfit wage grade  if married==0), ///
legend(label(1 "married") label(2 "single"))



****************************** 
*       REGRESSION (MINI)    *
******************************
reg y x1 x2 
reg wage age race 
reg wage age race grade collgrad married union ttl_exp tenure




*************************************************************************************
*									CHALLENGE	3									*						
*************************************************************************************
/*

(1)  Create a variable for annual income (which is the number of hours worked each week
	multiplied by wages multiplied by the number of weeks in a year). Call this variable annual_inc.
	
	
(2) Plot density graphs of annual income for college graduates and non graduates (separately) 
	on the same plot. Label the lines appropriately. What is your takeaway?

	
(3) Plot a scatter plot and a linear graph of how annual income changes with level of education.


(4) Plot annual income against education for both whites and blacks on the same plot. 
	Label lines appropriately.
	What is your takeaway?
 	
gen annual_inc =  wage*hours*52
twoway (kdensity annual_inc if collgrad==1) (kdensity annual_inc if collgrad==0), ///
legend(label(1 "College Grad") label(2 "Non Grad"))
twoway (scatter annual_inc grade) (lfit annual_inc grade )
twoway (lfit annual_inc grade if race==1 )(lfit annual_inc grade  if race==2), ///
legend(label(1 "White") label(2 "Black"))

*/

 *************************************************************************************



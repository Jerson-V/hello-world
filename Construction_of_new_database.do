****** Medicare Advantage (MA) enrollment ******
*Define the folders to be used
gl rutaup   "C:\Users\GRADE\Documents\Postulación BID\Initial_Data"
gl rutasave "C:\Users\GRADE\Documents\Postulación BID\Outcome"

******1) Import and clean the data base
*1.1 We import the data. We change them from ".cvs" to ".dta"
import delimited "$rutaup/scp-1205.csv", clear

*1.2 We analyze the variables quickly
codebook 

*1.3 As the variables don't have a name, we assign one following the informative file
**We create the variable according to the given example
egen healthplanname=concat(v3 v4), p(" ")
drop v3 v4
**Renaming
ren v1 countyname 
ren v2 state 
ren v5 typeofplan 
ren v6 countyssa 
ren v7 eligibles 
ren v8 enrollees 
ren v9 penetration 
ren v10 ABrate

*1.4 We replace missing values by zero. 
local k eligibles enrollees penetration
foreach var of local k{
destring `var', replace
replace `var'=0 if `var'==.
}

******2) We create the new database
*2.1 We create the variables that will help us to generate the variables "numberofplans1" 
*and "numberofplans2". 
gen ten_enrollees=1 if enrollees>10
gen high_penetration=1 if penetration>0.5

*2.2 We convert the variable "countyssa" into a numeric variable to use it in the collapse.
destring countyssa, replace force

*2.3 We collapse the data to obtain the observations at the county level
collapse (sum) ten_enrollees (sum) high_penetration ///
(max) countyssa (sum) eligibles (sum) enrollees, by(countyname state)

*2.4 
ren ten_enrollees numberofplans1
ren high_penetration numberofplans2
ren enrollees totalenrollees
gen totalpenetration=100*(totalenrollees/eligibles)

*2.5 We define the variable labels
label var countyname     "name of the county"
label var state "state postal code"
label var numberofplans1     "number of health plans with more than 10 enrollees"
label var numberofplans2 "number of health plans with penetration > 0.5"
label var countyssa     "Social Security Administration county code"
label var eligibles  "number of individuals in the county that are Medicare eligible"
label var totalenrollees     "number of individuals in the county with a MA health plan"
label var totalpenetration  "percent of individuals in the county enrolled in a MA plan"

*2.6 We give the order to the database according to the request.
gl xlist countyname state numberofplans1 numberofplans2 countyssa eligibles totalenrollees totalpenetration
order $xlist 

*2.7 We save
save "$rutasave/Medicare_Advantage-County-level-dataset.dta", replace




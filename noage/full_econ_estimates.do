// Put correct path here!
cd Z:\OLG_CGE_Model\code\elasticities\noage
// Bootstrap repetitions, test with low number, then increase to >100
local reps = 100

* (1) College (Education based estimates)
cap restore

// Data Preparations
use Datensatz1991_2017.dta, clear

replace BQU2=BQU1 if jahr==1991
recode BQU2 (2=12) (3=4) (4=5) (5=6) if jahr<=1991

gen skilled = .
replace skilled = .
replace skilled = 0 if BQU2 == 4
replace skilled = 1 if BQU2 == 10
drop if skilled ==.
*gen skilled = komp > 2

drop if lohn == . | lohn < 0
drop if lohn >= 500
drop if lohn <= 5
drop if vollzeit != 1
drop if angestellt != 1

drop if BMU3==1
gen ind = .
replace ind = 1 if BMU3 >=2 & BMU3<=5
replace ind = 2 if BMU3 >= 11 & BMU3 <= 13
replace ind = 3 if BMU3 == 6
replace ind = 4 if BMU3 >= 7 & BMU3 <= 8
replace ind = 5 if BMU3 == 10
replace ind = 6 if (BMU3 >= 14 & BMU3 <= 16) | (BMU3 >= 18 & BMU3 <=20) | BMU3==9
replace ind = 7 if BMU3 == 17 
drop if ind==.

gen jahr2=.
replace jahr2 = 1992 if jahr == 1992 | jahr == 1993
replace jahr2 = 1994 if jahr == 1994 | jahr == 1995
replace jahr2 = 1996 if jahr == 1996 | jahr == 1997
replace jahr2 = 1998 if jahr == 1998 | jahr == 1999
replace jahr2 = 2000 if jahr == 2000 | jahr == 2001
replace jahr2 = 2002 if jahr == 2002 | jahr == 2003
replace jahr2 = 2004 if jahr == 2004 | jahr == 2005
replace jahr2 = 2006 if jahr == 2006 | jahr == 2007
replace jahr2 = 2008 if jahr == 2008 | jahr == 2009
replace jahr2 = 2010 if jahr == 2010 | jahr == 2011
replace jahr2 = 2012 if jahr == 2012 | jahr == 2013
replace jahr2 = 2014 if jahr == 2014 | jahr == 2015
replace jahr2 = 2016 if jahr == 2016 | jahr == 2017
drop jahr
drop if jahr2==.
rename jahr2 jahr

save bootstrap_input_college.dta, replace

// Calculate Skill Shares
do labor_age_college.do
do labor_age_college_ind.do
	
use bootstrap_input_college.dta, clear
// Update the program
do age_bootstrap_college.do
// Run the bootstrap
bootstrap sigeE_college = r(sigeE_college) Trend = r(Trend), rep(`reps') : cardlemieux
// Store estimates
estimates store E2
matrix betas = e(b)
matrix ses = e(se)
matrix results = (betas\ses)
mat list results

// Industry-Specific Estimations
do age_bootstrap_ind_college.do
// Save F-Stats
quietly cardlemieuxind
mat f_coll = (0)
forval i=1/7 {
	mat f_coll = (f_coll,F_`i')
	}
mat f_coll = f_coll[1,2..8]
mat colnames f_coll = sigE_coll_1 sigE_coll_2 sigE_coll_3 sigE_coll_4 sigE_coll_5 sigE_coll_6 sigE_coll_7

bootstrap sigE_coll_1=r(sigE_coll_1) Trend_1=r(Trend_1) sigE_coll_2=r(sigE_coll_2) Trend_2=r(Trend_2) sigE_coll_3=r(sigE_coll_3) Trend_3=r(Trend_3) sigE_coll_4=r(sigE_coll_4) Trend_4=r(Trend_4) sigE_coll_5=r(sigE_coll_5) Trend_5=r(Trend_5) sigE_coll_6=r(sigE_coll_6) Trend_6=r(Trend_6) sigE_coll_7=r(sigE_coll_7) Trend_7=r(Trend_7), rep(`reps'): cardlemieuxind
estimates store F2
matrix betasi = e(b)
matrix sesi = e(se)
matrix resultsi = (betasi\sesi)
mat list resultsi
mat results = (results,resultsi)
mat list results


* (2) Skill (Occupation-Based Estimates)
cap restore
// Preparations again
use Datensatz1991_2017.dta, clear

gen skilled = komp > 2

drop if lohn == . | lohn < 0
drop if lohn >= 500
drop if lohn <= 5
drop if vollzeit != 1
drop if angestellt != 1

drop if BMU3==1
gen ind = .
replace ind = 1 if BMU3 >=2 & BMU3<=5
replace ind = 2 if BMU3 >= 11 & BMU3 <= 13
replace ind = 3 if BMU3 == 6
replace ind = 4 if BMU3 >= 7 & BMU3 <= 8
replace ind = 5 if BMU3 == 10
replace ind = 6 if (BMU3 >= 14 & BMU3 <= 16) | (BMU3 >= 18 & BMU3 <=20) | BMU3==9
replace ind = 7 if BMU3 == 17 
drop if ind==.


gen jahr2=.
replace jahr2 = 1992 if jahr == 1992 | jahr == 1993
replace jahr2 = 1994 if jahr == 1994 | jahr == 1995
replace jahr2 = 1996 if jahr == 1996 | jahr == 1997
replace jahr2 = 1998 if jahr == 1998 | jahr == 1999
replace jahr2 = 2000 if jahr == 2000 | jahr == 2001
replace jahr2 = 2002 if jahr == 2002 | jahr == 2003
replace jahr2 = 2004 if jahr == 2004 | jahr == 2005
replace jahr2 = 2006 if jahr == 2006 | jahr == 2007
replace jahr2 = 2008 if jahr == 2008 | jahr == 2009
replace jahr2 = 2010 if jahr == 2010 | jahr == 2011
replace jahr2 = 2012 if jahr == 2012 | jahr == 2013
replace jahr2 = 2014 if jahr == 2014 | jahr == 2015
replace jahr2 = 2016 if jahr == 2016 | jahr == 2017
drop jahr
drop if jahr2==.
rename jahr2 jahr

save bootstrap_input.dta, replace

// Skill Shares
do labor_age.do
do labor_age_ind.do

use bootstrap_input.dta, clear

// Update Program
do age_bootstrap.do
// Run Bootstrap
bootstrap sigeE_college = r(sigeE_college) Trend = r(Trend), rep(`reps') : cardlemieux
// Store Estimates
estimates store G2
matrix betas = e(b)
matrix ses = e(se)
matrix results2 = (betas\ses)
mat list results2
matrix fullresults = (results,results2)
mat list fullresults

// Industry-Specific Estimates
do age_bootstrap_ind.do
// Save F-Stats
quietly cardlemieuxind
mat f_skill_us = (0)
forval i=1/7 {
	mat f_skill_us = (f_skill_us,F_`i')
	}
mat f_skill_us = f_skill_us[1,2..8]
mat colnames f_skill_us = sigE_coll_1 sigE_coll_2 sigE_coll_3 sigE_coll_4 sigE_coll_5 sigE_coll_6 sigE_coll_7

bootstrap sigE_coll_1=r(sigE_coll_1) Trend_1=r(Trend_1) sigE_coll_2=r(sigE_coll_2) Trend_2=r(Trend_2) sigE_coll_3=r(sigE_coll_3) Trend_3=r(Trend_3) sigE_coll_4=r(sigE_coll_4) Trend_4=r(Trend_4) sigE_coll_5=r(sigE_coll_5) Trend_5=r(Trend_5) sigE_coll_6=r(sigE_coll_6) Trend_6=r(Trend_6) sigE_coll_7=r(sigE_coll_7) Trend_7=r(Trend_7), verbose rep(`reps'): cardlemieuxind
estimates store H2
matrix betasi = e(b)
matrix sesi = e(se)
matrix resultsi = (betasi\sesi)
mat list resultsi
mat results2 = (fullresults,resultsi)
mat list results2

// Save all the estimates on harddisk
estimates restore E2
estimates save ch_college2, replace
estimates restore F2
estimates save ch_college_ind2, replace
estimates restore G2
estimates save ch_skill2, replace
estimates restore H2
estimates save ch_skill_ind2, replace

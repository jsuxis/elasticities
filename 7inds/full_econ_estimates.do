// Put correct path here!
cd Z:\OLG_CGE_Model\code\elasticities\7inds
local reps = 5

* (1) College
cap restore
use Datensatz1991_2017.dta, clear

replace BQU2=BQU1 if jahr==1991
recode BQU2 (2=12) (3=4) (4=5) (5=6) if jahr<=1991

gen skilled = .
replace skilled = .
replace skilled = 0 if BQU2 == 4
replace skilled = 1 if BQU2 == 10
drop if skilled ==.

keep if age >= 20 & age <= 65
drop if lohn == . | lohn < 0
drop if lohn >= 500
drop if lohn <= 5
drop if vollzeit != 1
drop if angestellt != 1

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
keep if altersgr>1 &altersgr<9
keep if jahr >=1992 & jahr<=2016
do age_bootstrap_college.do
bootstrap sigeE_college = r(sigmaE) sigA_college = r(sigmaA) Trend = r(trend), rep(`reps') : cardlemieux
estimates store E
matrix betas = e(b)
matrix ses = e(se)
matrix results = (betas\ses)
mat list results

do age_bootstrap_ind_college.do
bootstrap sigE_coll_1=r(sigmaE_1) sigA_coll_1=r(sigmaA_1) sigE_coll_2=r(sigmaE_2) sigA_coll_2=r(sigmaA_2) sigE_coll_3=r(sigmaE_3) sigA_coll_3=r(sigmaA_3) sigE_coll_4=r(sigmaE_4) sigA_coll_4=r(sigmaA_4) sigE_coll_5=r(sigmaE_5) sigA_coll_5=r(sigmaA_5) sigE_coll_6=r(sigmaE_6) sigA_coll_6=r(sigmaA_6) sigE_coll_7=r(sigmaE_7) sigA_coll_7=r(sigmaA_7) Trend_1 = r(trend_1) Trend_2 = r(trend_2) Trend_3 = r(trend_3) Trend_4 = r(trend_4) Trend_5 = r(trend_5) Trend_6 = r(trend_6) Trend_7 = r(trend_7), rep(`reps'): cardlemieuxind
estimates store F
matrix betasi = e(b)
matrix sesi = e(se)
matrix resultsi = (betasi\sesi)
mat list resultsi
mat results = (results,resultsi)
mat list results


* (2) Skill
cap restore
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

// Calculate Skill Shares
do labor_age.do
do labor_age_ind.do

use bootstrap_input.dta, clear
keep if altersgr>1 &altersgr<9
do age_bootstrap.do
bootstrap sigeE_college = r(sigmaE) sigA_college = r(sigmaA) Trend = r(trend), rep(`reps') : cardlemieux
estimates store G
matrix betas = e(b)
matrix ses = e(se)
matrix results2 = (betas\ses)
mat list results2
matrix fullresults = (results,results2)
mat list fullresults

do age_bootstrap_ind.do
bootstrap sigE_coll_1=r(sigmaE_1) sigA_coll_1=r(sigmaA_1) sigE_coll_2=r(sigmaE_2) sigA_coll_2=r(sigmaA_2) sigE_coll_3=r(sigmaE_3) sigA_coll_3=r(sigmaA_3) sigE_coll_4=r(sigmaE_4) sigA_coll_4=r(sigmaA_4) sigE_coll_5=r(sigmaE_5) sigA_coll_5=r(sigmaA_5) sigE_coll_6=r(sigmaE_6) sigA_coll_6=r(sigmaA_6) sigE_coll_7=r(sigmaE_7) sigA_coll_7=r(sigmaA_7) Trend_1 = r(trend_1) Trend_2 = r(trend_2) Trend_3 = r(trend_3) Trend_4 = r(trend_4) Trend_5 = r(trend_5) Trend_6 = r(trend_6) Trend_7 = r(trend_7), rep(`reps'): cardlemieuxind
estimates store H
matrix betasi = e(b)
matrix sesi = e(se)
matrix resultsi = (betasi\sesi)
mat list resultsi
mat results2 = (fullresults,resultsi)
mat list results2

estimates restore E
estimates save ch_college7, replace
estimates restore F
estimates save ch_college_ind7, replace
estimates restore G
estimates save ch_skill7, replace
estimates restore H
estimates save ch_skill_ind7, replace


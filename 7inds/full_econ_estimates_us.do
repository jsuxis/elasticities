cd Z:\OLG_CGE_Model\code\elasticities\7inds
local reps = 50

* (1) College
cap restore
use us_data.dta, clear

gen jahr=year
replace jahr = 1980 if year == 1980 | year == 1981
replace jahr = 1982 if year == 1982 | year == 1983
replace jahr = 1984 if year == 1984 | year == 1985
replace jahr = 1986 if year == 1986 | year == 1987
replace jahr = 1988 if year == 1988 | year == 1989
replace jahr = 1990 if year == 1990 | year == 1991
replace jahr = 1992 if year == 1992 | year == 1993
replace jahr = 1994 if year == 1994 | year == 1995
replace jahr = 1996 if year == 1996 | year == 1997
replace jahr = 1998 if year == 1998 | year == 1999
replace jahr = 2000 if year == 2000 | year == 2001
replace jahr = 2002 if year == 2002 | year == 2003
replace jahr = 2004 if year == 2004 | year == 2005
replace jahr = 2006 if year == 2006 | year == 2007
replace jahr = 2008 if year == 2008 | year == 2009
replace jahr = 2010 if year == 2010 | year == 2011
replace jahr = 2012 if year == 2012 | year == 2013
replace jahr = 2014 if year == 2014 | year == 2015
replace jahr = 2016 if year == 2016 | year == 2017
drop if jahr==.

gen skilled = .
replace skilled = 0 if educ ==2 
replace skilled = 1 if educ >=4
drop if skilled ==.


keep if age >= 26 & age <= 60
drop if loglohn == . 
//drop if rhrwage >= 150
drop if loglohn < log(50)                   //?
keep if ftptlyr == 1 | ftptlyr == 3
drop if empl != 1


save bootstrap_input_college_us.dta, replace

do labor_age_college_us.do
do labor_age_ind_college_us.do

use bootstrap_input_college_us.dta, clear
keep if altersgr>1 &altersgr<9
do age_bootstrap_college_us.do
bootstrap sigeE_college = r(sigmaE) sigA_college = r(sigmaA) Trend = r(trend), rep(`reps') : cardlemieux
estimates store A
matrix betas = e(b)
matrix ses = e(se)
cap matrix results = (betas\ses)
mat list results

do age_bootstrap_ind_college_us.do
bootstrap sigE_coll_1=r(sigmaE_1) sigA_coll_1=r(sigmaA_1) sigE_coll_2=r(sigmaE_2) sigA_coll_2=r(sigmaA_2) sigE_coll_3=r(sigmaE_3) sigA_coll_3=r(sigmaA_3) sigE_coll_4=r(sigmaE_4) sigA_coll_4=r(sigmaA_4) sigE_coll_5=r(sigmaE_5) sigA_coll_5=r(sigmaA_5) sigE_coll_6=r(sigmaE_6) sigA_coll_6=r(sigmaA_6) sigE_coll_7=r(sigmaE_7) sigA_coll_7=r(sigmaA_7) Trend_1=r(trend_1) Trend_2=r(trend_2) Trend_3=r(trend_3) Trend_4=r(trend_4) Trend_5=r(trend_5) Trend_6=r(trend_6) Trend_7=r(trend_7), rep(`reps'): cardlemieuxind
estimates store B
matrix betasi = e(b)
matrix sesi = e(se)
cap matrix resultsi = (betasi\sesi)
cap mat list resultsi
cap mat results = (results,resultsi)
cap mat list results


* (2) Skill
cap restore
use us_data.dta, clear

gen jahr=year
replace jahr = 1980 if year == 1980 | year == 1981
replace jahr = 1982 if year == 1982 | year == 1983
replace jahr = 1984 if year == 1984 | year == 1985
replace jahr = 1986 if year == 1986 | year == 1987
replace jahr = 1988 if year == 1988 | year == 1989
replace jahr = 1990 if year == 1990 | year == 1991
replace jahr = 1992 if year == 1992 | year == 1993
replace jahr = 1994 if year == 1994 | year == 1995
replace jahr = 1996 if year == 1996 | year == 1997
replace jahr = 1998 if year == 1998 | year == 1999
replace jahr = 2000 if year == 2000 | year == 2001
replace jahr = 2002 if year == 2002 | year == 2003
replace jahr = 2004 if year == 2004 | year == 2005
replace jahr = 2006 if year == 2006 | year == 2007
replace jahr = 2008 if year == 2008 | year == 2009
replace jahr = 2010 if year == 2010 | year == 2011
replace jahr = 2012 if year == 2012 | year == 2013
replace jahr = 2014 if year == 2014 | year == 2015
replace jahr = 2016 if year == 2016 | year == 2017
drop if jahr==.

gen komp = 0 
replace komp = 1 if (ISCO_08 >= 300 & ISCO_08<400) | (ISCO_08>=9000 & ISCO_08<9700) // 03, 90-96 (Hilfsarbeitskräfte)
replace komp = 2 if (ISCO_08 >= 200 & ISCO_08<300) | (ISCO_08>=4000 & ISCO_08<8400) // 40-83 Bürokräfte, Bedienung von Machinen
replace komp = 3 if ISCO_08>=3000 & ISCO_08<3600 // 30-35 Fachkräfte
replace komp = 4 if (ISCO_08 >= 100 & ISCO_08<200) | (ISCO_08>=1000 & ISCO_08<2700)  // 10-26 Führungskräfte, Akademiker

drop if komp==0

gen skilled = komp > 2


keep if age >= 26 & age <= 60
drop if loglohn == . 
//drop if rhrwage >= 150
drop if loglohn < log(50)                   //?
keep if ftptlyr == 1 | ftptlyr == 3
drop if empl != 1

save bootstrap_input_us.dta, replace

do labor_age_skill_us.do
do labor_age_ind_skill_us.do

use bootstrap_input_us.dta, clear
keep if altersgr>1 &altersgr<9

do age_bootstrap_skill_us.do
*cardlemieux

bootstrap sigeE_college = r(sigmaE) sigA_college = r(sigmaA) Trend = r(trend), rep(`reps') : cardlemieux
estimates store C
matrix betas = e(b)
matrix ses = e(se)
cap matrix results2 = (betas\ses)
mat list results2
cap matrix fullresults = (results,results2)
mat list fullresults



do age_bootstrap_ind_skill_us.do
bootstrap sigE_coll_1=r(sigmaE_1) sigA_coll_1=r(sigmaA_1) sigE_coll_2=r(sigmaE_2) sigA_coll_2=r(sigmaA_2) sigE_coll_3=r(sigmaE_3) sigA_coll_3=r(sigmaA_3) sigE_coll_4=r(sigmaE_4) sigA_coll_4=r(sigmaA_4) sigE_coll_5=r(sigmaE_5) sigA_coll_5=r(sigmaA_5) sigE_coll_6=r(sigmaE_6) sigA_coll_6=r(sigmaA_6) sigE_coll_7=r(sigmaE_7) sigA_coll_7=r(sigmaA_7) Trend_1=r(trend_1) Trend_2=r(trend_2) Trend_3=r(trend_3) Trend_4=r(trend_4) Trend_5=r(trend_5) Trend_6=r(trend_6) Trend_7=r(trend_7), rep(`reps'): cardlemieuxind, rep(`reps'): cardlemieuxind
estimates store D
matrix betasi = e(b)
matrix sesi = e(se)
cap matrix resultsi = (betasi\sesi)
cap mat list resultsi
cap mat results2 = (fullresults,resultsi)
cap mat list results2


estimates restore A
estimates save us_college, replace
estimates restore B
estimates save us_college_ind, replace
estimates restore C
estimates save us_skill, replace
estimates restore D
estimates save us_skill_ind, replace


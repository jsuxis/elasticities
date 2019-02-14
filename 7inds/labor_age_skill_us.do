cd Z:\OLG_CGE_Model\code\elasticities\7inds
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

keep if age >= 15 & age <= 65
drop if altersgr==0

rename stundeges2 hours
gen stundeges2 = weeks * hours

preserve

collapse (sum) stundeges2 (count) n=stundeges2 /*[pw=gew]*/, by(geschl altersgr skilled jahr)
reshape wide stundeges2 n, i(jahr geschl altersgr) j(skilled)
drop if n0<=5 | n1<=5

gen labor = stundeges21 / stundeges20

collapse (mean) stundeges2* labor, by(jahr altersgr)

gen loglabor = log(labor)
gen loglabor_h = log(stundeges21)
gen loglabor_l = log(stundeges20)

gen ind=0

save labor_age_skill_us.dta, replace



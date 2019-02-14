// Put correct path here!
cd Z:\OLG_CGE_Model\code\elasticities\7inds

cap restore
use Datensatz1991_2017.dta, clear

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

gen skilled = komp > 2

recode BQU2 (2=12) (3=4) (4=5) (5=6) if jahr<=1995

keep if age >= 15 & age <= 65
drop if stundeges2 == . | stundeges2 < 0


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

save labor_age.dta, replace

restore

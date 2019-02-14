cd Z:\OLG_CGE_Model\code\elasticities\noage
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
replace skilled = 0 if educ == 2
replace skilled = 1 if educ >= 4
drop if skilled ==.

drop if ind==.

keep if age >= 15 & age <= 65
drop if stundeges2 == . | stundeges2 < 0


preserve

collapse (sum) stundeges2 (count) n=stundeges2 /*[pw=gew]*/, by(geschl skilled jahr ind)
reshape wide stundeges2 n, i(jahr geschl ind) j(skilled)
drop if n0<=5 | n1<=5

gen labor = stundeges21 / stundeges20

collapse (mean) stundeges2* labor, by(jahr ind)

gen loglabor = log(labor)
gen loglabor_h = log(stundeges21)
gen loglabor_l = log(stundeges20)



save labor_age_ind_college_us.dta, replace

restore

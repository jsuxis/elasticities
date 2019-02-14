cd Z:\OLG_CGE_Model\code\elasticities\7inds
local reps = 10

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

/*
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
*/


gen jahr2=.
replace jahr2 = 1992 if jahr == 1992 | jahr == 1993
replace jahr2 = 1993 if jahr == 1993 | jahr == 1994
replace jahr2 = 1994 if jahr == 1994 | jahr == 1995
replace jahr2 = 1995 if jahr == 1995 | jahr == 1996
replace jahr2 = 1996 if jahr == 1996 | jahr == 1997
replace jahr2 = 1997 if jahr == 1997 | jahr == 1998
replace jahr2 = 1998 if jahr == 1998 | jahr == 1999
replace jahr2 = 1999 if jahr == 1999 | jahr == 2000
replace jahr2 = 2000 if jahr == 2000 | jahr == 2001
replace jahr2 = 2001 if jahr == 2001 | jahr == 2002
replace jahr2 = 2002 if jahr == 2002 | jahr == 2003
replace jahr2 = 2003 if jahr == 2003 | jahr == 2004
replace jahr2 = 2004 if jahr == 2004 | jahr == 2005
replace jahr2 = 2005 if jahr == 2005 | jahr == 2006
replace jahr2 = 2006 if jahr == 2006 | jahr == 2007
replace jahr2 = 2007 if jahr == 2007 | jahr == 2008
replace jahr2 = 2008 if jahr == 2008 | jahr == 2009
replace jahr2 = 2009 if jahr == 2009 | jahr == 2010
replace jahr2 = 2010 if jahr == 2010 | jahr == 2011
replace jahr2 = 2011 if jahr == 2011 | jahr == 2012
replace jahr2 = 2012 if jahr == 2012 | jahr == 2013
replace jahr2 = 2013 if jahr == 2013 | jahr == 2014
replace jahr2 = 2014 if jahr == 2014 | jahr == 2015
replace jahr2 = 2015 if jahr == 2015 | jahr == 2016
replace jahr2 = 2016 if jahr == 2016 | jahr == 2017



drop jahr
drop if jahr2==.
rename jahr2 jahr

save bootstrap_input.dta, replace

do age_bootstrap.do
quietly cardlemieux

do age_bootstrap_ind.do
quietly cardlemieuxind

matrix noage = ( r(sigE_coll_1), r(sigE_coll_2), r(sigE_coll_3), r(sigE_coll_4), r(sigE_coll_5), r(sigE_coll_6), r(sigE_coll_7), r(Trend_1), r(Trend_2), r(Trend_3), r(Trend_4), r(Trend_5), r(Trend_6), r(Trend_7), r(sigA2_coll_1), r(sigA2_coll_2), r(sigA2_coll_3), r(sigA2_coll_4), r(sigA2_coll_5), r(sigA2_coll_6), r(sigA2_coll_7) /*, r(sigE2_coll_1), r(sigE2_coll_2), r(sigE2_coll_3), r(sigE2_coll_4), r(sigE2_coll_5), r(sigE2_coll_6), r(sigE2_coll_7), r(Trend2_1), r(Trend2_2), r(Trend2_3), r(Trend2_4), r(Trend2_5), r(Trend2_6), r(Trend2_7)*/ )



scalar n=_N
forval i=1/7 {
	scalar F_`i' = r(F_`i')
	scalar F1_`i' = r(F1_`i')
	}

cap program drop newboot
program define newboot, rclass
	preserve
	bsample , strata(jahr)
	cardlemieuxind
	return scalar sigE_coll_1 = r(sigE_coll_1)
	return scalar Trend_1 = r(Trend_1)
	return scalar sigE_coll_2 = r(sigE_coll_2)
	return scalar Trend_2 = r(Trend_2)
	return scalar sigE_coll_3 = r(sigE_coll_3)
	return scalar Trend_3 = r(Trend_3)
	return scalar sigE_coll_4 = r(sigE_coll_4)
	return scalar Trend_4 = r(Trend_4)
	return scalar sigE_coll_5 = r(sigE_coll_5)
	return scalar Trend_5 = r(Trend_5)
	return scalar sigE_coll_6 = r(sigE_coll_6)
	return scalar Trend_6 = r(Trend_6)
	return scalar sigE_coll_7 = r(sigE_coll_7)
	return scalar Trend_7 = r(Trend_7)
	
	return scalar sigA2_coll_1 = r(sigA2_coll_1)
	return scalar sigA2_coll_2 = r(sigA2_coll_2)
	return scalar sigA2_coll_3 = r(sigA2_coll_3)
	return scalar sigA2_coll_4 = r(sigA2_coll_4)
	return scalar sigA2_coll_5 = r(sigA2_coll_5)
	return scalar sigA2_coll_6 = r(sigA2_coll_6)
	return scalar sigA2_coll_7 = r(sigA2_coll_7)
	
	restore
end

simulate sigE_coll_1 = r(sigE_coll_1) sigE_coll_2 = r(sigE_coll_2) sigE_coll_3 = r(sigE_coll_3) sigE_coll_4 = r(sigE_coll_4)  sigE_coll_5 = r(sigE_coll_5)  sigE_coll_6 = r(sigE_coll_6)  sigE_coll_7 = r(sigE_coll_7)   Trend_1 = r(Trend_1)  Trend_2 = r(Trend_2) Trend_3 = r(Trend_3) Trend_4 = r(Trend_4) Trend_5 = r(Trend_5) Trend_6 = r(Trend_6) Trend_7 = r(Trend_7) sigA2_coll_1 = r(sigA2_coll_1) sigA2_coll_2 = r(sigA2_coll_2) sigA2_coll_3 = r(sigA2_coll_3) sigA2_coll_4 = r(sigA2_coll_4)  sigA2_coll_5 = r(sigA2_coll_5)  sigA2_coll_6 = r(sigA2_coll_6)  sigA2_coll_7 = r(sigA2_coll_7)/*sigE2_coll_1 = r(sigE2_coll_1) sigE2_coll_2 = r(sigE2_coll_2) sigE2_coll_3 = r(sigE2_coll_3) sigE2_coll_4 = r(sigE2_coll_4)  sigE2_coll_5 = r(sigE2_coll_5)  sigE2_coll_6 = r(sigE2_coll_6)  sigE2_coll_7 = r(sigE2_coll_7)   Trend2_1 = r(Trend2_1)  Trend2_2 = r(Trend2_2) Trend2_3 = r(Trend2_3) Trend2_4 = r(Trend2_4) Trend2_5 = r(Trend2_5) Trend2_6 = r(Trend2_6) Trend2_7 = r(Trend2_7)*//*Z_1=r(Z_1) Z_2=r(Z_2) Z_3=r(Z_3) Z_4=r(Z_4) Z_5=r(Z_5) Z_6=r(Z_6) Z_7=r(Z_7)*/, reps(`reps'): newboot

mat se = (0)
forval i=1/7 {
	tabstat sigE_coll_`i', stat(mean sd q iqr) save
	mat temp=r(StatTotal)
	scalar sigE_coll_`i'_se = temp[6,1]/1.349
	mat se = (se\sigE_coll_`i'_se)
	}

forval i=1/7 {
	tabstat Trend_`i', stat(mean sd q iqr) save
	mat temp=r(StatTotal)
	scalar Trend_`i'_se = temp[6,1]/1.349
	mat se = (se\sigE_coll_`i'_se)
	}

mat se = se[2..15,1]
scalar list 
local n = n
bstat, stat(noage) n(`n') verbose

mat betas = e(b)
mat betas = betas'
mat betas_se = (betas,se)
mat ci_left = (betas-1.96*se)
mat ci_right = (betas+1.96*se)
mat newconf = (betas, se, ci_left, ci_right)
mat se = se'
mat colnames se = sigE_coll_1 sigE_coll_2 sigE_coll_3 sigE_coll_4 sigE_coll_5 sigE_coll_6 sigE_coll_7 Trend_1 Trend_2 Trend_3 Trend_4 Trend_5 Trend_6 Trend_7
matrix F = (0,0)
forval i=1/7 {
	mat F = (F,F_`i')
	}
mat F = F[1,3..9]
mat colnames F = sigE_coll_1 sigE_coll_2 sigE_coll_3 sigE_coll_4 sigE_coll_5 sigE_coll_6 sigE_coll_7

matrix F1 = (0,0)
forval i=1/7 {
	mat F1 = (F1,F1_`i')
	}
mat F1 = F1[1,3..9]
mat colnames F1 = sigE_coll_1 sigE_coll_2 sigE_coll_3 sigE_coll_4 sigE_coll_5 sigE_coll_6 sigE_coll_7

estadd matrix sd = se
estadd matrix F = F
estadd matrix F1 = F1

esttab, cells( (b(star fmt(3)) F(fmt(3)) F1(fmt(3)))se(par fmt(2)) sd(par fmt(2))) drop(Trend*) nonumber coeflabel(sigE_coll_1 "Manufacturing" sigE_coll_2 "Finance" sigE_coll_3 "Construction" sigE_coll_4 "Trade \& Transport" sigE_coll_5 "IT" sigE_coll_6 "Other Services" sigE_coll_7 "Health") noobs star(* 0.10 ** 0.05 *** 0.01)


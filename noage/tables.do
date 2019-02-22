cd C:\Users\buchma04\Dropbox\elasticities\noage
use bootstrap_input_college.dta, clear

tab komp skilled, cell nofreq
gen skilled2 = komp>2
tab skilled2 skilled, cell nofreq

gen educ = 1 if BQU2>=1 & BQU2 <6 | BQU2==11 | BQU2==12
replace educ = 2 if BQU2 == 4 | BQU2 == 5
replace educ = 3 if BQU2 >=6 & BQU2 <10
replace educ = 4 if BQU2 ==10

keep if jahr>=2016
tab komp educ, nofreq row 

use Datensatz1991_2017.dta, clear

replace BQU2=BQU1 if jahr==1991
recode BQU2 (2=12) (3=4) (4=5) (5=6) if jahr<=1991

gen skilled = .
replace skilled = .
replace skilled = 0 if BQU2 <= 4
replace skilled = 1 if BQU2 >= 10
drop if skilled ==.

drop if BQU2 < 1
forval j=1991/2017 {
	sum BQU2 if jahr==`j' [iw=gewicht]
	local n2 = r(N)
	sum BQU2 if BQU2 == 10 & jahr==`j'
	local n1 = r(N)
	local n3ch_`j' = `n1'/`n2'
	di `n3ch_`j''
	}

use us_data.dta, clear
forval j=1991/2016 {
	sum educ if year==`j' [iw=weight]
	local n2 = r(N)
	sum educ if educ >= 4 & year==`j'
	local n1 = r(N)
	local n3us_`j' = `n1'/`n2'
	di `n3us_`j''
	}



** RESULTS **

estimates use ch_college2
scalar T = 13
estadd scalar T = T
est sto ch_college_noage
estimates use ch_skill2
scalar T = 13
estadd scalar T = T
est sto ch_skill_noage
estimates use us_college2
est sto us_college_noage
estimates use us_skill2
est sto us_skill_noage

esttab ch_college_noage ch_skill_noage  us_college_noage us_skill_noage using main_ch.tex, replace se coeflabel(sigeE_college "Skill" sigA_college "Age") mtitle("Education" "Occupation" "Education" "Occupation") drop() mgroups("Switzerland" "USA", pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) booktabs nonumber noobs star(* 0.10 ** 0.05 *** 0.01)

estimates use ch_college_ind2
estadd  matrix F = f_coll, replace
scalar T = 13
estadd scalar T = T
est sto ch_college_ind_noage
estimates use ch_skill_ind2
estadd matrix F = f_skill, replace
scalar T = 13
estadd scalar T = T
est sto ch_skill_ind_noage
estimates use us_college_ind2
estadd matrix F = f_coll_us
estadd scalar T = 18
est sto us_college_ind_noage
estimates use us_skill_ind2
estadd matrix F = f_skill_us
estadd scalar T = 18
est sto us_skill_ind_noage

estimates use ch_college_ind7
est sto ch_college_ind7
estimates use ch_skill_ind7
est sto ch_skill_ind7
estimates use us_college_ind
est sto us_college_ind7
estimates use us_skill_ind
est sto us_skill_ind7



// CH only results, Aggregate
esttab ch_college_noage ch_skill_noage using main_ch.tex, replace se coeflabel(sigeE_college "Skill") mtitle("Education" "Occupation" "Education" "Occupation") drop() mgroups("Switzerland" "USA", pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) booktabs nonumber star(* 0.10 ** 0.05 *** 0.01) order(sigeE_college Trend) scalars(T) 


// CH only results, Industry
esttab ch_college_ind_noage ch_skill_ind_noage using ind_skill_ch.tex, replace se cells( (b(star fmt(3)) F(fmt(3)))se(par fmt(2)) ) drop(Trend* /*sigA**/) nonumber coeflabel(sigE_coll_1 "Manufacturing" sigE_coll_2 "Finance" sigE_coll_3 "Construction" sigE_coll_4 "Trade \& Transport" sigE_coll_5 "IT" sigE_coll_6 "Other Services" sigE_coll_7 "Health")  star(* 0.10 ** 0.05 *** 0.01) scalars(T) mtitle("Education" "Occupation") booktabs 



esttab ch_college_ind_noage ch_skill_ind_noage us_college_ind_noage us_skill_ind_noage /*using ind_skill.tex*/, replace se drop(Trend*) mtitle("Education" "Occupation" "Education" "Occupation") mgroups("Switzerland" "USA", pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) booktabs nonumber coeflabel(sigE_coll_1 "Manufacturing" sigE_coll_2 "Finance" sigE_coll_3 "Construction" sigE_coll_4 "Trade \& Transport" sigE_coll_5 "IT" sigE_coll_6 "Other Services" sigE_coll_7 "Health") noobs star(* 0.10 ** 0.05 *** 0.01) main(fstat)

esttab ch_college_ind_noage ch_skill_ind_noage us_college_ind_noage us_skill_ind_noage using ind_trend.tex, replace se drop(sigE*) mtitle("Education" "Occupation" "Education" "Occupation") mgroups("Switzerland" "USA", pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) booktabs nonumber coeflabel(Trend_1 "Manufacturing" Trend_2 "Finance" Trend_3 "Construction" Trend_4 "Trade \& Transport" Trend_5 "IT" Trend_6 "Other Services" Trend_7 "Health") noobs star(* 0.10 ** 0.05 *** 0.01)

esttab ch_college_ind_noage ch_skill_ind_noage using ind_skill2.tex, replace cells( (b(star fmt(3)) F(fmt(3)))se(par fmt(2)) ) drop(Trend*) nonumber coeflabel(sigE_coll_1 "Manufacturing" sigE_coll_2 "Finance" sigE_coll_3 "Construction" sigE_coll_4 "Trade \& Transport" sigE_coll_5 "IT" sigE_coll_6 "Other Services" sigE_coll_7 "Health")  star(* 0.10 ** 0.05 *** 0.01) scalars(T) mtitle("Education" "Occupation") booktabs

esttab us_college_ind_noage us_skill_ind_noage using ind_skill3.tex, replace cells( (b(star fmt(3)) F(fmt(3)))se(par fmt(2)) ) drop(Trend*) nonumber coeflabel(sigE_coll_1 "Manufacturing" sigE_coll_2 "Finance" sigE_coll_3 "Construction" sigE_coll_4 "Trade \& Transport" sigE_coll_5 "IT" sigE_coll_6 "Other Services" sigE_coll_7 "Health")  star(* 0.10 ** 0.05 *** 0.01) scalars(T) mtitle("Education" "Occupation") booktabs

cap program drop cardlemieux

program define cardlemieux, rclass

	preserve
	gen wagegap = .
	gen wgt = .
	gen wage_u = .
	gen wage_s = .
	gen age2 = age^2
	keep if altersgr >1 & altersgr <9
	
	forval y=1980(2)2016 {
		forval a=2/8 {
			reg loglohn i.skilled i.geschl age i.nonwhite if jahr==`y' & altersgr==`a', robust
			mat covar_`y'_`a' = e(V)
			local var_`y'_`a' = 1/covar_`y'_`a'[2,2]
			mat b_`y'_`a' = e(b)
			local gap_`y'_`a' = b_`y'_`a'[1,2]
			replace wgt = `var_`y'_`a'' if jahr==`y' & altersgr==`a'  
			replace wagegap = `gap_`y'_`a'' if jahr==`y' & altersgr==`a' 
			}
	}

	collapse (mean) wagegap wgt wage_u wage_s, by(jahr)
	
	gen ind = 0
	
	save wage_reg_age_us.dta, replace

	use labor_age_college_us.dta, clear
	merge 1:1 jahr using wage_reg_age_us.dta, nogen
	rename wagegap logwage
	sort jahr
	gen t = _n

	gen early = jahr < 2002
	keep if jahr > 1980
	
	reg logwage t loglabor [aw=wgt]
	mat betas = e(b)
	local r1 = betas[1,2]
	local trend = betas[1,1]
	local sigE = -1/`r1'
	display _newline "Sigma E: `sigE'"
	display _newline "Trend: `trend'"
	return scalar sigmaE = `sigE'
	return scalar trend = `trend'
	restore
end


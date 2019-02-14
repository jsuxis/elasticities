cap program drop cardlemieux

program define cardlemieux, rclass

	preserve
	gen wagegap = .
	gen wgt = .
	gen wage_u = .
	gen wage_s = .
	gen age2 = age^2
	keep if altersgr >1 & altersgr <9

	// Calculating wage gaps, saving inverse of variance for later use as weight
		forval y=1992(1)2016 {
		forval a=2/8 {
			reg loglohn i.skilled i.geschl age if jahr==`y' & altersgr==`a', robust
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
	
	save wage_reg_age.dta, replace

	// Merging with skill shares calculated in different file
	use labor_age.dta, clear
	merge 1:1 jahr using wage_reg_age.dta, nogen
	rename wagegap logwage
	sort jahr
	gen t = _n
	gen t2 = t*t

	keep if jahr >= 1992

	reg logwage t loglabor [aw=wgt]
	mat betas = e(b)
	local r1 = betas[1,2]
	local trend = betas[1,1]
	local sigE = -1/`r1'
	display _newline "Sigma E: `sigE'"
	display _newline "Trend: `trend'"
	return scalar sigeE_college = `sigE'
	return scalar Trend = `trend'
	restore
end


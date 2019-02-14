cap program drop cardlemieux

program define cardlemieux, rclass

	preserve
	gen wagegap = .
	gen wgt = .
	gen wage_u = .
	gen wage_s = .
	gen age2 = age^2
	keep if altersgr >1 & altersgr <9
	/*
	forval y=1992(2)2016 {
		reg loglohn i.skilled i.geschl age age2 if jahr==`y', robust
		mat covar_`y'_`a' = e(V)
		local var_`y'_`a' = 1/covar_`y'_`a'[2,2]
		mat b_`y'_`a' = e(b)
		local gap_`y'_`a' = b_`y'_`a'[1,2]
		replace wgt = `var_`y'_`a'' if jahr==`y' 
		replace wagegap = `gap_`y'_`a'' if jahr==`y' */
/*		reg loglohn skilled age i.geschl age2 if jahr==`y', robust
			mat covar_`y' = e(V)
			local var_`y' = 1/covar_`y'[1,1]
			mat b_`y' = e(b)
			local gap_`y' = b_`y'[1,1]
			local men_u_`y' = b_`y'[1,5]
			local women_u_`y' = b_`y'[1,5]+b_`y'[1,4]
			local men_s_`y' = b_`y'[1,5]+b_`y'[1,1]
			local women_s_`y' = b_`y'[1,5]+b_`y'[1,4]+b_`y'[1,1]		
			display `var_`y''
			display `gap_`y''
			replace wgt = `var_`y'' if jahr==`y' 
			replace wagegap = `gap_`y'' if jahr==`y' 
			replace wage_u = `men_u_`y'' if jahr==`y' & geschl==1
			replace wage_u = `women_u_`y'' if jahr==`y' & geschl==2
			replace wage_s = `men_s_`y'' if jahr==`y' & geschl==1
			replace wage_s = `women_s_`y'' if jahr==`y' & geschl==2	
		} */

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


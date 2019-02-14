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
		reg loglohn i.skilled i.geschl age age2 i.nonwhite if jahr==`y', robust
		mat covar_`y'_`a' = e(V)
		local var_`y'_`a' = 1/covar_`y'_`a'[2,2]
		mat b_`y'_`a' = e(b)
		local gap_`y'_`a' = b_`y'_`a'[1,2]
		replace wgt = `var_`y'_`a'' if jahr==`y' 
		replace wagegap = `gap_`y'_`a'' if jahr==`y' 
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
			replace wage_s = `women_s_`y'' if jahr==`y' & geschl==2	*/			
			}
		
	collapse (mean) wagegap wgt wage_u wage_s, by(jahr)
	gen ind = 0
	
	save wage_reg_age_us.dta, replace


	use labor_age_skill_us.dta, clear
	merge 1:1 jahr using wage_reg_age_us.dta, nogen
	rename wagegap logwage
	sort jahr
	gen t = _n

	gen early = jahr < 1983
	gen late = jahr > 2002
	keep if jahr > 1980
	
	reg logwage t loglabor  [aw=wgt]
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

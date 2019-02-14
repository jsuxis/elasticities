cap program drop cardlemieuxind

program define cardlemieuxind, rclass

	preserve
	gen wagegap = .
	gen wgt = .
	gen wage_u = .
	gen wage_s = .
	gen age2=age^2
	keep if altersgr >1 & altersgr <9
	
	forval i=1/7 {
		forval y=1992(1)2016 {
			reg loglohn i.skilled i.geschl age age2 if jahr==`y' & ind==`i', robust
			mat covar_`y'_`i' = e(V)
			local var_`y'_`i' = 1/covar_`y'_`i'[2,2]
			mat b_`y'_`i' = e(b)
			local gap_`y'_`i' = b_`y'_`i'[1,2]
			replace wgt = `var_`y'_`i'' if jahr==`y' & ind==`i'  
			replace wagegap = `gap_`y'_`i'' if jahr==`y' & ind==`i' 
			}
		}
	
	collapse (mean) wagegap wgt wage_u wage_s, by(jahr ind)

	append using wage_reg_age.dta
	save wage_reg_age_ind.dta, replace


	use labor_age_ind.dta, clear
	append using labor_age.dta
	merge 1:1 jahr ind using wage_reg_age_ind.dta, nogen
	rename wagegap logwage
	sort ind jahr
	by ind: gen t = _n
	gen t2 = t*t
	sort jahr ind
	by jahr: gen loglabortotal = loglabor[1]
	keep if jahr >= 1992
	sort ind jahr
	// Alternative potential instrument:
	by ind: gen lagged = loglabor[_n-1]

	forval i=1/7 {
		ivreg2 logwage t (loglabor = loglabortotal)  [aw=wgt] if ind==`i' , first liml
		mat betas = e(b)
		scalar F_`i' = e(widstat)
		mat list betas
		local r1 = betas[1,1]
		local r2 = betas[1,2]
		local sigE_`i' = -1/`r1'
		local sigA_`i' = `r2'
		display _newline "Sigma E Industry `i': `sigE_`i''"
		display _newline "Sigma A Industry `i': `sigA_`i''"
		return scalar sigE_coll_`i' = `sigE_`i''
		return scalar Trend_`i' = `sigA_`i''
		return scalar F_`i' = F_`i'
		}
	

	*use bootstrap_input.dta, clear
	restore
end


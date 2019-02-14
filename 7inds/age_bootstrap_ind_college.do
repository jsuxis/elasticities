cap program drop cardlemieuxind

program define cardlemieuxind, rclass

	preserve
	gen wagegap = .
	gen wgt = .
	gen wage_u = .
	gen wage_s = .
	tempfile start end
	save `start', replace
	collapse (mean) loglohn, by(jahr altersgr ind skilled)
	reshape wide loglohn, i(jahr altersgr ind) j(skilled)
	rename loglohn0 wage_u
	rename loglohn1 wage_s
	save `end', replace
	use `start', clear
	
	forval i=1/7 {
		
		forval y=1992(2)2016 {
			forval a=2/8 {
				reg loglohn i.skilled i.geschl age if jahr==`y' & altersgr==`a' & ind==`i', robust
				mat covar_`y'_`a'_`i' = e(V)
				local var_`y'_`a'_`i' = 1/covar_`y'_`a'_`i'[2,2]
				mat b_`y'_`a'_`i' = e(b)
				local gap_`y'_`a'_`i' = b_`y'_`a'_`i'[1,2]
				replace wgt = `var_`y'_`a'_`i'' if jahr==`y' & altersgr==`a' & ind==`i'  
				replace wagegap = `gap_`y'_`a'_`i'' if jahr==`y' & altersgr==`a' & ind==`i'
				}
			}
		}
	
	collapse (mean) wagegap wgt, by(jahr altersgr ind)
	merge 1:1 jahr altersgr ind using `end', nogen
	save wage_reg_age_ind.dta, replace
	save wage_reg_age_ind_college.dta, replace


	use labor_age_ind_college.dta, clear
	merge 1:1 jahr altersgr ind using wage_reg_age_ind.dta, nogen
	keep if altersgr >1 & altersgr <9
	rename wagegap logwage
	sort altersgr jahr
	by altersgr: gen t = _n
	gen t2=t*t

	save firststep_ind.dta, replace
	
* First Step
	gen outcome_u = .
	gen outcome_s = .
	
	append using firststep.dta
	
	sort jahr altersgr ind
	by jahr altersgr: gen loglabortotal = loglabor[1]
	forval i=1/7 {
		ivregress 2sls logwage i.jahr i.altersgr (loglabor = loglabortotal) if ind==`i', robust 
		mat temp_`i' = e(b)
		local sigA_`i' = -temp_`i'[1,1]
		replace outcome_u = wage_u + `sigA_`i''*stundeges20 if ind == `i'
		replace outcome_s = wage_s + `sigA_`i''*stundeges21 if ind == `i'
		// the following only works for given amount of t, adjust submatrices as needed		
		reg outcome_u i.jahr ibn.altersgr if ind == `i', nocon
		mat alpha_`i' = e(b)
		mat alpha_`i' = alpha_`i'[1,14..20]
		reg outcome_s i.jahr ibn.altersgr if ind == `i', nocon
		mat beta_`i' = e(b)
		mat beta_`i' = beta_`i'[1,14..20]
		scalar sig_`i' = `sigA_`i''
		}
	
	rename stundeges20 h_l
	rename stundeges21 h_h
	keep h_l h_h jahr altersgr ind
	reshape wide h_l h_h, i(jahr ind) j(altersgr)
	sort ind jahr
	gen L = .
	gen H = .
	drop if ind == 0
	// matacode is also dependent on t, adjust this too
	forval i=1/7 {
		mata: matacode_ind`i'()
		}
	
	keep jahr ind L H
	save age_2step_ind.dta, replace
	
	use firststep_ind.dta, clear

	merge m:1 jahr ind using age_2step_ind.dta, nogen update
	append using firststep.dta
	merge m:1 ind jahr  using age_2step.dta, update
	gen ratio1 = log(H/L)
	gen ratio2 = loglabor - ratio1
	sort jahr ind
	keep if altersgr >1 & altersgr <9
	by jahr: gen loglabortotal = ratio1[1]
	sort jahr altersgr ind
	by jahr altersgr: gen loglabortotal2 = ratio2[1]
	keep if jahr >= 1992
	gen late = jahr >= 2008


	forval i=1/7 {
		ivregress 2sls logwage t t2 i.altersgr (ratio1 ratio2 = loglabortotal loglabortotal2 )  [aw=wgt] if ind==`i'
		
		mat betas = e(b)
		mat list betas
		local r1 = betas[1,1]
		local r2 = betas[1,2]
		local r3 = betas[1,3]
		local sigE_`i' = -1/`r1'
		local sigA_`i' = -1/`r2'
		display _newline "Sigma E Industry `i': `sigE_`i''"
		display _newline "Sigma A Industry `i': `sigA_`i''"
		return scalar sigmaE_`i' = `sigE_`i''
		return scalar sigmaA_`i' = `sigA_`i''
		return scalar trend_`i' = `r3'
		}
	
	restore
end


clear mata
mata:
	function matacode_ind1()
	{
		upper = 1 
		lower = 13
		alpha = st_matrix("alpha_1")
		beta = st_matrix("beta_1")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_1")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}
	
		function matacode_ind2()
	{
		upper = 1+(2-1)*13 
		lower = 2*13
		alpha = st_matrix("alpha_2")
		beta = st_matrix("beta_2")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_2")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}
	function matacode_ind3()
	{
		upper = 1+(3-1)*13 
		lower = 3*13
		alpha = st_matrix("alpha_3")
		beta = st_matrix("beta_3")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_3")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}
	function matacode_ind4()
	{
		upper = 1+(4-1)*13 
		lower = 4*13
		alpha = st_matrix("alpha_4")
		beta = st_matrix("beta_4")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_4")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}
	function matacode_ind5()
	{
		upper = 1+(5-1)*13 
		lower = 5*13
		alpha = st_matrix("alpha_5")
		beta = st_matrix("beta_5")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_5")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}
	function matacode_ind6()
	{
		upper = 1+(6-1)*13 
		lower = 6*13
		alpha = st_matrix("alpha_6")
		beta = st_matrix("beta_6")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_6")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}
	function matacode_ind7()
	{
		upper = 1+(7-1)*13 
		lower = 7*13
		alpha = st_matrix("alpha_7")
		beta = st_matrix("beta_7")
		L_j = st_data((upper, lower),"h_l*")
		H_j = st_data((upper, lower),"h_h*")
		sigA = st_numscalar("sig_7")
		sigA
		eta = 1-sigA
		alpha = alpha :/ rowsum(alpha)
		alpha
		beta = beta :/ rowsum(beta)
		beta
		L_j
		H_j
		eta
		L_j = L_j :^ eta
		H_j = H_j :^ eta
		L_t = alpha*L_j'
		L_t = L_t :^ (1/eta)
		H_t = beta*H_j'
		H_t = H_t :^ (1/eta)
		L_t 
		H_t
		st_store((upper, lower),"L",L_t')
		st_store((upper, lower),"H",H_t')	
		}

end

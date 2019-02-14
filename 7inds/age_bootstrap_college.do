cap program drop cardlemieux

program define cardlemieux, rclass

	preserve
	gen wagegap = .
	gen wgt = .
	gen wage_u = .
	gen wage_s = .
	tempfile start end
	save `start', replace
	collapse (mean) loglohn, by(jahr altersgr skilled)
	reshape wide loglohn, i(jahr altersgr) j(skilled)
	rename loglohn0 wage_u
	rename loglohn1 wage_s
	save `end', replace
	use `start', clear
		
	forval y=1992(2)2016 {
		forval a=2/8 {
			reg loglohn i.skilled i.geschl age if jahr==`y' & altersgr==`a', robust
			mat covar_`y'_`a' = e(V)
			local var_`y'_`a' = 1/covar_`y'_`a'[2,2]
			mat b_`y'_`a' = e(b)
			local gap_`y'_`a' = b_`y'_`a'[1,2]
			replace wgt = `var_`y'_`a'' if jahr==`y' & altersgr==`a'  
			replace wagegap = `gap_`y'_`a'' if jahr==`y' & altersgr==`a' 
			/*reg loglohn i.skilled##i.geschl age if jahr==`y' & altersgr==`a', robust
			mat covar_`y'_`a' = e(V)
			local var_`y'_`a' = 1/covar_`y'_`a'[2,2]
			mat b_`y'_`a' = e(b)
			local gap_men_`y'_`a' = b_`y'_`a'[1,2]
			local gap_women_`y'_`a' = b_`y'_`a'[1,2]+b_`y'_`a'[1,8]
			replace wgt = `var_`y'_`a'' if jahr==`y' & altersgr==`a'  
			replace wagegap = `gap_men_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==0
			replace wagegap = `gap_women_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==1	*//*
			reg loglohn skilled age if jahr==`y' & altersgr==`a' & geschl==1, robust
			mat covar_`y'_`a' = e(V)
			local var_`y'_`a' = 1/covar_`y'_`a'[1,1]
			mat b_`y'_`a' = e(b)
			local gap_men_`y'_`a' = b_`y'_`a'[1,1]
			local men_u_`y'_`a' = b_`y'_`a'[1,2]*age +b_`y'_`a'[1,3] 
			local men_s_`y'_`a' = b_`y'_`a'[1,1] + b_`y'_`a'[1,2]*age +b_`y'_`a'[1,3] 
			replace wgt = `var_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==1
			reg loglohn skilled age if jahr==`y' & altersgr==`a' & geschl==2, robust
			mat covar_`y'_`a' = e(V)
			local var_`y'_`a' = 1/covar_`y'_`a'[1,1]
			mat b_`y'_`a' = e(b)
			local gap_women_`y'_`a' = b_`y'_`a'[1,1]
			local women_u_`y'_`a' = b_`y'_`a'[1,2]*age +b_`y'_`a'[1,3] 
			local women_s_`y'_`a' = b_`y'_`a'[1,1] + b_`y'_`a'[1,2]*age +b_`y'_`a'[1,3]
			replace wgt = `var_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==2
			replace wagegap = `gap_men_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==1
			replace wagegap = `gap_women_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==2
			replace wage_u = `men_u_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==1
			replace wage_u = `women_u_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==2
			replace wage_s = `men_s_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==1
			replace wage_s = `women_s_`y'_`a'' if jahr==`y' & altersgr==`a' & geschl==2*/	
			}
		}
	
	collapse (mean) wagegap wgt, by(jahr altersgr)
	merge 1:1 jahr altersgr using `end', nogen
	gen ind = 0
	
	save wage_reg_age_college.dta, replace


	use labor_age_college.dta, clear
	merge 1:1 jahr altersgr  using wage_reg_age_college.dta, nogen
	keep if altersgr >1 & altersgr <9
	rename wagegap logwage
	sort altersgr jahr
	by altersgr: gen t = _n
	gen t2=t*t

	save firststep.dta, replace
	
* First Step
	reg logwage loglabor i.jahr i.altersgr , robust 
	mat temp = e(b)
	local sigA = -temp[1,1]
	gen outcome_u = wage_u + `sigA'*stundeges20
	gen outcome_s = wage_s + `sigA'*stundeges21

	reg outcome_u i.jahr ibn.altersgr, nocon
	mat alpha = e(b)
	mat alpha = alpha[1,14..20]
	mat list alpha
	reg outcome_s i.jahr ibn.altersgr, nocon
	mat beta = e(b)
	mat beta = beta[1,14..20]
	mat list beta
	scalar sig = `sigA'
	
	rename stundeges20 h_l
	rename stundeges21 h_h
	keep h_l h_h jahr altersgr
	reshape wide h_l h_h, i(jahr) j(altersgr)
	gen L = .
	gen H = .
	
	mata: matacode()

	
	keep jahr L H
	gen ind = 0
	save age_2step.dta, replace
	
	use firststep.dta, clear
	merge m:1 jahr using age_2step.dta, nogen
	gen ratio1 = log(H/L)
	gen ratio2 = loglabor - ratio1
	keep if jahr >= 1992
	gen late = jahr >= 2008
	
	reg logwage t i.altersgr ratio1 ratio2 [aw=wgt]
	mat betas = e(b)
	local r1 = betas[1,9]
	local r2 = betas[1,10]
	local sigE = -1/`r1'
	local sigA = -1/`r2'
	local r3 = betas[1,1]
	display _newline "Sigma E: `sigE'"
	display _newline "Sigma A: `sigA'"
	return scalar sigmaE = `sigE'
	return scalar sigmaA = `sigA'
	return scalar trend = `r3'
	*use bootstrap_input.dta, clear
	restore
end


clear mata
mata:
	function matacode()
	{
		alpha = st_matrix("alpha")
		beta = st_matrix("beta")
		L_j = st_data(.,"h_l*")
		H_j = st_data(.,"h_h*")
		sigA = st_numscalar("sig")
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
		st_store(.,"L",L_t')
		st_store(.,"H",H_t')	
		}

end

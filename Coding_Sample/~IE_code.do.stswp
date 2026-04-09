/*==============================================================================
   Project:     Effect of parental death on education
   Do-file:     Sample construction and variable creation

   Description:
   This do-file builds the analysis sample by round, appends all rounds into
   a panel, corrects inconsistencies in the orphanhood variable, and constructs
   the main outcome and treatment variables
   
	* Note 1: Comments in original dofile were made in spanish. This is the translated 
	version
 
   * Note 2: This do-file is a coding sample illustrating workflow. Some
   limitations reflect survey design issues, and a few are coding imperfections I
   identified after the analysis was completed
==============================================================================*/


/*
	Contents:
	
	1. Directory setup
	2. Sample by round 
	4. Final sample
*/



*-----------------------------*
*    1. Directory setup       *
*-----------------------------*

cd "C:\Users\VICTOR\Desktop\IE\Bases_ie"


*-----------------------------*
*    2. Sample by round       *
*-----------------------------*

*--- R1.1 Sample selection ---*

use "R1\pechildlevel1yrold.dta", clear

* Drop children whose parents were already dead at baseline
codebook momlive
drop if momlive == 3   // mother deceased
drop if daddead == 3   // father deceased

*--- R1.2 Save ---*

keep childid
save muestra_r1.dta, replace




*--- R2.1 Sample selection ---*

use "R2\pechildlevel5yrold.dta", clear

* Restrict to children with living biological parents in R1
merge 1:1 childid using muestra_r1.dta
keep if _merge == 3
drop _merge

* Drop children lost to attrition
drop if situac_r2 != 1

* Drop children with a deceased or stepparent at baseline
drop if dadal == 0 | mumal == 0
drop if dadal == 1 & mumal == 1 & biodad == 0 | biomum == 0

* Recover parental status for children who didn't answer dadal but answered biodad
replace dadal = 1 if dadal == . & biodad == 1

*--- R2.2 Variable construction ---*

* X: treatment variables (no orphans in R2 by construction)
gen ronda      = 2
gen orphanhood = 0
gen orphan_dad = 0
gen orphan_mom = 0

* Y: outcome variables
egen gasto_educ = rowtotal(spyr11a spyr12a spyr13a spyr15 spyr16)

merge 1:1 childid using "R2\horas_actividades_r2.dta"
keep if _merge == 3   // Drop children with no time-use data
drop _merge

*--- R2.3 Save ---*

keep childid ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

save muestra_r2.dta, replace




*--- R3.1 Sample selection ---*

use "R3\pe_yc_childlevel.dta", clear

* Restrict to children active in R2 (drops R1/R2 deceased parents and R2-R3 attrition)
merge 1:1 childid using muestra_r2.dta
keep if _merge == 3
drop _merge

* Drop R2 variables before merging R3 data
drop ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

* Merge household-level file (parental information stored separately in R3)
merge 1:1 childid using "R3\pe_yc_householdlevel.dta"
keep if _merge == 3
drop _merge

*--- R3.2 Variable construction ---*

* X: treatment variables
gen ronda      = 3
gen orphanhood = 0
replace orphanhood = 1 if dadalr3 == 0 | mumalr3 == 0
gen orphan_dad = 0
replace orphan_dad = 1 if dadalr3 == 0
gen orphan_mom = 0
replace orphan_mom = 1 if mumalr3 == 0

* Y: outcome variables
egen gasto_educ = rowtotal(spyrr311 spyrr312 spyrr313 spyrr315 spyrr316)

gen estudia = .
replace estudia = 1 if enrschr3 == 1
replace estudia = 0 if enrschr3 == 0
drop enrschr3

merge 1:1 childid using "R3\horas_actividades_r3.dta"
keep if _merge == 3
drop _merge

*--- R3.3 Save ---*

keep childid ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

save muestra_r3.dta, replace




*--- R4.1 Sample selection ---*

use "R4\pe_r4_ycch_youngerchild.dta", clear

* Standardize childid format to match earlier rounds (e.g., PE031055)
tostring CHILDCODE, gen(childid_aux)
replace childid_aux = "0" + childid_aux if strlen(childid_aux) == 5
gen childid = "PE" + childid_aux
drop childid_aux CHILDCODE

* Restrict to children active in R3
* Note: children lost in R3 are still in the final sample if observed in R2 and R4
merge 1:1 childid using muestra_r3.dta
keep if _merge == 3
drop _merge

* Drop R3 variables before merging R4 data
drop ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

* Merge household-level file (parental information stored separately in R4)
merge 1:1 childid using "R4\R4_ychousehold.dta"
keep if _merge == 3
drop _merge

*--- R4.2 Variable construction ---*

* X: treatment variables
gen ronda      = 4
gen orphanhood = 0
replace orphanhood = 1 if DADALR4 == 0 | MUMALR4 == 0
gen orphan_dad = 0
replace orphan_dad = 1 if DADALR4 == 0
gen orphan_mom = 0
replace orphan_mom = 1 if MUMALR4 == 0

* Y: outcome variables
merge 1:1 childid using "R4\R4_ycnonfoodconsumption.dta"
keep if _merge == 3
drop _merge

rename SLEEPR4  horas_sleep
rename CROTHR4  horas_care
rename DMTSKR4  horas_chores
rename TSFARMR4 horas_npaywork
rename ACTPAYR4 horas_paywork
rename ATSCHR4  horas_school
rename STUDYGR4 horas_study

gen estudia = .
replace estudia = 1 if ENRSCHR4 == 1
replace estudia = 0 if ENRSCHR4 == 0
drop ENRSCHR4

*--- R4.3 Save ---*

keep childid ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

save muestra_r4.dta, replace




*--- R5.1 Sample selection ---*

use "R5\pe_r5_ycch_youngerchild.dta", clear

* Standardize childid format to match earlier rounds
tostring CHILDCODE, gen(childid_aux)
replace childid_aux = "0" + childid_aux if strlen(childid_aux) == 5
gen childid = "PE" + childid_aux
drop childid_aux CHILDCODE

* Restrict to children active in R4
* Note: children lost in R4 are still in the final sample if observed in R2, R3, and R5
merge 1:1 childid using muestra_r4.dta
keep if _merge == 3
drop _merge

* Drop R4 variables before merging R5 data
drop ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

* Merge household-level file (parental information stored separately in R5)
merge 1:1 childid using "R5\R5_ychousehold.dta"
keep if _merge == 3
drop _merge

*--- R5.2 Variable construction ---*

* X: treatment variables
gen ronda      = 5
gen orphanhood = 0
replace orphanhood = 1 if DADALR5 == 0 | MUMALR5 == 0
gen orphan_dad = 0
replace orphan_dad = 1 if DADALR5 == 0
gen orphan_mom = 0
replace orphan_mom = 1 if MUMALR5 == 0

* Y: outcome variables
merge 1:1 childid using "R5\R5_ycnonfoodconsumption.dta"
keep if _merge == 3
drop _merge

rename SLEEPR5  horas_sleep
rename CROTHR5  horas_care
rename DMTSKR5  horas_chores
rename TSFARMR5 horas_npaywork
rename ACTPAYR5 horas_paywork
rename ATSCHR5  horas_school
rename STUDYGR5 horas_study

gen estudia = .
replace estudia = 1 if ENRSCHR5 == 1
replace estudia = 0 if ENRSCHR5 == 0
drop ENRSCHR5

*--- R5.3 Save ---*

keep childid ronda orphanhood orphan_dad orphan_mom gasto_educ ///
     horas_sleep horas_care horas_chores horas_paywork horas_npaywork ///
     horas_study horas_school estudia

save muestra_r5.dta, replace


*-----------------------------*
*    3. Final sample          *
*-----------------------------*

cd "C:\Users\VICTOR\Desktop\IE\Bases_ie"

*--- 3.1 Append rounds ---*

use muestra_r2.dta, clear
append using muestra_r3.dta
append using muestra_r4.dta
append using muestra_r5.dta

*--- 3.2 Correct orphanhood inconsistencies ---*

* Some children appear to "revive" a deceased parent across rounds due to questionnaire errors (questions about parents changed from one survey to another). The affected IDs are corrected manually below.

sort childid ronda
bysort childid: egen suma     = total(orphanhood)
bysort childid: egen suma_dad = total(orphan_dad)
bysort childid: egen suma_mom = total(orphan_mom)

* Father deaths recorded late (should be R4)
foreach id in "PE031055" "PE071024" "PE111052" "PE121029" "PE161050" "PE171092" "PE181093" {
    replace orphanhood = 1 if childid == "`id'" & ronda == 4
    replace orphan_dad = 1 if childid == "`id'" & ronda == 4
}

* Mother death recorded late (should be R4)
replace orphanhood = 1 if childid == "PE091056" & ronda == 4
replace orphan_mom = 1 if childid == "PE091056" & ronda == 4

* Additional father death recorded late (should be R5)
replace orphanhood = 1 if childid == "PE121051" & ronda == 5
replace orphan_dad = 1 if childid == "PE121051" & ronda == 5

drop suma suma_dad suma_mom

*--- 3.3 Treatment variable G ---*

* G = first round in which a parent dies; 0 if never bereaved
bysort childid (ronda): egen G = min(cond(orphanhood == 1, ronda, .))
replace G = 0 if missing(G)

*--- 3.4 Merge auxiliary datasets ---*

* Cluster identifiers
merge m:1 childid using "base_clusters.dta"
keep if _merge == 3
drop _merge

* Time-invariant controls
merge m:1 childid using base_controles.dta
keep if _merge == 3
drop _merge

merge m:1 childid using base_controles_2.dta
keep if _merge == 3
drop _merge

* PPVT scores by round
merge m:1 childid using notas_ppvt.dta
keep if _merge == 3
drop _merge

gen ppvt = .
replace ppvt = porcentaje_ppvt_r2 if ronda == 2
replace ppvt = porcentaje_ppvt_r3 if ronda == 3
replace ppvt = porcentaje_ppvt_r4 if ronda == 4
replace ppvt = porcentaje_ppvt_r5 if ronda == 5

drop porcentaje_ppvt_r3 porcentaje_ppvt_r4 porcentaje_ppvt_r5
drop acces*

*--- 3.5 Clean time-use variables ---*

* Values above 24 are coding errors (likely 88 = not applicable)
foreach var of varlist horas_sleep horas_care horas_chores ///
                       horas_npaywork horas_paywork horas_school horas_study {
    replace `var' = . if `var' > 24
}

*--- 3.6 Deflate education expenditure ---*

* CPI from BCRP (base year = 100)
* 2006: 62.65  |  2009: 69.44  |  2013: 77.66  |  2016: 86.00
gen gasto_real = .
replace gasto_real = gasto_educ / 62.65011092 * 100 if ronda == 2
replace gasto_real = gasto_educ / 69.43510712 * 100 if ronda == 3
replace gasto_real = gasto_educ / 77.6556915  * 100 if ronda == 4
replace gasto_real = gasto_educ / 86.00411314 * 100 if ronda == 5

*--- 3.7 Save ---*

save muestra_FINAL.dta, replace

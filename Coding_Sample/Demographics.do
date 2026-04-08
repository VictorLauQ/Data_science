/*==============================================================================
   Do-file:     Demographics
   Date:        January 23, 2026
   
   Description: 
   This do-file constructs household-level demographic variables using the Ghana 	
   Living Standards Survey (GLSS7), 2016–2017.
==============================================================================*/

/*
	Contents:
	
	1. Directory setup
	2. Identifiers dataset
	3. Construction of variables
		3.1 Household variables (1 & 2)
		3.2 Educational variables (3,4 & 5)
	4. Final dataset
*/


*-----------------------------*
*    1. Directory setup       *
*-----------------------------*

* Path
global path "C:\Users\VICTOR\Desktop\FAO\Replication_Ghana"
cd $path

* Folders
global data "$path\data"
global do_files "$path\do_files"
global dta_files "$path\dta_files"
global temp "$path\temp"

* Data
global data_sec0   "$path\data\g7sec0.dta"
global data_sec1_5 "$path\data\g7sec1_5.dta"


*-----------------------------*
*    2. Identifiers dataset   *
*-----------------------------*

use $data_sec0, clear
describe
isid hid   // confirm  variable hid uniquely identifies observations

gen country = "Ghana"
keep hid country region district
save "$temp\hhid.dta", replace


*-----------------------------*
*   3. Variable construction  *
*-----------------------------*

*--- 3.1 Household composition variables ---*

use $data_sec1_5, clear
merge m:1 hid using "$temp\hhid.dta"
keep if _merge == 3   // Drop obs not matched in both datasets (should be none)
drop _merge

* (2) fem_head: Dummy = 1 if any individual in the household is female
codebook s1q2 s1q3
label list S1Q2 S1Q3   // s1q2: 2 = female and s1q3: 1 = head

sort hid
by hid: egen fem_head = max(s1q2 == 2 & s1q3 == 1)

* (1) hhsize
count if missing(s1q24)
sort hid
by hid: egen hhsize = total(s1q24 == 1)

* Collapse to household level
collapse (first) hhsize fem_head region district, by(hid)
save "$temp\Demographics_1.dta", replace


*--- 3.2 Education variables ---*
{
* Litearture regarding educational system in Ghana:   							*https://www.researchgate.net/publication/316035018_Educational_Reforms_in_Ghana_Past_and_Present
	* US Embassy: https://gh.usembassy.gov/educational-system-of-ghana/
	* AACRAO: https://www.aacrao.org/edge/country/ghana
	* WENR: https://wenr.wes.org/2000/03/ewenr-marchapril-2000-education-in-ghana
	
* Ghanian old system:
	* Primary school: 6 years
	* Middle school: up to 4 years
	* Secondary school: 5 years (O-levels)
	* Secondary school: 2 years (A-levels)
	* University: 3 years
	
* Ghanian current system:
	* Primary school: 6 years
	* JSS/JHS: 3 years
	* SSS: 3 years but from 2007-2010 -> SHS: 4 years
	* University: 4 years
}

use $data_sec1_5, clear

merge m:1 hid using "$temp\hhid.dta"
keep if _merge == 3   // drop obs not matched in both datasets
drop _merge

codebook s2aq1b s2aq2
label list S2AQ1B S2AQ2
count if missing(s2aq1b)
count if missing(s2aq2)

order hid s2aq1b s2aq2
sort  s2aq1b s2aq2   // Inspect level-grade combinations

gen yrs_educ = 0

	* No education, Kindergarden and Dont know responses
	replace yrs_educ = 0  if inlist(s2aq1b, 0, 1, 13)

	* Primary 
	replace yrs_educ = 0  if s2aq1b == 2 & s2aq2 == 0
	replace yrs_educ = 1  if s2aq1b == 2 & s2aq2 == 11
	replace yrs_educ = 2  if s2aq1b == 2 & s2aq2 == 12
	replace yrs_educ = 3  if s2aq1b == 2 & s2aq2 == 13
	replace yrs_educ = 4  if s2aq1b == 2 & s2aq2 == 14
	replace yrs_educ = 5  if s2aq1b == 2 & s2aq2 == 15
	replace yrs_educ = 6  if s2aq1b == 2 & s2aq2 == 16
	
	* JSS/JHS
	replace yrs_educ = 6  if s2aq1b == 3 & s2aq2 == 0
	replace yrs_educ = 7  if s2aq1b == 3 & s2aq2 == 17
	replace yrs_educ = 8  if s2aq1b == 3 & s2aq2 == 18
	replace yrs_educ = 9  if s2aq1b == 3 & s2aq2 == 19
	
	* Middle (old system)
	replace yrs_educ = 6   if s2aq1b == 4 & s2aq2 == 0
	replace yrs_educ = 7   if s2aq1b == 4 & s2aq2 == 20
	replace yrs_educ = 8   if s2aq1b == 4 & s2aq2 == 21
	replace yrs_educ = 9   if s2aq1b == 4 & s2aq2 == 22
	replace yrs_educ = 10  if s2aq1b == 4 & s2aq2 == 23
	
	* SSS/SHS
	replace yrs_educ = 9  if s2aq1b == 5 & s2aq2 == 0
	replace yrs_educ = 10 if s2aq1b == 5 & s2aq2 == 24
	replace yrs_educ = 11 if s2aq1b == 5 & s2aq2 == 25
	replace yrs_educ = 12 if s2aq1b == 5 & s2aq2 == 26
	replace yrs_educ = 13 if s2aq1b == 5 & s2aq2 == 27
	
	* Secondary (old system)
	replace yrs_educ = 10  if s2aq1b == 6 & s2aq2 == 0
	replace yrs_educ = 11  if s2aq1b == 6 & s2aq2 == 28
	replace yrs_educ = 12  if s2aq1b == 6 & s2aq2 == 29
	replace yrs_educ = 13  if s2aq1b == 6 & s2aq2 == 30
	replace yrs_educ = 14  if s2aq1b == 6 & s2aq2 == 31
	replace yrs_educ = 15  if s2aq1b == 6 & s2aq2 == 32
	
	replace yrs_educ = 16  if s2aq1b == 6 & s2aq2 == 33
	replace yrs_educ = 17  if s2aq1b == 6 & s2aq2 == 34
	
	* Voc/Tech/Comm
	replace yrs_educ = 14 if s2aq1b == 7 & s2aq2 == 0
	replace yrs_educ = 15 if s2aq1b == 7 & s2aq2 == 41
	replace yrs_educ = 16 if s2aq1b == 7 & s2aq2 == 42
	replace yrs_educ = 17 if s2aq1b == 7 & s2aq2 == 43
	replace yrs_educ = 18 if s2aq1b == 7 & s2aq2 == 44
	replace yrs_educ = 19 if s2aq1b == 7 & s2aq2 == 45
	replace yrs_educ = 20 if s2aq1b == 7 & s2aq2 == 46
	
	* Teacher Training/Agric/ Nursing Cert
	replace yrs_educ = 14 if s2aq1b == 8 & s2aq2 == 0
	replace yrs_educ = 15 if s2aq1b == 8 & s2aq2 == 41
	replace yrs_educ = 16 if s2aq1b == 8 & s2aq2 == 42
	replace yrs_educ = 17 if s2aq1b == 8 & s2aq2 == 43
	replace yrs_educ = 18 if s2aq1b == 8 & s2aq2 == 44
	replace yrs_educ = 19 if s2aq1b == 8 & s2aq2 == 45
	replace yrs_educ = 20 if s2aq1b == 8 & s2aq2 == 46
	
	* Polytechnic
	replace yrs_educ = 14 if s2aq1b == 9 & s2aq2 == 0
	replace yrs_educ = 15 if s2aq1b == 9 & s2aq2 == 41
	replace yrs_educ = 16 if s2aq1b == 9 & s2aq2 == 42
	replace yrs_educ = 17 if s2aq1b == 9 & s2aq2 == 43
	replace yrs_educ = 18 if s2aq1b == 9 & s2aq2 == 44
	replace yrs_educ = 19 if s2aq1b == 9 & s2aq2 == 45
	replace yrs_educ = 20 if s2aq1b == 9 & s2aq2 == 46
	
	* University (Bachelor)
	replace yrs_educ = 14 if s2aq1b == 10 & s2aq2 == 0
	replace yrs_educ = 15 if s2aq1b == 10 & s2aq2 == 41
	replace yrs_educ = 16 if s2aq1b == 10 & s2aq2 == 42
	replace yrs_educ = 17 if s2aq1b == 10 & s2aq2 == 43
	replace yrs_educ = 18 if s2aq1b == 10 & s2aq2 == 44
	
	* Unviersity (Post Graduate)
	replace yrs_educ = 18 if s2aq1b == 11 & s2aq2 == 0
	replace yrs_educ = 19 if s2aq1b == 11 & s2aq2 == 41
	replace yrs_educ = 20 if s2aq1b == 11 & s2aq2 == 42
	replace yrs_educ = 21 if s2aq1b == 11 & s2aq2 == 43
	replace yrs_educ = 22 if s2aq1b == 11 & s2aq2 == 44
	replace yrs_educ = 23 if s2aq1b == 11 & s2aq2 == 45
	replace yrs_educ = 24 if s2aq1b == 11 & s2aq2 == 46
	
	* Professional (old system)
	replace yrs_educ = 18 if s2aq1b == 12 & s2aq2 == 0
	replace yrs_educ = 19 if s2aq1b == 12 & s2aq2 == 41
	replace yrs_educ = 20 if s2aq1b == 12 & s2aq2 == 42
	replace yrs_educ = 21 if s2aq1b == 12 & s2aq2 == 43
	replace yrs_educ = 22 if s2aq1b == 12 & s2aq2 == 44
	replace yrs_educ = 23 if s2aq1b == 12 & s2aq2 == 45
	replace yrs_educ = 24 if s2aq1b == 12 & s2aq2 == 46
	
* Note: Some individuals report completing a given level but record 0 grades (likely enrolled but dropped out in the first year). These are treated as 0 years at that level. Both s2aq1b and s2aq2 are used jointly to assign years of schooling

* Limitation: It is difficult to determine whether individuals with university education belong to the old or new system. Age at enrollment would help, but many individuals started school at ages other than 6
	
	
* (3) totyrs_educ: Total years of education summed across all members
sort hid
by hid: egen totyrs_educ = total(yrs_educ)

* (4) educave: Average years of education across members
by hid: egen educave = mean(yrs_educ)

* (5) edu_years_head: Years of education of the household head
codebook s1q3
label list S1Q3   // 1 = head

gen edu_years_head_aux = yrs_educ if s1q3 == 1
by hid: egen edu_years_head = max(edu_years_head_aux)
drop edu_years_head_aux

collapse (first) totyrs_educ educave edu_years_head country region district, by(hid)
save "$temp\Demographics_2.dta", replace


*-----------------------------*
*    4. Final dataset         *
*-----------------------------*

use "$temp\Demographics_2.dta", clear

merge 1:1 hid using "$temp\Demographics_1.dta"
keep if _merge == 3   // Drop obs not matched in both datasets
drop _merge

order hid country region district hhsize fem_head totyrs_educ educave edu_years_head

label var hhsize         "Number of household members"
label var fem_head       "Female household head (=1 if female)"
label var totyrs_educ    "Total years of education of all household members"
label var educave        "Average years of education across household members"
label var edu_years_head "Years of education of the household head"

save "$dta_files\Demog_hh.dta", replace

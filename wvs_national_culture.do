****************************************************************************************
* Fleming and Özak (2021). "Equal Under God"
* Program that generates country-level dataset based on WVS
* Code follows Desmet, Ortuño-Ortín, and Wacziarg (2017)
****************************************************************************************
clear all
capture cd "~/Dropbox"
capture cd "~/LatexMe"
cd "./Religion/equalundergod/"
set more off

* Load Data

use "data/WVS/Integrated_values_surveys_1981-2021.dta"

ren S002VS wave

foreach var of varlist * {
    di "`var'"
    local var2=lower("`var'")
    di "`var2'"
    capture rename `var' `var2'
}

decode s003, g(country)
compress

* Controls

ren g016 home_language
ren g026 mother_immigrant
ren g027 father_immigrant
ren g027a immigrant

label var x003 "Age"
replace x003 = 18 if x003 < 18 & x003 > 0
replace x003 = 100 if x003 > 100
ren x003 age

gen age10 = 1 if age<25
replace age10 = 2 if age<35 & age>=25
replace age10 = 3 if age<45 & age>=35
replace age10 = 4 if age<55 & age>=45
replace age10 = 5 if age<65 & age>=55
replace age10 = 6 if age>=65 & age~=.
label var age10 "Age Groups (10yr)"

gen age_major = 1 if age<25
replace age_major = 2 if age<45 & age>=25
replace age_major = 3 if age<65 & age>=45
replace age_major = 4 if age>=65 & age~=.
label var age_major "Major Age Groups"

gen age3 = 1 if age<25
replace age3 = 2 if age<65 & age>=25
replace age3 = 3 if age>=65 & age~=.
label var age3 "Age Groups (<25, 25-64, 65+)"


label var x025 "Education"
ren x025 educ


label var x025r "Education Level"
ren x025r educ_level


gen income_scale = x047_wvs
replace income_scale = x047_evs if missing(x047_wvs)
label var income_scale "Ten-Step Income Scale"


g male = x001 == 1 & !missing(x001)
gen birth = x002

g children = x011
replace children = 6 if children > 6

ren x028 employed 
ren x045 social_class
ren x007 married 

g iso2=s009

local controls = "male age* educ educ_level income_scale employed children social_class married birth home_language mother_immigrant father_immigrant immigrant iso2 cow_num cow_alpha s017 s018 s019 pwght" 

order s003 wave `controls' 

* Variables of Interest
replace a001 = . if a001 < 0
label var a001 "How Important Is Family?"
gen importantfam = 4-a001
label var importantfam "How Important is Family?"
gen famimportant = a001 == 1 if !missing(a001)
label var famimportant "a001 == 1"

replace a025 = . if a025 < 0
gen alwaysrespect = a025 == 1 if !missing(a025)
label var alwaysrespect "Always Repsect Parents"
gen earnrespect = a025 == 2 if !missing(a025)
label var earnrespect "Respect is Earned"

replace a026 = . if a026 < 0
gen parentduty = a026 == 1 if !missing(a026)
label var parentduty "Parent Duty to Children"
gen parentlife = a026 == 2 if !missing(a026)
label var parentlife "Parents Have Own Life"


replace a027 = . if a027 < 0
label var a027 "Good Manners"

replace a029 = . if a029 < 0
label var a029 "Independence"

replace a030 = . if a030 < 0
label var a030 "Hard Work"

replace a034 = . if a034 < 0
label var a034 "Imagination"

replace a035 = . if a035 < 0
label var a035 "Respect for Others"

replace a038 = . if a038 < 0
label var a038 "Thrift"

replace a041 = . if a041 < 0
label var a041 "Unselfishness"

replace a042 = . if a042 < 0
label var a042 "Obedience"

replace a124_02 = . if a124_02 < 0
label var a124_02 "Neighbors Different Race"

replace a124_06 = . if a124_06 < 0
label var a124_06 "Neighbors Immigrants"

replace a165 = . if a165 < 0
replace a165 = 0 if a165 == 2
label var a165 "General Trust"

replace a173 = . if a173 < 0
label var a173 "Freedom of Choice"

replace c001 = . if c001 < 0
replace c001 = 2 if c001 == 3
replace c001 = 0 if c001 == 2
label var c001 "Male Jobs Priority"

replace e036 = . if e036 < 0
label var e036 "Private Ownership"

replace e040 = . if e040 < 0
label var e040 "Hard Work Brings Success"

replace e235 = . if e235 < 0
label var e235 "Democracy"

/* replace e131 = . if e131 < 0 
gen poor_lazy = e131 == 1
label var poor_lazy "Poor Lazy"
gen poor_unfair = e131 == 2
label var poor_unfair "Poor Unfair" */

replace y003 = . if y003 < -2
rename y003 autonomy
replace autonomy = -autonomy

replace f114 = . if f114 < 0
label var f114 "Claim Benefits"

replace f115 = . if f115 < 0 
label var f115 "Avoid Bus Fare"

replace f116 = . if f116 < 0
label var f116 "Cheat Taxes"

replace f117 = . if f117 < 0
label var f117 "Accept Bribe"

replace f139 = . if f139 < 0
label var f139 "Stolen Gooods"

label var s003 "Country"
label var s020 "Year"

*convert all scale survey variables to binary 

g claim_benefits = f114 > 5 if !missing(f114)
label var claim_benefits "Claim Benefits"
g cheat_bus = f115 > 5 if !missing(f115)
label var cheat_bus "Cheat Bus Fare"
g cheat_tax = f116 > 5 if !missing(f116)
label var cheat_tax "Cheat Taxes"
g accept_bribe = f117 > 5 if !missing(f117)
label var accept_bribe "Accept Bribe"
g work_success = e040 < 6 if !missing(e040)
label var work_success "Hard Work Brings Success"
g freedom = a173 > 5 if !missing(a173)
label var freedom "Freedom of Choice"
g private = e036 < 6 if !missing(e036)
label var private "Private Ownership"
g democracy = e235 ==1 if e235 > 0
label var democracy "Democracy"
tab democracy


************************************************
* Create Variables from Literature
************************************************

*Collectivism:
g conformity = a042 + a027
label var conformity "Conformity"
g conformity_scale = conformity - a029 - a034
label var conformity_scale "Conformity (Scale)"

*Morality
pca a165 a035 
predict morality1, score
label var morality1 "Morality Index"

pca a165 a035 a042 a173
predict morality2, score
label var morality2 "Morality Index"

*Hierarchy
pca autonomy y020 y021
predict hierarchy, score
label var hierarchy "Hierarchy Index"

*Family Ties
pca a001 a025 a026
predict familyties, score
label var familyties "Family Ties"

*Social Capital
pca f114 f115 f116 f117 // f139
predict socialcap, score
label var socialcap "Social Capital"

local keep_vars = "a001 alwaysrespect parentduty a027 a029 a030 a034 a035 a038 a041 a042 a124_02 a124_06 a165 a173 c001 e036 e040 e235 autonomy f114 f115 f116 f117 f139 conformity conformity_scale morality1 morality2 hierarchy familyties socialcap"


keep s003 wave `controls' `keep_vars'

collapse `keep_vars' [pweight = pwght], by(s003 iso2 wave)

save national_culture_wvs, replace

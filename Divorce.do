***pre data***
import excel "C:\Users\DELL\Desktop\data_marriage_1.xlsx", sheet("Sheet1") firstrow
destring marriagecouple,replace
destring dirvorcecouple ,replace
tab marriagecouple
tab dirvorcecouple
save "C:\Users\DELL\Desktop\Divorce\data_marriage.dta", replace

***merge house data***
cd C:\Users\DELL\Desktop\Divorce\
merge 1:m year city1 using house
drop if _merge==2
sort city1 year
drop ln_house_price _merge
gen ln_house_price=log(house_price)
tab city1

***merge city data***
merge 1:m year city1 using city_index
drop if _merge==2
sort city1 year
tab city1
drop _merge

***rename variable***
rename GDP_市辖区 gdp
rename GDP增速_市辖区 gdp_growth
rename 人均GDP_市辖区 gdp_percapita
rename 一般公共预算支出_市辖区 public_invest
rename 一般公共预算支出_教育_市辖区 edu_invest
rename 户籍人口数_市辖区 people
rename 户籍人口自然增长率_市辖区 peo_growth
rename 城镇登记失业人员数_市辖区 unemploy
rename 道路面积_市辖区 roadarea
rename 建成区绿化覆盖率_市辖区 forest_ratio
rename 房地产开发投资_市辖区 house_invest
rename 普通中学学校数_市辖区 junior_school
rename 普通小学学校数_市辖区 primary_school
rename 普通中学专任教师数_市辖区 junior_teacher
rename 普通中学在校生数_市辖区 junior_student
rename 普通高等学校专任教师数_市辖区 high_teacher
rename 普通高等学校在校生数_市辖区 high_student
rename 普通小学专任教师数_市辖区 primary_teacher
rename 普通小学在校生数_市辖区 primary_student
rename 医疗卫生机构数_医院和卫生院_市辖区 hospital
rename 失业保险参保人数_市辖区 unemploy_insurance

keep city1 year marriagecouple dirvorcecouple policy firstround house_price ln_house_price gdp gdp_growth gdp_percapita public_invest edu_invest people peo_growth unemploy roadarea forest_ratio house_invest junior_school primary_school high_teacher junior_teacher primary_teacher high_student junior_student primary_student hospital unemploy_insurance

destring _all,replace

***clean***
gen population = people
replace population= people * 10000 if population < 1000

***merge 2019 population***
**Data_Final_v2

gen marriage_ratio = marriagecouple / population
gen dirvorce_ratio = dirvorcecouple / population

gen primary_teacher_student_ratio = primary_teacher/(primary_student*10000)
gen junior_teacher_student_ratio = junior_teacher / (junior_student*10000)
gen unemploy_ratio= unemploy/ population

gen ln_gdp_percapita=log(gdp_percapita)
gen ln_public_invest =log(public_invest)
gen ln_edu_invest =log(edu_invest )

encode city1, gen(city)
xtset city year

gen metropolis=0
replace metropolis=1 if city==2
replace metropolis=1 if city==11
replace metropolis=1 if city==32
replace metropolis=1 if city==52

gen capital=0
replace capital=1 if city==11
replace capital=1 if city==26
replace capital=1 if city==59
replace capital=1 if city==27
replace capital=1 if city==20

replace capital=1 if city==46
replace capital=1 if city==76
replace capital=1 if city==22
replace capital=1 if city==2
replace capital=1 if city==12

replace capital=1 if city==41
replace capital=1 if city==18
replace capital=1 if city==60
replace capital=1 if city==14
replace capital=1 if city==49

replace capital=1 if city==72
replace capital=1 if city==44
replace capital=1 if city==77
replace capital=1 if city==32
replace capital=1 if city==13

replace capital=1 if city==50
replace capital=1 if city==35
replace capital=1 if city==69
replace capital=1 if city==39
replace capital=1 if city==68

replace capital=1 if city==10
replace capital=1 if city==67
replace capital=1 if city==75
replace capital=1 if city==6

***mean variables***
egen mean_dirvorce=mean(dirvorce_ratio), by(year firstround)
egen mean_marriage=mean(marriage_ratio), by(year firstround)
egen mean_dirvorcecouple=mean(dirvorcecouple), by(year firstround)


****************************************************Please use Data_Final_v3 Here***
use Final_Data_v3.dta, clear


***Descriptive Analysis***

eststo all: estpost summarize population marriagecouple dirvorcecouple  ln_house_price ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital
eststo Policy2011: estpost summarize population marriagecouple dirvorcecouple  ln_house_price ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital if firstround==1
eststo Non_Policy2011: estpost summarize population marriagecouple dirvorcecouple  ln_house_price ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital if firstround==0
esttab all Policy2011 Non_Policy2011 using table1.tex, replace b(pattern(0 0 0 1) fmt(2)) cell("mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0))") mtitle("Full Sample" "Policy2011" "Non-Policy2011") 


***parallel trend assumption***
graph twoway (connect mean_dirvorce year if firstround==1,sort) (connect mean_dirvorce year if firstround==0,sort lpattern(dash)), ///
xline(2011,lpattern(dash) lcolor(gray)) ///
ytitle("mean_dirvorce") xtitle("year") ///
ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ///
legend(label(1 "Treated") label( 2 "Control")) ///
xlabel(2005 (1) 2019)  graphregion(color(white)) //

graph twoway (connect mean_marriage year if firstround==1,sort) (connect mean_marriage year if firstround==0,sort lpattern(dash)), ///
xline(2011,lpattern(dash) lcolor(gray)) ///
ytitle("mean_marriage") xtitle("year") ///
ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ///
legend(label(1 "Treated") label( 2 "Control")) ///
xlabel(2005 (1) 2019)  graphregion(color(white)) //

graph twoway (connect mean_dirvorcecouple year if firstround==1,sort) (connect mean_dirvorcecouple year if firstround==0,sort lpattern(dash)), ///
xline(2011,lpattern(dash) lcolor(gray)) ///
ytitle("mean_dirvorcecouple") xtitle("year") ///
ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ///
legend(label(1 "Treated") label( 2 "Control")) ///
xlabel(2005 (1) 2019)  graphregion(color(white)) //

***DID***

gen time=(year>=2011)&!missing(year)
gen did=time*firstround
diff mean_dirvorcecouple,t(firstround) p(time) cov(house_price gdp gdp_growth gdp_percapita public_invest edu_invest peo_growth unemploy roadarea forest_ratio house_invest primary_teacher_student_ratio junior_teacher_student_ratio hospital unemploy_insurance)

diff mean_dirvorcecouple,t(firstround) p(time) cov(house_price)

eststo model1:reg mean_dirvorcecouple time firstround did ln_house_price,cluster(city)
quietly estadd local fiexedYear "NO", replace
quietly estadd local fiexedCity "NO", replace

eststo model2:reghdfe mean_dirvorcecouple time firstround did ln_house_price,absorb(year) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "NO", replace

eststo model3:reghdfe mean_dirvorcecouple time firstround did ln_house_price,absorb(city) cluster(city)
quietly estadd local fiexedYear "NO", replace
quietly estadd local fiexedCity "YES", replace

eststo model4:reghdfe mean_dirvorcecouple time firstround did ln_house_price,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

esttab model1 model2 model3 model4 using reg_1.tex, replace s(fiexedYear fiexedCity N r2,label("Time-FE""City-FE""Observations""R-squared" )) se noconstant star(* .10 ** .05 *** .01) keep(did ln_house_price) 


gen period = year - 2011
forvalues i = 2(-1)1{
gen pre_`i' = (period == -`i' & firstround == 1)
}
gen current = (period == 0 & firstround== 1)
forvalues j = 1(1)2{
gen  time_`j' = (period == `j' & firstround == 1)
 }
reghdfe mean_dirvorcecouple time firstround ln_house_price pre_* current time_* i.year,absorb(year) cluster(city)
est sto reg
coefplot reg,keep(pre_* current time_*) vertical recast(connect) yline(0) xline(4,lp(dash)) ytitle("Policy Effect") xtitle("Time （pre_*policy，currentpolicy，time_*after_policy）")

***Heterogeneity Test***
egen m_mean_dirvorcecouple=mean(dirvorcecouple), by(year firstround metropolis)

egen p_mean_dirvorcecouple=mean(dirvorcecouple), by(year firstround capital)


eststo model41:reghdfe m_mean_dirvorcecouple time firstround did ln_house_price if metropolis==1 |firstround==0,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

eststo model42:reghdfe m_mean_dirvorcecouple time firstround did ln_house_price if metropolis==0 |firstround==0,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

eststo model43:reghdfe p_mean_dirvorcecouple time firstround did ln_house_price if capital==1 |firstround==0,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

eststo model44:reghdfe p_mean_dirvorcecouple time firstround did ln_house_price if capital==0 |firstround==0,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

esttab model41 model42 model43 model44 using reg_4.tex, replace s(fiexedYear fiexedCity N r2,label("Time-FE""City-FE""Observations""R-squared" ))  noconstant star(* .10 ** .05 *** .01)  mtitle("Metropolis" "Non-Metropolis""Provincial Capital" "Non-Provincial Capital"   ) keep(did) se



***placebo test***
*generate the fake treated group from the sample 500 times
set matsize 500
mat b = J(500,1,0) //* matrix for coefficients
mat se = J(500,1,0) //* matrix for se
mat p = J(500,1,0) //* matrix for p-values

*repeat the randomization process 500 times
forvalues i=1/500{
 use Final_Data_v3.dta, clear
 xtset city year  
 keep if year==2005   
 sample 46, count   //randomly select 46 cities from the sample as treated group
 keep city  
 save match_id.dta, replace   
 merge 1:m city using Final_Data_v3.dta 
 gen treat = (_merge == 3) // 1 for treated group, 0 for control group
 gen time = (year>=2011)&!missing(year) //generate the dummy as policy implementation
 gen did = treat*time
 reghdfe mean_dirvorcecouple time firstround did ln_house_price,absorb(year city) cluster(city)
 
 
 mat b[`i',1] = _b[did]
 mat se[`i',1] = _se[did]
 mat p[`i',1] = 2*ttail(e(df_r), abs(_b[did]/_se[did]))
}

* convert matrix to vectors
svmat b, names(coef)
svmat se, names(se)
svmat p, names(pvalue)

* delete the missing values and add the labels
drop if pvalue1 == .
label var pvalue1 p_value
label var coef1 coefficients
keep coef1 se1 pvalue1

*plot for the placebo test
twoway (histogram coef1, color(ltblue)) (kdensity coef1), ///
title("Placebo Test") ///
xlabel(-3500(700)3500) ylabel(,angle(0)) xtitle("Coefficients") ///
xline(3190.4, lwidth(vthin) lp(shortdash)) ytitle("Density") ///
legend(label(1 "histogram of estimates") label( 2 "kdensity of estimates")) ///
graphregion(color(white)) 



***PSM-DID***
use Final_Data_v3.dta, clear
gen time=(year>=2011)&!missing(year)
gen did=time*firstround

set seed 0001 //Define the seed

gen tmp = runiform() //Generate random numbers

sort tmp //Randomly organize the database

psmatch2 firstround ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital, out(mean_dirvorcecouple) logit ate neighbor(1) common caliper(.05) ties //Through neighbor matching, you can have an outcome here or not

pstest ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital, both graph //Test whether the covariate is balanced between the treatment group and the control group
psgraph

gen common=_support

drop if common == 0 //Remove observations that do not meet the common area assumption

*drop _weight ==0 //There are also cases where the unmatched ones are deleted directly
reg mean_dirvorcecouple did time firstround ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital

xtreg mean_dirvorcecouple did time firstround ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital i.year, fe


***PSM-DID2***
global xlist "ln_edu_invest ln_public_invest ln_gdp_percapita unemploy_ratio junior_teacher_student_ratio primary_teacher_student_ratio forest_ratio hospital"

psmatch2 firstround $xlist, out(mean_dirvorcecouple) logit ate neighbor(1) common caliper(.05) ties 
gen time_psm=(year>=2011)&!missing(year)
gen psm_did=time_psm*firstround
eststo model31:reghdfe mean_dirvorcecouple time_psm firstround psm_did ln_house_price if _support==1,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

esttab model4 model31 using reg_3.tex, replace s(fiexedYear fiexedCity N r2,label("Time-FE""City-FE""Observations""R-squared" )) se noconstant star(* .10 ** .05 *** .01) keep(did psm_did) 


***Results for Policy Exclusion***
*乌鲁木齐6 2014/ 兰州10 2015/ 南宁13 2014/ 合肥18 2014/ 呼和浩特20 2014/ 哈尔滨22 2014/ 太原27 2014/ 无锡38 2014/ 昆明39 2016/ 武汉44 2017/ 沈阳46 2014/ 济南49 2018/ 苏州64 2016/ 西宁67 2014/ 西安68 2014/ 郑州72 2014/ 金华74 2014/ 银川75 2014/ 长春76 2014/ 
keep if firstround==1
gen exclusion=0
replace exclusion=1 if city==6
replace exclusion=1 if city==10
replace exclusion=1 if city==13
replace exclusion=1 if city==18
replace exclusion=1 if city==20

replace exclusion=1 if city==22
replace exclusion=1 if city==27
replace exclusion=1 if city==38
replace exclusion=1 if city==39
replace exclusion=1 if city==44

replace exclusion=1 if city==46
replace exclusion=1 if city==49
replace exclusion=1 if city==64
replace exclusion=1 if city==67
replace exclusion=1 if city==68

replace exclusion=1 if city==72
replace exclusion=1 if city==74
replace exclusion=1 if city==75
replace exclusion=1 if city==76

egen ex_dirvorcecouple=mean(dirvorcecouple), by(year exclusion)
graph twoway (connect ex_dirvorcecouple year if exclusion==1,sort) (connect ex_dirvorcecouple year if exclusion==0,sort lpattern(dash)), ///
xline(2014,lpattern(dash) lcolor(gray)) xline(2016,lpattern(dash) lcolor(gray)) ///
ytitle("mean_dirvorcecouple") xtitle("year") ///
ylabel(,labsize(*0.75)) xlabel(,labsize(*0.75)) ///
legend(label(1 "Treated") label( 2 "Control")) ///
xlabel(2005 (1) 2019)  graphregion(color(white)) //

gen policy2=0
replace policy2=1 if policy==0 & year > 2013
*乌鲁木齐6 2014/ 兰州10 2015/ 南宁13 2014/ 合肥18 2014/ 呼和浩特20 2014/ 哈尔滨22 2014/ 太原27 2014/ 无锡38 2014/ 昆明39 2016/ 武汉44 2017/ 沈阳46 2014/ 济南49 2018/ 苏州64 2016/ 西宁67 2014/ 西安68 2014/ 郑州72 2014/ 金华74 2014/ 银川75 2014/ 长春76 2014/ 

gen exclusion_year=0
replace exclusion_year=2015 if city==6
replace exclusion_year=2016 if city==10
replace exclusion_year=2015 if city==13
replace exclusion_year=2015 if city==18
replace exclusion_year=2015 if city==20
replace exclusion_year=2015 if city==22
replace exclusion_year=2015 if city==27
replace exclusion_year=2015 if city==38
replace exclusion_year=2017 if city==39
replace exclusion_year=2018 if city==44
replace exclusion_year=2015 if city==46
replace exclusion_year=2019 if city==49
replace exclusion_year=2017 if city==64
replace exclusion_year=2015 if city==67
replace exclusion_year=2015 if city==68
replace exclusion_year=2015 if city==72
replace exclusion_year=2015 if city==74
replace exclusion_year=2015 if city==75
replace exclusion_year=2015 if city==76

gen event = year - exclusion_year

forvalues i=5(-1)1{
  gen before`i'=(event==-`i'& policy2==1)
}

gen now=(event==0 & policy2==1)

forvalues i=1(1)3{
  gen after`i'=(event==`i'& policy2==1)
}

eststo model51:reg ex_dirvorcecouple before* now after* ln_house_price policy2,cluster(city)
quietly estadd local fiexedYear "NO", replace
quietly estadd local fiexedCity "NO", replace

eststo model52:reghdfe ex_dirvorcecouple before* now after* ln_house_price policy2,absorb(year) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "NO", replace

eststo model53:reghdfe ex_dirvorcecouple before* now after* ln_house_price policy2,absorb(city) cluster(city)
quietly estadd local fiexedYear "NO", replace
quietly estadd local fiexedCity "YES", replace

eststo model54:reghdfe ex_dirvorcecouple before* now after* ln_house_price policy2,absorb(year city) cluster(city)
quietly estadd local fiexedYear "YES", replace
quietly estadd local fiexedCity "YES", replace

esttab model51 model52 model53 model54 using reg_5.tex, replace s(fiexedYear fiexedCity N r2,label("Time-FE""City-FE""Observations""R-squared" )) se noconstant star(* .10 ** .05 *** .01) keep(now after1 after2 after3 ln_house_price policy2) 




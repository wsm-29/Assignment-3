* Read in data: 
import delimited using "/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/3/sports-and-education.csv",varname(1) clear


**# balance table generation
global balanceopts "prehead(\begin{tabular}{l*{6}{c}}) postfoot(\end{tabular}) noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01)"

estpost ttest nearbigmarket athleticquality academicquality, by(ranked2017) unequal welch
esttab . using "/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/3/balancetable.tex", cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide label collabels("Control" "Treatment" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) replace mgroups(none)

**# propensity score
logit ranked2017 nearbigmarket athleticquality academicquality
predict propensity_score, pr

twoway histogram propensity_score, start(0) width(0.1) bc(red%30) freq || histogram propensity_score if ranked2017==0, start(0) width(0.1) bc(blue%30) freq legend(order(1 "Treatment (Ranked)" 2 "Control (Unranked)"))
graph export "/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/3/overlap.png", as(png) name("Graph")
**# block


sort propensity_score
gen block = floor(_n/4)

**# label variables

label var ranked2017 "Being Ranked in 2017"
label var academicquality "Academic Quality"
label var athleticquality "Atheltic Program Quality"
label var nearbigmarket "Near Large Metropolitan Areas"


gen lalumnidonations2018=ln(alumnidonations2018)
**# regression

reg lalumnidonations2018 ranked2017 nearbigmarket athleticquality academicquality
eststo r1
areg lalumnidonations2018 ranked2017 nearbigmarket athleticquality academicquality,a(block)
eststo r2

**********************************
estadd local fe " ",replace: r1 r2
estadd local bfe "Yes", replace: r2


esttab r1 r2 using"/Users/sw3947/Desktop/FALL2024/Research Method B/assignment/3/table.tex", replace label se  wrap width(\hsize)title("\label{tab:assignment3} The Effect of Being Ranked on Alumni Donations") mgroups("Alumni Donations in 2018 (Log)", pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span ) nomtitles keep(ranked2017 nearbigmarket athleticquality academicquality) order(ranked2017 nearbigmarket athleticquality academicquality )   scalar("fe Fixed Effects:" "bfe Block")

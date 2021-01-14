import delimited "/Users/marcelo/Downloads/final.csv", clear



replace p10_1=. if  p10_1>4  & p10_1<5 


gen estatura=p20_1*100 + p20_2

replace p43=. if p43>8 & p43<9 /*quito los valores imputados*/


replace p43m=. if p43m>6 & p43m<7 /*quito los valores imputados*/

replace p87=. if p87>2004 & p87<2005 /*quito los valores imputados*/

replace p87=2017-p87

oprobit objetivo p05 i.p06 i.p09_1 i.p10_1 estatura p21 i.p23 i.p24 p28 p38_11 i.p43 p38m_11 i.p43m ///
p60 p61 p64 p86 i.p87 p98 p122 p131 p132 p142 p143 p144  i.p151 i.region escolaridadh indigena [fw=factor]

export delimited using "/Users/marcelo/Downloads/final_oprobit.csv", replace

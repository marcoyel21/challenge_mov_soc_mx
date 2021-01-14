clear 

cd /Users/arleenholden/Desktop/ALEXA/Maestria/data_challenge

use /Users/arleenholden/Desktop/ALEXA/Maestria/data_challenge/bases/principal.dta

gen hacinamiento= p01/p121

gen hacinamiento_antes= p27/p28_1

/* ---------------------------------------------------------------------------
           Variable dependiente: riqueza del hogar con metodo PCA  en percentil
   ------------------------------------------------------------------------ */

* Es para crear variables dummy de las variables que se utilizan en la riqueza del hogar
recode p125a p126a p126j p126c p126f p126k p129a p126d p126b p128c p128d p128e p30_a p33_a p33_h p33_c p33_i p33_f p33_d p34_a p34_e p32_b p32_c p32_d (2=0) (8=.)

*indice pca de la riqueza actual
* Para instalar el paquete de PCA
* help polychoricpca
polychoricpca p125a p126a p126j p126c p126f p126k p129a p126d p126b p128c p128d p128e p120 hacinamiento,score(index_adulto) nscore(1)

*indice pca de la riqueza a los 14 años (riqueza de los padres)
polychoricpca p30_a p33_a p33_h p33_c p33_i p33_f p33_d p34_a p34_e p32_b p32_c p32_d p29 hacinamiento_antes, score(index_nino) nscore(1)

*escolaridad en años
gen escolaridadh=.
replace escolaridadh=0 if (p13==1|p13==97)
replace escolaridadh=p14 if p13==2
replace escolaridadh=6+p14 if (p13==3|p13==4)
replace escolaridadh=9+p14 if (p13==5|p13==6|p13==7|p13==9)
replace escolaridadh=12+p14 if (p13==8|p13==10|p13==11)
replace escolaridadh=16+p14 if p13==12

gen escolaridadp=.
replace escolaridadp=0 if (p43==1|p43==13)
replace escolaridadp=p44 if p43==2
replace escolaridadp=6+p44 if (p43==3|p43==4)
replace escolaridadp=9+p44 if (p43==5|p43==6|p43==7|p43==9)
replace escolaridadp=12+p44 if (p43==8|p43==10|p43==11)
replace escolaridadp=16+p44 if p43==12

gen escolaridadm=.
replace escolaridadm=0 if (p43m==1|p43m==13)
replace escolaridadm=p44m if p43m==2
replace escolaridadm=6+p44m if (p43m==3|p43m==4)
replace escolaridadm=9+p44m if (p43m==5|p43m==6|p43m==7|p43m==9)
replace escolaridadm=12+p44m if (p43m==8|p43m==10|p43m==11)
replace escolaridadm=16+p44m if p43m==12

*escolaridad promedio de los padres
gen escolaridadpromediopadres=(escolaridadm+escolaridadp)/2
replace escolaridadpromediopadres=escolaridadp if escolaridadm==.
replace escolaridadpromediopadres=escolaridadm if escolaridadp==.


*percentiles de escolaridad
xtile per_esc_h=escolaridadh, nquantiles(10) 
xtile per_esc_p=escolaridadp, nquantiles(10) 
xtile per_esc_m=escolaridadm, nquantiles(10) 
xtile per_esc_pm=escolaridadpromediopadres, nquantiles(10) 

*percentil ingreso 14 años y hoy
xtile per_ing_14=index_nino, nquantiles(10)
xtile per_ing_hoy=index_adulto, nquantiles(10)

*diferencia de percentil ingresos 
gen dif_per=per_ing_hoy-per_ing_14
gen movilidad=3 if dif_per>0 
replace movilidad=2 if dif_per==0
replace movilidad=1 if dif_per<0

/* ---------------------------------------------------------------------------
								Modelos
   ------------------------------------------------------------------------ */

* Variables control utilizadas

*Dummy mujer
tostring p06,force replace
destring p06,replace
gen mujer=p06==2

*Pigmentacion de piel (el mas alto es color mas claro)
tostring p151,force replace
destring p151,replace

*Region del pais 
tostring region,force replace
destring region,replace

*Años cumplidos tiene
gen edad=p05

*Escolaridad de los padres
tostring p43 p43m,force replace
destring p43 p43m,replace

*tamanio de localidad
tostring p24,force replace
destring p24,replace

*padre o madre hablan algun dialecto indigena
tostring p39 p39m,force replace
destring p39 p39m,replace
gen indigena=0 
replace indigena=1 if p39==1 | p39m==1

* p60 es el número de hijos e hijas que tuvo su madre

*solamente nos quedamos con aquellas personas mayores a 30 anios
* keep if edad>30

*Modelo 1: Logits movilidad social 
*dummy de movilidad ascendente
gen movilidad_ascendente=movilidad==3
*Modelo
logit movilidad_ascendente escolaridadh mujer p151 i.region edad p43 p43m p24 indigena p60, vce(robust)

*dummy sin movilidad
gen sin_movilidad=movilidad==2
*Modelo
logit sin_movilidad escolaridadh mujer p151 i.region edad p43 p43m p24 indigena p60, vce(robust)

*dummy con movilidad_descendente
gen movilidad_descendente=movilidad==1
*modelo
logit movilidad_descendente escolaridadh mujer p151 i.region edad p43 p43m p24 indigena p60, vce(robust)

*Modelo 2: oprobit
oprobit per_ing_hoy per_ing_14 escolaridadh  per_esc_pm mujer p151 p60 indigena i.region edad  p24, vce(robust)

*Modelo 3: oprobit 
oprobit per_esc_h per_ing_14 per_esc_pm mujer p151 p60 indigena i.region edad p24, vce(robust)





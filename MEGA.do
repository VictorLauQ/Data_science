cd "C:\Users\VICTOR\Desktop\data\ESCRITORIO\Esta Aplicada\BD"
use datos1

describe gedad //características de la variable (type, display format, value label, variable label)
codebook neduc //describe + range, unique values, missings
summarize neduc //obs, mean, std dev, min, max
summarize neduc, detail //+percentiles, vaiance, skewness
kdensity horas2 //sirve para ver valores atipicos
bysort sexo sector: summarize ingxh //bysort divide por grupos
keep sexo //mantener columnas
keep if sexo == 1 //mantener filas

import excel datos0.xlsx, sheet("Sheet1") cellrange(A1:I2) firstrow clear //importar excel
export excel using prueba_1.xlsx, firstrow(variables) nolabel replace // "no label" te respeta las categorías de las categóricas (el número de las variables azules)

return list //ultimos valores guardados
display r(mean)
lookfor edad //buscar variables que contengan edad
count if ing2 >= 30 & ing2 != . // cuantas personas tienen más de 30 soles de ingreso en ocupación secundaria. Missing (.) es infinito+
order edad id sexo * // ordenamos poniendo primero la variable edad y luego el resto en el orden anterior

*MERGE
merge 1:1 ao dpto using gr_poblacion, keep(1 3)	//me quedo con obs _merge ==1 o ==3
merge m:1 ao dpto using gr_fiscal, keepus(gr_gas) //solo agrega var gr_gas de using

*m:1

*1 -> identificadores para BD1 y BD2
*BD1:
use gr_fiscal, clear
isid ao dpto // ID 
*BD2:
use gl_fiscal, clear
isid ao dpto prov // ID
*2 -> identificadores en comun
** BD1 -> gr_fiscal // BD2 -> gl_fiscal
**BD1 -> ao dpto
**BD2 -> ao dpto prov
**IDs en comun -> "ao dpto" -> en el merge
***** BD1 -> "ao dpto" -> unique (1)
***** BD2 -> "ao dpto" -> many (m)
*3 -> definir master y using, y mergear
*Master -> gl_fiscal
*Using -> gr_fiscal
use gl_fiscal, clear
merge m:1 ao dpto using gr_fiscal

*Appendear 2015 debajo de 2014
use gr_fiscal_2014, clear
append using gr_fiscal_2015


*Variables
gen ejemplo = "" // variable textual vacía
gen ejemplo2 = . // variable numérica vacía

set obs 200
set seed 1 // darle una semilla para el muestreo aleatorio -> para fines de replicabilidad
gen aleatoria_1 = runiform(2,4)
gen aleatoria_1 = runiform(2,4) // 2 -> cota inferior, 4 -> cota superior
gen aleatoria_2 = rnormal(0,1) //0 -> mean, 1 -> standard deviation
gen aleatoria_3 = rchi2(10) // 10 -> df grados de libertad
gen aleatoria_4 = rbinomial(3,0.7) // 3 -> numero de intentos, 7 -> probabilidad de exito

gen ing_total = ing1 + ing2
egen ing_total = rowtotal(ing1 ing2) //considera missing como 0
egen ing_total = rowtotal(ing1 ing2), m //suma de dos "." es "."

*crear variables
gen mujeres_costa = . //crea variable numérica vacía
replace mujeres_costa = 1 if sexo == 1 & ( dominio == 1 | dominio == 2 | dominio == 3)

gen mujeres_costa1 = inlist(sexo,1) & inlist(dominio,1,2,3) // inlist sirve para crear variables dummies (si cumple la condición, =1; si no la cumple, =0) (variable dentro de inlist tiene que ser categórica)

*crear categoricas
label list dominio
gen costa = inlist(dominio,1,2,3,8)
gen sierra = inlist(dominio,4,5,6)
gen selva = inlist(dominio,7)

gen region = inlist(dominio,1,2,3,8)*1 + inlist(dominio,4,5,6)*2+inlist(dominio,7)*3

*Etiquetas:
*1. Etiqueta a variable
label variable region "Región Natural"
*2. Etiqueta a cada valor -> creamos el label "etiqueta_1"
label define regiones_naturales 1 "Costa" 2 "Sierra" 3 "Selva"
*3. Incorporar el label creado a la variable region
label values region regiones_naturales

decode dominio, gen(zona) // convierte etiquetas en textos
encode dpto, gen(departamento)	// convierte textos en etiquetas

split id, gen(id2_) parse(-) // separador de texto es "-". Crea varias variables en texto. USAR ESTE.
split id, gen(id_) parse(-) destring // si es que las variables creadas son numéricas, las pasa a numéricas.

tostring id_*, replace // convierte números a textos
destring id_*, replace	// convierte textos	a números

gen mes = substr("20091231",5,2) // posicion 5, 2 strings

*PCTILE -> crea variables que contiene percentiles (puntos de corte)
pctile cortes=ingxh, nq(4) // número de quantiles
*XTILE -> crea variable que contiene las cartegorias por quantil (en el grupo que se encuentra cada observaciòn)
xtile cuartos=ingxh, nq(4)

gen ing1_acum = sum(ing1) //suma acumulada
egen ing1_acum3 = total(ing1) //suma total
bysort sexo: egen total_ing1_2 = total(ing1) //crea por sexo

gen nro = _n
gen total = _N
gen nro_diferencia =  (nro[_n] - nro[_n-1])
gen nro_diferencia_varporc =  (nro[_n] - nro[_n-1])/nro[_n-1]

format %16.0g suma_acum_ing //formato par números grandes

*Factor Expansion
[pw = factor] 
[fw = round(factor)]
[iw = factor] 

*TABLAS

*Tabulate (sirve para cateogricas)
tabulate neduc [fw= round(factor)], m //(solo categoricas) (m  incluye missings) para cada categoria te da frecuencia absoluta, relativa y acumuladas
tab neduc [fw = round(factor)], nol //sin labels en la variable
tab neduc [fw = round(factor)], gen(dummy_neduc_) // te arma tabla y crea dummies para cada categoria -> "dummy_neduc_1, dummy_neduc_2, dummy_neduc_3, ..."

tab neduc [fw = round(factor)], plot //te pone asteriscos al costado de la tabla
hist neduc [fw = round(factor)] //solo acepta fweights

tab neduc sector [iw = factor] //te da frecuencias absolutas
tab neduc sector [iw = factor], col nofreq // "col" -> frecuencia relativa respecto a columnas // "nofreq" -> no frecuencia absoluta
tab neduc sector [iw = factor], row nofreq // "row" -> relativa respecto a filas
tab neduc sector [iw = factor], cell nofreq // "cell" -> relativa respecto al total


*Tabstat (para continuas)
**tabla semi rígida que reporta los estadísticos que tu quieras, pero los mismos para todas las variables
tabstat ingxh ingxh1 ingxh2 [fw = round(factor)], s(me iqr k sk)
tabstat ingxh ingxh1 ingxh2 [fw = round(factor)], s(me iqr k sk) col(s) // columnas tienen los estadísticos
tabstat ingxh ingxh1 ingxh2 [fw = round(factor)], s(me iqr k sk) col(v) //columnas tienen las variables

tabstat ingxh ingxh1 ingxh2 [fw = round(factor)], by(neduc) s(me iqr k sk) col(s) // "by(neduc)" corre el comando tabstat para cada nivel de la variable categórica "neduc"
tabstat ingxh* [fw=round(factor)], by(sexo) s(mean iqr k sk) not //no muestra el total_ing1_2

*Table (para todo, super flexible, reporta los estadísticos que quieras para la variable que quieras)
table neduc [pw=factor], stat(mean ing1) stat(cv ing2) 


*Transformar BD1 

* COLLAPSE
collapse (mean) mean_ingxh = ingxh (sd) sd_ingxh = ingxh (p50) p50_ingxh = ingxh (count) contar_grupo = ingxh [fw = round(factor)], by(neduc sexo dominio)// te crear variabales de cada estadistico segun el bysector

* RESHAPE
use gr_fiscal, clear
reshape wide gl_gas, i(dpto prov) j(ao) // el id es ao dpto prov pero el id final es solo spto prov
reshape wide gl_gas, i(dpto prov) j(ao)

use gr_fiscal, clear
reshape long gr_, i(ao dpto) j(categoria) string
**** gr_ -> parte comun de las 3 variables que vamos a fusionar 
**** i -> id de la base inicial
**** j -> una nueva variable que va a tener a las variables con inicio comun "gr_"
**** string -> si la variable categoria tiene categorías (gr_gas, gr_trans, gr_ing -> categorías: gar, trans, ing). Si hubiese números en la variable categoria, no aplicar string (gr_1, gr_2, gr_3 -> categorías: 1, 2, 3)

* Graficos

*1 Histograma de una variable continua
hist ingxh [fw=round(factor)] // en densidad
hist ingxh [fw=round(factor)], fraction // en fraccion
hist ingxh [fw=round(factor)], percent //en porcentaje

hist ingxh [fw=round(factor)], kdensity percent //kdensity (función de distribución estimada)
hist ingxh [fw=round(factor)], kdensity by(sector sexo) //por subgrupos

*2 Gráfico de caja y bigotes
** raya medio -> p50
** caja inferior -> p25
** caja superior -> p75
*RIQ -> p75 - p25
** bigote inferior -> p25 - 1.5*RIQ
** bigote superior -> p75 + 1.5*RIQ
gr box ingxh horas [pw=factor]


*Diferencias entre "by" y "over":
*1 Variable y 1 categoria
gr box ingxh [pw=factor], by(sector) //Si
gr box ingxh [pw=factor], over(sector) //Si
*1 Variable y 2 categorías
gr box ingxh [pw=factor], by(sector sexo) // Si
gr box ingxh [pw=factor], over(sector sexo) // too many variables specified!!
*2 Variables y 1 categoria
gr box ingxh horas [pw=factor], over(sector) //Si
gr box ingxh horas [pw=factor], by(sector) // Si


*3 Gráfico de barras
gr bar (mean) ing1 (median) ing2 [pw=factor] 
gr hbar (mean) ing1 (median) ing2 [pw=factor]
gr hbar (mean) ing1 (median) ing2 [pw=factor], by(sector sexo)


*4 SCATTER (COLLAPSE) -> te indica correlación (si hay) y signo (no causalidad)
**Si hay mucha data.. no se ve bien -> 45mil individuos.. 45mil puntitos (?) (no sirve)
scatter ingxh edad [pw=factor]
*Obtener BD a nivel region con promedios de ingxh y edad
collapse (mean) promedio_ingxh = ingxh (mean) prom_edad = edad [pw=factor], by(dpto)
*a esta BD -> scatter ok
scatter promedio_ingxh prom_edad [pw=fraccion_poblacion_dpto] //son promedios poblacionales, ya no necesitas el factor de expansión

*5 LINE (COLLAPSE)
*Graficar ingxh promedio para distintos niveles de edad (2 variables continuas)
*Line como scatter -> tener poca data, particularmente tener el eje "x" con valores UNICOS.
line ingxh edad // esto intenta graficar una linea, pero está uniendo todos los puntos..
collapse (mean) ingxh [pw=factor], by(edad)
line ingxh edad


*A partir de datos3.dta, grafique el percentil 90 del ingreso en la ocupación principal por dominio según sector de los trabajadores de 25 a 55 años de edad con al menos superior universitaria completa.
graph hbar (p90) ing1 if inrange(edad,25,55) & inlist(neduc,10,11), over(sector) over(dominio) asyvars 
graph hbar (p90) ing1 if inrange(edad,25,55) & inlist(neduc,10,11) [pw=fac], over(sector) over(dominio) asyvars blabel(bar, position(inside) color(white))

*ii)Subopciones de over() para asignar un orden a las barras
h graph hbar
/*
    over_subopts                    Description
    ----------------------------------------------------------------------------
    relabel(# "text" ...)           change axis labels
    label(cat_axis_label_options)   rendition of labels
    axis(cat_axis_line_options)     rendition of axis line

    gap([*]#)                       gap between bars within over() category
    sort(varname)                   put bars in prespecified order
    sort(#)                         put bars in height order
    sort((stat) varname)            put bars in derived order
    descending                      reverse default or specified bar order
    reverse                         reverse scale to run from max to min
    ----------------------------------------------------------------------------
*/

* sort(#) puts the bars in height order.  # refers to the yvar number on which the ordering should be performed;
graph hbar (p90) ing1 if inrange(edad,25,55) & inlist(neduc,10,11) [pw=fac], over(sector) over(dominio, sort(2)) asyvars blabel(bar, position(inside) color(white)) ytitle("Ingreso en ocupación principal en soles 2007 (p90)") //sort(2) ordena las categorías de dominio según la 2da categoría de sector (sort es subopción de over ojo)















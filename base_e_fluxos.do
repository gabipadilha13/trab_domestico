
global pnadc "\\srjn4\area_corporativa\PNAD\PNAD Continua\Bases\Bases_primarias_PNADC\Trimestral"
*global pnadc "\\sbsb2\DISOC_RIO\BMT\PnadC\Bases"

cd "\\srjn4\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases"
*cd "\\sbsb2\DISOC_RIO\BMT\PnadC\domesticas_temp\bases"

local anos 2018 2017 2016 2015 2014 2013 2012
foreach y in `anos' {

use v1016 domicilioid upa  v1008 v1014 pessoasid v2007 v2008 v20081 v20082 peso reg uf reg_pme v2003 v2005 ///
rm_ride idade v2007 cor v2010 vd3004 vd3005 setor_ibge v4013 ocup desocup inativo vd4002 ///
com_cart sem_cart militar_estat empregador conta_propria nao_rem vd4009 v4010 v4041 prev vd4012 vd4019 ///
informal1 informal2 informal3 vd4031 vd4032 vd4035 salmp_habt salmp_efet salmt_habt salmt_efet ano trimestre v4024 ///
v4032 v4039 v4043 v4048 v4049 v4056 v4013 v4044 ///
using "${pnadc}\pnadc_`y'_def.dta", clear


gen trab_dom=1 if inlist(vd4009,3,4)
gen EC_72=1 if (trimestre>=2 & ano==2013)|(ano>=2014)
gen LC_150=1 if (trimestre>=2 & ano==2015)|(ano>=2016)
gen E_Social=1 if (trimestre==4 & ano==2015)|(ano>=2016)
bysort domicilioid trimestre: egen renda_hab_dom = total(vd4019)
gen renda_hab_dom_excl = renda_hab_dom - vd4019
replace renda_hab_dom_excl = renda_hab_dom if renda_hab_dom_excl==.

label var v1016 "número da entrevista"
label var upa "unidade primária de amostragem"
label var v1008 "número de seleção do domicílio"
label var v1014 "painel"
label var domicilioid "identificador do domicílio"

label var v2003 "No de ordem"
label var v2005 "Posicao no domicilio"
label var v2007 "sexo - variável original"
label var v2008 "dia de nascimento"
label var v20081 "mês de nascimento"
label var v20082 "ano de nascimento"
label var pessoasid "identificador de pessoas"

label var peso "peso"
label var reg "região"
label var uf "unidade da federação"
label var reg_pme "região metropolitana"
label var rm_ride "região metropolitana - variável original"

label var idade "idade"
label var cor "cor ou raça"
label var v2010 "cor ou raça - variável original"

label var vd3004 "nível de instrução mais elevado alcançado"
label var vd3005 "anos de estudo (fund. 9 anos)"

label var setor_ibge "setor de atividade"
label var v4013 "código setor de atividade"

label var ocup "ocupados"
label var desocup "desocupados"
label var inativo "inativos"
label var vd4002 "condição de ocupação na semana de referência - variável original"
label var com_cart "empregado com carteira assinada"
label var sem_cart "empregado sem carteira assinada"
label var militar_estat "militar e servidor estatutário"
label var empregador "empregador"
label var conta_propria "trabalhador por conta-própria"
label var nao_rem "não remunerado"
label var vd4009 "posição na ocupação e categoria do emprego do trabalho principal"
label var v4010 "código de ocupação do trabalho principal"
label var v4041 "código de ocupação do trabalho secundário"
label var v4013 "código de CNAE do trabalho principal"
label var v4044 "código de CNAE do trabalho secundário"

label var prev "contribuição para a previdência"
label var vd4012 "contribuição para a previdência - variável original"

label var informal1 "(trabalhadores sem carteira + conta-propria s/prev)/(protegidos + sem carteira + conta-propria)"
label var informal2 "(trabalhadores sem carteira + conta-propria + nao remunerados)/ocupados"
label var informal3 "(trabalhadores sem carteira + conta-propria s/prev + empregador s/prev + nao remunerados)/ocupados"

label var v4039 "Horas habitualmente trabalhadas no trabalho primcipal"
label var vd4031 "horas habitualmente trabalhadas em todos os trabalhos"
label var vd4032 "horas efetivamente trabalhadas no trabalho principal"
label var vd4035 "horas efetivamente trabalhadas em todos os trabalhos"

label var salmp_habt "salário habitual do trabalho principal"
label var salmp_efet "salário efetivo do trabalho principal"
label var salmt_habt "salário habitual de todos os trabalhos"
label var salmt_efet "salário efetivo de todos os trabalhos"

label var v4032 "Contribuinte no trab principal"

label var v4043 "Pos ocupação no trabalho secundário"
label var v4056 "Horas normalmente trabalhadas no trabalho secundário"
label var v4048 "Carteira assinada no trabalho secundário"
label var v4049 "Contribuinte no trab secundário"

label var ano "ano de referência"
label var trimestre "trimestre de referência"

label var trab_dom "trabalhadores domésticos"
label var EC_72 "=1 a partir do 2º trim de 2013"
label var LC_150 "=1 a partir do 3º trim de 2015" 
label var E_Social "=1 a partir do 4º trim de 2015"
label var v4024 "realiza trabalho doméstico em mais de um domicílio"
label var vd4019 "renda habitualmente recebida por tds os trabalhos"
label var renda_hab_dom "soma das rendas hab por tds os trabs no domicilio"
label var renda_hab_dom_excl "soma das rendas hab por tds os trabs no dom excluindo a propria"

compress
save "Base_PNADC_`y'.dta" , replace
}

// Fazendo fluxos de transição no mercado de trabalho

//Períodos:

// Pré EC 72: Antes de 2013.2
// Entre EC 72 e LC 150: De 2013.2 até 2015.3
// Entre LC 150 e E-Social: 2015.3 até 2015.4
// Entre EC 72 até E-Social: 2013.2 até 2015.4
// Pós E-Social: A partir de 2016

use pessoasid ocup desocup inativo vd4002 com_cart sem_cart militar_estat empregador conta_propria nao_rem ano trimestre trab_dom EC_72 LC_150 E_Social peso v2007 ///
	using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2012.dta", clear
// juntando com a base do próximo ano
append using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2013.dta"
append using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2014.dta"
append using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2015.dta"
append using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2016.dta"
append using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2017.dta"
append using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\Base_PNADC_2018.dta"
keep (pessoasid ocup desocup inativo vd4002 com_cart sem_cart militar_estat empregador conta_propria nao_rem ano trimestre trab_dom EC_72 LC_150 E_Social peso v2007)
//drop if ano==2013 & trimestre==1
keep if v2007==2 // só mulheres
drop if pessoasid=="."
// fazendo o fluxo a partir de OLF
// OLF U OIW OFW PDW IDW FDW
gen OLF = 0 if inativo==1 // fora da força de trabalho
bysort pessoasid (ano trimestre): replace OLF = 1 if (OLF==0 & inativo[_n+1]==1) // OLF -> OLF : continua inativo no próximo trimestre
bysort pessoasid (ano trimestre): replace OLF = 2 if (OLF==0 & desocup[_n+1]==1) // OLF -> U : vira desempregado no próximo trimestre
bysort pessoasid (ano trimestre): replace OLF = 3 if (OLF==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]!=1) // OLF -> OIW : não tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OLF = 4 if (OLF==0 & com_cart[_n+1]==1 & trab_dom[_n+1]!=1) // OLF -> OFW : tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OLF = 5 if (OLF==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]==1) // OLF -> IDW : não tem carteira assinada e é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OLF = 6 if (OLF==0 & com_cart[_n+1]==1 & trab_dom[_n+1]==1) // OLF -> FDW : tem carteira assinada e é doméstico no próximo trimestre
replace OLF = . if OLF==0
label def OLF 1 "OLF->OLF" 2 "OLF->U" 3 "OLF->OIW" 4 "OLF->OFW" 5 "OLF->IDW" 6 "OLF->FDW"
label val OLF OLF
tab OLF , generate(OLF)

//fazendo o fluxo a partir de U
gen U = 0 if desocup==1 // desempregado
bysort pessoasid (ano trimestre): replace U = 1 if (U==0 & inativo[_n+1]==1) // U -> OLF : desempregado vira inativo no próximo trimestre
bysort pessoasid (ano trimestre): replace U = 2 if (U==0 & desocup[_n+1]==1) // U -> U : continua desempregado no próximo trimestre
bysort pessoasid (ano trimestre): replace U = 3 if (U==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]!=1) // U -> OIW : não tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace U = 4 if (U==0 & com_cart[_n+1]==1 & trab_dom[_n+1]!=1) // U -> OFW : tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace U = 5 if (U==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]==1) // U -> IDW : não tem carteira assinada e é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace U = 6 if (U==0 & com_cart[_n+1]==1 & trab_dom[_n+1]==1) // U -> FDW : tem carteira assinada e é doméstico no próximo trimestre
replace U = . if U==0
replace U = . if U==0
label def U 1 "U->OLF" 2 "U->U" 3 "U->OIW" 4 "U->OFW" 5 "U->IDW" 6 "U->FDW"
label val U U
tab U , generate(U)

//fazendo o fluxo a partir de OIW
gen OIW = 0 if (trab_dom!=1 & sem_cart==1) // trabalhador informal que não é doméstico
bysort pessoasid (ano trimestre): replace OIW = 1 if (OIW==0 & inativo[_n+1]==1) // OIW -> OLF :  vira inativo no próximo trimestre
bysort pessoasid (ano trimestre): replace OIW = 2 if (OIW==0 & desocup[_n+1]==1) // OIW -> U : vira desempregado no próximo trimestre
bysort pessoasid (ano trimestre): replace OIW = 3 if (OIW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]!=1) // OIW -> OIW : continua sem carteira assinada e NÃO sendo doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OIW = 4 if (OIW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]!=1) // OIW -> OFW : tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OIW = 5 if (OIW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]==1) // OIW -> IDW : não tem carteira assinada e é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OIW = 6 if (OIW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]==1) // OIW -> FDW : tem carteira assinada e é doméstico no próximo trimestre
replace OIW = . if OIW==0
replace OIW = . if OIW==0
label def OIW 1 "OIW->OLF" 2 "OIW->U" 3 "OIW->OIW" 4 "OIW->OFW" 5 "OIW->IDW" 6 "OIW->FDW"
label val OIW OIW
tab OIW , generate(OIW)

//fazendo o fluxo a partir de OFW 
gen OFW = 0 if (trab_dom!=1 & com_cart==1) // trabalhador formal que não é doméstico
bysort pessoasid (ano trimestre): replace OFW = 1 if (OFW==0 & inativo[_n+1]==1) // OFW -> OLF :  vira inativo no próximo trimestre
bysort pessoasid (ano trimestre): replace OFW = 2 if (OFW==0 & desocup[_n+1]==1) // OFW -> U : vira desempregado no próximo trimestre
bysort pessoasid (ano trimestre): replace OFW = 3 if (OFW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]!=1) // OFW -> OIW : não tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OFW = 4 if (OFW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]!=1) // OFW -> OFW : continua com carteira assinada e NÃO sendo doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OFW = 5 if (OFW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]==1) // OFW -> IDW : não tem carteira assinada e é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace OFW = 6 if (OFW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]==1) // OFW -> FDW : tem carteira assinada e é doméstico no próximo trimestre
replace OFW = . if OFW==0
replace OFW = . if OFW==0
label def OFW 1 "OFW->OLF" 2 "OFW->U" 3 "OFW->OIW" 4 "OFW->OFW" 5 "OFW->IDW" 6 "OFW->FDW"
label val OFW OFW
tab OFW , generate(OFW)

//fazendo o fluxo a partir de IDW
gen IDW = 0 if (trab_dom==1 & sem_cart==1) //trabalhador doméstico informal
bysort pessoasid (ano trimestre): replace IDW = 1 if (IDW==0 & inativo[_n+1]==1) // IDW -> OLF : vira inativo no próximo trimestre
bysort pessoasid (ano trimestre): replace IDW = 2 if (IDW==0 & desocup[_n+1]==1) // IDW -> U : vira desempregado no próximo trimestre
bysort pessoasid (ano trimestre): replace IDW = 3 if (IDW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]!=1) // IDW -> OIF : não tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace IDW = 4 if (IDW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]!=1) // IDW -> OCF : tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace IDW = 5 if (IDW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]==1) // IDW -> IDW : continua sem carteira assinada e sendo doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace IDW = 6 if (IDW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]==1) // IDW -> FDW : tem carteira assinada e é doméstico no próximo trimestre
replace IDW = . if IDW==0
replace IDW = . if IDW==0
label def IDW 1 "IDW->OLF" 2 "IDW->U" 3 "IDW->OIF" 4 "IDW->OCF" 5 "IDW->IDW" 6 "IDW->FDW"
label val IDW IDW
tab IDW , generate(IDW)

//fazendo o fluxo a partir de FDW
gen FDW = 0 if (trab_dom==1 & com_cart==1) //trabalhador doméstico formal
bysort pessoasid (ano trimestre): replace FDW = 1 if (FDW==0 & inativo[_n+1]==1) // FDW -> OLF : vira inativo no próximo trimestre
bysort pessoasid (ano trimestre): replace FDW = 2 if (FDW==0 & desocup[_n+1]==1) // FDW -> U : vira desempregado no próximo trimestre
bysort pessoasid (ano trimestre): replace FDW = 3 if (FDW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]!=1) // FDW -> OIF : não tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace FDW = 4 if (FDW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]!=1) // FDW -> OCF : tem carteira assinada e NÃO é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace FDW = 5 if (FDW==0 & sem_cart[_n+1]==1 & trab_dom[_n+1]==1) // FDW -> IDW : não tem carteira assinada e é doméstico no próximo trimestre
bysort pessoasid (ano trimestre): replace FDW = 6 if (FDW==0 & com_cart[_n+1]==1 & trab_dom[_n+1]==1) // FDW -> FDW : continua tendo carteira assinada e sendo doméstico no próximo trimestre
replace FDW = . if FDW==0
replace FDW = . if FDW==0
label def FDW 1 "FDW->OLF" 2 "FDW->U" 3 "FDW->OIF" 4 "FDW->OCF" 5 "FDW->IDW" 6 "FDW->FDW"
label val FDW FDW
tab FDW , generate(FDW)

collapse (sum)s_OLF1=OLF1 s_OLF2=OLF2 s_OLF3=OLF3 s_OLF4=OLF4 s_OLF5=OLF5 s_OLF6=OLF6 s_U1=U1 s_U2=U2 s_U3=U3 s_U4=U4 s_U5=U5 s_U6=U6 s_OIW1=OIW1 s_OIW2=OIW2 s_OIW3=OIW3 s_OIW4=OIW4 s_OIW5=OIW5 s_OIW6=OIW6 s_OFW1=OFW1 s_OFW2=OFW2 s_OFW3=OFW3 s_OFW4=OFW4 s_OFW5=OFW5 s_OFW6=OFW6 s_IDW1=IDW1 s_IDW2=IDW2 s_IDW3=IDW3 s_IDW4=IDW4 s_IDW5=IDW5 s_IDW6=IDW6 s_FDW1=FDW1 s_FDW2=FDW2 s_FDW3=FDW3 s_FDW4=FDW4 s_FDW5=FDW5 s_FDW6=FDW6 ///
	(mean)m_OLF1=OLF1 m_OLF2=OLF2 m_OLF3=OLF3 m_OLF4=OLF4 m_OLF5=OLF5 m_OLF6=OLF6 m_U1=U1 m_U2=U2 m_U3=U3 m_U4=U4 m_U5=U5 m_U6=U6 m_OIW1=OIW1 m_OIW2=OIW2 m_OIW3=OIW3 m_OIW4=OIW4 m_OIW5=OIW5 m_OIW6=OIW6 m_OFW1=OFW1 m_OFW2=OFW2 m_OFW3=OFW3 m_OFW4=OFW4 m_OFW5=OFW5 m_OFW6=OFW6 m_IDW1=IDW1 m_IDW2=IDW2 m_IDW3=IDW3 m_IDW4=IDW4 m_IDW5=IDW5 m_IDW6=IDW6 m_FDW1=FDW1 m_FDW2=FDW2 m_FDW3=FDW3 m_FDW4=FDW4 m_FDW5=FDW5 m_FDW6=FDW6 ///
	(rawsum)n_OLF1=OLF1 n_OLF2=OLF2 n_OLF3=OLF3 n_OLF4=OLF4 n_OLF5=OLF5 n_OLF6=OLF6 n_U1=U1 n_U2=U2 n_U3=U3 n_U4=U4 n_U5=U5 n_U6=U6 n_OIW1=OIW1 n_OIW2=OIW2 n_OIW3=OIW3 n_OIW4=OIW4 n_OIW5=OIW5 n_OIW6=OIW6 n_OFW1=OFW1 n_OFW2=OFW2 n_OFW3=OFW3 n_OFW4=OFW4 n_OFW5=OFW5 n_OFW6=OFW6 n_IDW1=IDW1 n_IDW2=IDW2 n_IDW3=IDW3 n_IDW4=IDW4 n_IDW5=IDW5 n_IDW6=IDW6 n_FDW1=FDW1 n_FDW2=FDW2 n_FDW3=FDW3 n_FDW4=FDW4 n_FDW5=FDW5 n_FDW6=FDW6 [iw=peso]

gen periodo="Todo o período (2012 a 2018)"

preserve
keep s_OLF* m_OLF* n_OLF* periodo 
reshape long s_OLF m_OLF n_OLF, i(periodo) j(OLF)
label val OLF OLF
save "fluxoOLF4.dta", replace
restore 

preserve
keep s_U* m_U* n_U* periodo 
reshape long s_U m_U n_U, i(periodo) j(U)
label val U U
save "fluxoU4.dta", replace
restore 

preserve
keep s_OIW* m_OIW* n_OIW* periodo 
reshape long s_OIW m_OIW n_OIW, i(periodo) j(OIW)
label val OIW OIW
save "fluxoOIW4.dta", replace
restore 

preserve
keep s_OFW* m_OFW* n_OFW* periodo 
reshape long s_OFW m_OFW n_OFW, i(periodo) j(OFW)
label val OFW OFW
save "fluxoOFW4.dta", replace
restore 

preserve
keep s_IDW* m_IDW* n_IDW* periodo 
reshape long s_IDW m_IDW n_IDW, i(periodo) j(IDW)
label val IDW IDW
save "fluxoIDW4.dta", replace
restore 

preserve
keep s_FDW* m_FDW* n_FDW* periodo 
reshape long s_FDW m_FDW n_FDW, i(periodo) j(FDW)
label val FDW FDW
save "fluxoFDW4.dta", replace
restore 

clear
use "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\fluxoU4.dta" 
export excel using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Resultados\fluxos_4.xls", sheet("U") firstrow(variables)
use "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\fluxoOLF4.dta" 
export excel using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Resultados\fluxos_4.xls", sheet("OLF") firstrow(variables)
use "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\fluxoOIW4.dta" 
export excel using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Resultados\fluxos_4.xls", sheet("OIW") firstrow(variables)
use "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\fluxoOFW4.dta" 
export excel using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Resultados\fluxos_4.xls", sheet("OFW") firstrow(variables)
use "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\fluxoIDW4.dta" 
export excel using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Resultados\fluxos_4.xls", sheet("IDW") firstrow(variables)
use "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Bases\fluxoFDW4.dta" 
export excel using "\\srjn3\area_corporativa\MTRAB II\Pnad_C_projetos\Trabalho_domestico\Resultados\fluxos_4.xls", sheet("FDW") firstrow(variables)
























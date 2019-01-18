proc delete data=_all_;
run;
goptions reset=all;

/*FAZENDO OS MAPAS*/
/*IMPORTANDO O SHAPEFILE das aponds*/
proc mapimport datafile="C:\Users\Furriel\Box Sync\MULHERES_NEGRAS\Shapes\MGA_SRD_PDC_SAS.shp"
	out=shape_mulheres;
run;

/*FAZENDO AS DELIMITAÇÕES DAS CIDADES*/
/*PRIMEIRAMENTE VAMOS IMPORTAR O SHAPE COM AS DELIMITAÇÕES*/
proc mapimport datafile="C:\Users\Furriel\Box Sync\MULHERES_NEGRAS\Shapes\MGA_SRD_PDC_MU.shp"
	out=shape_cidades;
run;
proc sort data=shape_mulheres out=shape_cidades;
	by NM_MUNICIP;
run;

proc gproject data=shape_mulheres out=shape_mulheres_proj degrees eastlong;
id NM_MUNICIP Aponds;
run;

/*AQUI CRIAREMOS UM DATA SET AUXILIAR PARA A DELIMITAÇÃO DOS MUNICÍPIOS*/
data delimitacao;
	length function $8;
		retain xsys '2' ysys '2' hsys '3' size 1 color 'black' when 'a';
		set shape_cidades;
			by NM_MUNICIP segment;
			function = ifc(first.segment or (lag(x)=. and lag(y)=.), 'poly', 'polycont');
run;

/*CRIANDO OS LABELS*/
/*CALCULANDO UM PONTO CENTRAL NO POLIGONO PARA O LABEL DA CIDADE*/
proc summary data=shape_mulheres(keep= X Y NM_MUNICIP) nway missing;
	class NM_MUNICIP;
	var x y;
	 output out=label_aux(drop=_type_ _freq_) mean=;
run;

/*CRIANDO OS LABELS COM OS NOMES DAS CIDADES*/
data maplabel;
	set label_aux end=end;
	length text $11;
	retain  position '5' xsys '2' ysys '2' hsys '4' function 'label'
size 1.5 style "'Tahoma/bo'"
color "Black" when "a";
text=NM_MUNICIP;
run;

*CRIANDO AS FAIXAS DE RENDA;
proc format;
value cut_salario 
low - 600.00 = "menos que R$600,00" 
600.01 - 800.00 = "R$600,01 - R$800,00"
800.01 - 1000.00 = "R$800,01 - R$1000,00" 
1000.01 - 1300.00 = "R$1000,01 - R$1200,00"
1300.01 - high = "R$1200,001 ou mais";
run;

proc format;
value cut_educ 
0 - 0.030 = "0% - 3%"
0.031 - 0.070 = "3,1% - 7%" 
0.071 - 0.100 = "7,1% - 10%"
.101 - high = "10,1% ou mais";
run;

/*RESOLUÇÃO*/
goptions xpixels=1024 ypixels=768 gunit=pct;
*CORES PARA O MAPA (from ... http://colorbrewer2.org/);
pattern1 v=ms c=cxffffb2; 
pattern2 v=ms c=cxfecc5c;
pattern3 v=ms c=cxfd8d3c;
pattern4 v=ms c=cxf03b20;
pattern5 v=ms c=cxbd0026;

/*CRIANDO UMA MACRO PARA AS VARIÁVEIS*/
%macro plot_map(variavel=, nome_var=,formatar=);
/*LEGENDA PARA O MAPA*/
ods pdf file="C:\Users\Furriel\Box Sync\MULHERES_NEGRAS\Resultados\&variavel..pdf" startpage= yes;
options orientation=landscape;
legend1 mode=share origin=(5,60) across=1 shape=bar(4,4)pct
label=(position=top "&nome_var");
/*PLOT DO MAPA*/
proc gmap all data=shape_mulheres map=shape_mulheres annotate=delimitacao;
	id Apond;
	choro &variavel/annotate=maplabel discrete coutline=white legend=legend1;
	format &variavel &formatar;
run;
quit;
ODS pdf close;
%mend plot_map;

%plot_map(variavel=brancaME,nome_var=Média de salário das mulheres brancas,formatar=cut_salario.);
%plot_map(variavel=brancaP,nome_var=Porcentagem de mulheres brancas com ensino superior,formatar=cut_educ.);

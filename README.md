# Building a simple map in SAS

To make a map in SAS you need a shapefile, this file has the spatial coordinates to plot the map respecting the actual proportions of the space. 
In this case used the IBGE APONDs(Areas of Weighting) shapefile of the cities of Maringá, Sarandi and Paiçandu. You can download this shapes here:[IBGE shapefiles](https://downloads.ibge.gov.br/downloads_geociencias.htm).
To import the shapefile in sas I used proc mapimport. How I want to show the delimitation of the cities and of the Aponds I used two shapefiles.

```sas
/* IMPORTANDO O SHAPEFILE DAS APONDS*/
proc mapimport datafile = "\\XXX PUT YOUR DIRECTORY XXX\\MGA_SRD_PDC_SAS.shp"
  out=shape_mulheres;
run;

/*FAZENDO AS DELIMITAÇÕES DAS CIDADES*/
proc mapimport datafile = "\\XXX PUT YOUR DIRECTORY XXX\\MGA_SRD_PDC_MU.shp"
  out=shape_cidades;
run;
```
Here I created a auxiliar dataset to ensure that the cities outlines in the maps, for this I applied the function ifc that returns a character value based on whether an expression is true, false, or missing  by NM_MUNICIP(my id of the cities) segment.

```sas
/*AQUI CRIAREMOS UM DATA SET AUXILIAR PARA A DELIMITAÇÃO DOS MUNICÍPIOS*/
data delimitacao;
  length function $8;
    retain xsys '2' ysys '2' hsys '3' size 1 color 'black' when 'a';
    set shape_cidades;
        by NM_MUNICIP segment;
        function = ifc(first.segment or (lag(x)=. and lag(y)=.), 'poly', 'polycont');
run;
```

The next step was to create a data with the central coordinates of cities to place the label. To do this I used proc summary and calculated the average of latitude and longitude. From the dataset "label_aux" I created another auxiliary dataset to add size, color and font of the name of the city.

```sas
/*CRIANDO OS LABELS*/
/*CALCULANDO UM PONTO CENTRAL NO POLIGONO PARA O LABEL DA CIDADE*/
proc summary data = shape_mulheres(keep= X Y NM_MUNICIP) nway missing;
 class NM_MUNICIP;
 var x y;
   output out = label_aux(drop=_type_ _freq_) mean=;
run;
/*CRIANDO OS LABELS COM OS NOMES DAS CIDADES*/
data maplabel;
    set label_aux end = end;
    length text $11;
    retain  position '5' xsys '2' ysys '2' hsys '4' function 'label'
        size 1.5 style "'Tahoma/bo'"
        color "Black" when "a";
        text = NM_MUNICIP;
run;
```
The proc format was used to make the percentage cuts of higher education and income of women.

```sas
*CRIANDO AS FAIXAS DE RENDA;
proc format;
value cut_salario 
low - 600.00 = "menos que R$600,00" 
600.01 - 800.00 = "R$600,01 - R$800,00"
800.01 - 1000.00 = "R$800,01 - R$1000,00" 
1000.01 - 1300.00 = "R$1000,01 - R$1200,00"
1300.01 - high = "R$1200,001 ou mais";
run;

*CRIANDO FAIXAS PARA ESCOLARIDADE ALTA;
proc format;
value cut_educ 
0 - 0.030 = "0% - 3%"
0.031 - 0.070 = "3,1% - 7%" 
0.071 - 0.100 = "7,1% - 10%"
.101 - high = "10,1% ou mais";
run;
```

```sas

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
%plot_map(variavel=pretaME,nome_var=Média de salário das mulheres negras,formatar=cut_salario.);
%plot_map(variavel=brancaME,nome_var=Média de salário das mulheres brancas,formatar=cut_salario.);
%plot_map(variavel=pretaP,nome_var=Porcentagem de mulheres negras com ensino superior,formatar=cut_educ.);
%plot_map(variavel=brancaP,nome_var=Porcentagem de mulheres brancas com ensino superior,formatar=cut_educ.);
```

<img align="center" width="800" height="400" src="https://github.com/WOLFurriell/MapsInSAS/blob/master/MulherEDU2.png">

<img align="center" width="800" height="400" src="https://github.com/WOLFurriell/MapsInSAS/blob/master/MulherME2.png">

You can see the script wihtout comments here [script](https://github.com/WOLFurriell/MapsInSAS/blob/master/Cartogramas_mulheres.sas)




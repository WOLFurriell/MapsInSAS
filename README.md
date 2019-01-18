# Building a simple map in SAS

To make a map in SAS you need a shapefile, this file has the spatial coordinates to plot the map respecting the actual proportions of the space. 
In this case used the IBGE APONDs(Areas of Weighting) shapefile of the cities of Maringá, Sarandi and Paiçandu. You can download this shapes here:[IBGE shapefiles](https://downloads.ibge.gov.br/downloads_geociencias.htm).
To import the shapefile in sas I used proc mapimport. How I want to show the delimitation of the cities and of the Aponds I used two shapefiles.

```sas
/* IMPORTANDO O SHAPEFILE DAS APONDS*/
proc mapimport datafile="C:\Users\Furriel\Box Sync\MULHERES_NEGRAS\Shapes\MGA_SRD_PDC_SAS.shp"
out=shape_mulheres;
run;

/*FAZENDO AS DELIMITAÇÕES DAS CIDADES*/
proc mapimport datafile="C:\Users\Furriel\Box Sync\MULHERES_NEGRAS\Shapes\MGA_SRD_PDC_MU.shp"
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

The next step was to create a data with the central coordinates of cities to place the label. To do this I used proc summary and calculated the average of latitude and longitude.

```sas
/*CRIANDO OS LABELS*/
/*CALCULANDO UM PONTO CENTRAL NO POLIGONO PARA O LABEL DA CIDADE*/
proc summary data=shape_mulheres(keep= X Y NM_MUNICIP) nway missing;
 class NM_MUNICIP;
 var x y;
 output out=label_aux(drop=_type_ _freq_) mean=;
run;

```


```sas
```


```sas
```


```sas
```

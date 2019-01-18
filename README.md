# Building a simple mapa in SAS

To make a map in SAS you need a shapefile, this file has the spatial coordinates to plot the map respecting the actual proportions of the space. 
In this case used the IBGE APONDs(Areas of Weighting) shapefile of the cities of Maringá, Sarandi and Paiçandu. You can download this shapes here:[IBGE shapefiles](https://downloads.ibge.gov.br/downloads_geociencias.htm)

```sas
proc mapimport datafile="C:\Users\Furriel\Box Sync\MULHERES_NEGRAS\Shapes\MGA_SRD_PDC_SAS.shp"
  out=shape_mulheres;
run;

```

/* 1. Charger les données, en modifiant l’échelle de la l’énergie, qu’on préfère mesuré en milliards de tonnes */
/* équivalent pétrole. */
/* DATA pibenergie; */
/* 	INFILE "/chemin/vers/le/fichier/pib.energie.data" DLM = ","; */
/* 	INPUT pays :$20. pib energie zone :$20.; */
/* 	energie = energie / 1000000000; */
/* RUN; */


LIBNAME lib "/home/u63017368/Archive/Cours/TP Noté";

DATA pibenergie;
	INFILE "/home/u63017368/Archive/Cours/TP Noté/pib.energie.data" DLM=","; /*1.charger*/
	INPUT pays :$20. pib energie zone :$20.; /*Modifier en miliard*/
	energie =energie / 1000000000;
RUN;




/* 2. En utilisant la procédure TABULATE, afficher la moyenne des deux variables numériques, selon les zones */
/* géographiques. Faire la même chose en utilisant la procédure MEANS. */
/* PROC TABULATE DATA=pibenergie; */
/* 	CLASS zone; */
/* 	VAR pib energie; */
/* 	TABLE zone, pib*(MEAN) energie*(MEAN); */
/* RUN; */
/* PROC MEANS DATA=pibenergie MEAN; */
/* 	CLASS zone; */
/* 	VAR pib energie; */
/* RUN; */


/* 2. En utilisant la procédure TABULATE, afficher la moyenne des deux variables numériques, selon les zones */
PROC TABULATE data=pibenergie;
	CLASS zone;
	VAR pib energie;
	TABLE zone, (pib energie)*(MEAN); /* N MAX MIN*/
RUN;


PROC MEANS DATA=pibenergie MEAN;
	CLASS zone;
	VAR pib energie;
RUN;



/*3. Boite a moustache*/
PROC SGPLOT data= pibenergie;
	VBOX pib / CATEGORY=zone;
RUN;

PROC SGPLOT data=pibenergie;
	VBOX energie / CATEGORY=zone;
RUN;



/*4. Nuage de points*/
PROC SGPLOT data=pibenergie;
	SCATTER x=pib y=energie / DATALABEL=pays;
RUN;

/** 在此基础上变为log轴 */
PROC SGPLOT data=pibenergie;
	SCATTER X=pib Y=energie / DATALABEL=pays;
	XAXIS TYPE=log;
	YAXIS TYPE=log;
RUN;

/* 5. Macro + K-Means*/

%MACRO kmeans (k=2);
	PROC FASTCLUS DATA=pibenergie MAXC=&k MAXITER=10 OUT=km;
		VAR pib energie;
		ID pays;
	RUN;
	PROC SGPLOT DATA=km;
		VBOX pib / CATEGORY=CLUSTER;
	RUN;
	PROC SGPLOT DATA=km;
		VBOX energie / CATEGORY=CLUSTER;
	RUN;
%MEND kmeans;
%kmeans (k=3);


/* 6. Modifier le macro-programme pour que la méthode K-means utilise les données centrées et réduites
(avec la procédure STDIZE). Les boîtes à moustaches doivent afficher les données brutes. */
%MACRO kmeans2 (k=2);
	PROC STDIZE DATA=pibenergie OUT=pibenergie2;
		VAR pib energie;
	RUN;
	PROC FASTCLUS DATA=pibenergie2 MAXC=&k MAXITER=10 OUT=km;
		VAR pib energie;
		ID pays;
	RUN;
	PROC SGPLOT DATA=km;
		VBOX pib / CATEGORY=CLUSTER;
	RUN;
	PROC SGPLOT DATA=km;
		VBOX energie / CATEGORY=CLUSTER;
	RUN;
%MEND kmeans2;
%kmeans2 (k=3);

/* 7. Donner une interprétation de chacun des clusters obtenus. */
/* Sans centrer et réduire les données, en trois clusters, on trouve :
   - un cluster avec une seule instance, à la consommation d'énergie très élevée et le PIB assez élevé (les USA) ;
   - un cluster à la consommation d'énergie moyenne et au PIB élevé ;
   - un cluster à consommation d'énergie faible et au PIB faible.
   En centrant et en réduisant les données, on trouve les USA, la Chine et les autres pays. */

/* 8. Faire le même travail (questions 5 à 7) avec le méthode de Ward. */
%MACRO ward (k=2);
	PROC CLUSTER DATA=pibenergie METHOD=WARD OUTTREE=tree;
		VAR pib energie;
		ID pays;
	RUN;
	PROC TREE DATA=tree NCLUSTERS=&k OUT=ward;
		ID pays;
	RUN;
	PROC SORT DATA=ward OUT=ward;
		BY pays;
	RUN;
	DATA fusion;
		MERGE pibenergie ward;
		BY pays;
	RUN;
	PROC SGPLOT DATA=fusion;
		VBOX pib / CATEGORY=CLUSTER;
	RUN;
	PROC SGPLOT DATA=fusion;
		VBOX energie / CATEGORY=CLUSTER;
	RUN;
%MEND ward;
%ward (k=3);
%MACRO ward2 (k=2);
	PROC STDIZE DATA=pibenergie OUT=pibenergie2;
		VAR pib energie;
	RUN;
	PROC CLUSTER DATA=pibenergie2 METHOD=WARD OUTTREE=tree;
		VAR pib energie;
		ID pays;
	RUN;
	PROC TREE DATA=tree NCLUSTERS=&k OUT=ward;
		ID pays;
	RUN;
	PROC SORT DATA=ward OUT=ward;
		BY pays;
	RUN;
	DATA fusion;
		MERGE pibenergie ward;
		BY pays;
	RUN;
	PROC SGPLOT DATA=fusion;
		VBOX pib / CATEGORY=CLUSTER;
	RUN;
	PROC SGPLOT DATA=fusion;
		VBOX energie / CATEGORY=CLUSTER;
	RUN;
%MEND ward2;
%ward2 (k=3);
/* Sur les données brutes, on trouve des clusters similaires à ceux de K-means
   Sur les données centrées-réduites, on trouve un cluster avec la Chine et les USA, et deux autres clusters :
   - un cluster avec des pays à la consommation d'énergie et au PIB faibles ;
   - un cluster avec des pays à la consommation d'énergie et au PIB moyens. */

















































-- création de la base de donnée nommée bano_paris
create database bano_paris;
\c bano_paris
create extension postgis;
CREATE TABLE bano75_integration
(
   id character varying,
   num character varying,
   voie character varying,
   cp character varying,
   commune character varying,
   source_bano character varying,
   latitude double precision,
   longitude double precision
)
WITH (
   OIDS=FALSE
);



COPY bano75_integration(id, num, voie, cp, commune, source_bano, longitude, latitude)
FROM '/home/marih/Desktop/rendu_bano/bano.csv' DELIMITER ',' CSV;

ALTER TABLE bano75_integration ADD type_voie character varying,   ADD  article_voie character varying,  ADD nom_voie character varying;

update bano75_integration set type_voie=
(case 
	when SPLIT_PART( voie,' ', 1)='Grande' and SPLIT_PART( voie,' ', 2)= 'Avenue' then '{Grande Avenue}'
	else  SPLIT_PART( voie,' ', 1)  
	end);

update bano75_integration set article_voie=
(case 
	when SPLIT_PART( voie,' ', 2)='de' and SPLIT_PART( voie,' ', 3)= 'la' then 'de la'
	when SPLIT_PART( voie,' ', 2)='de' and SPLIT_PART( voie,' ', 3)= 'le' then 'de le'
	when SPLIT_PART( voie,' ', 2)='de' and LEFT(SPLIT_PART( voie,' ', 3), 2)= 'l''' then 'de l'''
	when SPLIT_PART( voie,' ', 2)='de' and LEFT(SPLIT_PART( voie,' ', 3), 2)!= 'l''' and SPLIT_PART( voie,' ', 3)!='la' and 	 SPLIT_PART( voie,' ', 3)!='le'then 'de'
	when SPLIT_PART( voie,' ', 2)='du' then 'du'
	when SPLIT_PART( voie,' ', 2)='des' then 'des'
	when LEFT(SPLIT_PART( voie,' ', 2), 2)= 'd''' then 'd'''
	when SPLIT_PART( voie,' ', 1)='Grande' and SPLIT_PART( voie,' ', 2)='Avenue' then 'de la'
	else ''
end);
update bano75_integration set nom_voie=
(case
	
	when SPLIT_PART( voie,' ', 2)='de' and SPLIT_PART( voie,' ', 3)= 'la' then 
	     SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+8, 100)
	when SPLIT_PART( voie,' ', 2)='de' and SPLIT_PART( voie,' ', 3)= 'le' then 
	     SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+8, 100)
	when SPLIT_PART( voie,' ', 2)='de' and LEFT(SPLIT_PART( voie,' ', 3), 2)= 'l''' then 
	     SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+7, 100)
	when SPLIT_PART( voie,' ', 2)='du' then 
	     SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+5, 100)
	when LEFT(SPLIT_PART( voie,' ', 2), 2)= 'd''' then 
	     SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+4, 100) 
	when SPLIT_PART( voie,' ', 2)='des' then 
	     SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+6, 100) 
	when SPLIT_PART( voie,' ', 1)='Grande' and SPLIT_PART( voie,' ', 2)='Avenue' then 
	   SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+14, 100) 
	when SPLIT_PART( voie,' ', 2)='de' and LEFT(SPLIT_PART( voie,' ', 3), 2)!= 'l''' and SPLIT_PART( voie,' ', 3)!='la' and 	 	    SPLIT_PART( voie,' ', 3)!='le'then  SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+5, 100)
        else SUBSTR(voie,length(SPLIT_PART( voie,' ', 1))+2, 100) 
end);

select AddGeometryColumn ('bano75_integration', 'geom',4326, 'POINT', 2) ;
update bano75_integration set geom = ST_SetSRID(ST_MakePoint(latitude,longitude),4326);

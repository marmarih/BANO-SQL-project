----------------------------------------------------------------------------
-- Ce fichier contient l'ensemble des requêtes SQL utilisé dans le projet --
-- Ces requêtes s'appuient sur les expressions régulières				  --
----------------------------------------------------------------------------

-- création de la base de donnée bano75
create database bano75;
--on accède à la BD
\c bano75
-- création de l'extension postgis pour la BD crée
create extension postgis;
-- création de table avec ses 8 champs
-- création de la base de donnée nommée bano_paris
create database bano75;
\c bano75
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
-- injection du fichier bano.csv dans la table crée ci-dessus
-- '/home/marih/Desktop/rendu_bano/bano.csv'  est le chemin du fichier bano.csv

COPY bano75_integration(id, num, voie, cp, commune, source_bano, longitude, latitude)
FROM '/home/marih/Desktop/rendu_bano/bano.csv' DELIMITER ',' CSV;

-- modification de la table bano75_integration : ajout de 4 colonnes

ALTER TABLE bano75_integration ADD part2 character varying, ADD type_voie character varying,   ADD  article_voie character varying,  ADD nom_voie character varying;
-- remplissage des colonnes
-- la fonction sbstr('nom_du_champ', l'emplacement_du_caractère_de_départ, l'emplacement_du_caractère_d'arrêt) permet d'extraire une chaine de caractère
-- SPLIT_PART( 'nom_du_champ,'caractère_de_division', numéro_du_split)) permet de diviser le champs selon le caractère de division et retourne le split dont le numéro est le 3ème paramètre de la fonction
-- regexp_replace('nom_du_champ',chaine_à_remplacé, chaine_de_remplacement)

update bano75_integration set 		part2     =substr(voie ,length(SPLIT_PART( voie,' ', 1))+2 ,((length (voie))-(strpos(voie,'de|des|d''|du '))));
update bano75_integration set		type_voie = (case 
						when SPLIT_PART( voie,' ', 1)='Grande' and 
						SPLIT_PART( voie,' ', 2)= 'Avenue' then '{Grande Avenue}'
						else  regexp_replace(voie, part2, '')   
						end);

update bano75_integration set		article_voie = (case 
						when SPLIT_PART( voie,' ', 1)='Grande' and SPLIT_PART( voie,' ', 2)= 'Avenue' then 'de la'
       						else (substring(part2 from '^d''|^de|^des|^de+\s+la|^de+\s+le|^des|^de+\s+l''|^du'))
       						end );
-- regexp_replace('nom_du_champ',chaine_à_remplacé, chaine_de_remplacement)

update bano75_integration set		nom_voie = (case 
						when SPLIT_PART( voie,' ', 1)='Grande' and SPLIT_PART( voie,' ', 2)= 'Avenue' then 'ville de la reunion'
       						else regexp_replace(part2, '^d''|^de|^des|^de+\s+la|^de+\s+le|^des|^de+\s+l''|^du', '')
 					        end );

ALTER TABLE bano75_integration
DROP COLUMN part2;
-- ajout de la colonne geom de type point dont la latitude et la longitude sont les colonnes latitude et longitude de la table

select AddGeometryColumn ('bano75_integration', 'geom',4326, 'POINT', 2) ;
update bano75_integration set geom = ST_SetSRID(ST_MakePoint(latitude,longitude),4326);







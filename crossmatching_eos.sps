* Encoding: UTF-8.
GET
  FILE='H:\GitHub\movies\allthemovies.sav'.
DATASET NAME allmovies WINDOW=FRONT.
EXECUTE.


SAVE OUTFILE='H:\GitHub\movies\crossmatch.sav'
  /COMPRESSED
  /KEEP key title opening_year metatitle metayear imdbtitle imdbyear.


DATASET CLOSE allmovies.

GET
  FILE='h:\GitHub\movies\crossmatch.sav'.
DATASET NAME cross WINDOW=FRONT.
EXECUTE.

RENAME VARIABLES opening_year=year.


DATASET ACTIVATE cross.
DATASET COPY  imdbonly.
DATASET ACTIVATE  imdbonly.
FILTER OFF.
USE ALL.
SELECT IF (title = '' & metatitle = '' & imdbtitle ~= '').
EXECUTE.
DELETE VARIABLES title year metatitle metayear.
EXECUTE.

SAVE OUTFILE='h:\GitHub\movies\imdbonly.sav'
   /COMPRESSED.

DATASET ACTIVATE  cross.

DATASET CLOSE imdbonly.



SELECT IF (title ~= '' | metatitle ~= '').
EXECUTE.

SORT CASES BY key.



SAVE OUTFILE='h:\GitHub\movies\crossmatch.sav'
  /COMPRESSED.




SAVE TRANSLATE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/crossmatch.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES.

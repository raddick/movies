* Encoding: UTF-8.

GET
  FILE='/Users/jordan/Documents/movies/data_2017_5_9/allthemovies.sav'.
DATASET NAME allmovies WINDOW=FRONT.
EXECUTE.


SAVE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/crossmatch.sav'
  /COMPRESSED
  /KEEP key title opening_year metatitle metayear imdbtitle imdbyear.


DATASET CLOSE allmovies.

GET
  FILE='/Users/jordan/Documents/movies/data_2017_5_9/crossmatch.sav'.
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

SAVE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/imdbonly.sav'
   /COMPRESSED.

DATASET ACTIVATE  cross.

DATASET CLOSE imdbonly.



SELECT IF (title ~= '' | metatitle ~= '').
EXECUTE.

SORT CASES BY key.



SAVE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/crossmatch.sav'
  /COMPRESSED.




SAVE TRANSLATE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/crossmatch.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES.

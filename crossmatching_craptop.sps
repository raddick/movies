* Encoding: UTF-8.
GET
  FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\allthemovies.sav'.
DATASET NAME allmovies WINDOW=FRONT.
EXECUTE.


SAVE  
 OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\crossmatch.sav'
  /COMPRESSED
  /KEEP key title opening_year metatitle metayear imdbtitle imdbyear.


DATASET CLOSE allmovies.

GET
  FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\crossmatch.sav'.
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

SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\imdbonly.sav'
   /COMPRESSED.

DATASET ACTIVATE  cross.

DATASET CLOSE imdbonly.

SELECT IF (title ~= '' | metatitle ~= '').
EXECUTE.

SORT CASES BY key.

SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\crossmatch.sav'
  /COMPRESSED.

DATASET CLOSE cross.

GET FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\crossmatch.sav'.
DATASET NAME all3 WINDOW=FRONT.
DATASET ACTIVATE all3.

DATASET COPY not_boxofficemojo.
DATASET ACTIVATE not_boxofficemojo.

SELECT IF ((title = '') AND (metatitle ~= '' AND imdbtitle ~= '')).
EXECUTE.

SAVE TRANSLATE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\compare\nobom.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES
  /REPLACE.

DATASET ACTIVATE all3.
DATASET CLOSE not_boxofficemojo.

DATASET COPY not_metacritic.
DATASET ACTIVATE not_metacritic.

SELECT IF ((metatitle = '') AND (title ~= '' AND imdbtitle ~= '')).
EXECUTE.

SAVE TRANSLATE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\compare\nometa.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES
  /REPLACE.

DATASET ACTIVATE all3.
DATASET CLOSE not_metacritic.

DATASET COPY not_imdb.
DATASET ACTIVATE not_imdb.

SELECT IF ((imdbtitle = '') AND (title ~= '' AND metatitle ~= '')).
EXECUTE.

SAVE TRANSLATE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\compare\noimdb.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES
  /REPLACE.

DATASET ACTIVATE all3.
DATASET CLOSE not_imdb.


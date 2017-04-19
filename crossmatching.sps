GET
  FILE='/Users/jordan/Google Drive/movies/allthemovies.sav'.
DATASET NAME allmovies WINDOW=FRONT.
EXECUTE.


SAVE OUTFILE='/Users/jordan/Google Drive/movies/crossmatch.sav'
  /COMPRESSED
  /KEEP key title year metatitle metayear imdbtitle imdbyear.


DATASET CLOSE allmovies.

GET
  FILE='/Users/jordan/Google Drive/movies/crossmatch.sav'.
DATASET NAME cross WINDOW=FRONT.
EXECUTE.



DATASET ACTIVATE cross.
DATASET COPY  imdbonly.
DATASET ACTIVATE  imdbonly.
FILTER OFF.
USE ALL.
SELECT IF (title = '' & metatitle = '' & imdbtitle ~= '').
EXECUTE.
DELETE VARIABLES title year metatitle metayear.
EXECUTE.


DATASET ACTIVATE  cross.

SELECT IF ((title ~= '' | metatitle ~= '') & (imdbtitle = '')).
EXECUTE.

SORT CASES BY title.

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



GET DATA /TYPE=XLSX
  /FILE='/Users/jordan/Documents/movies/data_2017_5_9/imdb/imdb1960_for_matching.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME imdbprev WINDOW=FRONT.
DATASET ACTIVATE imdbprev.

ALTER TYPE key (A13).
FORMATS key (A13).

MISSING VALUES imdbrating length nVotes budget revenue (-1).

FORMATS imdbrating (F3.1).
FORMATS length (F5.0).
FORMATS budget (DOLLAR10.0).
FORMATS revenue (DOLLAR10.0).

RECODE mpaa ('PG'='0') ('PG-13'='1') ('R'='2').
EXECUTE.

VALUE LABELS mpaa
   0 'PG'
   1 'PG-13'
   2 'R'.

SORT CASES BY key(A).

* Identify Duplicate Cases.
*MATCH FILES
  /FILE=*
  /BY key
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
*DO IF (PrimaryFirst).
*COMPUTE  MatchSequence=1-PrimaryLast.
*ELSE.
*COMPUTE  MatchSequence=MatchSequence+1.
*END IF.
*LEAVE  MatchSequence.
*FORMATS  MatchSequence (f7).
*COMPUTE  InDupGrp=MatchSequence>0.
*SORT CASES InDupGrp(D).
*MATCH FILES
  /FILE=*
  /DROP=PrimaryFirst PrimaryLast InDupGrp.
*VARIABLE LABELS  MatchSequence 'Sequential count of matching cases'.
*VARIABLE LEVEL  MatchSequence (SCALE).
*EXECUTE.
*DATASET COPY imdbprev_duplicates.
*DATASET ACTIVATE imdbprev_duplicates.
*SELECT IF MatchSequence > 0.
*EXECUTE.
*SORT CASES BY MatchSequence(D).
*SAVE TRANSLATE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/imdb/imdb1960_duplicates.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES.

DATASET ACTIVATE cross.


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

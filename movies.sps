* Encoding: UTF-8.
* Encoding: .
* Encoding: .
/* General tips about programming SPSS:
/*    1) All commands end with periods. 
/*    1) SPSS provides helpful color-coding. Command names are blue, option names are green, and option 

/* First, read in the Excel file with the Box Office Mojo data, using the "Get Data" command */

GET DATA /TYPE=XLSX   /* File type is .xlsx (Excel 2010+) */
  /FILE='/Users/jordan/Documents/movies/data_2017_5_9/boxofficemojo/boxofficemojo2000s.xlsx'   /* Name of file, including the full path (so the script knows where to find it on the computer */
  /SHEET=name 'Sheet1'  /* Read from the worksheet called "Sheet1" - this is only needed for Excel files (when you have specified TYPE=XLSX above)
  /CELLRANGE=full  /* Read all cells, do not skip any variables (columns) or cases (rows)
  /READNAMES=on /* Get the names of the variables (columns from the first row of the Excel file
  /ASSUMEDSTRWIDTH=32767 /* Strings (text values) might be as long as 32,767 characters long, the largest possible value. Picking such a large value makes the load time longer, but guarantees we dont't miss anything.  */ 
.
EXECUTE.

/* SPSS refers to windows containing data as "datasets." The next line just says to give the data we just opened a name. When we have multiple datasets open, we can switch back and forth between them to run commands. */

DATASET NAME movies WINDOW=FRONT.

FORMATS totalgross openinggross (DOLLAR10.0).
FORMATS totaltheaters openingtheaters (F6.0).

VARIABLE LEVEL  opening_year opening_month opening_day (scale).


ALTER TYPE key (A13).
EXECUTE.
FORMATS key (A13).

COMPUTE  opening_date=DATE.DMY(opening_day, opening_month, opening_year).
EXECUTE.

FORMATS opening_date (SDATE10).

SORT CASES BY key(A).



* Let's make sure there are no duplicated key values.
*  DATASET ACTIVATE movies.
  FREQUENCIES VARIABLES=key
   /FORMAT=DFREQ
    /ORDER=ANALYSIS.
/* Duplicated values on the first try, with fixes:
/* finalgigirl (FIX: keep one as 2015, delete other two)
/* offendnder (FIX: keep one as 2012, delete other two)
/* toystor(3d) (FIX: delete all, these are re-releases)
/* distric10atum (FIX: delete the one without the b, it is a foreign re-release and has no data anyway
/* fantasia00max) (FIX: delete separate 35mm & IMAX versions, rename combined one as fantasia002000
/* forever15015 (FIX: separate movies, now forever15ever and forever15oung
/* lobster16ase) (FIX: separate releases, keep only US release as lobster16ster


GET DATA /TYPE=XLSX
  /FILE='/Users/jordan/Documents/movies/data_2017_5_9/metacritic/metacritic2000s.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME metacritic WINDOW=FRONT.

ALTER TYPE key (A13).
EXECUTE.

FORMATS key (A13).

FORMATS metascore (F3.0).
FORMATS metadate (SDATE10).
FORMATS metayear (F4.0).

SORT CASES BY key(A).

* Let's make sure there are no duplicated key values.
   FREQUENCIES VARIABLES=key
     /FORMAT=DFREQ
     /ORDER=ANALYSIS.

/* Duplicated values on the first try, with fixes... the hell with this, let's automate.
*DATASET ACTIVATE metacritic.
* Identify Duplicate Cases.
*SORT CASES BY key(A).
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
  /DROP=PrimaryLast InDupGrp.
*VARIABLE LABELS  PrimaryFirst 'Indicator of each first matching case as Primary' MatchSequence 
    'Sequential count of matching cases'.
*VALUE LABELS  PrimaryFirst 0 'Duplicate Case' 1 'Primary Case'.
*VARIABLE LEVEL  PrimaryFirst (ORDINAL) /MatchSequence (SCALE).
*EXECUTE.
*DATASET COPY  metacritic_duplicates.
*DATASET ACTIVATE  metacritic_duplicates.
*FILTER OFF.
*USE ALL.
*SELECT IF (MatchSequence>0).
*EXECUTE.
*DATASET ACTIVATE  metacritic_duplicates.
*SAVE TRANSLATE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/metacritic/metacritic_duplicates.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES.

DATASET ACTIVATE movies.

MATCH FILES /FILE=*
  /FILE='metacritic'
  /IN source01
  /BY key.
EXECUTE.


DATASET CLOSE metacritic.

VALUE LABELS source01
    0 'Box Office Mojo'
    1 'Metacritic'.


GET DATA /TYPE=XLSX
  /FILE='/Users/jordan/Documents/movies/data_2017_5_9/imdb/imdball.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME imdb WINDOW=FRONT.
DATASET ACTIVATE imdb.




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

MATCH FILES
  /FILE=*
  /BY key
  /FIRST=PrimaryFirst
  /LAST=PrimaryLast.
DO IF (PrimaryFirst).
COMPUTE  MatchSequence=1-PrimaryLast.
ELSE.
COMPUTE  MatchSequence=MatchSequence+1.
END IF.
LEAVE  MatchSequence.
FORMATS  MatchSequence (f7).
COMPUTE  InDupGrp=MatchSequence>0.
SORT CASES InDupGrp(D).
MATCH FILES
  /FILE=*
  /DROP=PrimaryFirst PrimaryLast InDupGrp.
VARIABLE LABELS  MatchSequence 'Sequential count of matching cases'.
VARIABLE LEVEL  MatchSequence (SCALE).
EXECUTE.
DATASET COPY imdb_duplicates.
DATASET ACTIVATE imdb_duplicates.
SELECT IF MatchSequence > 0.
EXECUTE.
SORT CASES BY MatchSequence(D).
SAVE TRANSLATE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/imdb/imdb2000s_duplicates.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /FIELDNAMES VALUE=NAMES
  /CELLS=VALUES
  /REPLACE.


DATASET ACTIVATE movies.

SORT CASES BY key(A).

MATCH FILES /FILE=*
  /FILE='imdb'
  /IN source02
  /BY key.
EXECUTE.

DATASET CLOSE imdb.

COMPUTE source02 = source02 * 2.
EXECUTE.

VALUE LABELS source02
    0 'Previous'
    2 'IMDb'.


COMPUTE sourcedataset=source01.
EXECUTE.

IF missing(sourcedataset)=1 sourcedataset=source02.
EXECUTE.

VALUE LABELS sourcedataset
    0 'Box Office Mojo'
    1 'Metacritic'
    2 'IMDb'.

DELETE VARIABLES source01 source02.

DATASET ACTIVATE movies.
FREQUENCIES VARIABLES=sourcedataset
  /ORDER=ANALYSIS.

SAVE OUTFILE='/Users/jordan/Documents/movies/data_2017_5_9/allthemovies.sav'
  /DROP=originalorder metaorder imdborder
  /COMPRESSED.










COMPUTE releasemonth=XDATE.MONTH(opening_date).
EXECUTE.

COMPUTE releaseweekday=XDATE.WKDAY(opening_date).
EXECUTE.

FORMATS releasemonth (F2.0) releaseweekday (F1.0).

VALUE LABELS releasemonth
   1 'January'
   2 'February'
   3 'March'
   4 'April'
   5 'May'
   6 'June'
   7 'July'
   8 'August'
   9 'September'
   10 'October'
   11 'November'
   12 'December'.
EXECUTE.

VALUE LABELS releaseweekday
    1 'Sunday'
    2 'Monday'
    3 'Tuesday'
    4 'Wednesday'
    5 'Thursday'
    6 'Friday'
    7 'Saturday'.
EXECUTE.

COMPUTE releaseweeknumber = XDATE.WEEK(opening_date).
EXECUTE.

FORMATS releaseweeknumber (F2.0).


GET DATA /TYPE=XLSX
  /FILE='/Users/jordan/Google Drive/movies/cpi.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME cpidata WINDOW=FRONT.
SORT CASES BY opening_date.

DATASET ACTIVATE movies.
SORT CASES BY opening_date.


MATCH FILES /FILE=*
  /TABLE='cpidata'
  /BY opening_date.
EXECUTE.

DATASET CLOSE cpidata.

COMPUTE adjusted_gross = total_gross * cpimultiplier.
COMPUTE adjusted_opening_gross = opening_gross * cpimultiplier.
EXECUTE.

FORMATS adjusted_gross adjusted_opening_gross (DOLLAR11.0).

RENAME VARIABLES newkey=key.

SAVE OUTFILE='/Users/jordan/Google Drive/movies/allthemovies.sav'
  /COMPRESSED
  /KEEP key title year opening_date releasemonth releaseweekday releaseweeknumber
             total_gross adjusted_gross nvotes userscore metascore metacritic_user_score 
             studio total_theaters opening_gross adjusted_opening_gross
             opening_theaters vote_distribution
             metatitle metayear imdbtitle imdbyear cpimultiplier.

DATASET CLOSE movies.

GET
  FILE='/Users/jordan/Google Drive/movies/allthemovies.sav'.
DATASET NAME allmovies WINDOW=FRONT.


SAVE OUTFILE='/Users/jordan/Google Drive/movies/crossmatch.sav'
  /COMPRESSED
  /KEEP key title year metatitle metayear imdbtitle imdbyear.


DATASET CLOSE allmovies.

GET
  FILE='/Users/jordan/Google Drive/movies/crossmatch.sav'.
DATASET NAME cross WINDOW=FRONT.
EXECUTE.

DATASET ACTIVATE cross.

SORT CASES BY key.

DATASET COPY  imdbonly.
DATASET ACTIVATE  imdbonly.

SELECT IF (title = '' & metatitle = '' & imdbtitle ~= '').
EXECUTE.

DELETE VARIABLES title year metatitle metayear.
EXECUTE.

SAVE OUTFILE='/Users/jordan/Google Drive/movies/imdbonly.sav'
  /COMPRESSED.

DATASET CLOSE imdbonly.
DATASET ACTIVATE cross.

SELECT IF ((title ~= '' | metatitle ~= '') & (imdbtitle = '')).
EXECUTE.

SORT CASES BY title.

SAVE OUTFILE='/Users/jordan/Google Drive/movies/crossmatch.sav'
  /COMPRESSED.

DATASET CLOSE cross.

GET
  FILE='/Users/jordan/Google Drive/movies/crossmatch.sav'.
DATASET NAME crossmat WINDOW=FRONT.

DATASET CLOSE crossmat.


GET
  FILE='/Users/jordan/Google Drive/movies/allthemovies.sav'.
DATASET NAME allmovies WINDOW=FRONT.

DATASET ACTIVATE allmovies.

 SELECT IF (title ~= '' & imdbtitle ~= '' & metatitle ~= '').
 EXECUTE.

 SAVE OUTFILE='/Users/jordan/Google Drive/movies/three.sav'
   /COMPRESSED
   /KEEP key title year opening_date releasemonth releaseweekday releaseweeknumber
              total_gross adjusted_gross nvotes userscore metascore metacritic_user_score
              studio total_theaters opening_gross adjusted_opening_gross 
              opening_theaters vote_distribution
              metatitle metayear imdbtitle imdbyear 
              cpimultiplier. /* editedincrossmatch metaeditedcrossmatch imdbeditedcrossmatch.

DATASET CLOSE allmovies.

GET
  FILE='/Users/jordan/Google Drive/movies/three.sav'.
DATASET NAME three WINDOW=FRONT.



* Visual Binning.
*adjusted_gross.
RECODE  adjusted_gross (MISSING=COPY) (LO THRU 100000 = 1) (100001 THRU 10000000 = 2) (10000001 THRU 100000000 = 3) 
    (100000001 THRU HI = 4) (ELSE=SYSMIS) INTO adjusted_gross_binned.
FORMATS  adjusted_gross_binned (F1.0).
VALUE LABELS  adjusted_gross_binned 1 'Less than $100,000' 2 '$100,000 to $10 million' 3 '$10-100 million' 4 'More than '+
    '$100 million'.
VARIABLE LEVEL  adjusted_gross_binned (ORDINAL).
EXECUTE.

* Visual Binning.
*nvotes.
RECODE  nvotes (MISSING=COPY) (LO THRU 100=1) (101 THRU 1000=2) (1001 THRU 10000=3) (10001 THRU 100000=4) 
    (100001 THRU HI=5) (ELSE=SYSMIS) INTO nvotes_binned.
VARIABLE LABELS  nvotes_binned 'nvotes (Binned)'.
FORMATS  nvotes_binned (F5.0).
VALUE LABELS  nvotes_binned 1 'Less than 100 votes' 2 '101-1,000 votes' 3 '1,001-10,000 votes' 4 '10,001-100,000 votes'
    5 'More than 100,000 votes' .
VARIABLE LEVEL  nvotes_binned (ORDINAL).
EXECUTE.


/*DELETE VARIABLES releaseperiod.
/*COMPUTE releaseperiod = 0.
/*EXECUTE.
/*IF (releasemonth=1) releaseperiod=1.
/*IF (releasemonth=2 | releasemonth=4 | releasemonth=9) releaseperiod=2.
/*IF (releasemonth=3 | releasemonth=8 | releasemonth=10) releaseperiod=3.
/*IF (releasemonth=5 | releasemonth=6 | releasemonth=7 | releasemonth=11 | releasemonth=12) releaseperiod=4.
/*EXECUTE.
/*VARIABLE LEVEL releaseperiod (NOMINAL).
/*VALUE LABELS releaseperiod
    /*1 'January'
    /*2 'Likely dump month'
    /*3 'Possible dump month'
    /*4 'Not a dump month'.


/*DELETE VARIABLES dumpmonth.

COMPUTE dumpmonth=0.
EXECUTE.
/*IF (releaseperiod<=3) dumpmonth=1.
/* IF (releasemonth <= 2 | releasemonth=8 | releasemonth=9) dumpmonth=1.
IF (releasemonth<=4 | releasemonth=8 | releasemonth=9 | releasemonth=10) dumpmonth=1.
EXECUTE.


VARIABLE LEVEL dumpmonth (NOMINAL).
FORMATS dumpmonth (F1.0).
VALUE LABELS dumpmonth 
   0 'Not a dump month'
   1 'Dump month'.


SAVE OUTFILE='/Users/jordan/Documents/three.sav'
  /COMPRESSED.


SAVE TRANSLATE OUTFILE='/Users/jordan/Google Drive/movies/three.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.





DATASET ACTIVATE three.
MEANS TABLES=adjusted_gross userscore metascore BY dumpmonth
  /CELLS=MEAN COUNT STDDEV.








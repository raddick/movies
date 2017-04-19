* Encoding: UTF-8.
/* General tips about programming SPSS:
/*    1) All commands end with periods. 
/*    1) SPSS provides helpful color-coding. Command names are blue, option names are green, and option 


/* First, read in the Excel file with the Box Office Mojo data, using the "Get Data" command */

GET DATA /TYPE=XLSX   /* File type is .xlsx (Excel 2010+) */
  /FILE='/Users/jordan/Google Drive/movies/data_2016_5_17/boxofficemojo/boxofficemojo2000s.xlsx'   /* Name of file, including the full path (so the script knows where to find it on the computer */
  /SHEET=name 'Sheet1'  /* Read from the worksheet called "Sheet1" - this is only needed for Excel files (when you have specified TYPE=XLSX above)
  /CELLRANGE=full  /* Read all cells, do not skip any variables (columns) or cases (rows)
  /READNAMES=on /* Get the names of the variables (columns from the first row of the Excel file
  /ASSUMEDSTRWIDTH=32767 /* Strings (text values) might be as long as 32,767 characters long, the largest possible value. Picking such a large value makes the load time longer, but guarantees we dont't miss anything.  */ 
.
EXECUTE.

/* SPSS refers to windows containing data as "datasets." The next line just says to give the data we just opened a name. When we have multiple datasets open, we can switch back and forth between them to run commands. */

DATASET NAME movies WINDOW=FRONT.

COMPUTE  opening_date=DATE.DMY(opening_day, opening_month, opening_year).
EXECUTE.

/* Each data

STRING newkey (A13).
EXECUTE.
COMPUTE newkey = key.
EXECUTE.
DELETE VARIABLES key.
EXECUTE.


/* FORMATS key (A21). /* studio (a10).
/* FORMATS title (A255) mojocomments (A255).
FORMATS year (F4.0).
FORMATS total_gross opening_gross (DOLLAR11.0).
FORMATS total_theaters opening_theaters (F7.0).
FORMATS opening_date (SDATE10).
FORMATS editedincrossmatch (F1.0).

DELETE VARIABLES opening_year opening_month opening_day.
EXECUTE.

SORT CASES BY newkey(A).

* Let's make sure there are no duplicated key values.
  DATASET ACTIVATE movies.
  FREQUENCIES VARIABLES=newkey
    /FORMAT=DFREQ
    /ORDER=ANALYSIS.

/* Duplicated values on the first try, with fixes:
/* 2007aca08ims   (FIX: remove all Oscar-nominated shorts, since they don't match other datasets anyway)
/* deathfa09ting   (FIX: was a duplicate, remove one row)
/* fantasi00max)   (FIX: 35mm & IMAX listed together and separately, remove separate entries)
/* mission14nary   (FIX: was a duplicate, remove the row with less data listed)




GET DATA /TYPE=XLSX
  /FILE='/Users/jordan/Google Drive/movies/data_2016_5_17/metacritic/metacritic_2000s.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME metacritic WINDOW=FRONT.


STRING newkey (A13).
EXECUTE.
COMPUTE newkey = key.
EXECUTE.
DELETE VARIABLES key.
EXECUTE.


FORMATS metascore (F3.0) metacritic_user_score (F3.1).
FORMATS metareleasedate (SDATE10).
FORMATS metayear (F4.0).
FORMATS metaeditedcrossmatch (F1.0).

SORT CASES BY newkey(A).

* Let's make sure there are no duplicated key values.
*   DATASET ACTIVATE metacritic.
*   FREQUENCIES VARIABLES=newkey
*     /FORMAT=DFREQ
*     /ORDER=ANALYSIS.

/* Duplicated values on the first try, with fixes:
/* chaos03haos   { FIX: got fixed_key values from 2015-4-10 data: "chaos01haos" & "kaosu[c00aos]" }
/* home06home  { FIX: copied fixed_key values from 2015-4-10 IMBDb data: homeii05meii & homei05omei }
/* hunter12nter   { FIX: the 01/04/2012 release not found in other datasets, so fix key to hunteii12nter }
/* lastrid12ride   { FIX: the "Last Ride" (without the) gets fixed_key = "lastrid12the]" }
/* sleepin11auty   { FIX: the one with "The" was a TV movie, so remove }
/* student13dent   { FIX: the one with "The" was "El estudiante", so fixed_key = "elestud11ante"; the one without was IMDb in 2012, so fixed_key = "student12dent" }
/* take08take   { FIX: the one without "The" was "Take" in 2007 in IMDb, so "take07take"; the one with "The" gets "take07the]" }


DATASET ACTIVATE movies.

MATCH FILES /FILE=*
  /FILE='metacritic'
  /BY newkey.
EXECUTE.


DATASET CLOSE metacritic.



GET DATA /TYPE=XLSX
  /FILE='/Users/jordan/Google Drive/movies/data_2016_5_17/imdb/imdb.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME imdb WINDOW=FRONT.



DATASET ACTIVATE imdb.


STRING newkey (A13).
EXECUTE.
COMPUTE newkey = key.
EXECUTE.
DELETE VARIABLES key.
EXECUTE.

FORMATS imdbyear (F4.0). 
FORMATS userscore (F3.1).
FORMATS imdbeditedcrossmatch (F1.0).

SORT CASES BY newkey(A).

/* Let's make sure there are no duplicated key values.
*  DATASET ACTIVATE imdb.
*   FREQUENCIES VARIABLES=newkey
*    /FORMAT=DFREQ
*   /ORDER=ANALYSIS.

/* Duplicated values on the first try, with fixes:
/* fistof11saga /* fistoft11kaio, fistoft11raul, fistoft11eray], fistoft11sout, fistoft11toki */
/* 28weeks07ater /* 28weeks07secs, 28weeks07days */
/* betterm13rman /* One had A, one had The */
/* family08mily
/* monalis04lisa
/* quest96uest
/* treasur06land
/* Also LOTS of things that appeared twice that I didn't track. */


DATASET ACTIVATE movies.

MATCH FILES /FILE=*
  /FILE='imdb'
  /BY newkey.
EXECUTE.


DATASET CLOSE imdb.





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


* Encoding: UTF-8. 
* General tips about programming SPSS:.
*    1) All commands end with periods.
*    1) SPSS provides helpful color-coding. Command names are blue, option names are green, and option.


* First, read in the Excel file with the Box Office Mojo data, using the "Get Data" command.
GET DATA /TYPE=XLSX   
  /FILE=
    'C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\boxofficemojo\boxofficemojo2000s.xlsx'
  /SHEET=name 'Sheet1'  /* Read from the worksheet called "Sheet1" - this is only needed for Excel files (when you have specified TYPE=XLSX above) */
  /CELLRANGE=full  /* Read all cells, do not skip any variables (columns) or cases (rows) */
  /READNAMES=on /* Get the names of the variables (columns from the first row of the Excel file */
  /ASSUMEDSTRWIDTH=32767. /* Strings (text values) might be as long as 32,767 characters long, the largest possible value. Picking such a large value makes the load time longer, but guarantees we dont't miss anything.
EXECUTE.
* SPSS refers to windows containing data as "datasets." The next line just says to give the data we just opened a name. When we have multiple datasets open, we can switch back and forth between them to run commands.
DATASET NAME movies WINDOW=FRONT.

FORMATS totalgross openinggross (DOLLAR10.0).
FORMATS totaltheaters openingtheaters (F6.0).

VARIABLE LEVEL  opening_year opening_month opening_day (scale).

ALTER TYPE key (A13).
EXECUTE.
FORMATS key (A13).

SORT CASES BY key(A).

* Let's make sure there are no duplicated key values.
*  FREQUENCIES VARIABLES=key
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


GET DATA
  /TYPE=XLSX
  /FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\metacritic\metacritic_all.xlsx'
  /SHEET=name 'Sheet1'
  /READNAMES=ON
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME metacritic WINDOW=FRONT.

DELETE VARIABLES exists_on_site has_metascore meta_retrieved.
DELETE VARIABLES auto_url fixed_url.

RENAME VARIABLES (url = metacritic_url).

COMPUTE meta_retrieved=DATE.DMY(meta_retrieved_day, meta_retrieved_month, meta_retrieved_year).
EXECUTE.

FORMATS meta_retrieved (SDATE10).

DELETE VARIABLES meta_retrieved_day meta_retrieved_month meta_retrieved_year.

ALTER TYPE key (A13).
EXECUTE.

FORMATS key (A13).

FORMATS metascore (F3.0).
FORMATS metadate (SDATE10).
FORMATS metayear (F4.0).

SORT CASES BY key(A).

* Let's make sure there are no duplicated key values.
*   FREQUENCIES VARIABLES=key
     /FORMAT=DFREQ
     /ORDER=ANALYSIS.

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
  /FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\imdb\imdball.xlsx'
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
*DATASET COPY imdb_duplicates.
*DATASET ACTIVATE imdb_duplicates.
*SELECT IF MatchSequence > 0.
*EXECUTE.
*SORT CASES BY MatchSequence(D).
*SAVE TRANSLATE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\imdb\imdbduplicates.xlsx'
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

SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\allthemovies.sav'
  /DROP=originalorder metaorder imdborder
  /COMPRESSED.

DATASET CLOSE movies.

GET FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\allthemovies.sav'.
DATASET NAME allthemovies WINDOW=FRONT.
DATASET ACTIVATE allthemovies.

RENAME VARIABLES (opening_day opening_month opening_year = releaseday releasemonth releaseyear).

DO IF (missing(releaseday) = 0 AND missing(releasemonth) = 0 AND missing(releaseyear) = 0).
COMPUTE opening_date=DATE.DMY(releaseday, releasemonth, releaseyear).
END IF.
EXECUTE.

FORMATS opening_date (SDATE10).

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
  /FILE='C:\Users\sciserver\Documents\GitHub\movies\inflation\cpi.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.
DATASET NAME cpidata WINDOW=FRONT.
SORT CASES BY opening_date.

DATASET ACTIVATE allthemovies.
SORT CASES BY opening_date.

MATCH FILES /FILE=*
  /TABLE='cpidata'
  /BY opening_date.
EXECUTE.

DATASET CLOSE cpidata.

COMPUTE adjustedgross = totalgross * cpimultiplier.
COMPUTE adjustedopeninggross = openinggross * cpimultiplier.
EXECUTE.

FORMATS adjustedgross adjustedopeninggross (DOLLAR11.0).

COUNT nGenres=Western History Documentary Musical War Biography RealityTV Drama Animation Music 
    Mystery Crime Thriller News SciFi Action Sport Comedy Romance Adventure Family TalkShow Horror(1).
EXECUTE.

FORMATS nGenres(F2.0).

SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\allthemovies.sav'
  /COMPRESSED
  /KEEP key title metatitle metayear imdbtitle imdbyear
             releaseyear releasemonth releaseday
             opening_date releaseweekday releaseweeknumber 
             totalgross adjustedgross nVotes imdbrating metascore rank_in_year
             studio totaltheaters
             mpaa budget country language nGenres
             Western History Documentary Musical War Biography RealityTV
             Drama Animation Music Mystery Crime Thriller News SciFi
             Action Sport Comedy Romance Adventure Family TalkShow Horror
             openinggross adjustedopeninggross
             openingtheaters vote_distribution
             boxofficemojo_url metacritic_url 
             meta_retrieved cpimultiplier sourcedataset.

DATASET CLOSE allthemovies.

GET FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\allthemovies.sav'.
DATASET NAME finalmovies WINDOW=FRONT.

 SELECT IF (title ~= '' & imdbtitle ~= '' & metatitle ~= '').
 EXECUTE.

SORT CASES BY key.

* Visual Binning.
*adjusted_gross.
RECODE  adjustedgross (MISSING=COPY) (LO THRU 100000 = 1) (100001 THRU 10000000 = 2) (10000001 THRU 100000000 = 3) 
    (100000001 THRU HI = 4) (ELSE=SYSMIS) INTO adjustedgrossbinned.
FORMATS  adjustedgrossbinned (F1.0).
VALUE LABELS  adjustedgrossbinned 1 'Less than $100,000' 2 '$100,000 to $10 million' 3 '$10-100 million' 4 'More than '+
    '$100 million'.
VARIABLE LEVEL  adjustedgrossbinned (ORDINAL).
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

SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\movies_2017_5_9.sav'
  /COMPRESSED.

DATASET CLOSE finalmovies.

GET FILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\movies_2017_5_9.sav'.
DATASET NAME finalfinalmovies WINDOW=FRONT.

DATASET ACTIVATE finalfinalmovies.
*MEANS TABLES=adjustedgross imdbrating metascore BY dumpmonth
  /CELLS=MEAN COUNT STDDEV
  /STATISTICS ANOVA.

*FREQUENCIES VARIABLES=nGenres
  /STATISTICS=MEDIAN
  /ORDER=ANALYSIS.

*FREQUENCIES VARIABLES=Western History Documentary Musical War Biography RealityTV Drama Animation 
    Music Mystery Crime Thriller News SciFi Action Sport Comedy Romance Adventure Family TalkShow Horror    
  /FORMAT=DVALUE
  /ORDER=ANALYSIS.

SAVE TRANSLATE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\movies_2017_5_9.csv'
  /TYPE=CSV
  /ENCODING='UTF8'
  /MAP
  /REPLACE
  /DROP adjustedgrossbinned nvotes_binned dumpmonth
  /FIELDNAMES
  /CELLS=LABELS.



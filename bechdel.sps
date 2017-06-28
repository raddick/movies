* Encoding: UTF-8.
GET DATA
  /TYPE=XLSX
  /FILE=
    'C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\movies_2017_5_9_with_bechdel_jr.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.
DATASET NAME bechdel WINDOW=FRONT.

VALUE LABELS bechdelrating
    0 'One or zero women'
    1 'Women do not talk'
    2 'Women talk about men'
    3 'Passes Bechdel test'.

SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\bechdel.sav'
  /COMPRESSED.

DATASET ACTIVATE bechdel.
DATASET COPY randomsample.


DATASET ACTIVATE randomsample.
SAMPLE  458 from 8470.
EXECUTE.


SAVE OUTFILE='C:\Users\sciserver\Documents\GitHub\movies\data_2017_5_9\verify_crossmatch\random458.sav'
  /COMPRESSED.



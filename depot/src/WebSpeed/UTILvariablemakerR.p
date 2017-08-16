
/*------------------------------------------------------------------------
    File        : UTILvariablemakerR.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Trae Luttrell
    Created     : Thu Jul 21 16:17:56 EDT 2016
    Notes       : Here's some ideas for version 2 of this program.  After the user enters their selected table you can 
                    bring up a list of all the fields in that table and the user can select all the ones that he wants.  
                    Then you can have it process through the list of selected fields instead of bringing all of them
                    back which probably would work better with the desired output for fields in the table.  Another
                    idea is to allow the table field to be a comma-delimited list of tables instead of a single table.
                    Then you could just walk through the list and do it for multiple tables at once (not that it takes
                    long or anything).
                    
                  For some reason this doesn't work properly from the Developer Studio.  In there it only has access to
                    the first connected database (General, typically).  It doesn't work right for tables in other databases.
                    Running it from the Client Editor works fine, but I think maybe only with the selected database.
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/*DEFINE VARIABLE whatdb AS CHARACTER INITIAL "General" FORMAT "x(18)" NO-UNDO.*/
DEFINE VARIABLE whattable LIKE _file-name INITIAL "trh_hist" LABEL "Table" FORMAT "x(18)" NO-UNDO.
DEFINE VARIABLE whatfile AS CHARACTER INITIAL "c:\progress\wrk\variable-names.txt" FORMAT "x(50)" NO-UNDO.
DEFINE VARIABLE numcols AS INTEGER INITIAL 2 LABEL "HTML Columns" NO-UNDO.
DEFINE VARIABLE x AS INTEGER NO-UNDO.                                                   /* junk counter for HTML row tracking */

UPDATE SKIP(1)
/*    whatdb COLON 20*/
    whattable COLON 20 
    whatfile COLON 20 
    numcols COLON 20 SKIP(1) 
        WITH FRAME a WIDTH 80 SIDE-LABELS.

DEFINE STREAM outfile.

OUTPUT STREAM outfile TO VALUE(whatfile).

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
PUT STREAM outfile SKIP 
    "/* ***********************  Variable Definitions  *********************** */" SKIP(1).

FOR EACH _file WHERE _file-number >= 1 AND _file-number < 32000 AND  
        (_file-name = whattable OR whattable = "") NO-LOCK,
    EACH _field OF _file 
    USE-INDEX _Field-Position NO-LOCK:

    PUT STREAM outfile UNFORMATTED "DEFINE VARIABLE v-" _field-name " LIKE " _file-name "." _field-name " NO-UNDO." SKIP.
    
END.    /** of 4ea. _file, etc. --- variable definitions **/

PUT STREAM outfile UNFORMATTED 
    SKIP(2) 
    "/* ***********************  HTML variables  *********************** */" SKIP(1)
    "ASSIGN" SKIP.

FOR EACH _file WHERE _file-number >= 1 AND _file-number < 32000 AND  
        (_file-name = whattable OR whattable = "") NO-LOCK,
    EACH _field OF _file 
    USE-INDEX _Field-Position NO-LOCK:

    IF _data-type = "DECIMAL" THEN 
        PUT STREAM outfile UNFORMATTED "    v-" _field-name " = DECIMAL(get-value(~"h-" _field-name "~"))" SKIP.
    ELSE IF _data-type = "INTEGER" THEN 
        PUT STREAM outfile UNFORMATTED "    v-" _field-name " = INTEGER(get-value(~"h-" _field-name "~"))" SKIP.
    ELSE IF _data-type = "DATE" THEN 
        PUT STREAM outfile UNFORMATTED "    v-" _field-name " = DATE(get-value(~"h-" _field-name "~"))" SKIP.    
    ELSE IF _data-type = "LOGICAL" THEN 
        PUT STREAM outfile UNFORMATTED "    v-" _field-name " = IF LOGICAL(get-value(~"h-" _field-name "~")) = YES THEN YES ELSE NO" SKIP.              
    ELSE            /** for character fields **/ 
        PUT STREAM outfile UNFORMATTED "    v-" _field-name " = get-value(~"h-" _field-name "~")" SKIP.
    
END.    /** OF 4ea. _file, etc. --- HTML variables **/

PUT STREAM outfile UNFORMATTED 
    "   ." SKIP.
    

    
FOR EACH _file WHERE _file-number >= 1 AND _file-number < 32000 AND  
        (_file-name = whattable OR whattable = "") NO-LOCK,
    EACH _field OF _file 
    USE-INDEX _Field-Position NO-LOCK
        BREAK BY _file-recid BY _order:
        
    IF FIRST-OF (_file-recid) THEN DO: 
        
        PUT STREAM outfile UNFORMATTED SKIP(1) 
            "/* ***********************  HTML Form  *********************** */" SKIP(1)
            "~{&OUT}" SKIP
            "   ~"<DIV class='row'>~" SKIP" SKIP 
            "   ~"<DIV class='grid_2'> </DIV>~" SKIP" SKIP
            "   ~"<DIV class='grid_8'>~" SKIP" SKIP.
            
        IF numcols = 1 THEN 
            PUT STREAM outfile UNFORMATTED 
                "   ~"<DIV class='table_col'>~" SKIP" SKIP.

        ELSE IF numcols = 2 THEN 
            PUT STREAM outfile UNFORMATTED 
                "   ~"<DIV class='table_2col'>~" SKIP" SKIP.
                
        ELSE IF numcols = 3 THEN 
            PUT STREAM outfile UNFORMATTED 
                "   ~"<DIV class='table_3col'>~" SKIP" SKIP.                

        ELSE 
            PUT STREAM outfile UNFORMATTED 
                "/** UNSUPPORTED NUMBER OF HTML COLUMNS **/" SKIP
                "   ~"<DIV class='table_" numcols "col'>~" SKIP" SKIP.
            
        PUT STREAM outfile UNFORMATTED     
            "   ~"<FORM>~" SKIP" SKIP
            "   ~"  <TABLE>~" SKIP(1)" SKIP
            "   ~"      <TR>~" SKIP" SKIP
            "   ~"          <TH colspan=" (numcols * 2) ">Edit this " _file._file-label " record.</TH>~" SKIP" SKIP
            "   ~"      </TR>~" SKIP(1)" SKIP(1).
            
    END.  /** of first-of _file-recid **/

    IF x MODULO numcols = 0 THEN 
        PUT STREAM outfile UNFORMATTED 
            "   ~"      <TR>~" SKIP" SKIP.

    x = x + 1.

    PUT STREAM outfile UNFORMATTED 
        "   ~"          <TD>" _field._label "</TD>~" SKIP" SKIP                 /** label as field name **/
        "   ~"          <TD><INPUT type='".                                     /** start of input tag **/
                    
    IF _data-type = "DECIMAL" THEN 
        PUT STREAM outfile UNFORMATTED 
            "NUMBER".
            
    ELSE IF _data-type = "INTEGER" THEN
        PUT STREAM outfile UNFORMATTED 
            "NUMBER".
                
    ELSE IF _data-type = "DATE" THEN 
        PUT STREAM outfile UNFORMATTED 
            "DATE".
                
    ELSE IF _data-type = "LOGICAL" THEN 
        PUT STREAM outfile UNFORMATTED
            "CHECKBOX".
                
    ELSE                                                                        /** TEXT types **/
        PUT STREAM outfile UNFORMATTED 
            "TEXT".
        
    PUT STREAM outfile UNFORMATTED 
        "' name='h-" _field-name "' value='~" v-" _field-name " ~"' /></TD>~" SKIP" SKIP.       /** end of input tag **/
            
    IF x MODULO numcols = 0 THEN 
        PUT STREAM outfile UNFORMATTED 
            "   ~"      </TR>~" SKIP" SKIP(1).        
        
    IF LAST-OF (_file-recid) THEN DO: 
        
        PUT STREAM outfile UNFORMATTED  
            "   ~"   </TABLE>~" SKIP" SKIP
            "   ~"</FORM>~" SKIP           /** THIS MAY NEED TO BE MOVED FOR BUTTONS OR SOMETHING **/" SKIP(1)
            "   ~"</DIV>          <!-- end of table_" numcols "col -->~" SKIP" SKIP
            "   ~"</DIV>         <!-- end of grid_8 -->~" SKIP" SKIP(1)
            "   ~"<DIV class='grid_2'> </DIV>           <!-- spacer DIV -->~" SKIP" SKIP  
            "   ~"</DIV>     <!-- end of row -->!~" SKIP" SKIP(1).
                        
    END.  /** of first-of _file-recid **/    
        
END.    /** of 4ea. _file, etc. --- HTML form **/
                
PUT STREAM outfile UNFORMATTED 
    "   ." SKIP.                

OUTPUT STREAM outfile CLOSE.

/********************************  END OF FILE  *****************************/

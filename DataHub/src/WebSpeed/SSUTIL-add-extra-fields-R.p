/***********************************************************************
 *
 *  SSUTIL-add-extra-fields-R.p - DOUG LUTTRELL - Version 1.12
 *
 *  ------------------------------------------------------------------
 *
 *  This program is designed to make a *.df file that will add the 
 *  various Solsource common fields to each table in question (or
 *  to a single table).  It only makes the *.df file, it doesn't apply
 *  it to the database.  You still have to do that via the Data
 *  Administration tool in the Load Definitions section.
 *
 *  ------------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 06/May/14.  Original version.
 *  1.1 - written by DOUG LUTTRELL no 10/Feb/17.  Modified to allow for
 *          prompting for table name vs. whole database as well as to
 *          pick different output files.  Putting in a few brains to help
 *          with that, though not enough to keep you entirely out of 
 *          trouble.  Also added in the codepage stuff.  Not marked.
 *  1.11 - written by DOUG LUTTRELL on 26/Sep/17.  Made a minor change
 *          to the default output location.  It now defaults to the 
 *          C:\progress\wrk\DFs directory.  Also changed the size of the
 *          _prog_name field.  Marked by 111.
 *  1.12 - written by DOUG LUTTRELL on 13/Nov/17.  Added in the index
 *          for the deleted field.  No other automated indeces.  Marked
 *          by 112.
 *
 ************************************************************************/
 
/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE highfield LIKE _order NO-UNDO.
DEFINE VARIABLE tablpref AS CHARACTER NO-UNDO.
DEFINE VARIABLE posivar AS INTEGER NO-UNDO.
DEFINE VARIABLE ordvar AS INTEGER NO-UNDO.

/*** reset whattable to "" to do entire database ***/
def var whattable like _file-name label "Table Name" initial "" no-undo.

def var outfile as char format "x(50)" label "Output File" no-undo.

main-loop:
repeat:

update skip(1)
    whattable colon 20 
        help "Enter Table Name or leave blank for entire database"
    with frame a width 80 side-labels
        title "Database Field Addition".
            
if whattable = "" then 
    outfile = "c:\progress\wrk\DFs\" +                          /* 111 */
                substring(DBNAME,r-index(DBNAME,"\") + 1) + 
                "-add-fields.df".
else do:
    if not can-find(first _file where _file-name = whattable no-lock) then do:
        message "ERROR!  Database table ~"" whattable "~" not found in Database!" SKIP
            "Please re-enter."
                view-as alert-box warning buttons OK.
        next main-loop.
    end.  /** of not can-find whattable **/
            
    outfile = "C:\progress\wrk\DFs\" + whattable + "-add-fields.df".  /* 111 */
    
end.  /** of else do --- whattable was entered **/
                
update            
    outfile colon 20 skip(1)
        with frame a width 80 side-labels.

DEFINE STREAM outward.

OUTPUT STREAM outward TO value(outfile).

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH _file WHERE _file-number >= 1 AND _file-number < 32000 and 
    (_file-name = whattable or whattable = "") NO-LOCK:
    
    FIND LAST _field OF _file USE-INDEX _Field-Position NO-LOCK NO-ERROR.
    
    ASSIGN 
        tablpref    = SUBSTRING(_field-name,1,INDEX(_field-name,"_"))
        highfield   = _order + 10
        posivar     = _field-rpos + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "deleted~" OF ~"" _file-name "~" AS date" SKIP 
        "FORMAT ~"99/99/99~"" SKIP 
        "INITIAL ?" SKIP 
        "LABEL ~"Deletion Date~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 4" SKIP 
        "COLUMN-LABEL ~"Deletion Date~"" SKIP 
        "ORDER " highfield SKIP(2).
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.      
        
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "prog_name~" OF ~"" _file-name "~" AS character" SKIP 
        "FORMAT ~"x(64)~"" SKIP                 /* 111 */
        "INITIAL ~"~"" SKIP 
        "LABEL ~"Program Name~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 128" SKIP                    /* 111 */
        "COLUMN-LABEL ~"Prog Name~"" SKIP 
        "ORDER " highfield SKIP(2).
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.        
        
         
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "created_by~" OF ~"" _file-name "~" AS character" SKIP 
        "FORMAT ~"x(30)~"" SKIP 
        "INITIAL ~"~"" SKIP 
        "LABEL ~"Created By~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 30" SKIP 
        "COLUMN-LABEL ~"Creator~"" SKIP 
        "ORDER " highfield SKIP(2).
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.    
    
    
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "create_date~" OF ~"" _file-name "~" AS date" SKIP 
        "FORMAT ~"99/99/99~"" SKIP 
        "INITIAL ?" SKIP 
        "LABEL ~"Create Date~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 4" SKIP 
        "COLUMN-LABEL ~"Create Date~"" SKIP 
        "ORDER " highfield SKIP(2).

    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "modified_by~" OF ~"" _file-name "~" AS character" SKIP 
        "FORMAT ~"x(30)~"" SKIP 
        "INITIAL ~"~"" SKIP 
        "LABEL ~"Modified By~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 30" SKIP 
        "COLUMN-LABEL ~"Modified By~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "modified_date~" OF ~"" _file-name "~" AS date" SKIP 
        "FORMAT ~"99/99/99~"" SKIP 
        "INITIAL ?" SKIP 
        "LABEL ~"Modified Date~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 4" SKIP 
        "COLUMN-LABEL ~"Modified Date~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_char01~" OF ~"" _file-name "~" AS character" SKIP 
        "FORMAT ~"x(30)~"" SKIP 
        "INITIAL ~"~"" SKIP 
        "LABEL ~"Char01~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 30" SKIP 
        "COLUMN-LABEL ~"Char01~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_char02~" OF ~"" _file-name "~" AS character" SKIP 
        "FORMAT ~"x(30)~"" SKIP 
        "INITIAL ~"~"" SKIP 
        "LABEL ~"Char02~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 30" SKIP 
        "COLUMN-LABEL ~"Char02~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_char03~" OF ~"" _file-name "~" AS character" SKIP 
        "FORMAT ~"x(30)~"" SKIP 
        "INITIAL ~"~"" SKIP 
        "LABEL ~"Char03~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 30" SKIP 
        "COLUMN-LABEL ~"Char03~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_date01~" OF ~"" _file-name "~" AS date" SKIP 
        "FORMAT ~"99/99/99~"" SKIP 
        "INITIAL ?" SKIP 
        "LABEL ~"Date01~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 4" SKIP 
        "COLUMN-LABEL ~"Date01~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_date02~" OF ~"" _file-name "~" AS date" SKIP 
        "FORMAT ~"99/99/99~"" SKIP 
        "INITIAL ?" SKIP 
        "LABEL ~"Date02~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 4" SKIP 
        "COLUMN-LABEL ~"Date02~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_date03~" OF ~"" _file-name "~" AS date" SKIP 
        "FORMAT ~"99/99/99~"" SKIP 
        "INITIAL ?" SKIP 
        "LABEL ~"Date03~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 30" SKIP 
        "COLUMN-LABEL ~"Date03~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_log01~" OF ~"" _file-name "~" AS logical" SKIP 
        "FORMAT ~"yes/no~"" SKIP 
        "INITIAL ~"no~"" SKIP 
        "LABEL ~"Log01~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 1" SKIP 
        "COLUMN-LABEL ~"Log01~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_log02~" OF ~"" _file-name "~" AS logical" SKIP 
        "FORMAT ~"yes/no~"" SKIP 
        "INITIAL ~"no~"" SKIP 
        "LABEL ~"Log02~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 1" SKIP 
        "COLUMN-LABEL ~"Log02~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_log03~" OF ~"" _file-name "~" AS logical" SKIP 
        "FORMAT ~"yes/no~"" SKIP 
        "INITIAL ~"no~"" SKIP 
        "LABEL ~"Log03~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 1" SKIP 
        "COLUMN-LABEL ~"Log03~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_dec01~" OF ~"" _file-name "~" AS decimal" SKIP 
        "FORMAT ~"->>>,>>>,>>9.9<<<<~"" SKIP 
        "INITIAL ~"0~"" SKIP 
        "LABEL ~"Dec01~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 21" SKIP 
        "COLUMN-LABEL ~"Dec01~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_dec02~" OF ~"" _file-name "~" AS decimal" SKIP 
        "FORMAT ~"->>>,>>>,>>9.9<<<<~"" SKIP 
        "INITIAL ~"0~"" SKIP 
        "LABEL ~"Dec02~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 21" SKIP 
        "COLUMN-LABEL ~"Dec02~"" SKIP 
        "ORDER " highfield SKIP(2).      
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_dec03~" OF ~"" _file-name "~" AS decimal" SKIP 
        "FORMAT ~"->>>,>>>,>>9.9<<<<~"" SKIP 
        "INITIAL ~"0~"" SKIP 
        "LABEL ~"Dec03~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 21" SKIP 
        "COLUMN-LABEL ~"Dec03~"" SKIP 
        "ORDER " highfield SKIP(2).        
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_dec04~" OF ~"" _file-name "~" AS decimal" SKIP 
        "FORMAT ~"->>>,>>>,>>9.9<<<<~"" SKIP 
        "INITIAL ~"0~"" SKIP 
        "LABEL ~"Dec04~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 21" SKIP 
        "COLUMN-LABEL ~"Dec04~"" SKIP 
        "ORDER " highfield SKIP(2).       
    
    ASSIGN 
        highfield   = highfield + 10
        posivar     = posivar + 1.
        
    PUT STREAM outward UNFORMATTED  
        "ADD FIELD ~"" tablpref "_dec05~" OF ~"" _file-name "~" AS decimal" SKIP 
        "FORMAT ~"->>>,>>>,>>9.9<<<<~"" SKIP 
        "INITIAL ~"0~"" SKIP 
        "LABEL ~"Dec05~"" SKIP 
        "POSITION " posivar SKIP 
        "MAX-WIDTH 21" SKIP 
        "COLUMN-LABEL ~"Dec05~"" SKIP 
        "ORDER " highfield SKIP(2).       
    
   
   /** begin 112 **/
   
    /*********************************************************
     *  Add indeces here
     *********************************************************/
          
    PUT STREAM outward UNFORMATTED
        "ADD INDEX ~"" tablpref "-del-idx~" ON ~"" _file-name "~"" SKIP
        "AREA ~"Schema Area~"" SKIP
        "INDEX-FIELD ~"" tablpref "_deleted~" ASCENDING" SKIP(2).    
   
    /** end of 112 **/
    
END.  /** OF 4ea. _file **/

PUT STREAM outward UNFORMATTED
    "." SKIP
    "PSC" SKIP
    "cpstream=ISO8859-1" SKIP
    "." SKIP.
    /*** I think the db modified version number goes here ***/
    
OUTPUT STREAM outward CLOSE.

end.  /** of repeat --- main_loop **/


/***********************  End of File.  ************************/


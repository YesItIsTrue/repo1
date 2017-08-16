
/*------------------------------------------------------------------------
    File        : DEMO-include-4eawrap.i
    Purpose     : 

    Syntax      :

    Description : Showing something a little more useful than a text string.	

    Author(s)   : Doug Luttrell
    Created     : Fri Feb 27 16:17:51 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
    FOR EACH TK_mstr WHERE TK_mstr.TK_ID BEGINS tkid NO-LOCK
        BREAK BY {3}: 
        
        {DEMO-include.i {1} {2}}.    
                    
    END.  /** of 4ea. tk_mstr **/
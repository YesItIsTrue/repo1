
/*------------------------------------------------------------------------
    File        : ext-TestKit-delete.p
    Purpose     : See description

    Syntax      :

    Description : An external procedure to delete Test Kit record

    Author(s)   : Mark Jacobs
    Created     : Thu Aug 21 10:12:49 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  p-Tknum LIKE TK_mstr.TK_ID NO-UNDO.

DEFINE OUTPUT PARAMETER act  AS INTE NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


     FIND FIRST TK_mstr WHERE TK_ID = p-TKnum  NO-ERROR.                            
                IF AVAIL (TK_mstr) THEN DO:                                      
                    ASSIGN
                    TK_mstr.TK_deleted       = TODAY
                    TK_mstr.TK_modified_date = TODAY
                    TK_mstr.TK_modified_by   = USERID ("HHI")
                    TK_mstr.TK_status        = "Deleted"        
                    act                      = 1.        
                
                END. /* if avail TK_mstr then do: */
    
             ELSE DO:
                    ASSIGN
                       act = 2.
                       
             END. /* ELSE DO: */   
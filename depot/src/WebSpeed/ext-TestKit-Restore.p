
/*------------------------------------------------------------------------
    File        : ext-TestKit-Restore.p
    Purpose     : See description

    Syntax      :

    Description : To restore a deleted test kit.

    Author(s)   : Mark Jacobs
    Created     : Fri Aug 22 14:17:56 EDT 2014
    Notes       : Added p-tk-status to be able to update status field to either 
                  Created or In Stock 10/23/14 MJ
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  p-Tknum     LIKE TK_mstr.TK_ID NO-UNDO.
DEFINE INPUT PARAMETER  p-tk-status LIKE TK_mstr.TK_status NO-UNDO.
DEFINE OUTPUT PARAMETER o-act       AS INTE NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
    
    
    FIND FIRST TK_mstr WHERE TK_ID = p-TKnum  NO-ERROR.                            
                IF AVAIL (TK_mstr) THEN DO:                                      
                    ASSIGN
                    TK_mstr.TK_deleted       = ?
                    TK_mstr.TK_modified_date = TODAY
                    TK_mstr.TK_modified_by   = USERID("Modules")
                    TK_mstr.TK_status        = p-tk-status        
                    o-act                    = 1.        
                
                END. /* if avail TK_mstr then do: */
    
             ELSE DO:
                    ASSIGN
                       o-act = 2.
                       
             END. /* ELSE DO: */   
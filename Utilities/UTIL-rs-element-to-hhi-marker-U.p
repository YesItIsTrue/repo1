
/*------------------------------------------------------------------------
    File        : RSelementToHHImarker.p
    Purpose     : Code Overhaul June 2017

    Syntax      :

    Description : Migrates records from RS.ELEMENT_NAMES_RCD to HHI.marker_list

    Author(s)   : Andrew Garver
    Created     : Tue Jun 20 09:27:03 EDT 2017
    Notes       :
    
    ------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by ANDREW GARVER on 20/Jun/17.  Original Version.
    1.1 - written by DOUG LUTTRELL on 10/Aug/17.  Added code to respect
            the use of *_deleted fields.  Marked by 1dot1.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE v-correct-seq-id AS INTEGER NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH ELEMENT_NAMES_RCD NO-LOCK:

    FIND marker_list WHERE 
        marker_list.marker_item = ELEMENT_NAMES_RCD.Element_Symbol AND 
        marker_list.marker_desc = ELEMENT_NAMES_RCD.Element_Name AND 
        marker_list.marker_deleted = ?                      /* 1dot1 */
            EXCLUSIVE-LOCK NO-ERROR.
    
    IF NOT AVAILABLE (marker_list) THEN DO:
        ASSIGN v-correct-seq-id = NEXT-VALUE (seq-mark-ID).
        DO WHILE CAN-FIND (marker_list WHERE marker_list.marker_ID = v-correct-seq-id AND 
                            marker_list.marker_deleted = ? no-lock):    /* 1dot1 */
            ASSIGN v-correct-seq-id = NEXT-VALUE (seq-mark-ID).
        END.
    
        CREATE marker_list.
        ASSIGN 
            marker_list.marker_item = ELEMENT_NAMES_RCD.Element_Symbol
            marker_list.marker_desc = ELEMENT_NAMES_RCD.Element_Name
            marker_list.marker_created_by = USERID ("General")
            marker_list.marker_create_date = TODAY
            marker_list.marker_prog_name = SOURCE-PROCEDURE:FILE-NAME 
            marker_list.marker_ID = v-correct-seq-id.
            
    END.        /*** of if not avail marker_list ***/
    
END.   /**** of 4ea. element_names_rcd ****/

/*******************  EOF  ***********************/

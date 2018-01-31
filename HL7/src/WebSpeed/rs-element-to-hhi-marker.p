/*------------------------------------------------------------------------
    File        : RSelementToHHImarker.p
    Purpose     : Code Overhaul June 2017

    Syntax      :

    Description : Migrates records from RS.ELEMENT_NAMES_RCD to HHI.marker_list

    Author(s)   : Andrew Garver
    Created     : Tue Jun 20 09:27:03 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE v-correct-seq-id AS INTEGER NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH ELEMENT_NAMES_RCD EXCLUSIVE-LOCK: 
    ASSIGN v-correct-seq-id = NEXT-VALUE (seq-mark-ID). 
    DO WHILE CAN-FIND (marker_list WHERE marker_list.marker_ID = v-correct-seq-id): 
        ASSIGN v-correct-seq-id = NEXT-VALUE (seq-mark-ID).
    END.
    
    CREATE marker_list.
    ASSIGN 
        marker_list.marker_item = ELEMENT_NAMES_RCD.Element_Symbol
        marker_list.marker_desc = ELEMENT_NAMES_RCD.Element_Name
        marker_list.marker_created_by = "Utility"
        marker_list.marker_create_date = TODAY
        marker_list.marker_ID = v-correct-seq-id.        
END.   
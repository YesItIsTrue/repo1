
/*------------------------------------------------------------------------
    File        : upcreate-TKR-deet.p

    Description : the external procedure for updating or creating records in the TKR-det table.

    Author(s)   : Trae Luttrell
    Created     : Mon Aug 18 14:37:21 EDT 2014
    Updated     : 
    Version     : 1.0
    
        - - Version History - - 
        
            0.4 - Based on upcreate-TK-mstr 
            1.0 - Seems good
                   
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucTKRdet-id            LIKE TKR_det.TKR_id         NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-test_seq      LIKE TKR_det.TKR_test_seq   NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-item          LIKE TKR_det.TKR_item       NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-lab_result    LIKE TKR_det.TKR_lab_result NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-lab_resval    LIKE TKR_det.TKR_lab_resval NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-lab_ref       LIKE TKR_det.TKR_lab_ref    NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-ref_low       LIKE TKR_det.TKR_ref_low    NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-ref_high      LIKE TKR_det.TKR_ref_high   NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-ref_uom       LIKE TKR_det.tkr_ref_uom    NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucTKRdet-id           LIKE TKR_det.TKR_id         NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-create       AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-update       AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-avail        AS LOGICAL INITIAL YES      NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-successful   AS LOGICAL INITIAL NO       NO-UNDO.

/* ***************************  Main Block  *************************** */

maineblock: 
DO TRANSACTION:
    
    IF i-ucTKRdet-id = "" THEN DO:
    
        CREATE TKR_det.
    
        ASSIGN
            TKR_det.TKR_id              = i-ucTKRdet-id
            TKR_det.TKR_test_seq        = i-ucTKRdet-test_seq
            TKR_det.TKR_item            = i-ucTKRdet-item
            TKR_det.TKR_lab_result      = i-ucTKRdet-lab_result
            TKR_det.TKR_lab_resval      = i-ucTKRdet-lab_resval
            TKR_det.TKR_lab_ref         = i-ucTKRdet-lab_ref
            TKR_det.TKR_create_date     = TODAY
            TKR_det.TKR_created_by      = USERID ("HHI")
            TKR_det.TKR_modified_date   = TODAY
            TKR_det.TKR_modified_by     = USERID ("HHI")
            TKR_det.TKR_ref_low         = i-ucTKRdet-ref_low
            TKR_det.TKR_ref_high        = i-ucTKRdet-ref_high
            TKR_det.TKR_ref_uom         = i-ucTKRdet-ref_uom
            o-ucTKRdet-create           = YES 
            o-ucTKRdet-successful       = YES
            o-ucTKRdet-id               = TKR_det.TKR_id
            . 
            
    END. /*** of if id = "" THEN DO: ***/
    
    ELSE DO:
        
        FIND FIRST TKR_det WHERE
            TKR_det.TKR_id       = i-ucTKRdet-id AND 
            TKR_det.TKR_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE TKR_det THEN DO:
            
            /*** this is to allow blank inputs ***/
            ASSIGN
                o-ucTKRdet-update           = YES
                o-ucTKRdet-successful       = YES
                TKR_det.TKR_modified_date   = TODAY
                TKR_det.TKR_modified_by     = USERID ("HHI")
                o-ucTKRdet-id               = TKR_det.TKR_id
                TKR_det.TKR_test_seq        = IF i-ucTKRdet-test_seq    <> 0  THEN i-ucTKRdet-test_seq      ELSE TKR_det.TKR_test_seq
                TKR_det.TKR_item            = IF i-ucTKRdet-item        <> "" THEN i-ucTKRdet-item          ELSE TKR_det.TKR_item    
                TKR_det.TKR_lab_result      = IF i-ucTKRdet-lab_result  <> "" THEN i-ucTKRdet-lab_result    ELSE TKR_det.TKR_lab_result  
                TKR_det.TKR_lab_resval      = IF i-ucTKRdet-lab_resval  <> 0  THEN i-ucTKRdet-lab_resval    ELSE TKR_det.TKR_lab_resval
                TKR_det.TKR_lab_ref         = IF i-ucTKRdet-lab_ref     <> "" THEN i-ucTKRdet-lab_ref       ELSE TKR_det.TKR_lab_ref   
                TKR_det.TKR_ref_low         = IF i-ucTKRdet-ref_low     <> 0  THEN i-ucTKRdet-ref_low       ELSE TKR_det.TKR_ref_low
                TKR_det.TKR_ref_high        = IF i-ucTKRdet-ref_high    <> 0  THEN i-ucTKRdet-ref_high      ELSE TKR_det.TKR_ref_high
                TKR_det.TKR_ref_uom         = IF i-ucTKRdet-ref_uom     <> "" THEN i-ucTKRdet-ref_uom       ELSE TKR_det.TKR_ref_uom
                . 
                
        END. /*** of avail TKR_det DO: ***/
        
    END. /*** of no id ELSE DO: ***/ 
    
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */         
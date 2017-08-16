
/*------------------------------------------------------------------------
    File        : SUBtkrdet-RStP-ucU.p

    Description : the external procedure for updating or creating records in the TKR-det table.

    Author(s)   : Trae Luttrell
    Created     : Mon Aug 18 14:37:21 EDT 2014
    Updated     : 
    Version     : 1.0
    
        - - Version History - - 
        
            0.4 - Based on upcreate-TK-mstr 
            1.0 - Seems good
            1.1 - Added prog-name updater  
            
    2.0 - written by DOUG LUTTRELL on 01/Jun/16.  Modified to include all the 
            standard fields within the TKR_det table.  Also carrying in the 
            TKR__char01 as the lab_sampleid and the TKR__dec01 as the
            lab_sampleid_seqnbr.  Marked by 2dot0.  Revamped the whole thing.  
            Not actually marked.
                             
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
 
/* begin 2dot0 */
DEFINE INPUT PARAMETER i-ucTKRdet-minusSD       LIKE TKR_det.TKR_minusSD    NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-meanSD        LIKE TKR_det.TKR_meanSD     NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-plusSD        LIKE TKR_det.TKR_plusSD     NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-char01        LIKE TKR_det.tkr__char01    NO-UNDO.
DEFINE INPUT PARAMETER i-ucTKRdet-dec01         LIKE TKR_det.TKR__dec01     NO-UNDO. 
/* end 2dot0 */

DEFINE OUTPUT PARAMETER o-ucTKRdet-id           LIKE TKR_det.TKR_id         NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-create       AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-update       AS LOGICAL INITIAL NO       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-avail        AS LOGICAL INITIAL YES      NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucTKRdet-successful   AS LOGICAL INITIAL NO       NO-UNDO.


/* ***************************  Main Block  *************************** */
maineblock: 
DO TRANSACTION:
    
    FIND TKR_det WHERE TKR_det.TKR_ID = i-ucTKRdet-id AND 
        TKR_det.TKR_test_seq = i-ucTKRdet-test_seq AND 
        TKR_det.TKR_item = i-ucTKRdet-item
            EXCLUSIVE-LOCK NO-ERROR.
            
    IF NOT AVAILABLE (tkr_det) THEN DO: 
    
        CREATE TKR_det.
    
        ASSIGN
            TKR_det.TKR_id              = i-ucTKRdet-id
            TKR_det.TKR_test_seq        = i-ucTKRdet-test_seq
            TKR_det.TKR_item            = i-ucTKRdet-item
            TKR_det.TKR_create_date     = TODAY 
            TKR_det.TKR_created_by      = USERID("HHI")
            o-ucTKRdet-create           = YES. 
            
    END. /*** of if id = "" THEN DO: ***/
    
    ASSIGN
        TKR_det.TKR_lab_result      = IF i-ucTKRdet-lab_result  <> "" THEN i-ucTKRdet-lab_result    ELSE TKR_det.TKR_lab_result  
        TKR_det.TKR_lab_resval      = IF i-ucTKRdet-lab_resval  <> 0  THEN i-ucTKRdet-lab_resval    ELSE TKR_det.TKR_lab_resval
        TKR_det.TKR_lab_ref         = IF i-ucTKRdet-lab_ref     <> "" THEN i-ucTKRdet-lab_ref       ELSE TKR_det.TKR_lab_ref   
        TKR_det.TKR_ref_low         = IF i-ucTKRdet-ref_low     <> 0  THEN i-ucTKRdet-ref_low       ELSE TKR_det.TKR_ref_low
        TKR_det.TKR_ref_high        = IF i-ucTKRdet-ref_high    <> 0  THEN i-ucTKRdet-ref_high      ELSE TKR_det.TKR_ref_high
        TKR_det.TKR_ref_uom         = IF i-ucTKRdet-ref_uom     <> "" THEN i-ucTKRdet-ref_uom       ELSE TKR_det.TKR_ref_uom
        TKR_det.TKR_minusSD         = IF i-ucTKRdet-minusSD     <> "" THEN i-ucTKRdet-minusSD       ELSE TKR_det.TKR_minusSD  
        TKR_det.TKR_meanSD          = IF i-ucTKRdet-meanSD      <> "" THEN i-ucTKRdet-meanSD        ELSE TKR_det.TKR_meanSD                           /* 2dot0 */
        TKR_det.TKR_plusSD          = IF i-ucTKRdet-plusSD      <> "" THEN i-ucTKRdet-plusSD        ELSE TKR_det.TKR_plusSD 
        TKR_det.TKR_modified_date   = TODAY
        TKR_det.TKR_modified_by     = USERID ("HHI")
        TKR_det.TKR_prog_name       = SOURCE-PROCEDURE:FILE-NAME        /* 1dot1 */
        /*TODO: Do we want to simply cut this out since this is meant to be a sub proc, or do we want to update the corresponding fields in the TK_mstr table instead? */
        /*TKR_det.TKR__char01         = IF i-ucTKRdet-char01      <> "" THEN i-ucTKRdet-char01        ELSE TKR_det.tkr__char01*/
        /*TKR_det.TKR__dec01          = IF i-ucTKRdet-dec01       <> 0  THEN i-ucTKRdet-dec01         ELSE TKR_det.TKR__dec01*/        
        o-ucTKRdet-update           = YES
        o-ucTKRdet-successful       = YES
        o-ucTKRdet-id               = TKR_det.TKR_id
        . 
           
END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */         
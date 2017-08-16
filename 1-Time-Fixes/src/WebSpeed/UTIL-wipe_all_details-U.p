
/*------------------------------------------------------------------------
    File        : UTIL-wipe_all_details-U.p
    Purpose     : 

    Syntax      :

    Description : Wipe out all the detail records (TKR_det and Brothers).  Also reflag all testkit details for MPA and BioMed in the RS database.

    Author(s)   : Doug Luttrell
    Created     : Mon May 30 08:34:37 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE updatemode AS LOG INITIAL NO NO-UNDO.

DEFINE VARIABLE v-tkr_det AS INTEGER LABEL "TKR_det records" NO-UNDO.
DEFINE VARIABLE v-bfm_mstr AS INTEGER LABEL "BFM_mstr records" NO-UNDO.
DEFINE VARIABLE v-bhe_mstr AS INTEGER LABEL "BHE_mstr records" NO-UNDO.
DEFINE VARIABLE v-bmpa_det AS INTEGER LABEL "BMPA_det records" NO-UNDO.
DEFINE VARIABLE v-butee_mstr AS INTEGER LABEL "BUTEE_mstr records" NO-UNDO.

DEFINE VARIABLE v-rs-mpas AS INTEGER LABEL "RS MPA_RCDs" NO-UNDO.
DEFINE VARIABLE v-rs-biomeds AS INTEGER LABEL "RS TESTS_RESULT_RCDs" NO-UNDO.
DEFINE VARIABLE v-rs-tdr AS INTEGER LABEL "RS TESTS_DETAIL_RCDs" NO-UNDO.
DEFINE VARIABLE v-rs-mtdr AS INTEGER LABEL "RS MPA_TEST_DETAILS_RCDs" NO-UNDO. 
DEFINE VARIABLE v-rs-fmspec AS INTEGER LABEL "RS TESTS_FM_SPECIMEN_RCDs" NO-UNDO.
DEFINE VARIABLE v-rs-hespec AS INTEGER LABEL "RS TESTS_HE SPECIMEN_RATIOS_RCDs" NO-UNDO.
DEFINE VARIABLE v-rs-uteespec AS INTEGER LABEL "RS TESTS_UTM_UEE_SPECIMEN_RCDs" NO-UNDO.

DEFINE VARIABLE v-display_interval AS INTEGER LABEL "Display Interval" INITIAL 100 NO-UNDO.

FORM SKIP(1)
    v-tkr_det COLON 35
    v-bfm_mstr COLON 35 
    v-bhe_mstr COLON 35
    v-bmpa_det COLON 35 
    v-butee_mstr COLON 35 SKIP(1)
    v-rs-mpas COLON 35
    v-rs-biomeds COLON 35
    v-rs-tdr COLON 35 
    v-rs-mtdr COLON 35 
    v-rs-fmspec COLON 35
    v-rs-hespec COLON 35
    v-rs-uteespec COLON 35 SKIP(1)
        WITH FRAME result-counts WIDTH 80 SIDE-LABELS
            TITLE "-->  Results <--".
        
UPDATE SKIP(1)
    updatemode COLON 20 v-display_interval COLON 60 
    SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS. 
                       

/* ***************************  Main Block  *************************** */

/************************************************************************ 
 *  Cleanup PROGRESS side                                               *
 ************************************************************************/
FOR EACH tkr_det: 
    v-tkr_det = v-tkr_det + 1. 
    
    IF v-tkr_det MODULO v-display_interval = 0 THEN 
        DISPLAY v-tkr_det
            WITH FRAME result-counts.
            
    IF updatemode = YES THEN 
        DELETE tkr_det.        
            
END.  /** of 4ea. tkr_det **/

FOR EACH bfm_mstr: 
    v-bfm_mstr = v-bfm_mstr + 1.
    
    IF v-bfm_mstr MODULO v-display_interval = 0 THEN 
        DISPLAY v-bfm_mstr
            WITH FRAME result-counts.
    
    IF updatemode = YES THEN 
        DELETE bfm_mstr. 
                
END.  /** of 4ea. bfm_mstr **/

FOR EACH bhe_mstr: 
    v-bhe_mstr = v-bhe_mstr + 1.
    
    IF v-bhe_mstr MODULO v-display_interval = 0 THEN 
        DISPLAY v-bhe_mstr
            WITH FRAME result-counts.
        
    IF updatemode = YES THEN 
        DELETE bhe_mstr.     
            
END.  /** of 4ea. bhe_mstr **/

FOR EACH bmpa_det: 
    v-bmpa_det = v-bmpa_det + 1.
    
    IF v-bmpa_det MODULO v-display_interval = 0 THEN 
        DISPLAY v-bmpa_det
            WITH FRAME result-counts.

    IF updatemode = YES THEN 
        DELETE bmpa_det. 
            
END.  /** of 4ea. bmpa_det **/

FOR EACH butee_mstr: 
    v-butee_mstr = v-butee_mstr + 1.
    
    IF v-butee_mstr MODULO v-display_interval = 0 THEN 
        DISPLAY v-butee_mstr
            WITH FRAME result-counts.

    IF updatemode = YES THEN 
        DELETE butee_mstr. 
            
END.  /** of 4ea. butee_mstr **/


/************************************************************************
 *  Cleanup RS side                                                     *
 ************************************************************************/
FOR EACH MPA_RCD WHERE MPA_RCD.Progress_Flag = "AL" OR 
    MPA_RCD.Progress_Flag = "IL" OR 
    MPA_RCD.Progress_Flag = "UL": 
    
    v-rs-mpas = v-rs-mpas + 1.
    
    IF v-rs-mpas MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-mpas
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF MPA_RCD.Progress_Flag = "AL" OR MPA_RCD.Progress_Flag = "IL" THEN 
            MPA_RCD.Progress_Flag = "A".
        ELSE IF MPA_RCD.Progress_Flag = "UL" THEN 
            MPA_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. MPA_RCD **/
 
FOR EACH TESTS_RESULT_RCD WHERE TESTS_RESULT_RCD.Progress_Flag = "AL" OR 
    TESTS_RESULT_RCD.Progress_Flag = "IL" OR 
    TESTS_RESULT_RCD.Progress_Flag = "UL": 
    
    v-rs-biomeds = v-rs-biomeds + 1.
    
    IF v-rs-biomeds MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-biomeds
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF TESTS_RESULT_RCD.Progress_Flag = "AL" OR TESTS_RESULT_RCD.Progress_Flag = "IL" THEN 
            TESTS_RESULT_RCD.Progress_Flag = "A".
        ELSE IF TESTS_RESULT_RCD.Progress_Flag = "UL" THEN 
            TESTS_RESULT_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. TESTS_DETAIL_RCD **/

FOR EACH TESTS_DETAIL_RCD WHERE TESTS_DETAIL_RCD.Progress_Flag = "AL" OR 
    TESTS_DETAIL_RCD.Progress_Flag = "IL" OR 
    TESTS_DETAIL_RCD.Progress_Flag = "UL": 
    
    v-rs-tdr = v-rs-tdr + 1.
    
    IF v-rs-tdr MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-tdr
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF TESTS_DETAIL_RCD.Progress_Flag = "AL" OR TESTS_DETAIL_RCD.Progress_Flag = "IL" THEN 
            TESTS_DETAIL_RCD.Progress_Flag = "A".
        ELSE IF TESTS_DETAIL_RCD.Progress_Flag = "UL" THEN 
            TESTS_DETAIL_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. TESTS_DETAIL_RCD **/

FOR EACH MPA_TEST_DETAILS_RCD WHERE MPA_TEST_DETAILS_RCD.Progress_Flag = "AL" OR 
    MPA_TEST_DETAILS_RCD.Progress_Flag = "IL" OR 
    MPA_TEST_DETAILS_RCD.Progress_Flag = "UL": 
    
    v-rs-mtdr = v-rs-mtdr + 1.
    
    IF v-rs-mtdr MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-mtdr
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF MPA_TEST_DETAILS_RCD.Progress_Flag = "AL" OR MPA_TEST_DETAILS_RCD.Progress_Flag = "IL" THEN 
            MPA_TEST_DETAILS_RCD.Progress_Flag = "A".
        ELSE IF MPA_TEST_DETAILS_RCD.Progress_Flag = "UL" THEN 
            MPA_TEST_DETAILS_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. MPA_TEST_DETAILS_RCD **/


FOR EACH TESTS_FM_SPECIMEN_RCD WHERE TESTS_FM_SPECIMEN_RCD.Progress_Flag = "AL" OR 
    TESTS_FM_SPECIMEN_RCD.Progress_Flag = "IL" OR 
    TESTS_FM_SPECIMEN_RCD.Progress_Flag = "UL": 
    
    v-rs-fmspec = v-rs-fmspec + 1.
    
    IF v-rs-fmspec MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-fmspec
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "AL" OR TESTS_FM_SPECIMEN_RCD.Progress_Flag = "IL" THEN 
            TESTS_FM_SPECIMEN_RCD.Progress_Flag = "A".
        ELSE IF TESTS_FM_SPECIMEN_RCD.Progress_Flag = "UL" THEN 
            TESTS_FM_SPECIMEN_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. TESTS_FM_SPECIMEN_RCD **/


FOR EACH TESTS_HE_SPECIMEN_RATIOS_RCD WHERE TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "AL" OR 
    TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "IL" OR 
    TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "UL": 
    
    v-rs-hespec = v-rs-hespec + 1.
    
    IF v-rs-hespec MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-hespec
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "AL" OR TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "IL" THEN 
            TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "A".
        ELSE IF TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "UL" THEN 
            TESTS_HE_SPECIMEN_RATIOS_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. TESTS_HE_SPECIMEN_RATIOS_RCD **/


FOR EACH TESTS_UTM_UEE_SPECIMEN_RCD WHERE TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "AL" OR 
    TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "IL" OR 
    TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "UL": 
    
    v-rs-uteespec = v-rs-uteespec + 1.
    
    IF v-rs-uteespec MODULO v-display_interval = 0 THEN 
        DISPLAY v-rs-uteespec
            WITH FRAME result-counts.

    IF updatemode = YES THEN DO:

        IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "AL" OR TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "IL" THEN 
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "A".
        ELSE IF TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "UL" THEN 
            TESTS_UTM_UEE_SPECIMEN_RCD.Progress_Flag = "U".        
        
    END.  /** of updatemode = yes **/
            
END.  /** of 4ea. TESTS_UTM_UEE_SPECIMEN_RCD **/

DISPLAY 
    v-tkr_det v-bfm_mstr v-bhe_mstr v-bmpa_det v-butee_mstr
    v-rs-mpas v-rs-biomeds v-rs-tdr v-rs-mtdr v-rs-fmspec v-rs-hespec v-rs-uteespec
        WITH FRAME result-counts.
        
/****************************  END OF FILE  *****************************/


/*------------------------------------------------------------------------
    File        : TAP-Flags-37-MPA-Data.p
    Purpose     : 

    Syntax      :

    Description : Tap or flip or reverse the RS.MPA data - progress_flags.

    Author(s)   : Harold Luttrell, Sr.
    Created     : May 9, 2016
    Notes       :
  ----------------------------------------------------------------------*/
 
/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE updatemode AS LOG INITIAL   NO    NO-UNDO. 

DEFINE VARIABLE tap37list AS CHARACTER  
    INITIAL "2894,9696,17043,3013,14711,17045,17042,12023,11812,12017,13852,8648,14241,13456,
             5601,8512,17020,14181,12479,11751,15526,10792,12716,15279,14908,15175,8190,15405,
             12894,16678,15831,11861,12876,10420,17349,11588,20968" 
        NO-UNDO.
/*            2894,9696,17043,3013,14711,17045,17042,12023,11812,12017,13852,8648,14241,13456,
              5601,8512,17020,14181,12479,11751,15526,10792,12716,15279,14908,15175,8190,15405,
              12894,16678,15831,11861,12876,10420,17349,11588,20968
*/       
   
   
update skip(1) 
    updatemode colon 20 skip(1)
        with frame a width 80 side-labels.
            
/* ***************************  Main Block  *************************** */
/*PAUSE  0 BEFORE-HIDE.*/
/*FOR EACH RS.PATIENT_RCD  WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:*/
/*/*    IF updatemode = NO THEN  */                                                        */
/*        DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                    */
/*    IF updatemode = YES THEN DO:                                                         */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                         */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                         */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                         */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                         */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                         */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                         */
/*    END.  /* IF updatemode = YES  */                                                     */
/*END.                                                                                     */
/*DISPLAY  (count)  "= RS.PATIENT_RCD" SKIP.                                               */

/*PAUSE  0 BEFORE-HIDE.*/
/*FOR EACH RS.MAG_CUST_RCD  WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:*/
/*/*    IF updatemode = NO THEN  */                                                         */
/*        DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                     */
/*    IF updatemode = YES THEN DO:                                                          */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                          */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                          */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                          */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                          */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                          */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                          */
/*    END.  /* IF updatemode = YES  */                                                      */
/*END.                                                                                      */
/*DISPLAY  (count)  "= RS.MAG_CUST_RCD" SKIP.                                               */

PAUSE  0 BEFORE-HIDE.
FOR EACH RS.MPA_RCD  WHERE 
        LOOKUP(STRING(RS.MPA_RCD.PatientID),tap37list) > 0     
            EXCLUSIVE-LOCK
                BY MPA_Test_Kit_Nbr:
                        
/*    IF updatemode = NO THEN  */
        DISPLAY MPA_Test_Kit_Nbr FORMAT "x(10)" patientid MPA_Sample_ID_Number FORMAT "x(10)" Progress_Flag FORMAT "xx" (COUNT).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (COUNT)  "= RS.MPA_RCD" SKIP.

/*PAUSE  0 BEFORE-HIDE.*/
FOR EACH RS.MPA_TEST_DETAILS_RCD WHERE 
        LOOKUP(STRING(RS.MPA_TEST_DETAILS_RCD.PatientID),tap37list) > 0 
            EXCLUSIVE-LOCK
                BY MPA_Sample_ID_Number BY MPA_Sample_ID_SeqNbr:
/*    IF updatemode = NO THEN  */
        DISPLAY patientid MPA_Sample_ID_Number FORMAT "x(10)" Progress_Flag FORMAT "xx"  Progress_Datetime (COUNT).
    IF updatemode = YES THEN DO:
        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A". 
        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".
        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".
        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U". 
        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".   
    END.  /* IF updatemode = YES  */  
END.
DISPLAY  (COUNT)  "= RS.MPA_TEST_DETAILS_RCD" SKIP.

/* PAUSE  0 BEFORE-HIDE. */        
/*FOR EACH RS.patient_files WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:*/
/*/*    IF updatemode = NO THEN  */                                                         */
/*        DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                     */
/*    IF updatemode = YES THEN DO:                                                          */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                          */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                          */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                          */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                          */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                          */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                          */
/*    END.  /* IF updatemode = YES  */                                                      */
/*END.                                                                                      */
/*DISPLAY  (count)  "= RS.patient_files" SKIP.                                              */

/* PAUSE  0 BEFORE-HIDE. */        
/*FOR EACH RS.TESTS_RESULT_RCD WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:            */
/*/*    IF updatemode = NO THEN  */                                                                        */
/*        DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                                    */
/*    IF updatemode = YES THEN DO:                                                                         */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                                         */
/*    END.  /* IF updatemode = YES  */                                                                     */
/*END.                                                                                                     */
/*DISPLAY  (count)  "= RS.TESTS_RESULT_RCD" SKIP.                                                          */
/*                                                                                                         */
/*/*PAUSE  0 BEFORE-HIDE.*/                                                                                */
/*FOR EACH RS.TESTS_DETAIL_RCD WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:            */
/*/*    IF updatemode = NO THEN  */                                                                        */
/*        DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                                    */
/*    IF updatemode = YES THEN DO:                                                                         */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                                         */
/*    END.  /* IF updatemode = YES  */                                                                     */
/*END.                                                                                                     */
/*DISPLAY  (count)  "= RS.TESTS_DETAIL_RCD" SKIP.                                                          */
/*                                                                                                         */
/*/* PAUSE  0 BEFORE-HIDE. */                                                                              */
/*FOR EACH RS.TESTS_FM_SPECIMEN_RCD WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:       */
/*/*    IF updatemode = NO THEN  */                                                                        */
/*            DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                                */
/*    IF updatemode = YES THEN DO:                                                                         */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                                         */
/*    END.  /* IF updatemode = YES  */                                                                     */
/*END.                                                                                                     */
/*DISPLAY  (count)  "= RS.TESTS_FM_SPECIMEN_RCD" SKIP.                                                     */
/*                                                                                                         */
/*/* PAUSE  0 BEFORE-HIDE. */                                                                              */
/*FOR EACH RS.TESTS_HE_SPECIMEN_RATIOS_RCD WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:*/
/*/*    IF updatemode = NO THEN  */                                                                        */
/*            DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                                */
/*    IF updatemode = YES THEN DO:                                                                         */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                                         */
/*    END.  /* IF updatemode = YES  */                                                                     */
/*END.                                                                                                     */
/*DISPLAY  (count)  "= RS.TESTS_HE_SPECIMEN_RATIOS_RCD" SKIP.                                              */
/*                                                                                                         */
/*/* PAUSE  0 BEFORE-HIDE. */                                                                              */
/*FOR EACH RS.TESTS_UTM_UEE_SPECIMEN_RCD WHERE Progress_DateTime > DATETIME ("04/02/16")  EXCLUSIVE-LOCK:  */
/*/*    IF updatemode = NO THEN  */                                                                        */
/*            DISPLAY Progress_Flag FORMAT "xx"  Progress_Datetime (count).                                */
/*    IF updatemode = YES THEN DO:                                                                         */
/*        IF Progress_Flag = "IL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "IA" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "AL" THEN ASSIGN Progress_Flag = "A".                                         */
/*        IF Progress_Flag = "UL" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "IU" THEN ASSIGN Progress_Flag = "U".                                         */
/*        IF Progress_Flag = "DL" THEN ASSIGN Progress_Flag = "D".                                         */
/*    END.  /* IF updatemode = YES  */                                                                     */
/*END.                                                                                                     */
/*DISPLAY  (count)  "= RS.TESTS_UTM_UEE_SPECIMEN_RCD" SKIP.                                                */

    

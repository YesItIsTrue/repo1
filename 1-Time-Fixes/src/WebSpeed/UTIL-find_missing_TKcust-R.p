
/*------------------------------------------------------------------------
    File        : UTIL-find_missing_TKcust-R.p
    Purpose     : 

    Syntax      :

    Description : Utility to find the missing TK_cust_ID information by checking several sources.

    Author(s)   : Doug Luttrell
    Created     : Fri Jan 01 04:34:25 EST 2016
    Notes       :
        
  ----------------------------------------------------------------------
  
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 01/Jan/16.  Original version.
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
 
DEFINE VARIABLE v-cust LIKE TK_mstr.TK_cust_ID NO-UNDO.
DEFINE VARIABLE guess AS INTEGER NO-UNDO.
DEFINE VARIABLE errmsg AS CHARACTER FORMAT "x(70)" NO-UNDO.

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\progress\WRK\find_missing_TKcust.txt".
EXPORT STREAM outward DELIMITER ";"
    "TK_ID" "TK_test_seq" "TK_patient_ID" "TK_cust_ID" "New Cust ID" "Guess Number" "Error Message".
    
DEFINE VARIABLE v-count AS INTEGER EXTENT 10 NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

FOR EACH TK_mstr WHERE TK_mstr.TK_patient_ID > 0 AND 
        TK_mstr.TK_cust_ID = 0 AND 
        TK_mstr.TK_deleted = ? NO-LOCK,
    FIRST trh_hist WHERE 
        trh_hist.trh_serial = TK_mstr.TK_ID AND 
        trh_hist.trh_sequence = TK_mstr.TK_test_seq AND 
        trh_hist.trh_action = "SOLD" AND 
        trh_hist.trh_item = TK_mstr.TK_test_type AND 
        trh_hist.trh_deleted = ? NO-LOCK:
            
    ASSIGN 
        guess           = 1
        v-count[guess]  = v-count[guess] + 1.                                           /* Record Count */            
            
    FIND patient_mstr WHERE patient_mstr.patient_ID = TK_mstr.TK_patient_ID AND 
        patient_mstr.patient_deleted = ? NO-LOCK NO-ERROR.
        
    IF AVAILABLE (patient_mstr) THEN DO: 
        
        ASSIGN 
            guess           = 2
            v-count[guess]  = v-count[guess] + 1.                                       /* patient_mstr found */
        
        IF patient_mstr.patient_cust_ID > 0 THEN DO: 
        
            ASSIGN 
                guess           = 4
                v-count[guess]  = v-count[guess] + 1                                    /* FOUND missing Customer */
                v-cust          = patient_mstr.patient_cust_ID
                errmsg          = "FOUND missing Customer".                             
                
            /** Update the tk_mstr.tk_cust_id here **/
>>>            
            /** Need to change the main TK_mstr loop to be EXCLUSIVE-LOCK **/
            /** tk_mstr.tk_cust_id = v-cust **/
            /** don't forget to update the modified stuff and the program_name field **/
        
        END.  /** of if patient_cust_id > 0 **/
                
        ELSE IF patient_mstr.patient_RP_ID > 0 THEN DO: 
             
            ASSIGN 
                guess           = 5
                v-count[guess]  = v-count[guess] + 1                                    /* Found Responsible Party */
                v-cust          = patient_mstr.patient_RP_ID
                errmsg          = "Found Responsible Party".                            
                
            /** Update the tk_mstr.tk_cust_id here **/
>>>            
            /** Need to change the main TK_mstr loop to be EXCLUSIVE-LOCK **/
            /** tk_mstr.tk_cust_id = v-cust **/
            /** don't forget to update the modified stuff and the program_name field **/
            
            
        END.  /** of else if patient_RP_ID > 0 **/
        
        ELSE IF TK_mstr.TK_test_age >= 18 THEN DO: 
            
            IF CAN-FIND(FIRST pcl_det WHERE pcl_det.pcl_patient_id = TK_mstr.TK_patient_ID AND 
                            pcl_det.pcl_cond_id = 1 AND         /** 1 = Autism **/
                            pcl_det.pcl_deleted = ? NO-LOCK) THEN 
 
                ASSIGN 
                    guess           = 6
                    v-count[guess]  = v-count[guess] + 1                                /* Autism Patient */
                    v-cust          = 0
                    errmsg          = "Autism Patient".                           
        
            ELSE 
                ASSIGN 
                    guess           = 7
                    v-count[guess]  = v-count[guess] + 1                                /* Guess by Test Age -- Must be checked */
                    v-cust          = TK_mstr.TK_patient_ID
                    errmsg          = "Guess by Test Age -- Must be checked".                       
            
        END.  /** of if tk_test_age >= 18 **/            
    
        ELSE DO: 
            
            FIND people_mstr WHERE people_mstr.people_id = TK_mstr.TK_patient_ID AND 
                people_mstr.people_deleted = ? NO-LOCK NO-ERROR.
                
            IF AVAILABLE (people_mstr) THEN DO:  
                
                IF people_mstr.people_DOB <= (TODAY - (365 * 18)) THEN 
                    ASSIGN 
                        guess           = 8
                        v-count[guess]  = v-count[guess] + 1                   /* Guess by Current Age -- Should also be checked */
                        v-cust          = TK_mstr.TK_patient_ID
                        errmsg          = "Guess by Current Age -- Should also be checked". 
                
                ELSE 
                    ASSIGN 
                        guess           = 9
                        v-count[guess]  = v-count[guess] + 1                            /* Patient still < 18 -- No guess */
                        v-cust          = TK_mstr.TK_patient_ID
                        errmsg          = "Patient still < 18 -- No guess".               
                
            END.  /** of if avail people_mstr **/
            
            ELSE
                ASSIGN 
                    guess           = 10
                    v-count[guess]  = v-count[guess] + 1                                /* ORPHANED PATIENT */
                    v-cust          = 0
                    errmsg          = "ERROR! TK_ID = " + TK_mstr.TK_ID + 
                                        " / " + STRING(TK_mstr.TK_test_seq) + 
                                        " Patient = " + STRING(TK_mstr.TK_patient_ID) + 
                                        " exists without a people_mstr.  ORPHANED PATIENT.".                 
            
        END.  /** of else do --- main IF tree **/
    
    END.  /** of if avail patient_mstr **/
    
    ELSE DO: 
    
        ASSIGN 
            guess           = 3
            v-count[guess]  = v-count[guess] + 1                                        /* BROKEN TESTKIT */
            v-cust          = 0
            errmsg          = "ERROR! TK_ID = " + TK_mstr.TK_ID + 
                                " / " + STRING(TK_mstr.TK_test_seq) + 
                                " exists without Patient = " + STRING(TK_mstr.TK_patient_ID) + 
                                ".  BROKEN TESTKIT.".     
           
    END.  /** of else do --- no patient_mstr avail **/

    EXPORT STREAM outward DELIMITER ";"
        TK_mstr.TK_ID 
        TK_mstr.TK_test_seq 
        TK_mstr.TK_patient_ID
        TK_mstr.TK_cust_ID 
        v-cust 
        guess
        errmsg. 

END.  /** of 4ea. tk_mstr, etc. **/

DISPLAY STREAM outward
    SKIP(1)
    v-count[1] "Record Count" SKIP
    v-count[2] "patient_mstr found" SKIP
    v-count[3] "BROKEN TESTKIT" SKIP
    v-count[4] "FOUND missing Customer" SKIP
    v-count[5] "Found Responsible Party" SKIP
    v-count[6] "Autism Patient" SKIP
    v-count[7] "Guess by Test Age -- Must be checked" SKIP
    v-count[8] "Guess by Current Age -- Should also be checked" SKIP
    v-count[9] "Patient still < 18 -- No guess" SKIP
    v-count[10] "ORPHANED PATIENT" SKIP
        WITH FRAME outward NO-LABELS WIDTH 132.
    
OUTPUT STREAM outward CLOSE.

/***************************  End of File  ******************************/ 

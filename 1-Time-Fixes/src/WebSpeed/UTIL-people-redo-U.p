
/*------------------------------------------------------------------------
    File        : UTIL-people-redo-U.p
    Purpose     : 

    Syntax      :

    Description : Fix problem where people records exist with no reference.	

    Author(s)   : Doug Luttrell
    Created     : Tue Jun 07 18:33:59 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE updatemode AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-foundrec AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-patcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-custcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-tkpatcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-tkcustcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-doccount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rpcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-scustcount AS INTEGER NO-UNDO.
DEFINE VARIABLE v-labcount AS INTEGER NO-UNDO.

DEFINE VARIABLE v-oldprog AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-old_MC_prog AS CHARACTER NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE outfile AS CHARACTER INITIAL "C:\PROGRESS\WRK\UTIL-people-redo-U.txt" LABEL "Export File" FORMAT "x(55)" NO-UNDO. 
DEFINE STREAM outward. 

DEFINE VARIABLE logfile AS CHARACTER INITIAL "C:\PROGRESS\WRK\UTIL-pr-log.txt" LABEL "Logfile" FORMAT "x(55)" NO-UNDO.
DEFINE STREAM outlog. 

UPDATE SKIP(1)
    outfile COLON 20 
    SKIP(1)
    logfile COLON 20 
    SKIP(1)
    updatemode COLON 20
    SKIP(1)
        WITH FRAME a WIDTH 80 SIDE-LABELS. 
        
OUTPUT STREAM outward TO VALUE(outfile).
OUTPUT STREAM outlog TO VALUE(logfile).


/* ***************************  Main Block  *************************** */
FOR EACH people_mstr NO-LOCK:
    
    ASSIGN 
        v-patcount      = 0
        v-custcount     = 0
        v-tkpatcount    = 0
        v-tkcustcount   = 0
        v-doccount      = 0
        v-rpcount       = 0
        v-scustcount    = 0
        v-labcount      = 0
        v-foundrec      = NO
        v-oldprog       = ""
        v-old_MC_prog   = "". 
    
    FIND patient_mstr WHERE patient_mstr.patient_ID = people_mstr.people_id 
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (patient_mstr) THEN 
        ASSIGN 
            v-patcount  = v-patcount + 1
            v-foundrec  = YES.
    
    FIND cust_mstr WHERE cust_mstr.cust_id = people_mstr.people_id
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (cust_mstr) THEN
        ASSIGN 
            v-custcount = v-custcount + 1
            v-foundrec  = YES.
        
    FIND FIRST TK_mstr WHERE TK_mstr.TK_patient_ID = people_mstr.people_id
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (tk_mstr) THEN 
        ASSIGN 
            v-tkpatcount    = v-tkpatcount + 1
            v-foundrec      = YES.
    
    FIND FIRST TK_mstr WHERE TK_mstr.TK_cust_ID = people_mstr.people_id
        NO-LOCK NO-ERROR.
            
    IF AVAILABLE (tk_mstr) THEN 
        ASSIGN 
            v-tkcustcount   = v-tkcustcount + 1
            v-foundrec      = YES.
                
    FIND doctor_mstr WHERE doctor_mstr.doctor_ID = people_mstr.people_id
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (doctor_mstr) THEN 
        ASSIGN 
            v-doccount  = v-doccount + 1
            v-foundrec  = YES.
            
    FIND FIRST patient_mstr WHERE patient_mstr.patient_RP_ID = people_mstr.people_id
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (patient_mstr) THEN 
        ASSIGN 
            v-rpcount   = v-rpcount + 1
            v-foundrec  = YES.
            
    FIND scust_shadow WHERE scust_shadow.scust_ID = people_mstr.people_id
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (scust_shadow) THEN 
        ASSIGN 
            v-scustcount    = v-scustcount + 1
            v-foundrec      = YES.
    
    FIND HHI.lab_mstr WHERE HHI.lab_mstr.lab_contact_ID = people_mstr.people_id 
        NO-LOCK NO-ERROR.
    
    IF AVAILABLE (hhi.lab_mstr) THEN 
        ASSIGN 
            v-labcount  = v-labcount + 1
            v-foundrec  = YES.        
            
    IF v-foundrec = NO THEN DO:                                    
                    
        FIND FIRST PATIENT_RCD WHERE PATIENT_RCD.PatientID = people_mstr.people_id
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE (patient_rcd) THEN DO: 
            
            ASSIGN 
                v-oldprog    = PATIENT_RCD.Progress_Flag.
            
            IF updatemode = YES AND 
                v-oldprog <> "D" AND 
                v-oldprog <> "DL" THEN 
                
                ASSIGN 
                    PATIENT_RCD.Progress_Flag = "U".
            
        END.  /** of if avail patient_rcd **/
        
        ELSE DO: 
            
            FIND FIRST PATIENT_RCD WHERE PATIENT_RCD.PatLastName = people_mstr.people_lastname AND 
                PATIENT_RCD.PatFirstName = people_mstr.people_firstname AND 
                PATIENT_RCD.PatDOB = people_mstr.people_DOB AND 
                PATIENT_RCD.PatientID <> people_mstr.people_id 
                    EXCLUSIVE-LOCK NO-ERROR.
                    
            IF AVAILABLE (patient_rcd) THEN DO: 
                
                ASSIGN 
                    v-oldprog    = PATIENT_RCD.Progress_Flag.
                
                IF updatemode = YES AND 
                    v-oldprog <> "D" AND 
                    v-oldprog <> "DL" THEN 
                    
                    ASSIGN 
                        PATIENT_RCD.Progress_Flag = "U".
            
            END.  /** of if avail patient_rcd **/
            
        END.  /*** of if not avail patient_rcd ***/
    
        FIND FIRST MAG_CUST_RCD WHERE MAG_CUST_RCD.billing_lastname = people_mstr.people_lastname AND 
            MAG_CUST_RCD.billing_firstname = people_mstr.people_firstname 
/*            AND                                                  */
/*            (MAG_CUST_RCD.M_C_email = people_mstr.people_email OR*/
/*             MAG_CUST_RCD.M_C_email = people_mstr.people_email2) */
                EXCLUSIVE-LOCK NO-ERROR.
                
        IF AVAILABLE (mag_cust_rcd) THEN DO: 
            
            ASSIGN 
                v-old_MC_prog   = MAG_CUST_RCD.Progress_Flag.
                
            IF updatemode = YES AND 
                v-old_MC_prog <> "D" AND 
                v-old_MC_prog <> "DL" THEN 
                
                ASSIGN 
                    MAG_CUST_RCD.Progress_Flag = "U".
                    
        END.  /** of if avail mag_cust_rcd **/

        IF v-oldprog <> "" OR v-old_MC_prog <> "" THEN DO: 
                
            EXPORT STREAM outward DELIMITER ";"
                people_mstr.
    
        END.  /** of if v-oldprog or v-old_MC_prog <> "" **/
        
    END.  /** of if v-foundrec = no **/
    
    DISPLAY STREAM outlog 
        people_mstr.people_id 
        people_mstr.people_lastname 
        people_mstr.people_firstname
        people_mstr.people_DOB FORMAT "99/99/9999"
        people_mstr.people_email
/*        people_mstr.people_email2*/
        people_mstr.people_deleted
        v-patcount
        v-custcount
        v-tkpatcount
        v-tkcustcount
        v-doccount
        v-rpcount     
        v-scustcount
        v-labcount    
        v-foundrec      
        v-oldprog       
        v-old_MC_prog
            WITH FRAME searchresult WIDTH 278 DOWN.
            
    DOWN STREAM outlog.
     
END.  /*** of 4ea. people_mstr ***/

OUTPUT STREAM outward CLOSE.

/**************************   End of File.  ******************************/
    
     

/*------------------------------------------------------------------------
    File        : TheUTfixer.p
    Description : This is the program to find and fix the different errors with 
        the UTM and other related test types.

    Author(s)   : Trae Luttrell
    Created     : Tue May 10 11:34:15 EDT 2016
    Notes       : Needed to adjust the -L parameter of the General and RS Databases
        up to 128000 to allow it to run in one pass. 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW. 

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE c-UTM-UEE       AS INTEGER LABEL "UTM-UEE" NO-UNDO.
DEFINE VARIABLE v-UTM-UEE-log   AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTM-UEE-d  AS INTEGER LABEL "UTM-UEE deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UTM-UEE-u  AS INTEGER LABEL "UTM-UEE updated" NO-UNDO.
DEFINE VARIABLE c-UTMslashUEE   AS INTEGER LABEL "UTM/UEE" NO-UNDO.
DEFINE VARIABLE v-UTMsUEE-log   AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTMsUEE-d  AS INTEGER LABEL "UTM/UEE deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UTMsUEE-u  AS INTEGER LABEL "UTM/UEE updated" NO-UNDO.
DEFINE VARIABLE c-UTMbslashbUEE AS INTEGER LABEL "UTM / UEE" NO-UNDO.
DEFINE VARIABLE v-UTMbsbUEE-log AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTMbsbUEE-d  AS INTEGER LABEL "UTM / UEE deleted" NO-UNDO. 
DEFINE VARIABLE c-tk-UTMbsbUEE-u  AS INTEGER LABEL "UTM / UEE updated" NO-UNDO.
DEFINE VARIABLE c-UTMbbbb       AS INTEGER LABEL "UTM    " NO-UNDO.
DEFINE VARIABLE v-UTMbbbb-log   AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTMbbbb-d  AS INTEGER LABEL "UTM     deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UTMbbbb-u  AS INTEGER LABEL "UTM     updated" NO-UNDO.
DEFINE VARIABLE c-UTM           AS INTEGER LABEL "UTM" NO-UNDO.
DEFINE VARIABLE v-UTM-log       AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTM-d      AS INTEGER LABEL "UTM deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UTM-u      AS INTEGER LABEL "UTM updated" NO-UNDO.
DEFINE VARIABLE c-UTMnot3       AS INTEGER LABEL "UTMnot3"NO-UNDO.
DEFINE VARIABLE v-UTMnot3-log   AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTMnot3-d  AS INTEGER LABEL "UTMnot3 deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UTMnot3-u  AS INTEGER LABEL "UTMnot3 updated" NO-UNDO.
DEFINE VARIABLE c-UTEE          AS INTEGER LABEL "UTEE" NO-UNDO.
DEFINE VARIABLE v-UTEE-log      AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UTEE-d     AS INTEGER LABEL "UTEE deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UTEE-u     AS INTEGER LABEL "UTEE updated" NO-UNDO.
DEFINE VARIABLE c-UAA           AS INTEGER LABEL "UAA" NO-UNDO.
DEFINE VARIABLE v-UAA-log       AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UAA-d      AS INTEGER LABEL "UAA deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UAA-u      AS INTEGER LABEL "UAA updated" NO-UNDO.
DEFINE VARIABLE c-UEE           AS INTEGER LABEL "UEE" NO-UNDO.
DEFINE VARIABLE v-UEE-log       AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UEE-d      AS INTEGER LABEL "UEE deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UEE-u      AS INTEGER LABEL "UEE updated" NO-UNDO.
DEFINE VARIABLE c-UI            AS INTEGER LABEL "UI" NO-UNDO.
DEFINE VARIABLE v-UI-log        AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UI-d       AS INTEGER LABEL "UI deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UI-u       AS INTEGER LABEL "UI updated" NO-UNDO.
DEFINE VARIABLE c-UMI           AS INTEGER LABEL "UMI" NO-UNDO.
DEFINE VARIABLE v-UMI-log       AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UMI-d      AS INTEGER LABEL "UMI deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UMI-u      AS INTEGER LABEL "UMI updated" NO-UNDO.
DEFINE VARIABLE c-UMIP          AS INTEGER LABEL "UMIP" NO-UNDO.
DEFINE VARIABLE v-UMIP-log      AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UMIP-d     AS INTEGER LABEL "UMIP deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UMIP-u     AS INTEGER LABEL "UMIP updated" NO-UNDO.
DEFINE VARIABLE c-UP            AS INTEGER LABEL "UP" NO-UNDO.
DEFINE VARIABLE v-UP-log        AS LOGICAL LABEL "worthy?" NO-UNDO.
DEFINE VARIABLE c-tk-UP-d       AS INTEGER LABEL "UP deleted" NO-UNDO.
DEFINE VARIABLE c-tk-UP-u       AS INTEGER LABEL "UP updated" NO-UNDO.
DEFINE VARIABLE c-Uother        AS INTEGER LABEL "Other U's" NO-UNDO.
DEFINE VARIABLE v-Uother-log    AS LOGICAL LABEL "worthy?" NO-UNDO.

DEFINE VARIABLE c-trh_hist-UTE      AS INTEGER LABEL "TRH_hist UTE" NO-UNDO.
DEFINE VARIABLE c-trh_hist-UTE-d    AS INTEGER LABEL "TRH UTE deleted" NO-UNDO.
DEFINE VARIABLE c-trh_hist-UTE-u    AS INTEGER LABEL "TRH UTE updated" NO-UNDO.
DEFINE VARIABLE c-trh_hist-UTMsUEE  AS INTEGER LABEL "TRH_hist UTM / UEE" NO-UNDO.
DEFINE VARIABLE c-trh_hist-UTMsUEE-d AS INTEGER LABEL "TRH_hist UTM / UEE" NO-UNDO.
DEFINE VARIABLE c-trh_hist-UTMsUEE-u AS INTEGER LABEL "TRH_hist UTM / UEE" NO-UNDO.
DEFINE VARIABLE c-RESULT_RCD        AS INTEGER LABEL "RS-RESULT touched" NO-UNDO.
DEFINE VARIABLE c-RESULT_RCD-d      AS INTEGER LABEL "RS-RESULT sh-delete" NO-UNDO.
DEFINE VARIABLE c-RESULT_RCD-d2     AS INTEGER LABEL "RS-RESULT act-deleted" NO-UNDO.
DEFINE VARIABLE c-RESULT_RCD-u      AS INTEGER LABEL "RS-RESULT sh-update" NO-UNDO.
DEFINE VARIABLE c-RESULT_RCD-u2     AS INTEGER LABEL "RS-RESULT act-updated" NO-UNDO.
DEFINE VARIABLE c-DETAIL_RCD        AS INTEGER LABEL "RS-DETAIL touched" NO-UNDO.
DEFINE VARIABLE c-DETAIL_RCD-u      AS INTEGER LABEL "RS-DETAIL updated" NO-UNDO.
DEFINE VARIABLE c-DETAIL_RCD-d      AS INTEGER LABEL "RS-DETAIL deleted" NO-UNDO.
DEFINE VARIABLE c-SPECIMEN_RCD      AS INTEGER LABEL "RS-SPECIMEN touched" NO-UNDO.
DEFINE VARIABLE c-SPECIMEN_RCD-u    AS INTEGER LABEL "RS-SPECIMEN updated" NO-UNDO.
DEFINE VARIABLE c-SPECIMEN_RCD-d    AS INTEGER LABEL "RS-SPECIMEN deleted" NO-UNDO.
DEFINE VARIABLE c-ABBV_RCD          AS INTEGER LABEL "RS-ABBV" NO-UNDO.

DEFINE VARIABLE updatemode AS LOGICAL LABEL "Run Program in Update Mode?" INITIAL NO NO-UNDO.

DEFINE BUFFER TEsts_result_rcd2 FOR rs.TESTS_RESULT_RCD.  
DEFINE BUFFER TESTS_DETAIL_RCD2 FOR RS.TESTS_DETAIL_RCD.
DEFINE BUFFER TESTS_UTM_UEE_SPECIMEN_RCD2 FOR rs.TESTS_UTM_UEE_SPECIMEN_RCD.
DEFINE BUFFER trh_hist2 FOR General.trh_hist .
DEFINE BUFFER tk_mstr2 FOR HHI.tk_mstr . 

/* ***************************  Main Block  *************************** */

UPDATE updatemode WITH FRAME aaa. 
 
/* RS database Tables. */
/* Clean up the RS.TESTS_RESULT_RCD */
/*** only UTM / UEE's ***/
/*FOR EACH RS.TESTS_RESULT_RCD WHERE RS.TESTS_RESULT_RCD.Test_Abbv BEGINS "U" NO-LOCK BREAK BY RS.TESTS_RESULT_RCD.Test_Abbv:*/
/*                                                                                                                           */
/*    IF first-of(RS.TESTS_RESULT_RCD.Test_Abbv) THEN                                                                        */
/*         DISPLAY RS.TESTS_RESULT_RCD.Test_Abbv length(RS.TESTS_RESULT_RCD.Test_Abbv)                                       */
/*                  WITH FRAME e DOWN TITLE "--> TESTS_DETAIL_RCD <--".                                                      */
/*                                                                                                                           */
/*END.                                                                                                                       */

FOR EACH TESTS_RESULT_RCD2 WHERE TESTS_RESULT_RCD2.Test_Abbv =  "UTM / UEE" NO-LOCK:

    c-RESULT_RCD = c-RESULT_RCD + 1.

    FIND RS.TESTS_RESULT_RCD WHERE 
        RS.TESTS_RESULT_RCD.PatientID = TESTS_RESULT_RCD2.PatientID AND 
        RS.TESTS_RESULT_RCD.Lab_Sampleid = TESTS_RESULT_RCD2.Lab_Sampleid AND 
        RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_RESULT_RCD2.Lab_Sampleid_SeqNbr AND 
        RS.TESTS_RESULT_RCD.Test_Abbv = "UTEE" AND 
        RS.TESTS_RESULT_RCD.Test_Kit_Nbr = TESTS_RESULT_RCD2.Test_Kit_Nbr 
        NO-LOCK NO-ERROR.
        
    IF AVAILABLE (rs.TESTS_RESULT_RCD) THEN DO: /*** all set, delete the old one (the one with UTM / UEE for a Test_Abbv)? ***/
    
        RELEASE rs.TESTS_RESULT_RCD.
    
        c-RESULT_RCD-d = c-RESULT_RCD-d + 1.
        
        FIND RS.TESTS_RESULT_RCD WHERE 
            RS.TESTS_RESULT_RCD.PatientID = TESTS_RESULT_RCD2.PatientID AND 
            RS.TESTS_RESULT_RCD.Lab_Sampleid = TESTS_RESULT_RCD2.Lab_Sampleid AND 
            RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_RESULT_RCD2.Lab_Sampleid_SeqNbr AND 
            RS.TESTS_RESULT_RCD.Test_Abbv = TESTS_RESULT_RCD2.Test_Abbv AND 
            RS.TESTS_RESULT_RCD.Test_Kit_Nbr = TESTS_RESULT_RCD2.Test_Kit_Nbr 
            EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE (rs.TESTS_RESULT_RCD) THEN DO:
        
            IF updatemode = YES THEN DELETE rs.TESTS_RESULT_RCD.
            
            c-RESULT_RCD-d2 = c-RESULT_RCD-d2 + 1.
        
        END. /*** avail UTM / UEE ***/
        
    END. /*** avail UTEE ***/
    
    ELSE DO: /*** go ahead and assign the old one's Test_Abbv to "UTEE"  **/
    
        c-RESULT_RCD-u = c-RESULT_RCD-u + 1.
        
        FIND RS.TESTS_RESULT_RCD WHERE 
            RS.TESTS_RESULT_RCD.PatientID = TESTS_RESULT_RCD2.PatientID AND 
            RS.TESTS_RESULT_RCD.Lab_Sampleid = TESTS_RESULT_RCD2.Lab_Sampleid AND 
            RS.TESTS_RESULT_RCD.Lab_Sampleid_SeqNbr = TESTS_RESULT_RCD2.Lab_Sampleid_SeqNbr AND 
            RS.TESTS_RESULT_RCD.Test_Abbv = TESTS_RESULT_RCD2.Test_Abbv AND 
            RS.TESTS_RESULT_RCD.Test_Kit_Nbr = TESTS_RESULT_RCD2.Test_Kit_Nbr 
            EXCLUSIVE-LOCK NO-ERROR.
        
        IF AVAILABLE (rs.TESTS_RESULT_RCD) THEN DO:
        
            IF updatemode = YES THEN ASSIGN TESTS_RESULT_RCD.Test_Abbv = "UTEE".
        
            c-RESULT_RCD-u2 = c-RESULT_RCD-u2 + 1.
        
        END. /*** avail UTM / UEE ***/
        
    END. /*** assigned the old one's Test_Abbv to "UTEE"  **/

END.  /** of 4ea. RS.TESTS_RESULT_RCD **/

/*DISPLAY c-RESULT_RCD c-RESULT_RCD-d c-RESULT_RCD-d2 c-RESULT_RCD-u c-RESULT_RCD-u2 WITH 1 COL FRAME ours.*/

/* Clean up the RS.TESTS_DETAIL_RCD */
/*** according to the scratch pad investigation we only need to do "UTM / UEE" for RS.TESTS_DETAIL_RCD ***/
/*FOR EACH RS.TESTS_DETAIL_RCD WHERE RS.TESTS_DETAIL_RCD.Test_Abbv BEGINS "U" NO-LOCK BREAK BY RS.TESTS_DETAIL_RCD.Test_Abbv:*/
/*                                                                                                                           */
/*    IF first-of(RS.TESTS_DETAIL_RCD.Test_Abbv) THEN                                                                        */
/*         DISPLAY RS.TESTS_DETAIL_RCD.Test_Abbv length(RS.TESTS_DETAIL_RCD.Test_Abbv)                                       */
/*                  WITH FRAME d DOWN TITLE "--> TESTS_DETAIL_RCD <--".                                                      */
/*                                                                                                                           */
/*END.                                                                                                                       */

FOR EACH RS.TESTS_DETAIL_RCD2 WHERE TESTS_DETAIL_RCD2.Test_Abbv =  "UTM / UEE" NO-LOCK:

    c-DETAIL_RCD = c-DETAIL_RCD + 1.

    FIND RS.TESTS_DETAIL_RCD WHERE 
        RS.TESTS_DETAIL_RCD.PatientID = TESTS_DETAIL_RCD2.PatientID AND 
        RS.TESTS_DETAIL_RCD.Lab_Sampleid = TESTS_DETAIL_RCD2.Lab_Sampleid AND 
        RS.TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr = TESTS_DETAIL_RCD2.Lab_Sampleid_SeqNbr AND 
        RS.TESTS_DETAIL_RCD.Test_Abbv = "UTEE" AND 
        RS.TESTS_DETAIL_RCD.Test_Element_Item = TESTS_DETAIL_RCD2.Test_Element_Item
        NO-LOCK NO-ERROR.
     
    IF AVAILABLE (rs.tests_detail_rcd) THEN DO:
    
        RELEASE RS.TESTS_DETAIL_RCD.
    
        FIND RS.TESTS_DETAIL_RCD WHERE 
        RS.TESTS_DETAIL_RCD.PatientID = TESTS_DETAIL_RCD2.PatientID AND 
        RS.TESTS_DETAIL_RCD.Lab_Sampleid = TESTS_DETAIL_RCD2.Lab_Sampleid AND 
        RS.TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr = TESTS_DETAIL_RCD2.Lab_Sampleid_SeqNbr AND 
        RS.TESTS_DETAIL_RCD.Test_Abbv = TESTS_DETAIL_RCD2.Test_Abbv AND 
        RS.TESTS_DETAIL_RCD.Test_Element_Item = TESTS_DETAIL_RCD2.Test_Element_Item
        EXCLUSIVE-LOCK NO-ERROR.
     
        IF AVAILABLE (rs.TESTS_DETAIL_RCD) THEN DO:
         
            IF updatemode = YES THEN DELETE rs.TESTS_DETAIL_RCD.
            
            c-DETAIL_RCD-d = c-DETAIL_RCD-d + 1.
            
            RELEASE RS.TESTS_DETAIL_RCD.
             
        END. /*** avail UTEE and UTM / UEE, deletion ****/
         
    END. /*** avail UTEE ***/
     
    ELSE DO: /*** UTEE is NOT avail ***/
        
        FIND RS.TESTS_DETAIL_RCD WHERE 
        RS.TESTS_DETAIL_RCD.PatientID = TESTS_DETAIL_RCD2.PatientID AND 
        RS.TESTS_DETAIL_RCD.Lab_Sampleid = TESTS_DETAIL_RCD2.Lab_Sampleid AND 
        RS.TESTS_DETAIL_RCD.Lab_Sampleid_SeqNbr = TESTS_DETAIL_RCD2.Lab_Sampleid_SeqNbr AND 
        RS.TESTS_DETAIL_RCD.Test_Abbv = TESTS_DETAIL_RCD2.Test_Abbv AND 
        RS.TESTS_DETAIL_RCD.Test_Element_Item = TESTS_DETAIL_RCD2.Test_Element_Item
        EXCLUSIVE-LOCK NO-ERROR.
     
        IF AVAILABLE (rs.tests_detail_rcd) THEN DO:
             
             IF updatemode = YES THEN ASSIGN RS.TESTS_DETAIL_RCD.Test_Abbv = "UTEE".
             
             c-DETAIL_RCD-u = c-DETAIL_RCD-u + 1.
             
             RELEASE RS.TESTS_DETAIL_RCD.
             
        END. /** avail UTM / UEE **/
         
    END. /*** ELSE (because UTEE was not avail) ***/   

/*    DISPLAY c-DETAIL_RCD.*/
/*    PAUSE 0.             */

END.  /** of 4ea. RS.TESTS_DETAIL_RCD **/

/*DISPLAY c-DETAIL_RCD c-DETAIL_RCD-d c-DETAIL_RCD-u WITH 1 COL FRAME tail.*/

/* Clean up the RS.TESTS_UTM_UEE_SPECIMEN_RCD */
/*** according to the scratch pad investigation we only need to do "UTM / UEE" for RS.TESTS_UTM_UEE_SPECIMEN_RCD ***/
/*FOR EACH RS.TESTS_UTM_UEE_SPECIMEN_RCD WHERE RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv BEGINS "U" NO-LOCK BREAK BY RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv:*/
/*                                                                                                                                                         */
/*    IF first-of(RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv) THEN                                                                                            */
/*         DISPLAY RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv length(RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv)                                                 */
/*                  WITH FRAME c DOWN TITLE "--> TESTS_UTM_UEE_SPECIMEN_RCD <--".                                                                          */
/*                                                                                                                                                         */
/*END. */
  
FOR EACH TESTS_UTM_UEE_SPECIMEN_RCD2 WHERE TESTS_UTM_UEE_SPECIMEN_RCD2.Test_Abbv =  "UTM / UEE" NO-LOCK: 

    c-SPECIMEN_RCD = c-SPECIMEN_RCD + 1.
    
    FIND rs.TESTS_UTM_UEE_SPECIMEN_RCD WHERE 
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.PatientID = TESTS_UTM_UEE_SPECIMEN_RCD2.PatientID AND 
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid = TESTS_UTM_UEE_SPECIMEN_RCD2.Lab_Sampleid AND 
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr = TESTS_UTM_UEE_SPECIMEN_RCD2.Lab_Sampleid_SeqNbr AND 
        RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv = "UTEE"
    NO-LOCK NO-ERROR. 
    
    IF AVAILABLE (rs.TESTS_UTM_UEE_SPECIMEN_RCD) THEN DO: /*** avail with UTEE ***/
        
        RELEASE rs.TESTS_UTM_UEE_SPECIMEN_RCD.
        
        FIND rs.TESTS_UTM_UEE_SPECIMEN_RCD WHERE 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.PatientID = TESTS_UTM_UEE_SPECIMEN_RCD2.PatientID AND 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid = TESTS_UTM_UEE_SPECIMEN_RCD2.Lab_Sampleid AND 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr = TESTS_UTM_UEE_SPECIMEN_RCD2.Lab_Sampleid_SeqNbr AND 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv = TESTS_UTM_UEE_SPECIMEN_RCD2.Test_Abbv
        EXCLUSIVE-LOCK NO-ERROR.  
    
        IF AVAILABLE (rs.TESTS_UTM_UEE_SPECIMEN_RCD) THEN DO:
        
            IF updatemode = YES THEN DELETE rs.TESTS_UTM_UEE_SPECIMEN_RCD.
            
            c-SPECIMEN_RCD-d = c-SPECIMEN_RCD-d + 1.
            
            RELEASE rs.TESTS_UTM_UEE_SPECIMEN_RCD.
            
        END.
    
    END. /** avail with UTEE ***/
    
    ELSE DO:
    
        FIND rs.TESTS_UTM_UEE_SPECIMEN_RCD WHERE 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.PatientID = TESTS_UTM_UEE_SPECIMEN_RCD2.PatientID AND 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid = TESTS_UTM_UEE_SPECIMEN_RCD2.Lab_Sampleid AND 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.Lab_Sampleid_SeqNbr = TESTS_UTM_UEE_SPECIMEN_RCD2.Lab_Sampleid_SeqNbr AND 
            RS.TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv = TESTS_UTM_UEE_SPECIMEN_RCD2.Test_Abbv
        EXCLUSIVE-LOCK NO-ERROR. 
    
        IF AVAILABLE (rs.TESTS_UTM_UEE_SPECIMEN_RCD) THEN DO:
        
            IF updatemode = YES THEN ASSIGN TESTS_UTM_UEE_SPECIMEN_RCD.Test_Abbv =  "UTEE".
           
            c-SPECIMEN_RCD-u = c-SPECIMEN_RCD-u + 1.
            
            RELEASE rs.TESTS_UTM_UEE_SPECIMEN_RCD.
            
        END.
        
    END. /*** not avail UTEE (update path) ***/

END.  /** of 4ea. RS.TESTS_UTM_UEE_SPECIMEN_RCD **/

/* Clean up the RS.TESTS_ABBV_RCD */
FIND TESTS_ABBV_RCD WHERE TESTS_ABBV_RCD.Test_Abbv = "UTM / UEE" EXCLUSIVE-LOCK NO-ERROR.  /*** this table is like the Test_mstr in the HHI DB. ***/

IF AVAILABLE (TESTS_ABBV_RCD) THEN DO:

    c-ABBV_RCD = c-ABBV_RCD + 1.

    IF updatemode = YES THEN ASSIGN TESTS_ABBV_RCD.Test_Abbv = "UTEE".

    RELEASE TESTS_ABBV_RCD.

END.  /** of 4ea. RS.TESTS_ABBV_RCD **/

ELSE ASSIGN c-ABBV_RCD = c-ABBV_RCD - 1.

/* Gemeral database Table. */
/* Clean up the General.trh_hist */
/*** according to the scratch pad investigation we only need to do "UTE" and "UTM / UEE" ***/
/*FOR EACH trh_hist WHERE trh_item BEGINS "U" NO-LOCK BREAK BY trh_item:*/
/*                                                                      */
/*    IF first-of(trh_item) THEN                                        */
/*         DISPLAY trh_item LENGTH(trh_item)                            */
/*              WITH FRAME b DOWN TITLE "--> From trh_hist <--".        */
/*                                                                      */
/*END.                                                                  */

FOR EACH trh_hist2 WHERE trh_hist2.trh_item = "UTE" NO-LOCK:

    c-trh_hist-UTE = c-trh_hist-UTE + 1.

    FIND trh_hist WHERE 
        trh_hist.trh_ID = trh_hist2.trh_ID AND 
        trh_hist.trh_item = "UTEE" AND 
        trh_hist.trh_action = trh_hist2.trh_action
        NO-LOCK NO-ERROR. 

    IF AVAILABLE (trh_hist) THEN DO:
    
        FIND trh_hist WHERE 
        trh_hist.trh_ID = trh_hist2.trh_ID AND 
        trh_hist.trh_item = trh_hist2.trh_item AND 
        trh_hist.trh_action = trh_hist2.trh_action 
        EXCLUSIVE-LOCK NO-ERROR. 

        IF AVAILABLE (trh_hist) THEN DO:
        
            IF updatemode = YES THEN DELETE trh_hist.
            
            c-trh_hist-UTE-d = c-trh_hist-UTE-d + 1.
            
        END.
        
    END. /*** UTEE was avail ***/
    
    ELSE DO:
        
        FIND trh_hist WHERE 
        trh_hist.trh_ID = trh_hist2.trh_ID AND 
        trh_hist.trh_item = trh_hist2.trh_item AND 
        trh_hist.trh_action = trh_hist2.trh_action 
        EXCLUSIVE-LOCK NO-ERROR. 

        IF AVAILABLE (trh_hist) THEN DO:
        
            IF updatemode = YES THEN ASSIGN trh_hist2.trh_item = "UTEE"
            
            c-trh_hist-UTE-u = c-trh_hist-UTE-u + 1.
            
        END.
        
    END.

END. /** of 4ea. General.trh_hist **/

FOR EACH trh_hist2 WHERE trh_hist2.trh_item = "UTM / UEE" NO-LOCK:

    c-trh_hist-UTMsUEE = c-trh_hist-UTMsUEE + 1.

    FIND trh_hist WHERE 
        trh_hist.trh_ID = trh_hist2.trh_ID AND 
        trh_hist.trh_item = "UTEE" AND 
        trh_hist.trh_action = trh_hist2.trh_action
        NO-LOCK NO-ERROR. 

    IF AVAILABLE (trh_hist) THEN DO:
    
        FIND trh_hist WHERE 
        trh_hist.trh_ID = trh_hist2.trh_ID AND 
        trh_hist.trh_item = trh_hist2.trh_item AND 
        trh_hist.trh_action = trh_hist2.trh_action 
        EXCLUSIVE-LOCK NO-ERROR. 

        IF AVAILABLE (trh_hist) THEN DO:
        
            IF updatemode = YES THEN DELETE trh_hist.
            
            c-trh_hist-UTMsUEE-d = c-trh_hist-UTMsUEE-d + 1.
            
        END.
        
    END. /*** UTEE was avail ***/
    
    ELSE DO:
        
        FIND trh_hist WHERE 
        trh_hist.trh_ID = trh_hist2.trh_ID AND 
        trh_hist.trh_item = trh_hist2.trh_item AND 
        trh_hist.trh_action = trh_hist2.trh_action 
        EXCLUSIVE-LOCK NO-ERROR. 

        IF AVAILABLE (trh_hist) THEN DO:
        
            IF updatemode = YES THEN ASSIGN trh_hist2.trh_item = "UTEE"
            
            c-trh_hist-UTMsUEE-u = c-trh_hist-UTMsUEE-u + 1.
            
        END.
        
    END.

END.  /** of 4ea. General.trh_hist **/

/*DISPLAY           */
/*c-trh_hist-UTE    */
/*c-trh_hist-UTMsUEE*/
/*c-RESULT_RCD      */
/*c-DETAIL_RCD      */
/*c-SPECIMEN_RCD    */
/*c-ABBV_RCD        */
/*c-trh_hist-UTE    */
/*c-trh_hist-UTMsUEE*/
/*WITH 1 COL.       */

FOR EACH TK_mstr2 NO-LOCK BREAK BY TK_mstr2.TK_test_type:
    
/*    FOR EACH tk_mstr WHERE tk_test_type BEGINS "U" NO-LOCK BREAK BY tk_test_type:*/
/*                                                                                 */
/*    IF first-of(tk_test_type) THEN                                               */
/*         DISPLAY tk_test_type length(tk_test_type)                               */
/*                  WITH FRAME a DOWN TITLE "--> From tk_mstr <--".                */
/*                                                                                 */
/*    END.                                                                         */
    
    IF TK_mstr2.TK_test_type = "UTM-UEE" THEN DO: 
    
        ASSIGN c-UTM-UEE = c-UTM-UEE + 1.
    
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UTM-UEE-log = YES.
            ELSE ASSIGN v-UTM-UEE-log = NO.
    
        {TheUTfixer-tk.i "UTEE" "UTM-UEE" "UTM-UEE"}. 
            
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UTM/UEE" THEN DO:
    
        ASSIGN c-UTMslashUEE = c-UTMslashUEE + 1.
        
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UTMsUEE-log = YES.
            ELSE ASSIGN v-UTMsUEE-log = NO.
    
        {TheUTfixer-tk.i "UTEE" "UTM/UEE" "UTMsUEE"}.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UTM / UEE" THEN DO:
    
        ASSIGN c-UTMbslashbUEE = c-UTMbslashbUEE + 1.
        
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UTMbsbUEE-log = YES.
            ELSE ASSIGN v-UTMbsbUEE-log = NO.
    
        {TheUTfixer-tk.i "UTEE" "UTM / UEE" "UTMbsbUEE"}.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UTM    " THEN DO:
    
        IF LENGTH(HHI.TK_mstr2.TK_test_type) > 3 THEN DO:

            ASSIGN c-UTMbbbb = c-UTMbbbb + 1.        
          
            IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN
                ASSIGN v-UTMbbbb-log = YES.
                ELSE ASSIGN v-UTMbbbb-log = NO.
    
            
        END.  /**  IF LENGTH(HHI.TK_mstr2.TK_test_type) > 3  **/
                     
        ELSE IF LENGTH(HHI.TK_mstr2.TK_test_type) = 3 THEN DO: 
            
            ASSIGN c-UTM = c-UTM + 1.
    
            IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
                ASSIGN v-UTM-log = YES.
                ELSE ASSIGN v-UTM-log = NO.
    
        END.
            
        ELSE IF LENGTH(HHI.TK_mstr2.TK_test_type) = 3 THEN DO:
        
            ASSIGN c-UTMnot3 = c-UTMnot3 + 1.
    
            IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN
                ASSIGN v-UTMnot3-log = YES.
                ELSE ASSIGN v-UTMnot3-log = NO.

        END. /**** "UTM-UEE" ****/
    
    END.
    
    ELSE IF TK_mstr2.TK_test_type = "UTEE" THEN DO: 
        
        ASSIGN c-UTEE = c-UTEE + 1.
    
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UTEE-log = YES.
            ELSE ASSIGN v-UTEE-log = NO.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UAA" THEN DO: 
    
        ASSIGN c-UAA = c-UAA + 1.
    
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UAA-log = YES.
            ELSE ASSIGN v-UAA-log = NO.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UEE" THEN DO:
        
        ASSIGN c-UEE = c-UEE + 1.
   
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UEE-log = YES.
            ELSE ASSIGN v-UEE-log = NO.
    
    END. /**** "UTM-UEE" ****/
   
    ELSE IF TK_mstr2.TK_test_type = "UI" THEN DO: 
    
        ASSIGN c-UI = c-UI + 1.
    
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UI-log = YES.
            ELSE ASSIGN v-UI-log = NO.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UMI" THEN DO:
    
        ASSIGN c-UMI = c-UMI + 1.
    
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UMI-log = YES.
            ELSE ASSIGN v-UMI-log = NO.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UMIP" THEN DO:
    
        ASSIGN c-UMIP = c-UMIP + 1.
    
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UMIP-log = YES.
            ELSE ASSIGN v-UMIP-log = NO.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF TK_mstr2.TK_test_type = "UP" THEN DO:
    
        ASSIGN c-UP = c-UP + 1.
        
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-UP-log = YES.
            ELSE ASSIGN v-UP-log = NO.
    
    END. /**** "UTM-UEE" ****/
    
    ELSE IF INDEX(TK_mstr2.TK_test_type,"U") > 0 THEN DO:
        
        ASSIGN c-Uother = c-Uother + 1.
        
        IF (CAN-FIND (HHI.test_mstr WHERE test_mstr.test_type = TK_mstr2.TK_test_type NO-LOCK)) THEN 
            ASSIGN v-Uother-log = YES.
            ELSE ASSIGN v-Uother-log = NO.
        
/*        DISPLAY TK_mstr2.TK_ID TK_mstr2.TK_test_type.*/
        
    END. 
    
/*    DISPLAY TK_mstr.TK_ID TK_mstr.TK_test_type.*/
    
END.

DISPLAY
c-UTM-UEE       
v-UTM-UEE-log    
c-UTMslashUEE    
v-UTMsUEE-log   
c-UTMbslashbUEE 
v-UTMbsbUEE-log
c-UTMbbbb       
v-UTMbbbb-log
c-UTM           
v-UTM-log       
c-UTMnot3       
v-UTMnot3-log   
c-UTEE         
v-UTEE-log      
c-UAA           
v-UAA-log       
c-UEE         
v-UEE-log    
c-UI        
v-UI-log     
c-UMI        
v-UMI-log     
c-UMIP        
v-UMIP-log     
c-UP           
v-UP-log       
c-Uother       
v-Uother-log
WITH FRAME tkmstr 2 COL TITLE "HHI DB Results". 

DISPLAY 
c-tk-UTM-UEE-d 
c-tk-UTM-UEE-u           
c-tk-UTMsUEE-d
c-tk-UTMsUEE-u     
c-tk-UTMbsbUEE-d
c-tk-UTMbsbUEE-u 
WITH FRAME tkmstr2 2 COL TITLE "HHI - Deletions and Updates".
   

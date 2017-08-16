
/*------------------------------------------------------------------------
    File        : SUB-convert_ID-U.p
    Purpose     : 

    Syntax      :

    Description : When given a FROM people_ID convert all references of it TO a new people_ID.

    Author(s)   : Doug Luttrell
    Created     : Thu Jun 09 17:22:32 EDT 2016
    Notes       :
        
  ----------------------------------------------------------------------
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 09/Jun/16.  Original Version.
  1.1 - written by DOUG LUTTRELL on 02/Jul/16.  Turns out that the program could change things and then change them
            again later on if the first change moved a people_id out into a higher number and then later that higher 
            number came along in the FOR EACH and got changed back to something else.  DOH!  Also it was possible to 
            change the people_ID, which defeats the whole purpose of finding the new people_IDs.  In this program the
            change was around making sure that you can't change the people_ID and also making sure that if a record 
            has already been changed that it doesn't get changed again.  Not marked.  
  1.11 - written by DOUG LUTTRELL on 11/Aug/17.  Modified for the use in CMC structure (Version 12).  Found an error
            in the way it was doing group stuff anyway.  Marked by 111.
                            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
 
DEFINE INPUT PARAMETER i-fromID LIKE people_mstr.people_id NO-UNDO.
DEFINE INPUT PARAMETER i-toID LIKE people_mstr.people_id NO-UNDO.

DEFINE OUTPUT PARAMETER o-result AS CHARACTER NO-UNDO.

DEFINE BUFFER peop-buff FOR people_mstr.
DEFINE BUFFER pat-buff FOR patient_mstr. 
DEFINE BUFFER cust-buff FOR cust_mstr. 
DEFINE BUFFER doc-buff FOR doctor_mstr. 
DEFINE BUFFER scust-buff FOR scust_shadow. 

DEFINE VARIABLE x AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


/**  GENERAL DATABASE **/

/*/********************************************                                       */
/* *  people_mstr                             *                                       */
/* *  --------------------------------------  *                                       */
/* *  This should never be run because it     *                                       */
/* *  will corrupt the data you just did the  *                                       */
/* *  FIND on in the previous program.        *                                       */
/* ********************************************/                                      */
/*FIND people_mstr WHERE people_mstr.people_id = i-fromID                             */
/*        EXCLUSIVE-LOCK NO-ERROR.                                                    */
/*                                                                                    */
/*IF AVAILABLE (people_mstr) THEN DO:                                                 */
/*                                                                                    */
/*    IF NOT CAN-FIND(FIRST peop-buff WHERE peop-buff.people_id = i-toID NO-LOCK) THEN*/
/*        ASSIGN                                                                      */
/*            people_mstr.people_id = i-toID                                          */
/*            people_mstr.people_prog_name    = SOURCE-PROCEDURE:FILE-NAME.           */
/*                                                                                    */
/*END.  /** of if avail people_mstr **/                                               */


/********************************************
 *  cust_mstr                               *
 ********************************************/
FIND cust_mstr WHERE cust_mstr.cust_id = i-fromID AND 
    cust_mstr.cust__log01 = NO
        EXCLUSIVE-LOCK NO-ERROR.
    
IF AVAILABLE (cust_mstr) THEN DO: 
    
    IF NOT CAN-FIND(FIRST cust-buff WHERE cust-buff.cust_id = i-toID NO-LOCK) THEN 
        ASSIGN 
            cust_mstr.cust_id           = i-toID
            cust_mstr.cust__log01       = YES 
            cust_mstr.cust_prog_name    = SOURCE-PROCEDURE:FILE-NAME.
        
END.  /** of if avail cust_mstr **/


/****** Obsolete by the change to CMC (Version 12).  111 ************************
/********************************************
 *  grp_mstr                                *
 ********************************************/
FOR EACH grp_mstr WHERE grp_mstr.grp_people_ID = i-fromID AND 
    grp_mstr.grp__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        grp_mstr.grp_people_ID  = i-toID
        grp_mstr.grp__log01     = NO 
        grp_mstr.grp_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. grp_mstr **/
*********************************************************************************/

/************  Replaced the grp_mstr in CMC (Version 12).  111 ******************/
FOR EACH gud_det WHERE gud_det.gud_people_ID = i-fromID AND 
    gud_det.gud__log01 = NO 
        EXCLUSIVE-LOCK: 
            
    ASSIGN 
        gud_det.gud_people_ID   = i-toID
        gud_det.gud__log01      = YES           /** looks like this was broken in the grp_mstr anyway **/
        gud_det.gud_prog_name   = SOURCE-PROCEDURE:FILE-NAME.
        
END.  /** of 4ea. gud_det **/        
/***********  End of 111 *********/

/********************************************
 *  trh_hist                                *
 ********************************************/
FOR EACH trh_hist WHERE trh_hist.trh_people_ID = i-fromID AND 
    trh_hist.trh__log01 = NO
        EXCLUSIVE-LOCK:

    ASSIGN 
        trh_hist.trh_people_ID  = i-toID
        trh_hist.trh__log01     = YES 
        trh_hist.trh_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** 4ea. trh_hist **/


/********************************************
 *  att_files                               *       We need these because of the value5 field having patientid in it sometimes
 ********************************************/
FOR EACH att_files WHERE att_files.att_field5 = "patientid" AND 
    att_files.att_value5 = string(i-fromID) AND 
    att_files.att__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        att_files.att_value5    = STRING(i-toID)
        att_files.att__log01    = YES 
        att_files.att_prog_name = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** 4ea. att_filest **/




/**  HHI DATABASE  **/

/********************************************
 *  TK_mstr                                 *
 ********************************************/
FOR EACH TK_mstr WHERE TK_mstr.TK_cust_ID = i-fromID AND 
    TK_mstr.TK__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        tk_mstr.tk_cust_ID      = i-toID
        TK_mstr.tk__log01       = YES 
        tk_mstr.tk_prog_name    = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. tk_mstr for Customers **/

FOR EACH TK_mstr WHERE TK_mstr.TK_patient_ID = i-fromID AND 
    TK_mstr.TK__log02 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        tk_mstr.tk_patient_ID   = i-toID
        TK_mstr.tk__log02       = YES 
        tk_mstr.tk_prog_name    = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. tk_mstr for Patients **/


/********************************************
 *  catch_all                               *
 ********************************************/
FOR EACH catch_all WHERE catch_all.catch_people_ID = i-fromID AND 
    catch_all.catch__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        catch_all.catch_ID          = i-toID
        catch_all.catch__log01      = YES 
        catch_all.catch_prog_name   = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. catch_all **/


/********************************************
 *  doctor_mstr                             *
 ********************************************/
FIND doctor_mstr WHERE doctor_mstr.doctor_id = i-fromID AND 
    doctor_mstr.doctor__log01 = NO 
        EXCLUSIVE-LOCK NO-ERROR.
    
IF AVAILABLE (doctor_mstr) THEN DO: 
    
    IF NOT CAN-FIND(FIRST doc-buff WHERE doc-buff.doctor_id = i-toID NO-LOCK) THEN 
        ASSIGN 
            doctor_mstr.doctor_id           = i-toID
            doctor_mstr.doctor__log01       = YES 
            doctor_mstr.doctor_prog_name    = SOURCE-PROCEDURE:FILE-NAME.
        
END.  /** of if avail doctor_mstr **/


/********************************************
 *  lab_mstr                                *
 ********************************************/
FOR EACH lab_mstr WHERE lab_mstr.lab_contact_ID = i-fromID AND 
    lab_mstr.lab__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        lab_mstr.lab_contact_ID = i-toID
        lab_mstr.lab__log01     = YES 
        lab_mstr.lab_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. lab_mstr **/


/********************************************
 *  orig_catch_all                          *
 ********************************************/
FOR EACH orig_catch_all WHERE orig_catch_all.orig_catch_people_ID = i-fromID AND 
    orig_catch_all.orig__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        orig_catch_all.orig_catch_ID    = i-toID
        orig_catch_all.orig__log01      = YES 
        orig_catch_all.orig_prog_name   = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. orig_catch_all **/


/********************************************
 *  patient_mstr                            *
 ********************************************/
FIND patient_mstr WHERE patient_mstr.patient_id = i-fromID AND 
    patient_mstr.patient__log01 = NO 
        EXCLUSIVE-LOCK NO-ERROR.
    
IF AVAILABLE (patient_mstr) THEN DO: 
    
    IF NOT CAN-FIND(FIRST pat-buff WHERE pat-buff.patient_id = i-toID NO-LOCK) THEN 
        ASSIGN 
            patient_mstr.patient_id         = i-toID
            patient_mstr.patient__log01     = YES 
            patient_mstr.patient_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
        
END.  /** of if avail patient_mstr **/

FOR EACH patient_mstr WHERE patient_mstr.patient_RP_ID = i-fromID AND 
    patient_mstr.patient__dec02 = 0
        EXCLUSIVE-LOCK:

    ASSIGN 
        patient_mstr.patient_RP_ID      = i-toID
        patient_mstr.patient__dec02     = patient_mstr.patient__dec02 + 1
        patient_mstr.patient_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. patient_mstr --- Responsible Party **/

FOR EACH patient_mstr WHERE patient_mstr.patient_doctor_ID = i-fromID AND 
    patient_mstr.patient__dec03 = 0
        EXCLUSIVE-LOCK:

    ASSIGN 
        patient_mstr.patient_doctor_ID  = i-toID
        patient_mstr.patient__dec03     = patient_mstr.patient__dec03 + 1
        patient_mstr.patient_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. patient_mstr --- Doctor **/

FOR EACH patient_mstr WHERE patient_mstr.patient_cust_ID = i-fromID AND 
    patient_mstr.patient__dec04 = 0
        EXCLUSIVE-LOCK:

    ASSIGN 
        patient_mstr.patient_cust_ID    = i-toID
        patient_mstr.patient__dec04     = patient_mstr.patient__dec04 + 1
        patient_mstr.patient_prog_name  = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. patient_mstr --- Customers **/


/********************************************
 *  pcl_det                                 *
 ********************************************/
FOR EACH pcl_det WHERE pcl_det.pcl_patient_ID = i-fromID AND 
    pcl_det.pcl__log01 = NO 
        EXCLUSIVE-LOCK:

    ASSIGN 
        pcl_det.pcl_patient_ID  = i-toID
        pcl_det.pcl__log01      = YES 
        pcl_det.pcl_prog_name   = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. pcl_det **/


/********************************************
 *  scust_shadow                            *
 ********************************************/
FIND scust_shadow WHERE scust_shadow.scust_id = i-fromID AND 
    scust_shadow.scust__log01 = NO 
        EXCLUSIVE-LOCK NO-ERROR.
    
IF AVAILABLE (scust_shadow) THEN DO: 
    
    IF NOT CAN-FIND(FIRST scust-buff WHERE scust-buff.scust_id = i-toID NO-LOCK) THEN 
        ASSIGN 
            scust_shadow.scust_id           = i-toID
            scust_shadow.scust__log01       = YES 
            scust_shadow.scust_prog_name    = SOURCE-PROCEDURE:FILE-NAME.
        
END.  /** of if avail scust_shadow **/

FOR EACH scust_shadow WHERE scust_shadow.scust_doctor_ID = i-fromID AND 
    scust_shadow.scust__log02 = NO  
        EXCLUSIVE-LOCK:

    ASSIGN 
        scust_shadow.scust_doctor_ID    = i-toID
        scust_shadow.scust__log02       = YES 
        scust_shadow.scust_prog_name    = SOURCE-PROCEDURE:FILE-NAME.
    
END.  /** of 4ea. scust_shadow **/


DO x = 1 TO ERROR-STATUS:NUM-MESSAGES: 
    
    o-result    = o-result + ERROR-STATUS:GET-MESSAGE(x) + "|".

END.  /** of do x = 1 to num-messages **/ 


/****************************  END OF FILE  *****************************/

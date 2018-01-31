
/*------------------------------------------------------------------------
    File        : people_rec_delete.p
    Purpose     : Completely wipes a people_mstr record from existence

    Syntax      :

    Description : Recursively delete people_mstr record and all associated records

    Author(s)   : Andrew Garver
    Created     : Wed Jan 03 15:02:55 EST 2018
    Notes       :
        
    Usage       : After running this procedure, if the return value of v-success is NO then display the v-message, which
                  will be an error message. If the return value of v-success is YES and v-message is not blank, the 
                  message is a warning that should be displayed before the record can be deleted. If the value of v-success 
                  is YES and v-message is blank, the record was deleted successfully.
    
    If there are TKs, open sales orders, or a doctor with patients, or a customer tied to paitients,  
    or Client, or Employee CAN NOT delete people_record
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER v-people_id LIKE people_mstr.people_id NO-UNDO.
DEFINE INPUT PARAMETER v-bypass-warnings AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER v-success AS LOGICAL INITIAL NO NO-UNDO.
DEFINE OUTPUT PARAMETER v-message AS CHARACTER NO-UNDO.

FIND FIRST people_mstr WHERE people_mstr.people_id = v-people_id NO-ERROR.
IF AVAILABLE (people_mstr) THEN DO:
    
    /* Cannot delete */
    FIND FIRST Client_Mstr WHERE Client_Mstr.Client_people_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(Client_Mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is linked to a Client.".
        RETURN.
    END.
    FIND FIRST Emp_Mstr WHERE Emp_Mstr.Emp_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(Emp_Mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is linked to an Employee.".
        RETURN.
    END.
    FIND FIRST TK_mstr WHERE TK_mstr.TK_cust_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(TK_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is a customer for one or more Test Kits.".
        RETURN.
    END.
    FIND FIRST TK_mstr WHERE TK_mstr.TK_patient_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(TK_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is the patient for one or more Test Kits.".
        RETURN.
    END.
    FIND FIRST doctor_mstr WHERE doctor_mstr.doctor_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(doctor_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is a Doctor.".
        RETURN.
    END.
    FIND FIRST so_mstr WHERE so_mstr.so_cust_ID = people_mstr.people_id AND so_mstr.so_status <> "COMPLETE" NO-ERROR. /* IF OPEN */
    IF AVAILABLE(so_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete still has at least one open sales order.".
        RETURN.
    END.
    
    /* Warn before delete */
    FIND FIRST plink_mstr WHERE plink_mstr.plink_people_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(plink_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is linked to at least one other person.".
    END.
    FIND FIRST plink_mstr WHERE plink_mstr.plink_rel_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(plink_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is linked to at least one other person.".
    END.
    FIND FIRST Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(Proj_Mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is a currently active Client.".
    END.
    FIND FIRST Hours_Mstr WHERE Hours_Mstr.Hours_employee_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(Hours_Mstr) THEN DO:
        v-message = "The person who's record you are trying to delete has logged hours worked.".
    END.
    FIND FIRST sched_mstr WHERE sched_mstr.sched_instructor_ID = people_mstr.people_id NO-ERROR.
    IF AVAILABLE(sched_mstr) THEN DO:
        v-message = "The person who's record you are trying to delete is an instructor for at least one class.".
    END.
    
    /* Perform the actual delete */
    IF v-message = "" OR v-bypass-warnings = TRUE THEN DO:
        FOR EACH plink_mstr WHERE plink_mstr.plink_people_ID = people_mstr.people_id OR 
        plink_mstr.plink_rel_ID = people_mstr.people_id NO-LOCK:
            DELETE plink_mstr.
        END.
        
        FOR EACH Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = people_mstr.people_id NO-LOCK:
            DELETE Proj_Mstr.
        END.
            
        FOR EACH Hours_Mstr WHERE Hours_Mstr.Hours_employee_ID = people_mstr.people_id NO-LOCK:
            DELETE Hours_Mstr.
        END.
            
        FOR EACH sched_mstr WHERE sched_mstr.sched_instructor_ID = people_mstr.people_id NO-LOCK:
            DELETE sched_mstr.
        END.
            
        FOR EACH D_people_mstr WHERE D_people_mstr.D_people_id = people_mstr.people_id NO-LOCK:
            DELETE D_people_mstr.
        END.
        
        FOR EACH event_mstr WHERE event_mstr.event_contact = people_mstr.people_id NO-LOCK:
            DELETE event_mstr.
        END.
            
        FOR EACH cust_mstr WHERE cust_mstr.cust_id = people_mstr.people_id NO-LOCK:
            DELETE cust_mstr.
        END.
            
        FOR EACH gud_det WHERE gud_det.gud_people_ID = people_mstr.people_id NO-LOCK:
            DELETE gud_det.
        END.
            
        FOR EACH pal_list WHERE pal_list.pal_people_ID = people_mstr.people_id NO-LOCK:
            DELETE pal_list.
        END.
            
        FOR EACH session_det WHERE session_det.session_user_id = people_mstr.people_id NO-LOCK:
            DELETE session_det.
        END.
            
        FOR EACH usr_mstr WHERE usr_mstr.usr_people_ID = people_mstr.people_id NO-LOCK:
            DELETE usr_mstr.
        END.
            
        FOR EACH Emph_Hist WHERE Emph_hist.Emph_emp_ID = people_mstr.people_id NO-LOCK:
            DELETE Emph_Hist.
        END.
            
        FOR EACH MBC_det WHERE MBC_det.MBC_people_ID = people_mstr.people_id NO-LOCK:
            DELETE MBC_det.
        END.
            
        FOR EACH Attend_det WHERE Attend_det.attend_people_id = people_mstr.people_id NO-LOCK:
            DELETE Attend_det.
        END.
            
        FOR EACH bd_bill_det WHERE bd_bill_det.bd_People_ID = people_mstr.people_id NO-LOCK:
            DELETE bd_bill_det.
        END.
            
        FOR EACH dca_det WHERE dca_det.dca_people_ID = people_mstr.people_id NO-LOCK:
            DELETE dca_det.
        END.
            
        FOR EACH patient_mstr WHERE patient_mstr.patient_ID = people_mstr.people_id OR 
        patient_mstr.patient_RP_ID = people_mstr.people_id OR patient_mstr.patient_doctor_ID = people_mstr.people_id OR 
        patient_mstr.patient_cust_ID = people_mstr.people_id NO-LOCK:
            DELETE patient_mstr.
        END.
            
        FOR EACH pcl_det WHERE pcl_det.pcl_patient_id = people_mstr.people_id NO-LOCK:
            DELETE pcl_det.
        END.
            
        FOR EACH pd_det WHERE pd_det.pd_people_ID = people_mstr.people_id NO-LOCK:
            DELETE pd_det.
        END.
            
        FOR EACH regis_mstr WHERE regis_mstr.regis_people_ID = people_mstr.people_id NO-LOCK:
            DELETE regis_mstr.
        END.
            
        FOR EACH resp_det WHERE resp_det.resp_people_ID = people_mstr.people_id NO-LOCK:
            DELETE resp_det.
        END.
            
        FOR EACH trh_hist WHERE trh_hist.trh_people_id = people_mstr.people_id NO-LOCK:
            DELETE trh_hist.
        END.
            
        FOR EACH scust_shadow WHERE scust_shadow.scust_ID = people_mstr.people_id NO-LOCK:
            DELETE scust_shadow.
        END.
            
        FOR EACH speop_shadow WHERE speop_shadow.speop_ID = people_mstr.people_id NO-LOCK:
            DELETE speop_shadow.
        END.
    END.
    
    /* TBD */
    /*    FOR EACH lab_mstr WHERE lab_mstr.lab_ID = people_mstr.people_id OR*/ 
    /*              lab_mstr.lab_contact_id = people_mstr.people_id NO-LOCK:*/
    /*              DELETE lab_mstr.                                        */
    /*          END.                                                        */
    
    v-success = YES.

END.
ELSE DO:
    v-message = "It looks like the person you are trying to delete has already been deleted!".
END.
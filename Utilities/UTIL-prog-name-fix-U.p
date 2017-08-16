
/*------------------------------------------------------------------------
    File        : prog-name-fix.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Wed Jul 05 14:53:27 EDT 2017
    Notes       :
    
    ------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by ANDREW GARVER on 05/Jul/17.  Original Version.
    1.1 - written by DOUG LUTTRELL on 10/Aug/17.  Modified to support
            the use of the *_deleted fields.  Marked by 1dot1.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH addr_mstr WHERE addr_mstr.addr_prog_name = "ISO-CleanUP-addr_mstr-country.p - addr_mstr.addr_country updated with new country_ISO." AND 
        addr_deleted = ? EXCLUSIVE-LOCK:                        /* 1dot1 */
    ASSIGN 
        addr_mstr.addr_prog_name = "ISO-CleanUP-addr_mstr-country.p"
        addr_mstr.addr_modified_date = TODAY 
        addr_mstr.addr_modified_by = USERID ("General").
END.

FOR EACH addr_mstr WHERE addr_mstr.addr_prog_name = "ISO-CleanUP-addr_mstr-state.p - addr_mstr.addr_stateprov updated with new state_ISO." AND 
        addr_deleted = ? EXCLUSIVE-LOCK:                        /* 1dot1 */
    ASSIGN 
        addr_mstr.addr_prog_name     = "ISO-CleanUP-addr_mstr-state.p"
        addr_mstr.addr_modified_date = TODAY 
        addr_mstr.addr_modified_by   = USERID ("General").
END.

FOR EACH people_mstr WHERE people_mstr.people_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p44053_UTIL-genderfix-U.ped" AND 
        people_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        people_mstr.people_prog_name     = "UTIL-genderfix-U.p"
        people_mstr.people_modified_date = TODAY 
        people_mstr.people_modified_by   = USERID ("General").
END.

FOR EACH people_mstr WHERE people_mstr.people_prog_name = "ISO-CleanUP-people_mstr-state.p - people_people_id new address-ID." AND 
        people_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        people_mstr.people_prog_name     = "ISO-CleanUP-people_mstr-state.p"
        people_mstr.people_modified_date = TODAY 
        people_mstr.people_modified_by   = USERID ("General").
END.

FOR EACH people_mstr WHERE people_mstr.people_prog_name = "ISO-CleanUP-people_mstr-state.p - people_second_people_id new address-ID." AND 
        people_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        people_mstr.people_prog_name     = "ISO-CleanUP-people_mstr-state.p"
        people_mstr.people_modified_date = TODAY 
        people_mstr.people_modified_by   = USERID ("General").
END.

FOR EACH people_mstr WHERE people_mstr.people_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p42702_UTIL-renumber-people-U.ped" AND 
        people_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        people_mstr.people_prog_name     = "UTIL-renumber-people-U.p"
        people_mstr.people_modified_date = TODAY 
        people_mstr.people_modified_by   = USERID ("General").
END.

FOR EACH trh_hist WHERE trh_hist.trh_prog_name = "P:\OpenEdge\WRK\databases\Scripts-PF\p32296_UTIL-trhrebuild-U.ped" AND 
        people_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        trh_hist.trh_prog_name     = "UTIL-trhrebuild-U.p"
        trh_hist.trh_modified_date = TODAY 
        trh_hist.trh_modified_by   = USERID ("General").
END.

FOR EACH trh_hist WHERE trh_hist.trh_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p42702_UTIL-renumber-people-U.ped" AND 
        people_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        trh_hist.trh_prog_name     = "UTIL-renumber-people-U.p"
        trh_hist.trh_modified_date = TODAY 
        trh_hist.trh_modified_by   = USERID ("General").
END.

FOR EACH trh_hist WHERE trh_hist.trh_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p10300_UTIL-reimport-trhhistU.ped" AND 
        trh_deleted = ? EXCLUSIVE-LOCK:                         /* 1dot1 */
    ASSIGN 
        trh_hist.trh_prog_name     = "UTIL-reimport-trhhistU.p"
        trh_hist.trh_modified_date = TODAY 
        trh_hist.trh_modified_by   = USERID ("General").
END.

FOR EACH tkr_det WHERE tkr_det.tkr_prog_name = "P:\OpenEdge\WRK\databases\Scripts-PF\p29769_DV-oldMPAs-U-2.ped" AND 
        tkr_deleted = ? EXCLUSIVE-LOCK:                         /* 1dot1 */
    ASSIGN 
        tkr_det.tkr_prog_name     = "DV-oldMPAs-U-2.p"
        tkr_det.tkr_modified_date = TODAY 
        tkr_det.tkr_modified_by   = USERID ("General").
END.

FOR EACH doctor_mstr WHERE doctor_mstr.doctor_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p42702_UTIL-renumber-people-U.ped" AND 
        doctor_deleted = ? EXCLUSIVE-LOCK:                      /* 1dot1 */
    ASSIGN 
        doctor_mstr.doctor_prog_name     = "UTIL-renumber-people-U.p"
        doctor_mstr.doctor_modified_date = TODAY 
        doctor_mstr.doctor_modified_by   = USERID ("General").
END.

FOR EACH patient_mstr WHERE patient_mstr.patient_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p42702_UTIL-renumber-people-U.ped" AND 
        patient_deleted = ? EXCLUSIVE-LOCK:                     /* 1dot1 */
    ASSIGN 
        patient_mstr.patient_prog_name     = "UTIL-renumber-people-U.p"
        patient_mstr.patient_modified_date = TODAY 
        patient_mstr.patient_modified_by   = USERID ("General").
END.

FOR EACH scust_shadow WHERE scust_shadow.scust_prog_name = "P:\OpenEdge\TEST\databases\Scripts-PF\p42702_UTIL-renumber-people-U.ped" AND 
        scust_deleted = ? EXCLUSIVE-LOCK:                       /* 1dot1 */
    ASSIGN 
        scust_shadow.scust_prog_name     = "UTIL-renumber-people-U.p"
        scust_shadow.scust_modified_date = TODAY 
        scust_shadow.scust_modified_by   = USERID ("General").
END.

/**********************  EOF  ***************************/


/*------------------------------------------------------------------------
    File        : EXPORTallR.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Fri Jun 03 06:44:01 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE datefield AS DATE NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */
UPDATE datefield.

/* ***************************  Main Block  *************************** */
OUTPUT TO "C:\PROGRESS\WRK\EXPORTpeople_mstrR.txt".

EXPORT DELIMITER ";"
    "people_id"
    "people_firstname"
    "people_midname"
    "people_lastname"
    "people_prefix"
    "people_suffix"
    "people_addr_id"
    "people_company"
    "people_gender"
    "people_homephone"
    "people_workphone"
    "people_cellphone"
    "people_fax"
    "people_email"
    "people_email2" 
    "people_contact"
    "people_DOB"   
    "people_mstr.people_created_by" 
    "people_mstr.people_create_date"
    "people_mstr.people_modified_by"
    "people_mstr.people_modified_date"
    "people_mstr.people__char01"
    "people_mstr.people__char02"
    "people_mstr.people__char03"
    "people_mstr.people__date01"
    "people_mstr.people__date02"
    "people_mstr.people__date03"
    "people_mstr.people__log01"
    "people_mstr.people__log02"
    "people_mstr.people__log03"
    "people_mstr.people__dec01"
    "people_mstr.people__dec02"
    "people_mstr.people__dec03"
    "people_mstr.people__dec04"
    "people_mstr.people__dec05"
    "people_mstr.people_deleted"  
    "people_second_addr_ID"
    "people_mstr.people_title"
    "people_prefname".


FOR EACH people_mstr WHERE people_mstr.people_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        people_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTpatient_mstrR.txt".

EXPORT DELIMITER ";"
    "patient_ID"
    "patient_condition"
    "patient_notes"         
    "patient_RP_ID"   
    "patient_doctor_ID"          
    "patient_cust_ID"         
    "patient_verified"
    "patient_created_by"
    "patient_create_date" 
    "patient_modified_by"
    "patient_modified_date"
    "patient__char01"
    "patient__char02"
    "patient__char03"
    "patient__date01"  
    "patient__date02"          
    "patient__date03"    
    "patient__log01"
    "patient__log02"
    "patient__log03"
    "patient__dec01"
    "patient__dec02"
    "patient__dec03"
    "patient__dec04"
    "patient__dec05"
    "patient_deleted"
    "patient_prog_name".


FOR EACH patient_mstr WHERE patient_mstr.patient_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        patient_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTdoctor_mstrR.txt".

EXPORT DELIMITER ";"
    "doctor_ID"
    "doctor_TCP_code"
    "doctor_created_by" 
    "doctor_create_date"
    "doctor_modified_by"
    "doctor_modified_date"
    "doctor__char01"
    "doctor__char02"
    "doctor__char03" 
    "doctor__date01"   
    "doctor__date02" 
    "doctor__date03"
    "doctor__log01"
    "doctor__log02"
    "doctor__log03"
    "doctor__dec01"
    "doctor__dec02"
    "doctor__dec03"
    "doctor__dec04"
    "doctor__dec05"
    "doctor_deleted"
    "doctor_prog_name".


FOR EACH doctor_mstr WHERE doctor_mstr.doctor_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        doctor_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTcust_mstrR.txt".

EXPORT DELIMITER ";"
    "cust_ID"
    "cust_card_nbr"       
    "cust_card_seccode"                
    "cust_card_type"                   
    "cust_created_by"                  
    "cust_create_date"                 
    "cust_modified_by"                 
    "cust_modified_date"               
    "cust__char01"                     
    "cust__char02"                     
    "cust__char03"                     
    "cust__date01"                     
    "cust__date02"                     
    "cust__date03"                     
    "cust__log01"                      
    "cust__log02"                      
    "cust__log03"                      
    "cust__dec01"                      
    "cust__dec02"                      
    "cust__dec03"                      
    "cust__dec04"                      
    "cust__dec05"                      
    "cust_deleted"                    
    "cust_card_expmonth"               
    "cust_card_expyear"                
    "cust_prog_name".                   


FOR EACH cust_mstr WHERE cust_mstr.cust_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        cust_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTcountry_mstrR.txt".

EXPORT DELIMITER ";"
    "country_ISO"
    "country_display_name"       
    "country_region"                
    "country_intl_prefix"
    "country_from"
    "country_to"                   
    "country_created_by"                  
    "country_create_date"                 
    "country_modified_by"                 
    "country_modified_date"               
    "country__char01"                     
    "country__char02"                     
    "country__char03"                     
    "country__date01"                     
    "country__date02"                     
    "country__date03"                     
    "country__log01"                      
    "country__log02"                      
    "country__log03"                      
    "country__dec01"                      
    "country__dec02"                      
    "country__dec03"                      
    "country__dec04"                      
    "country__dec05"                      
    "country_deleted"                                    
    "country_prog_name"
    "Country_Primary"
    .                   


FOR EACH country_mstr WHERE country_mstr.country_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        country_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTaddr_mstrR.txt".

EXPORT DELIMITER ";"
    "addr_id"
    "addr_addr1"
    "addr_addr2"
    "addr_addr3"
    "addr_city"
    "addr_stateprov"
    "addr_zip"
    "addr_country"                   
    "addr_created_by"                  
    "addr_create_date"                 
    "addr_modified_by"                 
    "addr_modified_date"               
    "addr__char01"                     
    "addr__char02"                     
    "addr__char03"                     
    "addr__date01"                     
    "addr__date02"                     
    "addr__date03"                     
    "addr__log01"                      
    "addr__log02"                      
    "addr__log03"                      
    "addr__dec01"                      
    "addr__dec02"                      
    "addr__dec03"                      
    "addr__dec04"                      
    "addr__dec05"                      
    "addr_deleted"
    "addr_type"
    "addr_prog_name".                   


FOR EACH addr_mstr WHERE addr_mstr.addr_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        addr_mstr. 

END.
OUTPUT CLOSE.

OUTPUT TO "C:\PROGRESS\WRK\EXPORTpcl_detR.txt".

EXPORT DELIMITER ";"
    "pcl_testtype"
    "pcl_item_ID"
    "pcl_start_range"
    "pcl_end_range"
    "pcl_suppl_ID"
    "pcl_dosage_from"
    "pcl_dosage_to"
    "pcl_uom"
    "pcl_notes"
    "pcl_order"
    "pcl_group_ignore"
    "pcl_deleted" 
    "pcl_created_by" 
    "pcl_create_date"
    "pcl_modified_by"
    "pcl_modified_date"
    "pcl__char01"
    "pcl__char02"
    "pcl__char03" 
    "pcl__date01"   
    "pcl__date02" 
    "pcl__date03"
    "pcl__log01"
    "pcl__log02"
    "pcl__log03"
    "pcl__dec01"
    "pcl__dec02"
    "pcl__dec03"
    "pcl__dec04"
    "pcl__dec05"
    "pcl_hexcolor"
    "pcl_prog_name"
    "pcl_start_eff"
    "pcl_end_eff"
    .


FOR EACH pcl_det WHERE pcl_det.pcl_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        pcl_det. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTscust_shadowR.txt".

EXPORT DELIMITER ";"
    "scust_ID"
    "scust_magento_ID"
    "scust_prof"
    "scust_created_by"
    "scust_create_date"
    "scust_modified_by"
    "scust_modified_date"            
    "scust__char01"                     
    "scust__char02"                     
    "scust__char03"                     
    "scust__date01"                     
    "scust__date02"                     
    "scust__date03"                     
    "scust__log01"                      
    "scust__log02"                      
    "scust__log03"                      
    "scust__dec01"                      
    "scust__dec02"                      
    "scust__dec03"                      
    "scust__dec04"                      
    "scust__dec05"                      
    "scust_deleted"                    
    "scust_doctor_ID"                
    "scust_prog_name".                   


FOR EACH scust_shadow WHERE scust_shadow.scust_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        scust_shadow. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTstate_mstrR.txt".

EXPORT DELIMITER ";"
    "state_ISO"
    "state_display_name"       
    "state_country_ISO"                
    "state_stateID"                 
    "state_created_by"                  
    "state_create_date"                 
    "state_modified_by"                 
    "state_modified_date"               
    "state__char01"                     
    "state__char02"                     
    "state__char03"                     
    "state__date01"                     
    "state__date02"                     
    "state__date03"                     
    "state__log01"                      
    "state__log02"                      
    "state__log03"                      
    "state__dec01"                      
    "state__dec02"                      
    "state__dec03"                      
    "state__dec04"                      
    "state__dec05"                      
    "state_deleted"                                    
    "state_prog_name"
    "state_Primary"
    .                   


FOR EACH state_mstr WHERE state_mstr.state_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        state_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTtk_mstrR.txt".

EXPORT DELIMITER ";"
    "tk_ID"
    "TK_test_seq"                  
    "TK_test_type"               
    "TK_prof"                     
    "TK_domestic"                 
    "TK_cust_ID"                   
    "TK_patient_ID"              
    "TK_lab_sample_ID"               
    "TK_lab_seq"                 
    "TK_test_age"                    
    "TK_status"                
    "TK_comments"            
    "TK_notes" 
    "tk_created_by" 
    "tk_create_date"
    "tk_modified_by"
    "tk_modified_date"
    "tk__char01"
    "tk__char02"
    "tk__char03" 
    "tk__date01"   
    "tk__date02" 
    "tk__date03"
    "tk__log01"
    "tk__log02"
    "tk__log03"
    "tk__dec01"
    "tk__dec02"
    "tk__dec03"
    "tk__dec04"
    "tk__dec05"
    "TK_cust_paid"             
    "TK_deleted"                  
    "TK_lbl_print"        
    "TK_lab_paid"              
    "TK_lab_ID"    
    "TK_prog_name"                
    "TK_magento_order"           
    "TK_cust_paid_date".


FOR EACH tk_mstr WHERE tk_mstr.tk_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        tk_mstr. 

END.
OUTPUT CLOSE.

OUTPUT TO "C:\PROGRESS\WRK\EXPORTtl_mstrR.txt".

EXPORT DELIMITER ";"
    "tl_sect_ID"
    "tl_testtype"
    "tl_section_desc"
    "tl_order"
    "tl_start_eff"
    "tl_end_eff"
    "tl_deleted" 
    "tl_created_by" 
    "tl_create_date"
    "tl_modified_by"
    "tl_modified_date"
    "tl__char01"
    "tl__char02"
    "tl__char03" 
    "tl__date01"   
    "tl__date02" 
    "tl__date03"
    "tl__log01"
    "tl__log02"
    "tl__log03"
    "tl__dec01"
    "tl__dec02"
    "tl__dec03"
    "tl__dec04"
    "tl__dec05"
    "tl_prog_name"
    .


FOR EACH tl_mstr WHERE tl_mstr.tl_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        tl_mstr. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTtld_detR.txt".

EXPORT DELIMITER ";"
    "tld_sect_ID"
    "tld_item_ID"
    "tld_order"
    "tld_start_eff"
    "tld_end_eff"
    "tld_deleted" 
    "tld_created_by" 
    "tld_create_date"
    "tld_modified_by"
    "tld_modified_date"
    "tld__char01"
    "tld__char02"
    "tld__char03" 
    "tld__date01"   
    "tld__date02" 
    "tld__date03"
    "tld__log01"
    "tld__log02"
    "tld__log03"
    "tld__dec01"
    "tld__dec02"
    "tld__dec03"
    "tld__dec04"
    "tld__dec05"
    "tld_start_ref"
    "tld_end_ref"
    "tld_UOM"
    "tld_bar_type"
    "tld_prog_name"
    .


FOR EACH tld_det WHERE tld_det.tld_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        tld_det. 
        
END.
OUTPUT CLOSE.

OUTPUT TO "C:\PROGRESS\WRK\EXPORTtrh_histR.txt".

EXPORT DELIMITER ";"
    "trh_ID"
    "trh_item"
    "trh_action"
    "trh_qty"
    "trh_loc"
    "trh_lot"
    "trh_serial"
    "trh_deleted" 
    "trh_created_by" 
    "trh_create_date"
    "trh_modified_by"
    "trh_modified_date"
    "trh__char01"
    "trh__char02"
    "trh__char03" 
    "trh__date01"   
    "trh__date02" 
    "trh__date03"
    "trh__log01"
    "trh__log02"
    "trh__log03"
    "trh__dec01"
    "trh__dec02"
    "trh__dec03"
    "trh__dec04"
    "trh__dec05"
    "trh_sequence"
    "trh_site"
    "trh_prog_name"
    "trh_people_id"
    "trh_order"
    "trh_other_ID"
    "trh_comments"
    "trh_date"
    "trh_time"
    "trh_ref".


FOR EACH trh_hist WHERE trh_hist.trh_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        trh_hist. 

END.
OUTPUT CLOSE.   

OUTPUT TO "C:\PROGRESS\WRK\EXPORTtrr_detR.txt".

EXPORT DELIMITER ";"
    "trr_testtype"
    "trr_item_ID"
    "trr_start_range"
    "trr_end_range"
    "trr_suppl_ID"
    "trr_dosage_from"
    "trr_dosage_to"
    "trr_uom"
    "trr_notes"
    "trr_order"
    "trr_group_ignore"
    "trr_deleted" 
    "trr_created_by" 
    "trr_create_date"
    "trr_modified_by"
    "trr_modified_date"
    "trr__char01"
    "trr__char02"
    "trr__char03" 
    "trr__date01"   
    "trr__date02" 
    "trr__date03"
    "trr__log01"
    "trr__log02"
    "trr__log03"
    "trr__dec01"
    "trr__dec02"
    "trr__dec03"
    "trr__dec04"
    "trr__dec05"
    "trr_hexcolor"
    "trr_prog_name"
    "trr_start_eff"
    "trr_end_eff"
    .


FOR EACH trr_det WHERE trr_det.trr_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        trr_det. 

END.
OUTPUT CLOSE. 

OUTPUT TO "C:\PROGRESS\WRK\EXPORTuom_mstrR.txt".

EXPORT DELIMITER ";"
    "uom_uom"
    "uom_type"
    "uom_value"
    "uom_dest_uom"
    "uom_descrip"
    "uom_delete"
    "uom_deleted"
    "uom_prog_name"                   
    "uom_created_by"                  
    "uom_create_date"                 
    "uom_modified_by"                 
    "uom_modified_date"               
    "uom__char01"                     
    "uom__char02"                     
    "uom__char03"                     
    "uom__date01"                     
    "uom__date02"                     
    "uom__date03"                     
    "uom__log01"                      
    "uom__log02"                      
    "uom__log03"                      
    "uom__dec01"                      
    "uom__dec02"                      
    "uom__dec03"                      
    "uom__dec04"                      
    "uom__dec05"                      
    .                   


FOR EACH uom_mstr WHERE uom_mstr.uom_modified_date > datefield NO-LOCK: 
    
    EXPORT DELIMITER ";"
        uom_mstr. 

END.
OUTPUT CLOSE.      
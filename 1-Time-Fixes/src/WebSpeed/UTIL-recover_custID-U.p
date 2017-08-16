def var updatemode as log initial no label "Update?" no-undo.
def var outfile as char format "x(50)" label "Output To"
    initial "C:\progress\wrk\recover-custID.txt" no-undo.

update skip(1)
    updatemode colon 20
    outfile colon 20 skip(1)
        with frame a width 80 side-labels.

output to value(outfile).
export delimiter ";"
    "TK_ID" "TK_test_seq" "Missing_Cust" "Action".


FOR EACH tk_mstr WHERE tk_mstr.tk_cust_id <> 0 AND 
     tk_mstr.tk_deleted = ? AND 
     NOT CAN-FIND(FIRST prod.people_mstr WHERE prod.people_mstr.people_id = tk_mstr.tk_cust_id NO-LOCK) NO-LOCK: 
         
     FIND backup.people_mstr WHERE backup.people_mstr.people_id = tk_mstr.tk_cust_id AND 
          backup.people_mstr.people_deleted = ? 
               NO-LOCK NO-ERROR.
     
     IF AVAILABLE (backup.people_mstr) THEN DO: 
         
         export delimiter ";"
            tk_mstr.tk_id tk_mstr.tk_test_seq tk_mstr.tk_cust_id "Create from backup.people_mstr".
         
         if updatemode = yes then do: 
         
            CREATE prod.people_mstr.
            ASSIGN 
               prod.people_mstr.people_addr_id             = backup.people_mstr.people_addr_id 
               prod.people_mstr.people_cellphone           = backup.people_mstr.people_cellphone
               prod.people_mstr.people_company             = backup.people_mstr.people_company
               prod.people_mstr.people_contact             = backup.people_mstr.people_contact
               prod.people_mstr.people_created_by          = backup.people_mstr.people_created_by
               prod.people_mstr.people_create_date         = backup.people_mstr.people_create_date
               prod.people_mstr.people_deleted             = backup.people_mstr.people_deleted
               prod.people_mstr.people_DOB                 = backup.people_mstr.people_DOB
               prod.people_mstr.people_email               = backup.people_mstr.people_email
               prod.people_mstr.people_email2              = backup.people_mstr.people_email2
               prod.people_mstr.people_fax                 = backup.people_mstr.people_fax
               prod.people_mstr.people_firstname           = backup.people_mstr.people_firstname
               prod.people_mstr.people_gender              = backup.people_mstr.people_gender
               prod.people_mstr.people_homephone           = backup.people_mstr.people_homephone
               prod.people_mstr.people_id                  = backup.people_mstr.people_id
               prod.people_mstr.people_lastname            = backup.people_mstr.people_lastname
               prod.people_mstr.people_midname             = backup.people_mstr.people_midname
               prod.people_mstr.people_modified_by         = backup.people_mstr.people_modified_by
               prod.people_mstr.people_modified_date       = backup.people_mstr.people_modified_date
               prod.people_mstr.people_prefix              = backup.people_mstr.people_prefix
               prod.people_mstr.people_prefname            = backup.people_mstr.people_prefname
               prod.people_mstr.people_prog_name           = backup.people_mstr.people_prog_name
               prod.people_mstr.people_second_addr_ID      = backup.people_mstr.people_second_addr_ID
               prod.people_mstr.people_suffix              = backup.people_mstr.people_suffix
               prod.people_mstr.people_title               = backup.people_mstr.people_title
               prod.people_mstr.people_workphone           = backup.people_mstr.people_workphone
               prod.people_mstr.people__char01             = backup.people_mstr.people__char01
               prod.people_mstr.people__char02             = backup.people_mstr.people__char02
               prod.people_mstr.people__char03             = backup.people_mstr.people__char03
               prod.people_mstr.people__date01             = backup.people_mstr.people__date01
               prod.people_mstr.people__date02             = backup.people_mstr.people__date02
               prod.people_mstr.people__date03             = backup.people_mstr.people__date03
               prod.people_mstr.people__dec01              = backup.people_mstr.people__dec01
               prod.people_mstr.people__dec02              = backup.people_mstr.people__dec02
               prod.people_mstr.people__dec03              = backup.people_mstr.people__dec03
               prod.people_mstr.people__dec04              = backup.people_mstr.people__dec04
               prod.people_mstr.people__dec05              = backup.people_mstr.people__dec05
               prod.people_mstr.people__log01              = backup.people_mstr.people__log01
               prod.people_mstr.people__log02              = backup.people_mstr.people__log02
               prod.people_mstr.people__log03              = backup.people_mstr.people__log03
               .   
                  
        end.  /** of if updatemode = yes **/                        
                                                  
     END.  /*** of if avail backup.people_mstr ***/ 

     else do: 
        export delimiter ";"
            tk_mstr.tk_id 
            tk_mstr.tk_test_seq 
            tk_mstr.tk_cust_id
            "No people_mstr found".
     end.  /** of else do **/
     
END.  /** OF 4ea. tk_mstr, etc. **/


output close.

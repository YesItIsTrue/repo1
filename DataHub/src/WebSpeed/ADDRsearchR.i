
/*------------------------------------------------------------------------
    File        : ADDRsearchR.i
    Purpose     : minimize code

    Syntax      :

    Description : Search function for both ADDRviewR and ADDRprintR

    Author(s)   : Jacob Luttrell
    Created     : Mon Jul 06 17:32:22 MDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

 
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */  
FOR EACH patient_mstr       WHERE patient_mstr.patient_verified = LOGICAL("yes") AND  
                                      patient_mstr.patient_deleted = ? NO-LOCK,
    EACH tk_mstr            WHERE TK_mstr.TK_patient_ID = patient_mstr.patient_id AND
                                      TK_mstr.TK_lbl_print = ? AND 
                                      TK_mstr.TK_domestic = YES AND
                                      TK_mstr.TK_deleted = ? AND 
                                      ((TK_mstr.TK_ID >= fromTK ) OR
                                      (fromTK = "")) AND 
                                      ((TK_mstr.TK_ID <= toTK ) OR 
                                      (toTK  = "")) NO-LOCK,
    EACH test_mstr          WHERE test_mstr.test_type = TK_mstr.TK_test_type AND
                                      test_mstr.test_deleted = ?  AND
                                      test_mstr.test_family  = "MPA" NO-LOCK,
    FIRST people_mstr   WHERE people_mstr.people_id = patient_mstr.patient_ID AND 
                                      people_mstr.people_deleted = ? AND 
                                      ((people_mstr.people_firstname >= fromFN) OR 
                                      (fromFN = "")) AND 
                                      ((people_mstr.people_firstname <= toFN) OR 
                                      (fromFN = "" )) AND 
                                      ((people_mstr.people_lastname >= fromLN) OR 
                                      (fromLN = "")) AND 
                                      ((people_mstr.people_lastname <= toLN) OR 
                                      (toLN = "")) NO-LOCK,   
                                      /** should this be tied to the RP ID? **/                           
    FIRST addr_mstr     WHERE addr_mstr.addr_id = people_mstr.people_addr_id AND
                                        addr_mstr.addr_deleted = ? NO-LOCK
 BREAK BY people_mstr.people_lastname:
   
   IF showmsg = YES THEN
    {&out}
        "<p>atient rp id =" patient_mstr.patient_RP_ID "</p>".
   
    FIND morepeople             WHERE morepeople.people_id = patient_mstr.patient_RP_ID NO-LOCK NO-ERROR.
    
    IF showmsg = YES THEN
        {&out}
    "<p>morepeople id =" morepeople.people_id "</p>".

/*------------------------------------------------------------------------
    File        : SUBpat-attR.i

    Description : an include file that will build a table for the att_file for a patient

    Author(s)   : Trae Luttrell
    Created     : Tue Jan 06 03:58:42 MST 2015
    Notes       :
        
  ----------------------------------------------------------------------*/

DEFINE VARIABLE v-tally-x       AS        INTEGER           NO-UNDO.

/* ***************************  Main Block  *************************** */
    {&OUT}
        SKIP "<!-- start of att_file table -->" SKIP   
        "<div class='pancake'>" SKIP
        "<TABLE>" SKIP 
        "   <thead>" SKIP
        "       <TH colspan=2>Attached Files</TH>" SKIP
        "   </THEAD>" SKIP
        "   <tbody>" SKIP  
        "   <tr>" SKIP
        "       <td>Category</td>" SKIP
        "       <td>File Name</td>" SKIP
        "   </tr>" SKIP.
            
    FOR EACH att_files WHERE
        att_files.att_table     = "patient_mstr"            AND 
        att_files.att_field1    = "patient_mstr.patient_ID" AND 
        att_files.att_value1    = STRING({1})               AND
        att_files.att_deleted   = ?
        NO-LOCK:
        
        v-tally-x = v-tally-x + 1.
        
        {&OUT}
            "       <tr>" SKIP
            "           <td nowrap>" att_files.att_category "</td>" SKIP
            "           <td nowrap><a href=~"http://hhi-dc-4/hhidata/hhidata.aspx?state=download&patientid=" {1} 
            "&fileid=" att_files.att_file_id " ~">" att_files.att_filename "</a></td>" SKIP
            "       </tr>" SKIP
            .
            
    END. /* FOR EACH att_file */
    
    FOR EACH TK_mstr WHERE
            TK_mstr.TK_patient_ID = {1} AND
            TK_mstr.TK_deleted = ?
            NO-LOCK,
        EACH att_files WHERE
            /** the right way ***
            att_files.att_table     = "TK_mstr" AND
            att_files.att_field1    = "TK_mstr.TK_ID" AND
            att_files.att_value1    = TK_mstr.TK_ID AND
            att_files.att_field2    = "TK_mstr.TK_test_seq" AND
            att_files.att_value2    = string(TK_mstr.TK_test_seq) AND 
            *************************/
            /**** the broken way ****/ 
            att_files.att_table     = "TK_mstr" AND
            att_files.att_field1    = "TK_mstr.TK_lab_sample_ID" AND
            att_files.att_value1    = TK_mstr.TK_lab_sample_ID AND
            att_files.att_field2    = "TK_mstr.TK_lab_seq" AND
            att_files.att_value2    = string(TK_mstr.TK_lab_seq) AND 
            /************************/
            att_files.att_deleted   = ?
                NO-LOCK
        BREAK BY att_files.att_category DESCENDING BY TK_mstr.tk_id:
        
        v-tally-x = v-tally-x + 1.
        
        {&OUT}
            "       <tr>" SKIP
            "           <td nowrap >" att_files.att_category "</td>" SKIP
            "           <td nowrap><a href=~"http://hhi-dc-4/hhidata/hhidata.aspx?state=download&patientid=" {1} 
            "&fileid=" att_files.att_file_id " ~">" TK_mstr.TK_ID "</a></td>" SKIP
/*            "           <td nowrap ><a href=~"" STRING(att_files.att_filepath + att_files.att_filename)*/
/*             "~">" TK_mstr.TK_ID  "</a></td>" SKIP                                                     */
            "       </tr>" SKIP
            .
        
    END. /* 4ea TK_mstr */    
    
    IF v-tally-x = 0 THEN 
        {&OUT}
            "       <tr>" SKIP
            "           <td colspan='2'>No Attached Files</td>" SKIP
            "       </tr>" SKIP
            .
    
    {&OUT}
        "   <tr><td colspan='2'> End of Table </td></tr>"
        "   </tbody>" SKIP
        "</table>" SKIP
        SKIP "<!-- end of att_file table -->" SKIP
        "</div>" SKIP.                                                          /* end of the pancake div */
        
   
/**********************  END OF INCLUDE FILE  **************************/
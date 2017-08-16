
/*------------------------------------------------------------------------
    File        : DEMO-include.i
    Purpose     : 

    Syntax      :

    Description : Include file for demo purposes.

    Author(s)   : Doug Luttrell
    Created     : Fri Feb 27 16:02:24 EST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
        {&OUT}
            "<DIV class='row'>" SKIP
            "<DIV class='grid_2'> </DIV>" SKIP
            "<DIV class='grid_8'>" SKIP
            
            "<div class='table_col'>"      SKIP
            "<form>" SKIP
            "   <table>"    SKIP
            "       <tr>"   SKIP
            "           <th colspan=2>Testkit Details - {1} {2}</th>" SKIP
            "       </tr>"  SKIP  
            "       <tr>"   SKIP
            "           <td>Testkit ID</td>" SKIP
            "           <td>" tk_mstr.tk_id "</td>" SKIP
            "      </TR>" SKIP
            "      <TR>"
            "           <td>Testkit Sequence</td>" SKIP
            "           <td>" TK_mstr.TK_test_seq "</td>" SKIP
            "       </tr>"  SKIP 
            "      <TR>"
            "           <td>Testkit Type</td>" SKIP
            "           <td>" TK_mstr.TK_testtype "</td>" SKIP
            "       </tr>"  SKIP 
            "      <TR>"
            "           <td>Testkit Status</td>" SKIP
            "           <td>" TK_mstr.TK_status "</td>" SKIP
            "       </tr>"  SKIP 
            "      <TR>"
            "           <td>Patient ID</td>" SKIP
            "           <td>" TK_mstr.TK_patient_ID "</td>" SKIP
            "       </tr>"  SKIP
            "      <TR>"
            "           <td>Customer ID</td>" SKIP
            "           <td>" TK_mstr.TK_cust_ID "</td>" SKIP
            "       </tr>"  SKIP
            "      <TR>"
            "           <td>Lab Sample ID</td>" SKIP
            "           <td>" TK_mstr.TK_lab_sample_ID "</td>" SKIP
            "       </tr>"  SKIP    
            "      <TR>"
            "           <td>Lab Paid</td>" SKIP
            "           <td>" TK_mstr.TK_lab_paid "</td>" SKIP
            "       </tr>"  SKIP  
            "      <TR>"
            "           <td>Customer Paid</td>" SKIP
            "           <td>" TK_mstr.TK_cust_paid "</td>" SKIP
            "       </tr>"  SKIP           
            "   </TABLE>" SKIP
            "</DIV>     <!-- end of table_2col -->" SKIP
            
            
            "</DIV>         <!-- end of grid_8 -->" SKIP
            "<DIV class='grid_2'> </DIV>" SKIP  
            "</DIV>     <!-- end of row -->" SKIP.
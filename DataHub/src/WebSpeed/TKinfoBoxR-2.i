
/*------------------------------------------------------------------------
    File        : Information_Box.i
    Purpose     : To save time really.

    Syntax      :

    Description : This is an include file that can be tacked on to whatever report 
    needs to have a "Information Box" about the person whose test kit you are viewing.
    
    Originally used in the TKtestresR.html.

    Author(s)   : Trae Luttrell
    Created     : Thu May 07 10:52:47 EDT 2015
    Updated     : Mon Aug 22 15:07:00 EDT 2016
    Notes       :
        
----------------------------------------------------------------------------------------------

  Revision History:
  -----------------
  1.0 - written by TRAE LUTTRELL on 07/May/15.  Original version.
  1.1 - written by TRAE LUTTRELL on 01/Jun/15.  Modified date.
  1.2 - written by DOUG LUTTRELL on 29/Feb/16.  Changed one of the FIND commands error conditions
            and some other bits to prevent a failure condition when certain data is missing.
            Marked by 1dot2.
  1.21 - written by Jacob Luttrell to 01/Mar/16. Changed TK_test_type to tk_test_type (unmarked).  
  
  3.6  - written by DOUG LUTTRELL on 22/Mar/16.  Changes to support new CSS changes from Quinton
            to get the tables to line up.  Jumped version to 3.6 so it will sync up with the 
            parent procedure that this include is used in - TKtestresR.html.  Marked by 3dot6.
                              
  3.7 - written by DOUG LUTTRELL on 28/May/16.  Added an additional squiggly field for the test type
            so that this thing will do a better job of picking the proper record.  Marked by 3dot7.
            
  3.71 - written by DOUG LUTTRELL on 02/Jun/16.  Changed to use correct dates (support the 11.1 data
            structures).  Also fixed the last action column.  Marked by 371.            
                                          
  3.8  - written by DOUG LUTTRELL on 22/Aug/16.  Based on the TKinfoBoxR.i code in sync with 
            the TKtestresR-2.html.  Marked by 3dot8.
            
  3.81 - written by DOUG LUTTRELL on 11/Aug/17.  Not really checking the logic, just updating for compliation sake 
            with the change to CMC structure (Version 12).  Marked by 381.          
                                                      
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/*DEFINE VARIABLE v-include-error  AS INTEGER   INITIAL 0 NO-UNDO.*/
/*DEFINE VARIABLE v-html-counter   AS INTEGER   INITIAL 0 NO-UNDO.*/
/*                                                                */
DEFINE VARIABLE v-hold-date-col  AS CHARACTER NO-UNDO.                                  /* 381 */
/*DEFINE VARIABLE v-hold-lab-proc  AS CHARACTER NO-UNDO.          */
/*DEFINE VARIABLE v-hold-lab-rcvd  AS CHARACTER NO-UNDO.          */
/*DEFINE VARIABLE v-hold-date-comp AS CHARACTER NO-UNDO.          */
/*DEFINE VARIABLE v-hold-status    AS CHARACTER NO-UNDO.          */
 
/* ********************  Preprocessor Definitions  ******************** */

/* * {1} = TK_mstr.TK_ID * in some form * */ 
/* * {2} = people_mstr.people_ID * in some form * */
/* * {3} = tk_mstr.tk_test_type * in some form * */

/* ***************************  Main Block  *************************** */


FIND people_mstr WHERE 
    people_mstr.people_id = {2} AND 
    people_mstr.people_deleted = ?
    NO-LOCK NO-ERROR.
    
IF AVAILABLE (people_mstr) THEN 
DO: 

    IF V-ITMESSAGE = YES THEN  
        {&OUT}
            "<H3>TK ID = " {1} "</H3>" SKIP
            "<H3>Patient ID = " {2} "</H3>" SKIP.
            
    {&OUT}
        "<center>" SKIP 
        "<div class='row'>" SKIP
        "<div class='grid_1'></div>     <!-- spacer DIV -->" SKIP
        "<div class='grid_10'>" SKIP
        "<div class='pancake'>" SKIP
        "   <table>" SKIP                                                 
        "       <thead>" SKIP
        "           <tr>" SKIP
        "               <th colspan=5>"                                                                                 /* 3dot8 */ 
            people_mstr.people_firstname " " people_mstr.people_lastname "'s " CAPS({1}) "</th>" SKIP      /* 1dot2 */
        "           </tr>" SKIP
        "       </thead>" SKIP
        "       <tr>" SKIP
        "           <td width='21%'>Date Of Birth</td>" SKIP
/*        "           <td>Customer Paid</td>" SKIP                                                                        /* 3dot8 */*/
        "           <td width='26%'>Lab Sample ID</td>" SKIP
        "           <td width='12%'>Test Type</td>" SKIP
        "           <td width='17%'>Date Collected</td>" SKIP
        "           <td width='24%'>Lab Processed <BR> (Lab Completed)</td>" SKIP                              /* 3dot4 */
/*        "           <td>HHI Processed</td>" SKIP                                                                        /* 3dot8 */*/
/*        "           <td>HHI Completed</td>" SKIP                                                /* 3dot4 */             /* 3dot8 */*/
/*        "           <TD>Last Action</TD>" SKIP                                                  /* 1dot2 */             /* 3dot8 */*/
/*        "           <td>Current Status</td>" SKIP                                               /* 1dot2 */             /* 3dot8 */*/
        "       </tr>" SKIP.
    /*        "       <tr>" SKIP.                                                                   /* 1dot2 */ */

    FIND TK_mstr WHERE                    /* the fact that this is a find first may eventually cause problems */
        TK_mstr.TK_ID = {1} AND                 /* if the different sequences of a */
        TK_mstr.TK_test_seq = {4} AND                                                               /* 3dot7 */
        TK_mstr.TK_patient_ID = {2} AND         /* test kit have different dates on when they are completed and what not */
        TK_mstr.TK_test_type = {3} AND                                                              /* 3dot7 */
        TK_mstr.TK_deleted = ?
        NO-LOCK NO-ERROR.                   /* 1dot2 */
        
    IF AVAILABLE (TK_mstr) THEN DO:

        ASSIGN  
            v-hold-date-col  = "Date Collected N/A"
            v-hold-lab-proc  = "Lab Processed N/A" 
            v-hold-lab-rcvd  = "HHI Processed N/A"
            v-hold-date-comp = "Date Completed N/A"
            v-hold-status    = "Status N/A".

/*        {&OUT}                                                                                                 */
/*            "<!-- TK_mstr avail, Pre trh_hist -->" SKIP.                                            /* 1dot2 */*/

        FOR EACH trh_hist WHERE
            trh_hist.trh_item = TK_mstr.TK_test_type AND 
            trh_hist.trh_serial = TK_mstr.TK_ID AND
            trh_hist.trh_sequence = TK_mstr.TK_test_seq AND 
            trh_hist.trh_deleted = ? NO-LOCK
                BREAK BY trh_hist.trh_date BY trh_hist.trh_ID:                                      /* 371 */
                
            IF trh_hist.trh_action = "COLLECTED" AND 
                trh_hist.trh_date <> ? THEN                                                         /* 371 */
/*                ASSIGN v-hold-date-col = STRING(trh_hist.trh_create_date).*/
                ASSIGN v-hold-date-col = STRING(trh_hist.trh_date).                                 /* 371 */

                
            ELSE IF trh_hist.trh_action = "LAB_PROCESS" AND                                         /* 371 */ 
                    trh_hist.trh_date <> ? THEN                                                     /* 371 */
/*                    ASSIGN v-hold-lab-proc = STRING(trh_hist.trh_create_date).*/
                    ASSIGN v-hold-lab-proc = STRING(trh_hist.trh_date).                             /* 371 */


            ELSE IF trh_hist.trh_action = "PROCESSED" AND 
                    trh_hist.trh_date <> ? THEN                                                     /* 371 */
/*                    ASSIGN v-hold-lab-rcvd = STRING(trh_hist.trh_create_date).*/
                    ASSIGN v-hold-lab-rcvd = STRING(trh_hist.trh_date).                             /* 371 */
                    
            
            ELSE IF trh_hist.trh_action = "COMPLETE" AND                                            /* 371 */
                    trh_hist.trh_date <> ? THEN                                                     /* 371 */
/*                    ASSIGN v-hold-date-comp = STRING(trh_hist.trh_create_date).*/
                    ASSIGN v-hold-date-comp = STRING(trh_hist.trh_date).                            /* 371 */

      
            ASSIGN                                                                                  /* 371 */
                v-hold-status = trh_hist.trh_action.                                                /* 371 */
            
        END. /*** of the trh_hist 4ea ***/  
                      
                      
                      /***** this isn't necessarily finding the correct record.  Need to command it to sort a specific way. ****/
                      /** Commented out in 371 to support change **/
/*        FIND LAST trh_hist WHERE                                                                       */
/*            trh_hist.trh_item = TK_mstr.TK_test_type AND                                               */
/*            trh_hist.trh_serial = TK_mstr.TK_ID AND                                                    */
/*            trh_hist.trh_deleted = ?                                                                   */
/*                NO-LOCK NO-ERROR.                                                           /* 1dot2 */*/
/*                                                                                                       */
/*        IF AVAILABLE (trh_hist) THEN                                                                   */
/*            ASSIGN v-hold-status = trh_hist.trh_action.                                                */
        
        {&OUT}
            "       <TR>" SKIP                                                              /* 1dot2 */                                               
            "           <td>" people_mstr.people_DOB "</td>" SKIP
/*            "           <td>" TK_mstr.TK_cust_paid "</td>" SKIP                                                 /* 3dot8 */*/
            "           <td>" TK_mstr.TK_lab_sample_ID "</td>" SKIP
            "           <td>" TK_mstr.TK_test_type "</td>" SKIP
            "           <td>" v-hold-date-col "</td>" SKIP
            "           <td>" v-hold-lab-proc "</td>" SKIP
/*            "           <td>" v-hold-lab-rcvd "</td>" SKIP                                                      /* 3dot8 */*/
/*            "           <td>" v-hold-date-comp "</td>" SKIP                                                     /* 3dot8 */*/
/*            "           <td>" v-hold-status "</td>" SKIP                                                        /* 3dot8 */*/
/*            "           <td>" tk_mstr.tk_status "</td>" SKIP                                /* 1dot2 */         /* 3dot8 */*/
            "       </tr>" SKIP
            "   </table>" SKIP
            "</div> <!-- of class=pancake -->" SKIP
            "</div> <!-- of class=grid_10 -->" SKIP
            "<div class='grid_1'></div>     <!-- spacer DIV -->" SKIP
            "</div> <!-- of class=row -->" SKIP(1)
            "<br>" SKIP 
            "</center>" SKIP.   

    END. /*** of if avail TK_mstr ***/

    ELSE DO: 
        
        ASSIGN 
            v-include-error = 2.
    
        {&OUT}
            "           <td>Not Available</td>" SKIP
            "           <td>Not Available</td>" SKIP
            "           <td>Not Available</td>" SKIP
            "           <td>Not Available</td>" SKIP
/*            "           <td>Not Available</td>" SKIP                                                            /* 3dot8 */*/
/*            "           <td>Not Available</td>" SKIP                                                            /* 3dot8 */*/
/*            "           <td>Not Available</td>" SKIP                                                            /* 3dot8 */*/
/*            "           <td>Not Available</td>" SKIP                                                            /* 3dot8 */*/
            "       </tr>" SKIP
            "   </table>" SKIP 
            "</div> <!-- of class=pancake -->" SKIP
            "</div> <!-- of class=grid_10 -->" SKIP
            "<div class='grid_1'></div>     <!-- spacer DIV -->" SKIP
            "</div> <!-- of class=row -->" SKIP
            "<br>" SKIP 
            "</center>" SKIP. 

    END. /*** of else do: [not avail tk_mstr] ***/

END. /*** of if avail people_mstr ***/

ELSE 
    ASSIGN v-include-error = 1.

IF v-include-error <> 0 THEN 
    {&OUT} "<p>" v-include-error "</p>".
    
/* ***********************  End of Line  ************************ */
  

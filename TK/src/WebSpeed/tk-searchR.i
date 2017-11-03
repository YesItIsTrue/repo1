
/*------------------------------------------------------------------------
    File        : tk-searchR.i
    Purpose     : 

    Syntax      :

    Description : Contains user feedback table for search result for the test kit inquiry (TK_TKKit_searc.html)

    Author(s)   : Mark Jacobs
    Created     : Tue Feb 24 15:48:42 EST 2015
    Notes       :
 
 -----------------------------------------------------------------------
 
 Revision History:
 -----------------
 1.0  -  written by MARK JACOBS on 24/Feb/15.  Original Version.
 1.1  -  written by DOUG LUTTRELL on 08/Oct/15.  Tweaked the hyperlink 
            to point to the proper place.
 1.2  -  written by DOUG LUTTRELL on 03/Oct/17.  Changed hyperlinks (again)
            to not specify specific directories but to depend on the 
            PROPATH settings.  This is in accordance with the directory
            changes of Release 12 (CMC structure).  Not marked.
 
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


      {&OUT}
       "<tr>"       
            "<td></td>" SKIP   
            "<td nowrap>" "<a href=~"TRH-history-R.r?h-low-serial=" TK_ID  "&h-high-serial=" Tk_ID "&h-low-seq=" TK_test_seq "&h-high-seq=" TK_test_seq "&whattorun=1.41&h-act=1~">" TK_ID "</a> / " TK_test_seq  " </td>" SKIP
            "<td>" Tk_test_type "</td>" SKIP            
      /*      "<td>" TK_test_seq "</td>" SKIP      */ 
            "<td>" TK_mstr.TK_lab_sample_ID  " / " TK_mstr.TK_lab_seq  " </td>"    /* 2dot3 */
            "<td>" Tk_create_date "</td>"  SKIP    /** Commented out on 1/6/15... Uncommented out on 2/17/15 **/
            "<td>" TK_modified_date "</td>" SKIP.  /** Commented out on 2/17/15** Uncommented out 2/17/15 **/    
            
                IF TK_mstr.TK_domestic = ? THEN  /*** Domestic IF Block ***/
      {&OUT} 
            "<td>" "</td>" SKIP.
                ELSE
      {&OUT}      
            "<td>" TK_mstr.TK_domestic FORMAT "Dom/Intl" "</td>" SKIP.
            
                IF TK_mstr.TK_prof = ? THEN       /*** Professional IF block ***/
      {&OUT} 
            "<TD>" "</td>" SKIP. 
                ELSE
      {&OUT}          
            "<td>" TK_mstr.Tk_prof "</td>" SKIP.
            
                IF TK_mstr.TK_cust_paid = ? THEN   /*** Customer paid IF block ***/
      {&OUT}
            "<td>" "</td>" SKIP.
                ELSE
      {&OUT}
            "<td>"TK_mstr.TK_cust_paid "</td>" SKIP.       
      {&OUT}        
            "<td>" Tk_status "</td>" SKIP. 
            
             IF AVAILABLE (peop-pat-buf) THEN DO:                         /* Patient look up */
      {&OUT}
            "<td nowrap><a href=~"PATmainviewR.r?h-act=SELECTED&h-peopleid=" peop-pat-buf.people_id "&whattorun=3.11 "~" > " peop-pat-buf.people_lastname ", " peop-pat-buf.people_firstname "</a></TD>" SKIP . 
            
            END.  /* IF AVAILABLE (peop-pat-buf) THEN DO:  */
            
            ELSE
            
      {&OUT} 
            "<td></td>" SKIP.  
  
             IF AVAILABLE (peop-cust-buf) THEN DO:                     /* Customer look up */
             
             
           /*     FIND peop-cust-buf WHERE peop-cust-buf.people_id = cust_mstr.cust_id NO-LOCK NO-ERROR.         
                  FIND people_mstr WHERE people_mstr.people_id = cust_id NO-LOCK.   */
                                           
                ASSIGN
                cust-fname = peop-cust-buf.people_firstname
                cust-lname = peop-cust-buf.people_lastname.
           
           {&OUT} 
            "<td nowrap>"
                 "<a href='PEOPmaintU.r?"                                      /* 2dot3 */
                 "h-people_id=" peop-cust-buf.people_id                                              /* 2dot3 */
                 "&h-act=EDIT"                                                                     /* 2dot3 */
                 "&whattorun=35.99'>"                                                              /* 2dot3 */ 
             cust-lname ", " cust-fname "</a></td></tr>" SKIP.

/*            "<a href=TK_custupdate.r?f-name=" peop-cust-buf.people_firstname "&l-name=" peop-cust-buf.people_lastname                    */
/*            "&h-cust-id=" peop-cust-buf.people_id "&e-mail=" peop-cust-buf.people_email "&h-keep-going=YES&h-first-stop=1&whattorun=2.3>"*/
            
             END. /* IF AVAILABLE (cust_mst) THEN DO: */
         
           ELSE
           
            {&OUT} "<td></td></tr>" SKIP.
   
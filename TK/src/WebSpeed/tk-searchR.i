
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
 1.21 - written by DOUG LUTTRELL on 20/Oct/17.  Something still not correct
            with logicals down through this program tree.  Hyperlinks
            may be wonky too.  Not marked.
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


      {&OUT}
       "<tr>"       
            "<td nowrap>" 
                "<a href='TRH-history-R.r?h-low-serial=" TK_ID  
                    "&h-high-serial=" Tk_ID 
                    "&h-low-seq=" TK_test_seq 
                    "&h-high-seq=" TK_test_seq 
                    "&whattorun=1.41&h-act=1'>" 
                    TK_ID 
                "</a> / " TK_test_seq  
            "</td>" SKIP
            "<td>" TK_mstr.Tk_test_type "</td>" SKIP            
            "<td>" TK_mstr.TK_lab_sample_ID  " / " TK_mstr.TK_lab_seq  " </td>"
            "<td>" TK_mstr.Tk_create_date "</td>"  SKIP 
            "<td>" TK_mstr.TK_modified_date "</td>" SKIP.    
            
    IF TK_mstr.TK_domestic = ? THEN 
        {&OUT} 
            "<td></td>" SKIP.
    ELSE
        {&OUT}      
            "<td>" TK_mstr.TK_domestic FORMAT "Dom/Intl" "</td>" SKIP.
            
    IF TK_mstr.TK_prof = ? THEN 
        {&OUT} 
            "<TD>" "</td>" SKIP. 
    ELSE
        {&OUT}          
            "<td>" TK_mstr.Tk_prof "</td>" SKIP.
            
    IF TK_mstr.TK_cust_paid = ? THEN 
        {&OUT}
            "<td>" "</td>" SKIP.
    ELSE
        {&OUT}
            "<td>" TK_mstr.TK_cust_paid "</td>" SKIP.   
                
        {&OUT}        
        "<td>" Tk_status "</td>" SKIP.
        
    IF AVAILABLE (people_mstr2) THEN
        {&OUT}
            "<td>" people_mstr2.people_firstname + " " + people_mstr2.people_lastname "</td>" SKIP.
    ELSE 
        {&OUT}
            "<td></td>" SKIP.
            
    IF AVAILABLE (people_mstr3) THEN
        {&OUT} 
            "<td>" people_mstr3.people_firstname + " " + people_mstr3.people_lastname "</td>" SKIP.
    ELSE 
        {&OUT}
            "<td></td>" SKIP.
            
    {&OUT}
        "</tr>" SKIP.
   
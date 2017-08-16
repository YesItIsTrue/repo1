
/*------------------------------------------------------------------------
    File        : TLsecmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : Form for the TLsecmaintU code

    Author(s)   : Doug Luttrell
    Created     : Wed Oct 08 19:17:15 EDT 2014
    Notes       :
        
        
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.3">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="08/Oct/14">
    <META NAME="LAST_UPDATED" CONTENT="19/Nov/15">
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
  
  ***********************************************************************  
  REVISION HISTORY:
  -----------------
  1.0 - written by DOUG LUTTRELL on 08/Oct/14.  Original Version.
  1.1 - written by DOUG LUTTRELL on 19/Nov/14.  
  1.2 - written by DOUG LUTTRELL on 26/Jan/15.  Changed to use the new CSS grid, etc.
  1.3 - written by DOUG LUTTRELL on 19/Nov/15.  Changed Form
  ***********************************************************************
    
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<div class='row'>" SKIP 
    "<div class='grid_3'> </DIV>" SKIP
    "<DIV class='grid_6'>" SKIP
    "<FORM>" SKIP 
    "<DIV class='table_col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=2>Test Layout {6} (Sections)</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Test Type</TD>" SKIP 
    "       <TD class='REQ'>" SKIP.
    
IF "{2}" = "DISABLED" THEN 
    {&OUT}
        "<input type='hidden' name='h-testtype' value='" testtype "' />" SKIP 
        testtype "</td>" SKIP.
        
ELSE DO: 
        
    {&OUT}
        "           <select name='h-testtype' value='" testtype "' {2} >" SKIP.
        
    FOR EACH test_mstr WHERE 
        (test_mstr.test_starteff <= TODAY OR
         test_mstr.test_starteff = ?) AND 
        (test_mstr.test_endeff >= TODAY OR 
         test_mstr.test_endeff = ?) AND 
        test_mstr.test_deleted = ? NO-LOCK 
            BY test_mstr.test_type: 
                
        IF test_mstr.test_type = testtype THEN 
                thismarker  = "SELECTED".
            ELSE 
                thismarker  = "".
                
            {&OUT}
                "               <option value='" test_mstr.test_type "' " thismarker " >" test_mstr.test_type "</option>" SKIP.
                
    END.    /** of 4ea test_mstr **/            
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
            
END.  /** of else do --- {2} <> "DISABLED" **/

{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Test Section Description</TD>" SKIP
    "       <TD class='REQ'>" SKIP.
    
IF "{3}" = "DISABLED" THEN 
    {&OUT}
        /*
        "<input type='hidden' name='h-testtype' value='" testtype "' />" SKIP 
        */
        "<input type='hidden' name='h-sectid' value='" sectid "' />" SKIP 
        "<input type='hidden' name='h-sectdesc' value='" sectdesc "' />" SKIP       
        sectdesc "</td>" SKIP.
        
ELSE DO:  
     
    {&OUT}
        "           <select name='h-sectid' value='" sectid "' {3} >" SKIP.
    
    IF "{5}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=''> </option>" SKIP.
            
    FOR EACH tl_mstr WHERE tl_mstr.tl_testtype = testtype AND 
        tl_mstr.tl_deleted = ? NO-LOCK
            BY tl_mstr.tl_testtype BY tl_mstr.tl_section_desc: 
        
        IF tl_mstr.tl_sect_id = sectid THEN 
            ASSIGN 
                thismarker  = "SELECTED"
                sectdesc    = tl_mstr.tl_section_desc. 
        ELSE 
            thismarker  = "".
            
        {&OUT}
            "               <option value='" tl_mstr.tl_sect_id "' " thismarker " > " tl_mstr.tl_section_desc " </option>" SKIP.
            
    END.  /** of 4ea. tl_mstr **/
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.        
            
END.  /*** of else do --- {3} = DISABLED ***/
        
{&OUT}        
    "   </TR>" SKIP
/***
    "   <TR>" SKIP
    "       <TD>Section Description</TD>" SKIP
    "       <TD>" SKIP 
    "           <input type='text' size=60 name='h-sectdesc' value='" sectdesc "' {4} />" SKIP
    "       </TD>" SKIP
    "   </TR>" SKIP
***/
    
    "   <TR>" SKIP
    "       <TD>Start Effective Date</TD>" SKIP
    "       <TD><input type='date' name='html5-start' value='" disp-start "' {4} /></TD>" SKIP                                    /* 1dot4 */
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>End Effective Date</TD>" SKIP
    "       <TD><input type='date' name='html5-end' value='" disp-end "' {4} /></TD>" SKIP                                        /* 1dot4 */   
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Sort Order</TD>" SKIP
    "       <TD><input type='number' name='h-sortorder' value='" sortorder "' {4} /></TD>" SKIP
    "   </TR>" SKIP   
    "</TABLE>" SKIP
    "</DIV>         <!-- end of table_report -->" SKIP 
    "</DIV>     <!-- end of grid_6 -->" SKIP 
    "<DIV class='grid_3'> </DIV>" SKIP
    "</DIV>     <!-- end of row -->" SKIP.
    
                                                                                IF ITshowmsg = YES THEN 
                                                                                    {&OUT}
                                                                                        "Section ID = " sectid SKIP.

IF "{1}" = "FIND SECTION" THEN                                                                                                  /* 1dot3 */   
    {&OUT}                                                                                                                      /* 1dot3 */
    "<BR>"                                                                                                                      /* 1dot3 */                                                              
    "<div class='row'>" SKIP                                                                                                    /* 1dot3 */
    "   <div class='grid_3'> </DIV>" SKIP                                                                                       /* 1dot3 */
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                          /* 1dot3 */
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP                 /* 1dot3 */
    "   <div class='grid_2'> </DIV>" SKIP                                                                                       /* 1dot3 */
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='PROMPT' class='btn'>Add New Section to this Test</BUTTON></div>" SKIP /* 1dot3 */
    "   <div class='grid_3'> </DIV>" SKIP                                                                                       /* 1dot3 */
    "</div>" SKIP.                                                                                                              /* 1dot3 */
    
ELSE                                                                                                                            /* 1dot3 */
{&OUT}                                                                                                                          /* 1dot3 */
    "<BR>" SKIP                                                                                                                 /* 1dot3 */
    "<div class='row'>" SKIP                                                                                                    /* 1dot3 */                                                     
    "   <div class='grid_5'> </DIV>" SKIP                                                                                       /* 1dot3 */ 
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                          /* 1dot3 */              
    "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP                 /* 1dot3 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                                       /* 1dot3 */
    "</div>" SKIP.                                                                                                              /* 1dot3 */

/* *** removed in 1dot3 ***        
{&OUT}        
    "<div class='row'>" SKIP
    "<div class='grid_4'> </DIV>" SKIP
    "<DIV class='grid_4'>" SKIP 
    "<center>" SKIP
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                      /* 1dot1 */    
    "<INPUT type='hidden' name='h-act' value='{1}' />" SKIP
/*    "<DIV class='button'>{1}</DIV>" */
    "<INPUT type='submit' name='Submit' value='{1}' />" SKIP.

    
IF "{1}" = "FIND SECTION" THEN                                                                                              /* 1dot1 */
    {&OUT}                                                                                                                  /* 1dot1 */
        "<button type='submit' name='h-sectid' value='0'>Add a New Section to this Test</button>"  SKIP.                    /* 1dot1 */
        
{&OUT}
    "</DIV>" SKIP
    "<DIV class='grid_4'> </DIV>" SKIP
    "</DIV>     <!-- end of row -->" SKIP
    "</center>" SKIP
    "</DIV>" SKIP
    *** end of removal *** */
{&OUT}    
    "</FORM>" SKIP.
    
    
    
/*****************************  End of File  *********************************/    
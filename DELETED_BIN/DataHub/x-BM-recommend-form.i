
/*------------------------------------------------------------------------
    File        : BM-recommend-form.i
    Purpose     : 

    Syntax      : passing optional paraments via .i magic as follows:
        {1} = what you want the next action to be
        {2} = intended to be the "disabled" HTML parameter    
        

    Description : HTML screen layout.

    Author(s)   : Doug Luttrell
    Created     : Wed Sep 03 07:04:20 EDT 2014
    Notes       :
        
    <TITLE>Test Recommendation Maintenance</TITLE>
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="03/Sep/13">
    <META NAME="LAST_UPDATED" CONTENT="26/Oct/14">    
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/table.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/quinton2.css' />        
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT} 
    "<FORM method='post'>" SKIP 
    "<DIV class='table_2col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP 
    "       <TH colspan=4>Test Recommendation Maintenance</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Test Type</TD>" SKIP 
    "       <TD class='REQ'>" SKIP .
    
    
IF "{2}" = "DISABLED" THEN DO: 
    {&OUT}
        "<input type='hidden' name='h-testtype' value='" testtype "' />" SKIP 
        testtype SKIP.
        
    IF ITshowmsg = YES THEN 
        {&OUT} 
            " up top OK " SKIP. 
        
    {&OUT}
        "</td>" SKIP.    
        
END.  /** of if 2 = disabled **/

ELSE DO:                                                                        /** inside INITIAL **/
        
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
                "               <option value=~'" test_mstr.test_type "~' " thismarker " > " test_mstr.test_type " </option>" SKIP.
                
    END.    /** of 4ea test_mstr **/            
  

    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
    
END.  /*** of else do -- INITIAL ***/

{&OUT}    
    "       <TD>Test Item (Marker)</TD>" SKIP
    "       <TD class='REQ'>" SKIP.
    
    
     
IF "{3}" = "DISABLED" THEN DO: 
    
    {&OUT}
        /*
        "<input type='hidden' name='h-testtype' value='" testtype "' />" SKIP 
        "<input type='hidden' name='h-sectid' value=" sectid " />" SKIP        
        
        "<input type='hidden' name='h-sectdesc' value='" sectdesc "' />" SKIP       
        sectdesc 
        */
        "<input type='hidden' name='h-itemid' value='" itemid "' />" SKIP.
        
    IF "{1}" = "FIND TEST" THEN
        
        {&OUT}
            "<select name='h-tempdropdown' value='" marker_item "' DISABLED >" SKIP         /* 1dot1 */
            "   <option value=~'" marker_item "~' SELECTED >" marker_item "</option>" SKIP  /* 1dot1 */
            "</select>" SKIP.                                                               /* 1dot1 */
/*            "<select name='h-tempdropdown' value='" markitem "' DISABLED >" SKIP    */
/*            "   <option value=~'" markitem "~' SELECTED >" markitem "</option>" SKIP*/
/*            "</select>" SKIP.                                                       */
            
    ELSE 
        {&OUT}
              marker_item skip.
/*            markitem SKIP.*/

    IF ITshowmsg = YES THEN  
        {&OUT} 
            " 3 = DISABLED " SKIP. 
        
    {&OUT}
        "</td>" SKIP.        
        
END.  /** of if 4 = disabled **/        
        
ELSE DO:                                                                        /** inside FIND SECTION **/
     
    {&OUT}
        "           <select name='h-itemid' value=" itemid " {3} >" SKIP.
       
    FOR EACH tl_mstr WHERE tl_mstr.tl_testtype = testtype AND 
            (tl_mstr.tl_start_eff <= starteff OR
             starteff = ?) AND
            (tl_mstr.tl_end_eff >= endeff OR 
             endeff = ?) AND
            tl_mstr.tl_deleted = ? NO-LOCK,
        EACH tld_det WHERE tld_det.tld_sect_id = tl_mstr.tl_sect_id AND 
            
            (tld_det.tld_start_eff <= starteff OR 
             starteff = ?) AND 
            (tld_det.tld_end_eff >= endeff OR 
             endeff = ?) AND 
            tld_det.tld_deleted = ? NO-LOCK,
        FIRST marker_list WHERE marker_list.marker_ID = tld_det.tld_item_ID AND /* 1dot1 */
        marker_list.marker_deleted = ? NO-LOCK                                  /* 1dot1 */ 
/*                BY tld_det.tld_item_name:*/
            BY marker_list.marker_item:                                         /* 1dot1 */   
            
        IF marker_list.marker_item = marker_item THEN                           /* 1dot1 */       
/*        IF tld_det.tld_item_name = markitem THEN*/
            ASSIGN 
                thismarker  = "SELECTED".
        ELSE 
            ASSIGN 
                thismarker  = "".
            
        {&OUT}
        "               <option value=~'" tld_det.tld_item_ID "~' " thismarker " > " marker_list.marker_item " </option>" SKIP. /* 1dot1 */
/*            "               <option value=~'" tld_det.tld_item_ID "~' " thismarker " > " tld_det.tld_item_name " </option>" SKIP.*/
            
    END.  /** of 4ea. tl_mstr **/
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.        
            
END.  /*** of else do --- {3} = DISABLED ***/

        
{&OUT}        
    "   </TR>" SKIP.    
    
    
{&OUT}    
    "   <TR>" SKIP
    "       <TD>Range Start</TD>" SKIP
    "       <TD><INPUT type='number' name='h-startrange' value='" startrange "' step='.01' {4} /></TD>" SKIP
    "       <TD>Range End</TD>" SKIP
    "       <TD><INPUT type='number' name='h-endrange' value='" endrange "' step='.01' {4} /></TD>" SKIP
    "   </TR>" SKIP
    
    /*** uncomment if using effectivity date ranges ***
    "   <TR>" SKIP
    "       <TD>Start Effective Date</TD>" SKIP
    "       <TD><INPUT type='date' name='h-starteff' value='" starteff "' {4} /></TD>" SKIP
    "       <TD>End Effective Date</TD>" SKIP
    "       <TD><INPUT type='date' name='h-endeff' value='" endeff "' {4} /></TD>" SKIP
    "   </TR>" SKIP
    *******************/
    
    "   <TR>" SKIP
    "       <TD>Recommendation / Supplement</TD>" SKIP
    "       <TD class='REQ'>" SKIP
    "           <select type='select' name='h-recommendation' value='" recommendation "' {4} />" SKIP
    "               <option value=0>NOTES ONLY</option>" SKIP.
    
FOR EACH suppl_list NO-LOCK: 
    
    {&OUT}
        "               <option value=" suppl_list.suppl_id ">" suppl_list.suppl_name "</option>" SKIP.

END.        /** of 4ea. **/
    
{&OUT}
    "           </select>" SKIP
    "       </TD>" SKIP  
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Dosage</TD>" SKIP
    "       <TD>From: <INPUT type='number' name='h-from-dosage' value='" from-dosage "' step='.25' {5} />" SKIP       /* 1dot1 */
    "       <BR>To: <INPUT type='number' name='h-to-dosage' value='" to-dosage "' step='.25' {5} /></TD>" SKIP      /* 1dot1 */   
/*    "       <TD><INPUT type='number' name='h-dosage' value='" dosage "' step='.01' {5} /></TD>" SKIP*/
    "       <TD>Unit of Measure</TD>" SKIP
    "       <TD>" SKIP
    "           <select name='h-uom' value='" uom "' {5} >" SKIP
    "               <option value='PILL' >PILL</option>" SKIP
    "               <option value='SPRAY' >SPRAY</option>" SKIP
    "               <option value='TBSP' >TABLESPOON</option>" SKIP
    "               <option value='TSP' >TEASPOON</option>" SKIP
    "           </select>" SKIP
    "       </td>" SKIP
    "   </TR>" SKIP   
    "   <TR>" SKIP
    "       <TD>Notes</TD>" SKIP
    "       <TD colspan=3><INPUT type='text' name='h-notes' value='" notes "' maxlength=200 placeholder='Eat with bacon' size=100 {5} /></TD>" SKIP
    "   </TR>" SKIP    
    "   <TR>" SKIP
    "       <TD>Sort Order</TD>" SKIP
    "       <TD><INPUT type='number' name='h-sortorder' value='" sortorder "' {5} /></TD>" SKIP
    "       <TD>Ignore for Groups?</TD>" SKIP
    "       <TD>" SKIP
    "           <INPUT type='checkbox' name='h-ignore' value='" ignore "' {5} />" SKIP
    "       </TD>" SKIP
    "   </TR>" SKIP     
    "</TABLE>" SKIP
    "<center><INPUT type='hidden' name='h-act' value='{1}' />" SKIP
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP
    "<INPUT type='submit' name='Submit' value='{1}' /></center>" SKIP
    "</DIV>" SKIP
    "</FORM>" SKIP.
    

    
/*******************************************   End of File.  ********************************************/
     
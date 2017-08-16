
/*------------------------------------------------------------------------
    File        : TLitemmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : Form for the TLitemmaintU code

    Author(s)   : Doug Luttrell
    Created     : Wed Oct 09 10:17:15 EDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<FORM method='post' id='TLrecmaintU-form'>" SKIP 
    "<DIV class='table_2col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=4>Test Recommendation Maintenance</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Test Type</TD>" SKIP 
    "       <TD class='REQ'>" SKIP.
    
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
            
END.  /** of else do --- {2} <> "DISABLED" **/

    
/**************************

{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Test Section</TD>" SKIP
    "       <TD class='REQ'>" SKIP.

    
IF "{3}" = "DISABLED" THEN DO: 
     
    {&OUT}
        "<input type='hidden' name='h-sectid' value=" sectid " />" SKIP 
        "<input type='hidden' name='h-sectdesc' value=~'" sectdesc "~' />" SKIP       
        sectdesc.
        
    IF ITshowmsg = YES THEN 
        {&OUT} 
            " 3 = DISABLED " SKIP. 
        
    {&OUT}
        "</td>" SKIP.
        
END.  /*** of if 3 = disabled ***/        
        
ELSE DO:                                                                        /** inside FIND TEST **/
     
    {&OUT}
        "           <select name='h-sectid' value=" sectid " {3} >" SKIP.
   
   /** 
    IF "{7}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=0>Add a New Section to this Test</option>" SKIP.
      **/
      
            
    FOR EACH tl_mstr WHERE tl_mstr.tl_testtype = testtype AND 
        (tl_mstr.tl_start_eff <= starteff OR 
         starteff = ?) AND 
        (tl_mstr.tl_end_eff >= endeff OR 
         endeff = ?) AND 
        tl_mstr.tl_deleted = ? NO-LOCK
            BY tl_mstr.tl_testtype BY tl_mstr.tl_section_desc: 
        
        IF tl_mstr.tl_ID = sectid THEN 
            ASSIGN 
                thismarker  = "SELECTED"
                sectdesc    = tl_mstr.tl_section_desc.
        ELSE 
            thismarker  = "".
            
        {&OUT}
            "               <option value=" tl_mstr.tl_ID " " thismarker " > " tl_mstr.tl_section_desc " </option>" SKIP.
            
    END.  /** of 4ea. tl_mstr **/
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.        
            
END.  /*** of else do --- {3} = DISABLED ***/

*************/
        
{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Item / Marker</TD>" SKIP
    "       <TD class='REQ'>" SKIP.        
        
IF "{4}" = "DISABLED" THEN DO: 
    {&OUT}
        /*
        "<input type='hidden' name='h-testtype' value='" testtype "' />" SKIP 
        "<input type='hidden' name='h-sectid' value=" sectid " />" SKIP        
        "<input type='hidden' name='h-sectdesc' value='" sectdesc "' />" SKIP       
        sectdesc 
        */.

    IF ITshowmsg = YES THEN 
        {&OUT} 
            " 4 = DISABLED " SKIP. 
        
    {&OUT}
        "</td>" SKIP.        
        
END.  /** of if 4 = disabled **/        
        
ELSE DO:                                                                        /** inside FIND SECTION **/
     
    {&OUT}
        "           <select name='h-markitem' value=" markitem " {4} >" SKIP.
   
 
    IF "{7}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=''>Add a New Item (Marker) to this Test</option>" SKIP.

      
    
    FOR EACH tld_det WHERE tld_det.tld_id = sectid AND 
        (tld_det.tld_start_eff <= starteff OR 
         starteff = ?) AND 
        (tld_det.tld_end_eff >= endeff OR 
         endeff = ?) AND 
        tld_det.tld_deleted = ? NO-LOCK 
            BY tld_det.tld_item:
                
        IF tld_det.tld_item = markitem THEN 
            ASSIGN 
                thismarker  = "SELECTED".
        ELSE 
            ASSIGN 
                thismarker  = "".
            
        {&OUT}
            "               <option value=~'" tld_det.tld_item "~' " thismarker " > " tld_det.tld_item " </option>" SKIP.
            
    END.  /** of 4ea. tl_mstr **/
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.        
            
END.  /*** of else do --- {4} = DISABLED ***/

{&OUT}
    "   </TR>" SKIP.
    

        
{&OUT}        
    "   </TR>" SKIP
   "   <TR>" SKIP
    "       <TD>Start Effective Date</TD>" SKIP
    "       <TD><input type='date' name='h-starteff' value=" starteff " {6} /></TD>" SKIP
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>End Effective Date</TD>" SKIP
    "       <TD><input type='date' name='h-endeff' value=" endeff " {6} /></TD>" SKIP    
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Sort Order</TD>" SKIP
    "       <TD><input type='number' name='h-sortorder' value=" sortorder " {6} /></TD>" SKIP
    "   </TR>" SKIP   
    "</TABLE>" SKIP.
    
                                                                                IF ITshowmsg = YES THEN 
                                                                                    {&OUT}
                                                                                        "Section ID = " sectid SKIP.
        
{&OUT}         
    "<center><INPUT type='hidden' name='h-act' value='{1}' />" SKIP
    "<INPUT type='submit' name='Submit' value='{1}' /></center>" SKIP
    "</DIV>" SKIP
    "</FORM>" SKIP.
    
    
    
/*****************************  End of File  *********************************/    
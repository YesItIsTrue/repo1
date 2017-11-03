
/*------------------------------------------------------------------------
    File        : TLitemmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : Form for the TLitemmaintU code 

    Author(s)   : Doug Luttrell
    Created     : Wed Oct 09 10:17:15 EDT 2014
    Notes       :
         
        
    <TITLE>Test Section Maintenance</TITLE>
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.2">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="09/Oct/14">
    <META NAME="LAST_UPDATED" CONTENT="19/Nov/14">    
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/table.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/quinton2.css' />
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ***************************  Main Block  *************************** */ 
{&OUT}
    "<FORM method='get' id='TLitemmaintU-form'>" SKIP 
    "<DIV class='row'>" SKIP
    "<DIV class='grid_1'> </DIV>" SKIP                                         
    "<DIV class='grid_10'>" SKIP 
    "<DIV class='table_2col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=4>Test Layout Detail {8} (Items)</TH>" SKIP
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
                "               <option value='" test_mstr.test_type "' " thismarker " > " test_mstr.test_type " </option>" SKIP.
                
    END.    /** of 4ea test_mstr **/            
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
            
END.  /** of else do --- {2} <> "DISABLED" **/

{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Test Section</TD>" SKIP
    "       <TD class='REQ'>" SKIP.
    
IF "{3}" = "DISABLED" THEN DO: 
     
    {&OUT}
        "<input type='hidden' name='h-sectid' value='" sectid "' />" SKIP 
        "<input type='hidden' name='h-sectdesc' value='" sectdesc "' />" SKIP       
        sectdesc.
        
    IF ITshowmsg = YES THEN 
        {&OUT} 
            " 3 = DISABLED " SKIP. 
        
    {&OUT}
        "</td>" SKIP.
        
END.  /*** of if 3 = disabled ***/        
        
ELSE DO:                                                                        /** inside FIND TEST **/
     
    {&OUT}
        "           <select name='h-sectid' value='" sectid "' {3} >" SKIP.      
            
    FOR EACH tl_mstr WHERE tl_mstr.tl_testtype = testtype AND 
        (tl_mstr.tl_start_eff <= starteff OR 
         starteff = ?) AND 
        (tl_mstr.tl_end_eff >= endeff OR 
         endeff = ?) AND 
        tl_mstr.tl_deleted = ? NO-LOCK
            BY tl_mstr.tl_testtype BY tl_mstr.tl_section_desc: 
        
        IF tl_mstr.tl_sect_ID = sectid THEN 
            ASSIGN 
                thismarker  = "SELECTED"
                sectdesc    = tl_mstr.tl_section_desc.
        ELSE 
            thismarker  = "".
            
        {&OUT}
            "               <option value='" tl_mstr.tl_sect_ID "' " thismarker " > " tl_mstr.tl_section_desc " </option>" SKIP.
            
    END.  /** of 4ea. tl_mstr **/
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.        
            
END.  /*** of else do --- {3} = DISABLED ***/
        
{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Item / Marker</TD>" SKIP
    "       <TD class='REQ'>" SKIP.        
        
IF "{4}" = "DISABLED" THEN DO: 
    {&OUT}
        "<input type='hidden' name='h-itemid' value='" itemid "' />" SKIP 
        "<input type='hidden' name='h-markitem' value='" markitem "' />" SKIP 
        markitem
        .

    IF ITshowmsg = YES THEN 
        {&OUT} 
            " 4 = DISABLED " SKIP. 
        
    {&OUT}
        "</td>" SKIP.        
        
END.  /** of if 4 = disabled **/        
        
ELSE DO:                                                                        /** inside FIND SECTION **/
     
    {&OUT}
        "           <select name='h-itemid' value='" markitem "' {4} >" SKIP.

 
    IF "{7}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=''> </option>" SKIP.                  /* 1dot2 */

      
    
    FOR EACH tld_det WHERE tld_det.tld_sect_id = sectid AND 
        (tld_det.tld_start_eff <= starteff OR 
         starteff = ?) AND 
        (tld_det.tld_end_eff >= endeff OR 
         endeff = ?) AND 
        tld_det.tld_deleted = ? NO-LOCK,
        EACH marker_list WHERE marker_list.marker_ID = tld_det.tld_item_ID NO-LOCK                                              /* 1dot8 */
/*            BY marker_list.marker_item:*/
            BY marker_list.marker_display:                                                                                      /* 1dot8 */
                 
        IF tld_det.tld_item_ID = itemid THEN          
            ASSIGN 
                thismarker  = "SELECTED".
        ELSE 
            ASSIGN 
                thismarker  = "".
        
        /* 1dot1 */    
        {&OUT}
        "               <option value='" tld_det.tld_item_id " " thismarker "' >" marker_list.marker_item "</option>" SKIP.  /* 1dot8 */
        /* 1dot1 */
            
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
    "       <TD><input type='date' name='html5-start' value='" disp-start "' {6} /></TD>" SKIP
    "   </TR>" SKIP 
    "   <TR>" SKIP
    "       <TD>End Effective Date</TD>" SKIP
    "       <TD><input type='date' name='html5-end' value='" disp-end "' {6} /></TD>" SKIP    
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Sort Order</TD>" SKIP
    "       <TD><input type='number' name='h-sortorder' value='" sortorder "' {6} /></TD>" SKIP
    "   </TR>" SKIP
    "   <tr>" SKIP
    "       <td>Bar Type</TD>" SKIP.
    
    IF bartype = "centerBar" THEN 
    
    {&OUT}
    "       <td>" SKIP
    "<input style='vertical-align:75%;' type='radio' name='h-bartype' value='centerBar' {6} checked />"
    "<img style='padding:5px;' src='/depot/src/HTMLContent/images/Center_Bar.PNG' alt='From Center Out'/>"
    "<br>"
    "<input style='vertical-align:75%;' type='radio' name='h-bartype' value='bar' {6} />"
    "<img style='padding:5px;' src='/depot/src/HTMLContent/images/Left2Right_Bar.PNG' alt='Left to right'/>" SKIP
    "       </td>" SKIP.
    
    ELSE IF bartype = "bar" THEN
    
    {&OUT}
    "       <td>" SKIP
    "<input style='vertical-align:75%;' type='radio' name='h-bartype' value='centerBar' {6} />"
    "<img style='padding:5px;' src='/depot/src/HTMLContent/images/Center_Bar.PNG' alt='From Center Out'/>"
    "<br>"
    "<input style='vertical-align:75%;' type='radio' name='h-bartype' value='bar' {6} checked />"
    "<img style='padding:5px;' src='/depot/src/HTMLContent/images/Left2Right_Bar.PNG' alt='Left to right'/>" SKIP
    "       </td>" SKIP.
    
    ELSE 
    
    {&OUT}
    "       <td>" SKIP
    "<input style='vertical-align:75%;' type='radio' name='h-bartype' value='centerBar' {6} />"
    "<img style='padding:5px;' src='/depot/src/HTMLContent/images/Center_Bar.PNG' alt='From Center Out'/>"
    "<br>"
    "<input style='vertical-align:75%;' type='radio' name='h-bartype' value='bar' {6} />"
    "<img style='padding:5px;' src='/depot/src/HTMLContent/images/Left2Right_Bar.PNG' alt='Left to right'/>" SKIP
    "       </td>" SKIP.
    
    /** ANYWAYS **/
    
    {&OUT} 
    "   </tr>" SKIP  
    "</TABLE>" SKIP
    "</DIV><!-- of table 2col -->" SKIP
    "</DIV>         <!-- end of grid_10 -->" SKIP                                                                               /* 1dot6 */
    "<DIV class='grid_1'> </DIV>" SKIP                                                                                          /* 1dot6 */
    "</DIV>     <!-- end of row -->" SKIP.                                                                                      /* 1dot6 */
    
                                                                                IF ITshowmsg = YES THEN 
                                                                                    {&OUT}
                                                                                        "Section ID = " sectid SKIP.
 
IF "{1}" = "FIND ITEM" THEN DO:                                                                                                  /* 1dot6 */
    {&OUT}                                                                                                                      /* 1dot6 */
    "<BR>"                                                                                                                      /* 1dot6 */
    "<div class='row'>" SKIP                                                                                                    /* 1dot6 */
    "   <div class='grid_3'> </DIV>" SKIP                                                                                       /* 1dot6 */
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP.                                          /* 1dot6 */

    
    IF get-value("whattorun") = "4.10" THEN 
        {&OUT}
            "   <div class='grid_2'> </DIV>" SKIP  
            "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='DELETE' class='btn'>Delete this Item (Marker)</BUTTON></div>" SKIP. /* 1dot9 */
    ELSE
        {&OUT}
            "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP                 /* 1dot6 */
            "   <div class='grid_2'> </DIV>" SKIP                                                                                       /* 1dot6 */
            "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='PROMPT' class='btn'>Add a New Item (Marker) to this Test</BUTTON></div>" SKIP. /* 1dot6 */
            
    {&out}
    "   <div class='grid_3'> </DIV>" SKIP                                                                                       /* 1dot6 */
    "</div>" SKIP.                                                                                                              /* 1dot6 */
END.

ELSE                                                                                                                            /* 1dot6 */
{&OUT}                                                                                                                          /* 1dot6 */
    "<BR>" SKIP                                                                                                                 /* 1dot6 */
    "<div class='row'>" SKIP                                                                                                    /* 1dot6 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                                       /* 1dot6 */
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                          /* 1dot6 */
    "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP                 /* 1dot6 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                                       /* 1dot6 */
    "</div>" SKIP.                                                                                                              /* 1dot6 */

 
/* *** removed in 1dot6 ***
{&OUT}         
    "<center>" SKIP
    "<INPUT type='hidden' name='h-act' value='{1}' />" SKIP
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                /* 1dot1 */   
    "<INPUT type='submit' name='Submit' value='{1}' />" SKIP.

/* 1dot2 */    
IF "{1}" = "FIND ITEM" THEN                                                                                             
    {&OUT}                                                                                                              
        "<button type='submit' name='h-newitem' value='WIPE-itemid'>Add a New Item (Marker) to this Test</Button>" SKIP. 
/* 1dot2 */
    
{&OUT}    
    "</center>" SKIP                                                             
    "</DIV><!-- of div grid_6 -->" SKIP                                                               
    "</div><!-- of div row -->" SKIP. 
    *** end of removal *** */
{&OUT}                                                              
    "</FORM>" SKIP.
     
    
    
/*****************************  End of File  *********************************/    
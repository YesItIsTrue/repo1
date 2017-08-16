
/*------------------------------------------------------------------------
    File        : TLitemU-form.i
    Purpose     : 

    Syntax      :

    Description : Layout for the TKitemU.html program.

    Author(s)   : Doug Luttrell
    Created     : Sat Sep 27 22:15:23 EDT 2014
    Notes       :
        
          
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.31">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="26/Sep/14">
    <META NAME="LAST_UPDATED" CONTENT="09/Oct/15">
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
    <TITLE>Item / Marker Maintenance --- FORM</TITLE>
    
    
 *****************************************************************************
 Revision History:
 -----------------
 1.0 - written by DOUG LUTTRELL on 26/Sep/14.  Original Version.
 1.2 - written by DOUG LUTTRELL on 19/Nov/14.  
 1.3 - written by DOUG LUTTRELL on 27/Jan/15.  Incorporated the new grid css commands.
 1.31 - written by DOUG LUTTRELL on 09/Oct/15.  Changed button text.  Marked by 131.
 
 *****************************************************************************
      
  ----------------------------------------------------------------------*/
  

  

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
                                                                /** begin 1dot1 **/
                                                                IF ITshowmsg = YES THEN                                                         
                                                                    {&OUT}
                                                                        "<P>In the external TLitemU-form.i file again.</P>" SKIP 
                                                                        "<OL>Variable List" SKIP
                                                                        "   <LI>ACT = " act SKIP
                                                                        "   <LI>markid = " markid SKIP
                                                                        "   <LI>markdesc = " markdesc SKIP
                                                                        "   <LI>markdisp = " markdisp SKIP
                                                                        "</OL>" SKIP.                                                           
                                                                 /** end 1dot1 **/ 
        
{&OUT}
    "<DIV class='row'>" SKIP                                                    /* 1dot3 */
    "<DIV class='grid_2'> </DIV>" SKIP                                          /* 1dot3 */
    "<DIV class='grid_8'>" SKIP                                                 /* 1dot3 */
    "<FORM method='get' id='TLitemU-form'>" SKIP 
    "<DIV class='table_col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=4>Item (Marker) {5}</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Item / Marker</TD>" SKIP 
    "       <TD class='REQ'>" SKIP.
    
IF "{2}" = "DISABLED" THEN 
    {&OUT}
        "<input type='hidden' name='h-markid' value=" markid " >" SKIP 
        "<input type='hidden' name='h-markitem' value='" markitem "' >" SKIP 
        markitem "</td>" SKIP.
        
ELSE DO: 
    {&OUT}
        "           <select name='h-markid' value=" markid " {2} >" SKIP.
        
        
    IF "{4}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=''> </option>" SKIP.
        
        
    FOR EACH marker_list WHERE marker_list.marker_deleted = ? NO-LOCK
        BREAK BY marker_list.marker_item: 
        
        IF marker_list.marker_ID = markid THEN 
            thismarker  = "SELECTED".
        ELSE 
            thismarker  = "".
            
        {&OUT}
            "               <option value=" marker_list.marker_ID " " thismarker " > " marker_list.marker_item " </option>" SKIP.
            
    END.  /** of 4ea. marker_list **/
    
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
        
END.  /** of else do --- {2} <> "DISABLED" **/

{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Item Display</TD>" SKIP
    "       <TD>" SKIP
    "           <input type='text' name='h-markdisp' value='" markdisp "' size=18 {3} >" SKIP
    "       </TD>" SKIP
    "   </TR>" SKIP    
    "   <TR>" SKIP
    "       <TD>Item / Marker Description</TD>" SKIP
    "       <TD>" SKIP 
    "           <textarea rows=4 cols=50 name='h-markdesc' {3} >" markdesc "</textarea>" SKIP
    "       </TD>" SKIP
    "   </TR>" SKIP
    "</TABLE>" SKIP
    "</DIV>             <!-- end of table_col -->" SKIP                         /* 1dot3 */
    "</DIV>         <!-- end of grid_6 -->" SKIP                                /* 1dot3 */
    "<DIV class='grid_2'> </DIV>" SKIP                                          /* 1dot3 */
    "</DIV>     <!-- end of row -->" SKIP.                                      /* 1dot3 */
    
                                                                                                IF ITshowmsg = YES THEN 
                                                                                                    {&OUT}
                                                                                                        "Marker ID = " markid SKIP.

IF "{1}" = "FIND ITEM" THEN                                                                                                     /* 1dot4 */   
{&OUT}                                                                                                                          /* 1dot4 */
    "<BR>"                                                                                                                      /* 1dot4 */                                                              
    "<div class='row'>" SKIP                                                                                                    /* 1dot4 */
    "   <div class='grid_3'> </DIV>" SKIP                                                                                       /* 1dot4 */
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                          /* 1dot4 */
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP                 /* 1dot4 */
    "   <div class='grid_2'> </DIV>" SKIP                                                                                       /* 1dot4 */
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='PROMPT' class='btn'>Add New Item / Marker</BUTTON></div>" SKIP /* 1dot4 */    /* 131 */
    "   <div class='grid_3'> </DIV>" SKIP                                                                                       /* 1dot4 */
    "</div>" SKIP.                                                                                                              /* 1dot4 */
    
ELSE                                                                                                                            /* 1dot4 */
{&OUT}                                                                                                                          /* 1dot4 */
    "<BR>" SKIP                                                                                                                 /* 1dot4 */
    "<div class='row'>" SKIP                                                                                                    /* 1dot4 */                                                     
    "   <div class='grid_5'> </DIV>" SKIP                                                                                       /* 1dot4 */ 
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                          /* 1dot4 */              
    "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP                 /* 1dot4 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                                       /* 1dot4 */
    "</div>" SKIP.                                                                                                              /* 1dot4 */
    

{&OUT}    
    "</FORM>" SKIP.
    
    
    
/*****************************  End of File  *********************************/    
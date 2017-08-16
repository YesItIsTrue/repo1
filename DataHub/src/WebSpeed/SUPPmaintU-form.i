
/*------------------------------------------------------------------------
    File        : SUPPmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : Layout for the SUPPmaintU.html program.

    Author(s)   : Doug Luttrell
    Created     : Sat Sep 27 22:15:23 EDT 2014
    Notes       :
  
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.1">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="06/Oct/14">
    <META NAME="LAST_UPDATED" CONTENT="19/Nov/14"> 
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
    
  ----------------------------------------------------------------------*/

/*********************  Layout 2  ********************/

{&OUT}
    "<DIV class='row'>" SKIP
    "<DIV class='grid_1'> </DIV>" SKIP
    "<DIV class='grid_10'>" SKIP
    "<FORM method='post' id='SUPPmaintU-form'>" SKIP 
    "<DIV class='table_col'>" SKIP                                                  /* 1dot3 */
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=2>Supplement Maintenance</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Supplement</TD>" SKIP 
    "       <TD class='REQ'>" SKIP.
            
IF "{2}" = "DISABLED" THEN 
    {&OUT}
        "<input type='hidden' name='h-supplid' value=" supplid " >" SKIP 
        "<input type='hidden' name='h-supplname' value='" supplname "' >" SKIP 
        supplname "</td>" SKIP.
        
ELSE DO: 
    {&OUT}
        "           <select name='h-supplid' value=" supplid " {2} >" SKIP.
        
    IF "{4}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=''> </option>" SKIP.
    
    FOR EACH suppl_list WHERE suppl_list.suppl_deleted = ? NO-LOCK
        BY suppl_list.suppl_name:                                                               /* 1dot1 - bonus sort */ 
        
        IF suppl_list.suppl_id = supplid THEN 
            thismarker  = "SELECTED".
        ELSE 
            thismarker  = "".
            
        {&OUT}
            "               <option value=" suppl_list.suppl_ID " " thismarker " > " suppl_list.suppl_name " </option>" SKIP.
            
    END.  /** of 4ea. marker_list **/
    
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
        
END.  /** of else do --- {2} <> "DISABLED" **/
            
            
{&OUT}            
    "       </TD>" SKIP
    
/* *** Moved in 1dot3 ***
    "       <TD rowspan=2>Supplement Description</TD>" SKIP
    "       <TD rowspan=2>" SKIP
    "           <textarea rows=4 cols=50 name='h-suppldesc' {3} >" suppldesc "</textarea>" SKIP
    "       </TD>" SKIP
    *** end of move *** */
               
    "   </TR>" SKIP 
    "   <TR>" SKIP
    "         <TD>Magento SKU#</TD>" SKIP
    "         <TD><INPUT type='text' name='h-sku' value='" sku "' {3} /></TD>" SKIP 
    "   </TR>" SKIP
    "     <TR>" SKIP
    "         <TD>Default Quantity</TD>" SKIP
    "         <TD><INPUT type='number' name='h-defqty' value=" defqty " {3} /></TD>" SKIP
/* *** Moved in 1dot3 ***
    "       <TD rowspan=2>Default Notes</TD>" SKIP
    "       <TD rowspan=2>" SKIP
    "           <textarea rows=4 cols=50 name='h-defnotes' {3} >" defnotes "</textarea>" SKIP
    "       </TD>" SKIP 
    *** end of move *** */           
    "     </TR>" SKIP
    "     <TR>" SKIP
    "         <TD>Default Unit Of Measure (UOM)</TD>"  SKIP
    "           <TD><select name='h-defuom' value='" defuom "' {3} >" SKIP.
    
DO x = 1 TO NUM-ENTRIES(uomlist):
    
    IF ENTRY(x,uomlist) = defuom THEN 
        thisuom = "SELECTED".
    ELSE 
        thisuom = "".
        
    {&OUT}
        "<option value='" ENTRY(x,uomlist) "' " thisuom " >" ENTRY(x,uomlist) "</option>" SKIP.    
    
END.  /** of do x = 1 to num-entries uomlist **/
    
{&OUT} 
    "               </select>" SKIP
    "           </TD>" SKIP
    "   </TR>" SKIP                                                                                                     /* 1dot3 */
    "   <TR>" SKIP                                                                                                      /* 1dot3 */
    "       <TD >Supplement Description</TD>" SKIP                                                                      /* 1dot3 */
    "       <TD >" SKIP                                                                                                 /* 1dot3 */
    "           <textarea rows=4 cols=50 name='h-suppldesc' {3} >" suppldesc "</textarea>" SKIP                         /* 1dot3 */
    "       </TD>" SKIP                                                                                                 /* 1dot3 */
    "   </TR>" SKIP                                                                                                     /* 1dot3 */
    "   <TR>" SKIP                                                                                                      /* 1dot3 */ 
    "       <TD >Default Notes</TD>" SKIP                                                                               /* 1dot3 */
    "       <TD >" SKIP                                                                                                 /* 1dot3 */
    "           <textarea rows=4 cols=50 name='h-defnotes' {3} >" defnotes "</textarea>" SKIP                           /* 1dot3 */
    "       </TD>" SKIP                                                                                                 /* 1dot3 */
    "   </TR>" SKIP                                                                                                     /* 1dot3 */    
    "</TABLE>" SKIP
    "</DIV>" SKIP
    "</DIV>     <!-- end of grid_10 -->" SKIP
    "<DIV class='grid_1'> </DIV>" SKIP  
    "</DIV>     <!-- end of row -->" SKIP
    "<BR>" SKIP                                                                                                         /* 1dot3 */
    "<div class='row'>" SKIP                                                                                            /* 1dot3 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                               /* 1dot3 */
    "       <INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' class='btn'/>" SKIP   /* 1dot1 - bonus fix */    
    "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP         /* 1dot3 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                               /* 1dot3 */        
    "</div>" SKIP.                                                                                                      /* 1dot3 */
    
/* *** removed in 1dot3 ***
    "<div class='row'>" SKIP
    "   <div class='grid_3'> </DIV>" SKIP
    "   <div class='grid_2'>" SKIP
    "       <INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' class='btn'/>" SKIP   /* 1dot1 - bonus fix */
    "       <INPUT type='hidden' name='h-act' value='{1}' />" SKIP
    "       <INPUT type='submit' name='Submit' value='{1}' />" SKIP
    "   </div>" SKIP
    "   <div class='grid_2'> </DIV>" SKIP
    "   <div class='grid_2'>" SKIP .   
    
IF "{1}" = "FIND SUPPLEMENT" THEN                                                                                           /* 1dot1 */
    {&OUT}                                                                                                                  /* 1dot1 */
        "<button type='submit' name='h-supplid' value='0' class='btn'>Add a New Supplement</Button>" SKIP.                  /* 1dot1 */    


{&OUT}
    "</div> <!-- end of grid_2 --> " SKIP
    "   <div class='grid_3'> </DIV>" SKIP
    "</div> <!-- end of row --> " SKIP             
    "</FORM>" SKIP.  
    *** end of removal *** */    
/****************** End of Layout 2 ****************/

    
/*****************************  End of File  *********************************/    
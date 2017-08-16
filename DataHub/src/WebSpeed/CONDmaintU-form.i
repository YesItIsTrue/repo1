 
/*------------------------------------------------------------------------
    File        : CONDmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : Layout for the CONDmaintU.html program.
 
    Author(s)   : Doug Luttrell
    Created     : Mon Oct 06 21:15:23 EDT 2014
    Notes       :
        
    <TITLE>Condition Maintenance --- Form</TITLE>
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.2">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="06/Oct/14">
    <META NAME="LAST_UPDATED" CONTENT="02/Oct/15">    
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/table.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/quinton2.css' />  
    
    Revision History:
         *  1.3 - written by Jacob Luttrell on 02/Oct/15. Added more div tags to control page better
         *          and corrected buttons. Marked by 1dot3.      
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<FORM method='get' id='CONDmaintU-form'>" SKIP 
    "<DIV class='row'>" SKIP                                                    /* 1dot3 */ 
    "<DIV class='grid_2'> </DIV>" SKIP                                          /* 1dot3 */
    "<DIV class='grid_8'>" SKIP                                                 /* 1dot3 */
    "<DIV class='table_col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=2>Condition Maintenance</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Condition</TD>" SKIP 
    "       <TD class='REQ'>" SKIP.
    
IF "{2}" = "DISABLED" THEN 
    {&OUT}
        "<input type='hidden' name='h-condid' value=" condid " >" SKIP 
        "<input type='hidden' name='h-condname' value='" condname "' >" SKIP 
        condname "</td>" SKIP.
        
ELSE DO: 
    {&OUT}
        "           <select name='h-condid' value=" condid " {2} >" SKIP.
        
    IF "{4}" <> "DELETE" THEN 
        {&OUT}            
            "               <option value=''> </option>" SKIP.                          /* 1dot2 */
    
    FOR EACH condition_mstr WHERE condition_mstr.condition_deleted = ? NO-LOCK
        BY condition_mstr.condition_name:                                               /* 1dot2 - bonus fix on sort */ 
        
        IF condition_mstr.condition_ID = condid THEN 
            thiscondition  = "SELECTED".
        ELSE 
            thiscondition  = "".
            
        {&OUT}
            "               <option value=" condition_mstr.condition_ID " " thiscondition " > " condition_mstr.condition_name " </option>" SKIP.
            
    END.  /** of 4ea. condition_mstr **/
    
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
        
END.  /** of else do --- {2} <> "DISABLED" **/

{&OUT}
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Condition Description</TD>" SKIP
    "       <TD>" SKIP 
            "             <input type='text' name='h-conddesc' value='" conddesc "' size=78 {3} />" SKIP
    "       </TD>" SKIP
    "   </TR>" SKIP
    "     <TR>" SKIP
    "         <TD>Common Condition</TD>" SKIP
    "         <TD>" SKIP. 
    
IF iscommon = YES THEN 
    {&OUT}          
        "           <input type='checkbox' name='h-iscommon' value='YES' CHECKED {3} />" SKIP.
ELSE 
    {&OUT}
        "           <input type='checkbox' name='h-iscommon' value='YES' {3} />" SKIP.          
 
{&OUT}
    "       </TD>" SKIP
    "   </TR>" SKIP
    "</TABLE>" SKIP
    "</DIV>" SKIP 
    "</DIV>         <!-- end of grid_8 -->" SKIP                                                                            /* 1dot3 */
    "<DIV class='grid_2'> </DIV>" SKIP                                                                                      /* 1dot3 */
    "</DIV>     <!-- end of row -->" SKIP                                                                                   /* 1dot3 */
    "<BR>" SKIP.                                                                                                            /* 1dot3 */
    
                                                                                IF ITshowmsg = YES THEN 
                                                                                    {&OUT}
                                                                                        "condition ID = " condid SKIP.
        
/* ****** removed in 1dot3 ******
/*{&OUT}*/
/*    "<center>" SKIP*/
/*    "<INPUT type='hidden' name='h-act' value='{1}' />" SKIP                                              /* Don't Know why but this needs to be in the code to have Add New work */*/
/*    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                      /* 1dot1 */                                            */
/*    "<INPUT type='hidden' name='Submit' value='{1}' />" SKIP*/
/*    .*/
    ****** end of removal ****** */
    
 IF "{1}" = "FIND CONDITION" THEN                                                                                           /* 1dot2 */
    {&OUT}                                                                                                                  /* 1dot2 */
        "<div class='row'>" SKIP                                                                                            /* 1dot3 */
        "   <div class='grid_3'> </DIV>" SKIP                                                                               /* 1dot3 */
        "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                      /* 1dot1 */
        "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP         /* 1dot3 */
        "   <div class='grid_2'> </DIV>" SKIP                                                                               /* 1dot3 */
        "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='PROMPT' class='btn'>NEW CONDITION</BUTTON></div>" SKIP  /* 1dot3 */
        "   <div class='grid_3'> </DIV>" SKIP                                                                               /* 1dot3 */
        "</div>" SKIP                                                                                                       /* 1dot3 */
        "<BR>" SKIP .                                                                                                       /* 1dot3 */
    
/*        "<button type='submit' name='h-condid' value='0'>Add New Condition</button>"  SKIP.                                 /* 1dot2 */*/

ELSE                                                                                                            /* 1dot3 */
{&OUT}                                                                                                          /* 1dot3 */
    "<div class='row'>" SKIP                                                                                    /* 1dot3 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                       /* 1dot3 */
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                                      /* 1dot1 */
    "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP /* 1dot3 */
    "   <div class='grid_5'> </DIV>" SKIP                                                                       /* 1dot3 */
    "</div>" SKIP                                                                                               /* 1dot3 */
    "<BR>" SKIP.
    
{&OUT}
    "</center>" SKIP
    "</FORM>" SKIP.
    
    
    
/*****************************  End of File  *********************************/    
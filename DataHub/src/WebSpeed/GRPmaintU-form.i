
/*------------------------------------------------------------------------
    File        : GRPmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : .i file for Solsource Maintenance Template.  Needs to be resaved as a new file when being used with a program.

    Author(s)   : Jacob Luttrell
    Created     : Tue Apr 19 08:41:29 MDT 2016
    Notes       :
        {1} = Next act
        {2} = disabled or required or nothing for table required fields
        {3} = 'REQ' for country name 
        {4} = disabled or nothing for other fields
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
"<form>" SKIP
    "<DIV class='row'>" SKIP
    "<DIV class='grid_3'> </DIV>" SKIP
    "<DIV class='grid_6'>" SKIP
    "<div class='table_2col'>" SKIP
    "   <table>" SKIP(1)
    "       <tr>" SKIP
    "           <th colspan=4>Group Maintenance</th>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Group ID</td>" SKIP
    "           <td class='{3}' ><input type='text' name='h-ID' value='" v-ID "' {2} /></td>" SKIP
    "           <td>Group Type</td>" SKIP
    "           <td><input type='text' name='h-type' value='" v-type "' {4} /></td>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Description</td>" SKIP
    "           <td colspan='3'><input type='text' size='87' name='h-desc' value='" v-desc "' {4} /></td>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Notes</td>" SKIP
    "           <td colspan='3'><textarea rows='3' cols='89' name='h-notes' value='" v-notes "' {4} >" v-notes "</textarea></td>" SKIP
    "       </tr>" SKIP(1)
    "   </table>" SKIP
    "</div>" SKIP
    "</DIV>         <!-- end of grid_6 -->" SKIP
    "<DIV class='grid_3'> </DIV>" SKIP  
    "</DIV>     <!-- end of row -->" SKIP    
    "<BR>"  SKIP.

    
IF "{1}" = "INITIAL" THEN   
   
    {&OUT}
"<div class='row'>" SKIP
        "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP          
        "   <div class='grid_5'> </DIV>" SKIP
        "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>Search Again</BUTTON></div>" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "</div>" SKIP
        "</form>" SKIP.

ELSE    
    {&OUT}    
        "<div class='row'>" SKIP
        "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP 
        "<INPUT type='hidden' name='h-new' value='" v-new "' />" SKIP         
        "   <div class='grid_2'> </DIV>" SKIP
        "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>Submit</BUTTON></div>" SKIP        
        "   <div class='grid_1'> </DIV>" SKIP
        "   <div class='grid_2'><BUTTON type='reset' class='btn'>Reset</BUTTON></div>" SKIP
        "   <div class='grid_1'> </DIV>" SKIP
        "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='INITIAL' class='btn'>Search Again</BUTTON></div>" SKIP
        "   <div class='grid_2'> </DIV>" SKIP
        "</div>" SKIP   
        "</form>" SKIP.  
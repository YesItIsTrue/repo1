     
/*------------------------------------------------------------------------
    File        : MaintRecordDispTemp.i
    Purpose     : 

    Syntax      :

    Description : .i file for Solsource Maintenance Template.  Needs to be resaved as a new file when being used with a program.

    Author(s)   : Jacob Luttrell
    Created     : Tue Apr 19 08:41:29 MDT 2016
    Notes       :
        {1} = Next act
        {2} = disabled or required or nothing for display name field
        {3} = 'REQ' for country name 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
"<form>" SKIP
    "<DIV class='row'>" SKIP
    "<DIV class='grid_3'> </DIV>" SKIP
    "<DIV class='grid_6'>" SKIP
    "<div class='table_col'>" SKIP
    "   <table>" SKIP(1)
    "       <tr>" SKIP
    "           <th colspan=2>" /* Maintenance Screen Title Here */ "</th>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>" /* Carried Variable Title Here */ "</td>" SKIP
    "           <td>" /* Carried Variable Here */ "</td>" SKIP
    "       </tr>" SKIP(1)

    "       <tr>" SKIP
    "           <td>" /* Updatable Field Title Here */ "</td>" SKIP
    "           <td class='{3}' ><input type='text' name='" /* h-updatable-field */ "' value='" /* v-updatable-field */ "' {2} /></td>" SKIP
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
        "<INPUT type='hidden' name='" /* h-carried-variable */ "' value='" /* v-carried-variable */ "' />" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>Search Again</BUTTON></div>" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "</div>" SKIP
        "</form>" SKIP.

ELSE    
    {&OUT}    
        "<div class='row'>" SKIP
        "<INPUT type='hidden' name='" /* h-carried-variable */ "' value='" /* v-carried-variable */ "' />" SKIP
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
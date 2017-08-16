
/*------------------------------------------------------------------------
    File        : USRmaintU-form.i
    Purpose     : 

    Syntax      :

    Description : .i file for Solsource Maintenance Template.  Needs to be resaved as a new file when being used with a program.

    Author(s)   : Jacob Luttrell
    Created     : Tue Apr 19 08:41:29 MDT 2016
    Notes       :
        {1} = Next act
        {2} = disabled or required or nothing for display name field
        {3} = 'REQ' for important fields 
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
    "           <th colspan='4'>User Maintenance</th>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>First Name</td>" SKIP
    "           <td class='{3}' ><input type='text' name='h-fname' value='" v-fname "' {2} /></td>" SKIP    
    "           <td>Last Name</td>" SKIP
    "           <td class='{3}' ><input type='text' name='h-lname' value='" v-lname "' {2} /></td>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Email</td>" SKIP
    "           <td class='{3}' colspan='3'><input type='text' name='h-email' value='" v-email "' {2} /></td>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>User Name</td>" SKIP
    "           <td class='{3}' ><input type='text' name='h-uname' value='" v-uname "' {2} /></td>" SKIP    
    "           <td>Password</td>" SKIP
    "           <td class='{3}' ><input type='text' name='h-password' value='" v-password "' {2} /></td>" SKIP
    "       </tr>" SKIP(1)
        "       <tr>" SKIP
    "           <td>Password Expire</td>" SKIP
    "           <td><input type='date' name='h-password-exp' value='" char-pass-exp "' {4} /></td>" SKIP    
    "           <td>Password Reset</td>" SKIP
    "           <td><input type='date' name='h-password-rst' value='" char-pass-rst "' {4} /></td>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Group(s)</td>" SKIP
    "           <td class='{3}' colspan='3'><select name='h-grouplist' multiple {2}>" skip.

FOR EACH grp_mstr NO-LOCK:
    
    FIND gud_det WHERE gud_det.gud_people_ID = usr_mstr.usr_people_ID AND 
                       gud_det.gud_grp_id = grp_mstr.grp_ID 
                            NO-LOCK NO-ERROR.
                       
    IF AVAILABLE (gud_det) THEN 
        ASSIGN 
            isselected = "SELECTED".
    ELSE 
        ASSIGN         
            isselected = "NOTHING".    
    
    {&OUT}                                                                                
    "                               <option value='" grp_mstr.grp_ID "' " isselected ">" grp_mstr.grp_ID "</option>" SKIP.    
END. /* 4ea. grp_mstr */    
{&OUT}    
"               </select>" SKIP
    "           </td>" SKIP
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
        "<INPUT type='hidden' name='h-whichrec' value='" whichrec "' />" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>Search Again</BUTTON></div>" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "</div>" SKIP
        "</form>" SKIP.

ELSE    
    {&OUT}    
        "<div class='row'>" SKIP
        "<INPUT type='hidden' name='h-whichrec' value='" whichrec "' />" SKIP
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

/*------------------------------------------------------------------------
    File        : CNTRYmaintU-form.i
    Purpose     : Clean Code

    Syntax      :

    Description : html form for CNTRYmaintU

    Author(s)   : Jacob Luttrell
    Created     : Wed Apr 06 09:51:15 MDT 2016
    Notes       :
        {1} = Next act
        {2} = disabled or nothing for most fields
        {3} = 'REQ' for country name 
        {4} = required or nothing for country name

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
        "           <th colspan=2>Country Maintenance</th>" SKIP
        "       </tr>" SKIP(1)
        "       <tr>" SKIP
        "           <td>Country ISO</td>" SKIP
        "           <td>" v-country-ISO "</td>" SKIP
        "       </tr>" SKIP(1)
        "       <tr>" SKIP
        "           <td>Country Name</td>" SKIP
        "           <td class='{3}' ><input type='text' name='h-country-disp' value='" v-country-disp "' {2} {4} /></td>" SKIP
        "       </tr>" SKIP(1)
        "       <tr>" SKIP
        "           <td>International Prefix</td>" SKIP
        "           <td><input type='text' name='h-intl-prfx' value='" v-intl-prfx "' {2} /></td>" SKIP
        "       </tr>" SKIP(1)
        "       <tr>" SKIP
        "           <td>Primary</td>" SKIP
        "           <td><input type='radio' name='h-primary' value='" v-primary "' DISABLED /></td>" SKIP
        "       </tr>" SKIP(1)
        "   </table>" SKIP
        "</div>" SKIP
    "</DIV>         <!-- end of grid_6 -->" SKIP
    "<DIV class='grid_3'> </DIV>" SKIP  
    "</DIV>     <!-- end of row -->" SKIP    
    "<BR>"  SKIP.

IF act = "MAINTENANCE" THEN 

    {&OUT}    
"<div class='row'>" SKIP
    "<INPUT type='hidden' name='h-whichrec' value='" whichrec "' />" SKIP
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP          
    "<INPUT type='hidden' name='h-country-ISO' value='" v-country-ISO "' />" SKIP
    "   <div class='grid_3'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>Submit</BUTTON></div>" SKIP
    "   <div class='grid_1'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='DELETE' class='btn'>Delete</BUTTON></div>" SKIP
    "   <div class='grid_1'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='RESET' class='btn'>Search Again</BUTTON></div>" SKIP
    "   <div class='grid_3'> </DIV>" SKIP
    "</div>" SKIP   
    "</form>" SKIP. 
    
ELSE IF "{1}" = "INITIAL" THEN   
   
    {&OUT}
    "<div class='row'>" SKIP
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP          
    "<INPUT type='hidden' name='h-country-ISO' value='" v-country-ISO "' />" SKIP    
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
    "<INPUT type='hidden' name='h-country-ISO' value='" v-country-ISO "' />" SKIP
    "   <div class='grid_3'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>Submit</BUTTON></div>" SKIP
    "   <div class='grid_2'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='RESET' class='btn'>Search Again</BUTTON></div>" SKIP
    "   <div class='grid_3'> </DIV>" SKIP
    "</div>" SKIP   
    "</form>" SKIP. 
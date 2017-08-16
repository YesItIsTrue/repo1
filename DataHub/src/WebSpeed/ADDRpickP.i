
/*------------------------------------------------------------------------
    File        : ADDRpickP.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Thu Mar 24 08:36:36 MDT 2016
    Notes       :
        {1} = Page Title
        {2} = Next act
        {3} = Required/Disabled for most fields 
        {4} = class='req' for most fields      
        {5} = Disabled for extra addr lines
        {6} = Required/Disabled for state field
        {7} = class='req' for state field
        {8} = Required/Disabled for country field
        {9} = class='req' for country field
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

{&OUT}
    "<div class='row'>"                 SKIP
    "<div class='grid_2'></div>"        SKIP
    "<div class='grid_8'>"              SKIP
    "<div class='table_3col'>"          SKIP
    "<form>"        SKIP
    "   <table>"    SKIP
    "       <tr>"   SKIP
    "           <th colspan=6>" {1} "</th>" SKIP
    "       </tr>"  SKIP 
    "       <tr>"   SKIP
    "           <td>Address Line 1". 
  
IF act = "INITIAL" THEN
    {&OUT}
        " Contains". 
   
{&OUT} 
    "</td>" SKIP
    "           <td {4}><input type='text' name='h-addr1' value='" v-addr1 "' {3}/></td>" SKIP 
    "           <td colspan=4></td>" SKIP
    "       </tr>" SKIP.
    
IF act <> "INITIAL" THEN 
    {&OUT}      
        "       <tr>"   SKIP
        "           <td>Address Line 2</td>" SKIP
        "           <td><input type='text' name='h-addr2' value='" v-addr2 "' {5} /></td>" SKIP
        "           <td colspan=4></td>" SKIP
        "       </tr>" SKIP
        "       <tr>"   SKIP
        "           <td>Address Line 3</td>" SKIP
        "           <td><input type='text' name='h-addr3' value='" v-addr3 "' {5} /></td>" SKIP
        "           <td colspan=4></td>" SKIP
        "       </tr>" SKIP.            
  
{&OUT}   
    "       <tr>"   SKIP
    "           <td>City</td>" SKIP
    "           <td {4}><input type='text' name='h-city' value='" v-city "' {3}/></td>" SKIP
    "       <TD>State</TD>" SKIP
    "       <TD {7}>" SKIP
    "           <select name='h-state' {6}>" SKIP
    "               <option value=''></option>" SKIP.

IF act = "INITIAL" OR act = "PROMPT" THEN 

    FOR EACH state_mstr  WHERE                  
        state_mstr.state_deleted = ? AND 
        state_mstr.state_primary = YES  NO-LOCK:    

        IF state_mstr.state_ISO = v-state AND state_mstr.state_country_ISO = v-country THEN 
            {&OUT}
        "<option value=~"" state_mstr.state_ISO "~" SELECTED >" state_mstr.state_display_name "</option>" SKIP.
        
        ELSE   
        {&OUT}
            "<option value=~"" state_mstr.state_ISO "~">" state_mstr.state_display_name "</option>" SKIP. 

    END.  /** of 4ea. state_mstr **/

ELSE 
{../depot/src/WebSpeed/StateDropDown.i v-state v-country}.

{&OUT}
    "           </SELECT>" SKIP 
    "           </TD>" SKIP
    "           <td>Zip Code</td>" SKIP 
    "           <td {4}><input type='text' name='h-zip' value='" v-zip "' {3}/></td>" SKIP
    "       </tr>" SKIP
    "       <tr>" SKIP
    "            <td>Country</td>" SKIP
    "            <TD {9}>" SKIP
    "                <SELECT name='h-country' {8}>" SKIP
    "                    <option value=''></option>".
    
{../depot/src/WebSpeed/CountryDropDownList.i v-country}.        

{&OUT}
    "           </SELECT>" SKIP
    "       </TD>" SKIP
    "           <td colspan=4></td>" SKIP
    "       </tr>" SKIP             
    "   </table>"   SKIP
    "</div>" SKIP                                                                                                      
    "</div><!-- end of grid_8 -->" SKIP                                                                                
    "<div class='grid_2'></div>" SKIP                                                                                      
    "</div>" SKIP                                                                                                      
    "<BR>" SKIP.              



IF act = "STATE" THEN 
    {&OUT}
"       <input type='hidden' name='h-country'   value='" v-country "'/>"    SKIP.    

IF act = "CREATE" THEN 
    {&OUT}                                                                                  
    "<div class='row'>" SKIP                                                                                           
    "   <div class='grid_5'> </DIV>" SKIP
    "       <input type='hidden' name='whattorun'   value='" whatshouldrun "'/>"    SKIP
    "       <input type='hidden' name='h-prevproc'  value='" pp-in "'/>"    SKIP
    "       <input type='hidden' name='h-act'  value='" pp-act "'/>"    SKIP   
    "       <input type='hidden' name='h-pp-passBack-peopid'  value='" pp-passBack-peopid "'/>"    SKIP          
    "       <input type='hidden' name='h-pp-passBack-addrid'  value='" v-addr-ID "'/>"    SKIP    
    "       <input type='hidden' name='h-pp-passBack-char1'  value='" pp-passBack-char1 "'/>"    SKIP          
    "       <input type='hidden' name='h-pp-passBack-char2'  value='" pp-passBack-char2 "'/>"    SKIP 
    "       <input type='hidden' name='h-pp-passBack-int1'  value='" pp-passBack-int1 "'/>"    SKIP          
    "       <input type='hidden' name='h-pp-passBack-int2'  value='" pp-passBack-int2 "'/>"    SKIP                                                             
    "   <div class='grid_2'><BUTTON type='submit' name='h-addr-act' value='{2}' class='btn'>Return to Search</BUTTON></div>" SKIP                                       
    "   <div class='grid_5'> </DIV>" SKIP 
    "</form>"        SKIP                                                                              
    "</div>" SKIP.  
     
ELSE      
 {&OUT}
    "<div class='row'>" SKIP                                                                                           
    "   <div class='grid_3'> </DIV>" SKIP
    "       <input type='hidden' name='whattorun'   value='" whatshouldrun "'/>"    SKIP
    "       <input type='hidden' name='h-prevproc'  value='" pp-in "'/>"    SKIP
    "       <input type='hidden' name='h-act'  value='" pp-act "'/>"    SKIP   
    "       <input type='hidden' name='h-pp-passBack-peopid'  value='" pp-passBack-peopid "'/>"    SKIP          
    "       <input type='hidden' name='h-pp-passBack-addrid'  value='" v-addr-ID "'/>"    SKIP 
    "       <input type='hidden' name='h-pp-passBack-char1'  value='" pp-passBack-char1 "'/>"    SKIP          
    "       <input type='hidden' name='h-pp-passBack-char2'  value='" pp-passBack-char2 "'/>"    SKIP  
    "       <input type='hidden' name='h-pp-passBack-int1'  value='" pp-passBack-int1 "'/>"    SKIP          
    "       <input type='hidden' name='h-pp-passBack-int2'  value='" pp-passBack-int2 "'/>"    SKIP                                                                   
    "   <div class='grid_2'><BUTTON type='submit' name='h-addr-act' value='{2}' class='btn'>Submit</BUTTON></div>" SKIP         
    "   <div class='grid_2'> </DIV>" SKIP                                                                              
    "   <div class='grid_2'><BUTTON type='reset' class='btn'>Reset</BUTTON></div>" SKIP                                
    "   <div class='grid_3'> </DIV>" SKIP 
    "</form>"        SKIP                                                                              
    "</div>" SKIP.  

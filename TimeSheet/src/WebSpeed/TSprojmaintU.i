
/*------------------------------------------------------------------------
    File        : TSprojmaintU.i
    Purpose     : OUT statement holder

    Syntax      :

    Description : Display screens

    Author(s)   : Jacob Luttrell
    Created     : Thu Jan 14 15:07:38 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/*
Passing Variables:
    {1} = act
    {2} = Client abbv: req or nothing
    {3} = proj name: req or nothing
    {4} = client abbv: required or Nothing
    {5} = proj name: required or disabled 
    {6} = all other fields: disabled or readonly or nothing
    
*/
/* ********************  Preprocessor Definitions  ******************** */
{&OUT}
    "<form>" SKIP
    "<div class='row'>" skip
    "   <div class='grid_2'></div>" skip
    "       <div class='grid_8'>" skip          
    "               <div class='table_2col'>" skip
    "                   <table>" skip
    "                       <tr>" skip
    "                           <th colspan='4'>" SKIP.
IF admin-control = YES THEN
    {&OUT}
    "Developer's ".
    
   {&OUT} 
    "Project Maintenance</th>" skip
    "                       </tr>" skip                      
    "                       <tr>" skip
    "                           <td>Client Abbreviated Name</td>" skip              
    "                           <td class='{2}'><select name='h-clientid' {4} >" skip.
    
   

IF "{4}" = "REQUIRED" THEN DO:  
    IF admin-control = YES THEN 
        {&OUT}
    "<option value='9999999' >All</option>" SKIP. 
           
    FOR EACH Client_Mstr WHERE                  
        Client_Mstr.Client_deleted = ? NO-LOCK
            BY Client_Mstr.Client_abbv:  
         
        ASSIGN 
            clientid = Client_Mstr.Client_people_ID. 
            
        {&OUT}
        "<option value='" clientid "' >" Client_Mstr.Client_abbv "</option>" SKIP.
            
    END.  /** of 4ea. client_mstr **/
END. /* if {4} = required */
ELSE DO:
    IF clientid = 9999999 THEN 
        {&OUT}
"                       <option>ALL</option>" SKIP
            "   <INPUT type='hidden' name='h-clientid' value='9999999' />" SKIP.    
    ELSE 
    {&OUT}
            "                       <option>" clientabbv "</option>" SKIP
            "   <INPUT type='hidden' name='h-clientid' value='" clientid "' />" SKIP.
END.

{&OUT}
    "                           </SELECT></td>" SKIP       
    "                           <td>Project Name</td>" skip
    "                           <td class='{3}'><select name='h-projname' {5} >" skip.    

IF clientid = 9999999 THEN DO:
    FOR EACH Proj_Mstr WHERE Proj_Mstr.Proj_deleted = ? NO-LOCK
            BY Proj_Mstr.Proj_sort:
                         
        ASSIGN 
            projname = Proj_Mstr.Proj_name.                
            
        {&OUT}
        "<option value='" projname "' >" Proj_Mstr.Proj_name "</option>" SKIP.
            
    END.  /** of 4ea. proj_mstr **/
END.
ELSE DO:        
    FOR EACH Proj_Mstr  WHERE Proj_Mstr.Proj_client_ID = clientid AND               
        Proj_Mstr.Proj_deleted = ? NO-LOCK
            BY Proj_Mstr.Proj_sort:
                         
        ASSIGN 
            projname = Proj_Mstr.Proj_name.                
            
        {&OUT}
        "<option value='" projname "' >" Proj_Mstr.Proj_name "</option>" SKIP.
            
    END.  /** of 4ea. proj_mstr **/
END.                
          
{&OUT}

    "                           </SELECT></td>" SKIP                        
    "                       </tr>" skip                                          
    "                       <tr>" SKIP
    "                           <td>Hour Adjustment</td>" SKIP
    "                           <td><input type='number' value='" price-adj "' name='h-price-adj' {6} /></td>" skip
    "                           <td>Price Adjustment</td>" skip
    "                           <td>$<input type='number' name='h-price-adj-dollar' value='" price-adj-dollar "' {6} ></td>" skip
    "                       </tr>" SKIP
    "                       <tr>" skip                                             
    "                           <td>Estimated Project Hours</TD>" SKIP
    "                           <TD><input type='number' name='h-est-hours' value='" est-hours "' {6} /></TD>" SKIP
    "                           <td>Current Project Hours</TD>" SKIP
    "                           <TD>" curr-hours FORMAT "->>>,>>>,>>9.99" "</TD>" SKIP            
    "                       </tr>" skip                 
    "                       <tr>" skip
    "                           <td>Estimated Price Total</td>" skip            
    "                           <TD>$<input type='number' name='h-est-total' step='.01' value='" est-total "' {6} /></TD>" SKIP
    "                           <td>Current Price Total</td>" skip            
    "                           <TD>" curr-total FORMAT "$->>>,>>>,>>9.99" "</TD>" SKIP  
    "                       </tr>" SKIP
    "                       <tr>" SKIP
    "                           <td>Start Date</td>" skip
    "                           <td><input type='date' name='html5-start' value='" disp-start "' {6} /></td>" skip
    "                           <td>End Date</td>" skip
    "                           <td><input type='date' name='html5-end' value='" disp-end "' {6} /></td>" skip             
    "                       </tr>" skip
    "                       <tr>" skip
    "                           <td>Sort Order</td>" SKIP
    "                           <td colspan='3'><input type='number' value='" sortorder "' name='h-sortorder' step='10' {6}/></td>" skip
    "                       </tr>" SKIP.

IF admin-control = YES THEN DO:   

IF admin-only = YES THEN 
ischecked = "CHECKED". 

ELSE 
ischecked = "".

{&OUT}
    "                       <tr>" SKIP
    "                           <td>Updateable by Admin Only</td>" skip
    "                           <td colspan='3'><input type='checkbox' name='h-admin-only' value='yes' {6} " ischecked " /></td>" skip            
    "                       </tr>" skip.
END.  
   
{&OUT}            
    "                   </table>" skip
    "               </div>" skip                 
    "       </div>" skip
    "   </div class='grid_2'></div>" skip
    "</div>" skip            
    "<BR>" SKIP.
                
    
    IF act = "INITIAL" THEN 
    
        {&OUT}
    "<div class='row'>" SKIP
    "   <INPUT type='hidden' name='whattorun' value='" whatshouldrun "' />" SKIP
    "   <div class='grid_5'> </DIV>" SKIP
    "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>Submit</BUTTON></div>" SKIP
    "   <div class='grid_5'> </DIV>" SKIP
    "</div>" SKIP.        
            
    ELSE IF act = "PROJECT" THEN
    
        {&OUT}
    "<div class='row'>" SKIP
    "   <div class='grid_2'> </DIV>" SKIP
    "   <INPUT type='hidden' name='whattorun' value='" whatshouldrun "' />" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>Submit</BUTTON></div>" SKIP
    "   <div class='grid_1'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='NEW' class='btn'>New Project</BUTTON></div>" SKIP
    "   <div class='grid_1'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submint' name='h-act' value='INITIAL' class='btn'>Restart Search</BUTTON></div>" SKIP
    "   <div class='grid_2'> </DIV>" SKIP
    "</div>" SKIP
    "</form>" SKIP.
    
    ELSE
    
        {&OUT}                                 
    "<div class='row'>" SKIP
    "   <div class='grid_2'> </DIV>" SKIP
    "   <INPUT type='hidden' name='whattorun' value='" whatshouldrun "' />" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>Submit</BUTTON></div>" SKIP
    "   <div class='grid_1'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='INITIAL' class='btn'>Restart Search</BUTTON></div>" SKIP
    "   <div class='grid_1'> </DIV>" SKIP
    "   <div class='grid_2'><BUTTON type='reset' class='btn'>Clear Changes</BUTTON></div>" SKIP
    "   <div class='grid_2'> </DIV>" SKIP
    "</div>" SKIP
    "</form>" SKIP.

/* ***************************  Main Block  *************************** */

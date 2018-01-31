
/*------------------------------------------------------------------------
    File        : TSentryU.i
    Purpose     : OUT statement holder

    Syntax      :

    Description : Display screens

    Author(s)   : Jacob Luttrell
    Created     : Thu Jan 14 15:08:32 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/*
Passing Variables:
    {1} = act
    {2} = Client abbv: req or nothing
    {3} = client abbv: required or disabled or Nothing
    {4} = proj name: req or nothing
    {5} = proj name: required or disabled or nothing
    {6} = date: req or nothing
    {7} = date: required or disabled or nothing
    {8} = all other fields: req or nothing
    {9} = all other fields: reqired or disabled
    {10} = FOR ADMIN ONLY emp_id: req or nothing
    {11} = FOR ADMIN ONLY emp_id: required or disabled or nothing
    {12} = Button text
    {13} = FOR ADMIN ONLY v-time: req or nothing
    {14} = FOR ADMIN ONLY v-time: nothing or disabled
    
*/
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

{&OUT}
    "<form>" SKIP
    "<div class='row'>" skip
    "   <div class='grid_2'></div>" skip
    "       <div class='grid_8'>" skip          
    "               <div class='table_2col'>" skip
    "                   <table>" skip 
    "                       <tr>" skip
    "                           <th colspan='4'>Timesheet Entry</th>" skip
    "                       </tr>" skip          
    "                       <tr>" skip     
    "                           <td>Name</td>" skip. 
 
IF v-admin = YES THEN 
DO:
    {&OUT}
        "                           <td colspan='3' class='{10}' ><select name='h-empid' {11}>" skip  
        . 

    IF "{11}" = "REQUIRED" THEN 
    
        FOR EACH Emp_Mstr WHERE Emp_Mstr.Emp_deleted = ?
            NO-LOCK,
            EACH people_mstr WHERE people_mstr.people_id = Emp_Mstr.Emp_ID AND 
            people_mstr.people_deleted = ?
            NO-LOCK
            BREAK BY people_mstr.people_lastname BY people_mstr.people_firstname:          
            
            IF people_mstr.people_id = empid THEN 
                isselected = "SELECTED".
            ELSE 
                isselected = "".
                  
            ASSIGN 
                empname = people_mstr.people_lastname + ", " + people_mstr.people_firstname + " " + STRING(people_mstr.people_id).
            
            {&OUT}                                                                                
                "                               <option value='" people_mstr.people_id "' " isselected " >" empname "</option>" SKIP.
            
        END.  /* 4ea. client_mstr */    
 
    ELSE 
    DO: 
          
        FOR FIRST people_mstr WHERE people_mstr.people_id = empid AND 
            people_mstr.people_deleted = ?
            NO-LOCK:                      
            ASSIGN 
                empname = people_mstr.people_firstname + ", " + people_mstr.people_lastname + " " + STRING(people_mstr.people_id).       
        END. /* for first people_mstr */ 
          
        {&OUT}
          
            "                       <option>" empname "</option>" SKIP 
            "                       <INPUT type='hidden' name='h-empid' value='" people_mstr.people_id "' />" SKIP.
    
    END.

    {&OUT} 
        "                           </select></td>" SKIP
        "                       </tr>" skip.
    
END. /* if v-admin = yes */
    
ELSE 
DO:
         
    {&OUT}
        "                           <td colspan='3'>" empname "</td>" skip.

END.
    
{&OUT}    
    "                       </tr>" skip
    "                       <tr>" skip
    "                           <td>Client</td>" skip
    "                           <td class='{2}'><select name='h-clientid' {3}>" skip.

IF "{3}" = "REQUIRED" 
    /*    OR              */
    /*   "{3}" = "NOTHING"*/
    THEN 
    FOR EACH Client_Mstr  WHERE                  
        Client_Mstr.Client_deleted = ? NO-LOCK:  
                           
        ASSIGN 
            clientid = Client_Mstr.Client_people_ID. 
            
        {&OUT}
            "<option value='" clientid "' >" Client_Mstr.Client_abbv "</option>" SKIP.
            
    END.  /** of 4ea. client_mstr **/

ELSE
    {&OUT}
        "                       <option>" clientabbv "</option>" SKIP
        "                       <INPUT type='hidden' name='h-clientid' value='" clientid "' />" SKIP.


{&OUT} 
    "                           </SELECT></td>" SKIP 
    "                           <td>Project</td>" skip
    "                           <td class='{4}'><select name='h-projname' {5}>" skip.    

IF "{5}" = "REQUIRED" OR
    "{5}" = "NOTHING" THEN 
DO:
    
    IF v-admin = YES THEN   
    
        FOR EACH Proj_Mstr  WHERE Proj_Mstr.Proj_client_ID = clientid AND               
            Proj_Mstr.Proj_deleted = ? NO-LOCK BREAK BY Proj_Mstr.Proj_sort:
         
            IF Proj_Mstr.Proj_name = projname THEN 
                ASSIGN 
                    isselected = "SELECTED"
                    projname   = Proj_Mstr.Proj_name.              
            ELSE
                ASSIGN 
                    isselected = "".                
                
            {&OUT}
                "<option value='" Proj_Mstr.Proj_name "' " isselected " >" Proj_Mstr.Proj_name "</option>" SKIP.
                
        END.  /** of 4ea. proj_mstr **/ 
    ELSE 
        FOR EACH Proj_Mstr  WHERE Proj_Mstr.Proj_client_ID = clientid AND 
            Proj_Mstr.Proj_name <> "Regular / Salary" AND               
            Proj_Mstr.Proj_deleted = ? NO-LOCK BREAK BY Proj_Mstr.Proj_sort:
         
            IF Proj_Mstr.Proj_name = projname THEN 
                ASSIGN 
                    isselected = "SELECTED"
                    projname   = Proj_Mstr.Proj_name.              
            ELSE
                ASSIGN 
                    isselected = "".                
                
            {&OUT}
                "<option value='" Proj_Mstr.Proj_name "' " isselected " >" Proj_Mstr.Proj_name "</option>" SKIP.
                
        END.  /** of 4ea. proj_mstr **/                   
END. /* if {5} */
ELSE
    {&OUT}
        "                       <option>" projname "</option>" SKIP
        "                       <INPUT type='hidden' name='h-projname' value='" projname "' />" SKIP.

         
{&OUT}
    "                           </SELECT></td>" SKIP 
    "                       </tr>" SKIP
    "                       <tr>" skip
    "                           <td>Date</td>" skip.

IF "{7}" = "REQUIRED" OR 
    "{7}" = "NOTHING" THEN     

    {&OUT}    
        "                           <td class='{6}'><input type= date name='html5-date' value='" disp-date "' {7}></td>" SKIP.  

ELSE   
    {&OUT}
        "                           <td><input type= date name='html5-date' value='" disp-date "'  {7}>" SKIP
        "                               <INPUT type='hidden' name='html5-date' value='" disp-date "' /></td>" SKIP.    


IF projname = "Regular / Salary" THEN 
    {&OUT}  
        "                           <td>Hours</td>" skip             
        "                           <td><input type='number' step='.5' name='h-amount' value='" amount "' DISABLED /></td>" skip                         
        "                       </tr>" skip.

ELSE      
    {&OUT}  
        "                           <td>Hours</td>" skip             
        "                           <td class='{8}'><input type='number' step='.5' name='h-amount' value='" amount "' {9} /></td>" skip                         
        "                       </tr>" skip.

IF v-admin = YES THEN 
DO:   
                
    
    {&OUT} 
        "                       <tr>" skip
        "                           <td>Punch Time</td>" skip
        "                           <td class='{13}'><input type='time' name='h-time' value='" v-time "' {14} /></td>" skip
        "                           <td>Punch Time Description</td>" skip
        "                           <td class='{13}'><select name='h-time-desc' {14} >" skip
        "                               <option value=''>" SKIP.
    
    DO x = 1 TO NUM-ENTRIES(time-desclist): 
        IF ENTRY(x,time-desclist) = time-desc THEN 
                                 
            {&OUT}
                "                               <option value='" ENTRY(x,time-desclist) "' SELECTED>" ENTRY(x,time-desclist) "</option>" SKIP.
                
        ELSE
            {&OUT}
                "                               <option value='" ENTRY(x,time-desclist) "'>" ENTRY(x,time-desclist) "</option>" SKIP.
                
                
    END.
                
    {&OUT}
        "                           </select></td>" skip                       
        "                       </tr>" skip.
END. 
    
{&OUT}
    "                       <tr>" skip
    "                           <td>Description of Hours Charged</td>" skip
    "                           <td colspan='3' class='{8}'>" SKIP
    "                             <textarea rows='5' cols='85' maxlength='500' NAME='h-hours-desc' VALUE='" hours-desc "' {9} " SKIP 
    "onkeypress='CheckMaxLength(~"chars_remaining~", this, 500);' " SKIP
    "onkeydown='CheckMaxLength(~"chars_remaining~", this, 500);' " SKIP
    "onkeyup='CheckMaxLength(~"chars_remaining~", this, 500);'>" hours-desc "</textarea><br>" SKIP 
    "                             <span id='chars_remaining'></span>" skip
    "                           </td>" SKIP                 
    "                       </tr>" skip
    "                   </table>" skip
    "               </div>" skip                 
    "       </div>" skip
    "   </div class='grid_2'></div>" skip
    "</div>" skip
    "<BR>" SKIP. 

IF "{1}" = "UPDATE" THEN

    {&OUT}
        "<div class='row'>" SKIP
        "   <INPUT type='hidden' name='whattorun' value='" whatshouldrun "' />" SKIP
        "   <INPUT type='hidden' name='h-clnt-trans' value='" clnt-trans "' />" SKIP
        "   <INPUT type='hidden' name='h-old-clientid' value='" old-clientid "' />" SKIP
        "   <INPUT type='hidden' name='h-old-projname' value='" old-projname "' />" SKIP
        "   <INPUT type='hidden' name='h-old-date' value='" pass-old-date "' />" SKIP  
        "   <INPUT type='hidden' name='h-old-time' value='" pass-old-time "' />" SKIP
        "   <INPUT type='hidden' name='h-old-time-desc' value='" old-time-desc "' />" SKIP
        
        "   <input type='hidden' name='h-admin' value='" v-admin "'>" SKIP
        "   <div class='grid_2-5'> </DIV>" SKIP
        "   <div class='grid_1'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{12}</BUTTON></div>" SKIP
        "   <div class='grid_1'> </DIV>" SKIP        
        "   <div class='grid_1'><BUTTON type='reset' class='btn'>Reset Fields</BUTTON></div>" SKIP 
        "   <div class='grid_1'> </DIV>" SKIP
        "   <div class='grid_1'><BUTTON type='submit' name='h-act' value='DELETE' class='btn'>Delete Entry</BUTTON></div>" SKIP
        "   <div class='grid_1'> </DIV>" SKIP
        "   <div class='grid_1'><BUTTON type='submit' name='h-act' value='' class='btn'>Restart Entry</BUTTON></div>" SKIP
        "   <div class='grid_2-5'> </DIV>" SKIP
        "</div>" SKIP
        "</form>" SKIP.    

ELSE IF "{1}" = "EMPLOYEE" THEN 

        {&OUT}    
            "<div class='row'>" SKIP
            "   <div class='grid_5'> </DIV>" SKIP
            "   <INPUT type='hidden' name='whattorun' value='" whatshouldrun "' />" SKIP
            "   <input type='hidden' name='h-admin' value='" v-admin "'>" SKIP  
            "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{12}</BUTTON></div>" SKIP
            "   <div class='grid_5'> </DIV>" SKIP
            "</div>" SKIP
            "</form>" SKIP. 

    ELSE 
   
        {&OUT}    
            "<div class='row'>" SKIP
            "   <div class='grid_2'> </DIV>" SKIP
            "   <INPUT type='hidden' name='whattorun' value='" whatshouldrun "' />" SKIP 
            "   <INPUT type='hidden' name='h-old-clientid' value='" old-clientid "' />" SKIP
            "   <INPUT type='hidden' name='h-old-projname' value='" old-projname "' />" SKIP
            "   <INPUT type='hidden' name='h-old-date' value='" pass-old-date "' />" SKIP 
            "   <INPUT type='hidden' name='h-old-time' value='" pass-old-time "' />" SKIP
            "   <input type='hidden' name='h-admin' value='" v-admin "'>" SKIP     
            "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{12}</BUTTON></div>" SKIP
            "   <div class='grid_1'> </DIV>" SKIP
            "   <div class='grid_2'><BUTTON type='reset' class='btn'>Reset Fields</BUTTON></div>" SKIP
            "   <div class='grid_1'> </DIV>" SKIP
            "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='' class='btn'>Restart Entry</BUTTON></div>" SKIP      
            "   <div class='grid_2'> </DIV>" SKIP
            "</div>" SKIP
            "</form>" SKIP. 
 
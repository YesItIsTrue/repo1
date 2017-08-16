
/*------------------------------------------------------------------------
    File        : add_RP_rec.i
    Purpose     : An include procedure for adding an RP record to a existing patient record.

    Syntax      :

    Description : This is HTML form without submit buttons. Submit buttons has to be included in the calling procedure.

    Author(s)   : Mark Jacobs
    Created     : Thu May 21 11:28:48 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/



  
/* ***************************  Main Block  *************************** */


    
                                                                            
   
{&OUT}  
       "   <div class='row'>" SKIP 
       "   <div class='grid_12'>" SKIP
       "   <div class='table_3col'>" SKIP         
       "     <form method='post' ACTION='patient_RP_add.r'>" SKIP         
       "            <table >" SKIP 
       "                    <th colspan='6'>Create Responsible Person</th>" SKIP                         
       "                 <tr>" SKIP                
       "                 <th colspan='2'>Personal </th><th colspan='2'>Address </th><th colspan='3'>Contact </th>" SKIP           
       "                 <tr>" SKIP              
       "                     <td>Prefix</td><td><INPUT TYPE='text' NAME='rptitle' VALUE='' tabindex=43  ></td>" SKIP 
       "                     <td>Address Line1</td><td class='required'><INPUT TYPE='text' NAME='rpaddr1' VALUE='' tabindex=49 required></td>" SKIP
       "                     <td>Home Number</td><td align='left'><INPUT TYPE='text' NAME='rphome' VALUE=''  tabindex=56></td>" SKIP
       "                 </tr>" SKIP                         
       "                 <tr>" SKIP
       "                     <td>First Name</td><td class='required'><INPUT TYPE='text' NAME='rpfstn' VALUE='' tabindex=44 required></td>" SKIP
       "                     <td>Address Line2</td><td><INPUT TYPE='text' NAME='rpaddr2' VALUE='' tabindex=50></td>" SKIP
       "                     <td>Work Number</td><td align='left'><INPUT TYPE='text' NAME='rpwork' VALUE=''  tabindex=57></td>" SKIP
       "                 </tr>" SKIP   
       "                 <tr>" SKIP
       "                      <td>Middle Name</td><td><INPUT TYPE='text' NAME='rpmidn' VALUE='' tabindex=45></td>" SKIP   
       "                      <td>Address Line3</td><td><INPUT TYPE='text' NAME='rpaddr3' VALUE='' tabindex=51></td>" SKIP
       "                      <td>Cell Number</td><td align='left'><INPUT TYPE='text' NAME='rpcell' VALUE='' tabindex=58></td>" SKIP                             
       "                 </tr>" SKIP
       "                 <tr>" SKIP
       "                      <td>Last Name</td><td class='required'><INPUT TYPE='text' NAME='rplstn' VALUE='' tabindex=46 required></td>" SKIP                                
       "                      <td>City</td><td class='required'><INPUT TYPE='text' NAME='rpcity' VALUE='' tabindex=52 required></td>" SKIP  
       "                      <td>Fax Number</td><td align='left'><INPUT TYPE='text' NAME='rpfax' VALUE=''  tabindex=59></td>" SKIP                      
       "                 </tr>" SKIP
       "                 <tr>" SKIP
       "                      <td>Suffix</td><td><INPUT TYPE='text' NAME='rpsuffix' VALUE='' tabindex=47></td>" SKIP 
             
       "                      <td>State</td><td class='required'><SELECT NAME='rpst' tabindex=53 required >" SKIP
       "                           <OPTION SELECTED></OPTION>" SKIP
       "                           <OPTION VALUE=''></OPTION> " SKIP.
         
                                FOR EACH state_mstr NO-LOCK :
                                    ASSIGN
                                        RP-stname = state_mstr.State_Display_Name
                                        RP-stabbv = state_mstr.State_ISO.

{&OUT}
       "                           <OPTION VALUE=" RP-stabbv ">" RP-stname  "</option> " SKIP. 
               
                                END.  /* FOR EACH states_mstr */
         
{&OUT}                            
       "                      <td>Email Address</td><td class='required'><INPUT TYPE='text' NAME='rpemail' VALUE='' tabindex=60 required></td>" SKIP  
       "                 </tr>" SKIP
       "                 <tr>" SKIP
       "                      <td>Date of Birth</td ><td><input type='date' name='h-RP-dob' value='' tabindex=48></td>" SKIP                              
       "                      <td>Zip Code</td><td class='required'><input type='text' name='rpzip' value='' tabindex=54 required></td>" SKIP                      
       "                      <td>Second Email</td><td><input type='text' name='rpemail2' value='' tabindex=61></td>" SKIP    
       "                 </tr>" SKIP
       "                 <tr>" SKIP
       "                      <td></td><td></td>" SKIP 
                              
       "                      <td>Country</td><td><select name='rpcount' tabindex=55 >" SKIP
       "                       <option selected></option>" SKIP
       "                       <option value=''></option> " SKIP.  
  
                                FOR EACH country_mstr NO-LOCK :
                                    ASSIGN
                                        coname = country_mstr.Country_Display_Name
                                        coabbv = country_mstr.Country_ISO. 
 
{&OUT}
       "                     <OPTION VALUE=" coabbv ">" coname  "</OPTION>" SKIP.
      
                     
                             END.  /* FOR EACH county_mstr */
       
{&OUT}
       "                      <td colspan='2'></td>" SKIP                       
       "                 </tr>" SKIP .                                                 

  
                

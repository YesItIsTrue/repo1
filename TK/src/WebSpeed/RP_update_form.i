
/*------------------------------------------------------------------------
    File        : RP_update_form.i
    Purpose     : 

    Syntax      :

    Description : HTML input form for patient RP updates

    Author(s)   : Mark Jacobs
    Created     : Thu Jun 04 11:12:20 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */ 
{&OUT}

    " <div class='table_3col'>" SKIP
    "            <form method='post' ACTION='patient_update4.r'>" SKIP 
    "                <center>" SKIP
    "               <table >" SKIP 
    
    "                    <tr>" SKIP
    "                     <th colspan='6'>Responsible Person</th>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP 
    "                    <th colspan='2'>Personal</th><th colspan='2'>Address</th><th colspan='2'>Contact</th>" SKIP
    "                    <tr>" SKIP
    "                        <td>Prefix</td><td><input type='text' name='rptitle'tabindex=1 autofocus value=" RP-title "></td>" SKIP
    "                        <td>Address Line1</td><td><input type='text' name='rpaddr1'tabindex=9 value='" RP-add1 "' ></td>" SKIP 
    "                        <td>Home Number</td><td align='left'><input type='text' name='rphome'tabindex=16 value='" RP-H-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                        <td>First Name</td><td><input type='text' name='rpfstn'tabindex=2 value='" RP-fstn "' DISABLED></td>" SKIP
    "                        <td>Address Line2</td><td><input type='text' name='rpaddr2'tabindex=10 value='" RP-add2 "'></td>" SKIP
    "                        <td>Work Number</td><td align='left'><input type='text' name='rpwork'tabindex=17 value='" RP-w-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                         <td>Middle Name</td><td><input type='text' name='rpmidn'tabindex=3 value='" RP-midn "'></td>" SKIP
    "                         <td>Address Line3</td><td><input type='text' name='rpaddr3'tabindex=11 value='" RP-add3 "'></td>" SKIP
    "                         <td>Cell Number</td><td align='left'><input type='text' name='rpcell'tabindex=18 value='" RP-c-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                         <td>Last Name</td><td><input type='text' name='rplstn'tabindex=4 value='" RP-lstn "' DISABLED></td>" SKIP
    "                         <td>City</td><td><input type='text' name='rpcity'tabindex=12 value='" RP-city "'></td>" SKIP
    "                         <td>Fax Number</td><td align='left'><input type='text' name='rpfax'tabindex=19 value='" RP-fax-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                          <td>Suffix</td><td><input type='text' name='rpsuffix'tabindex=5 value='" RP-suf "'></td>" SKIP

    "                          <td>State</td><td><select name='rpst' tabindex=13 >" SKIP
    "                              <option selected>" RP-state-prov "</option>" SKIP
    "                              <option value=''></option>" SKIP.
            
                                 FOR EACH state_mstr WHERE 
                                          state_mstr.state_deleted = ? NO-LOCK :
                                                         
                                 IF state_mstr.State_ISO  = RP-state-prov AND 
                                 state_mstr.State_Country_ISO = RP-country THEN    
                                    isselected  = "SELECTED".                                          
                                 ELSE             
                                    isselected  = "". 
            /*
                            FOR EACH state_mstr NO-LOCK: 
                                ASSIGN
                                   RP-stname = state_mstr.State_Display_Name
                                   RP-stabbv = state_mstr.State_ISO.
            */   
            
            {&OUT}
     "            <option value=~"" state_mstr.State_ISO "~" " isselected " >" state_mstr.State_Display_Name "</option>" SKIP. 
  /*                                                           
{&OUT}
    "                        <option Value=" RP-stabbv ">" RP-stname  "</otion>" SKIP.
*/
                             END.  /* FOR EACH states_mstr */
{&OUT}
    "                          <td>Email Address</td><td><input type='text' name='rpemail'tabindex=20 value='" RP-email "'DISABLED></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                          <td>Date of Birth</td>" SKIP.

                                IF patdob = ? THEN
{&OUT}
    "                          <td><input type='text' name='h-RP-dob'tabindex=6 value=''DISABLED></td>" SKIP.
                                    ELSE.
{&OUT}
    "                          <td><input type='text' name='h-RP-dob'tabindex=6 value='" RP-dob "'DISABLED></td>" SKIP

    "                          <td>Zip Code</td><td><input type='text' name='rpzip'tabindex=14 value='" RP-zip "'></td>" SKIP

    "                          <td>Second Email</td><td><input type='text' name='rpemail2'tabindex=21 value='" RP-email2 "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP   
    "                    <td></td><td></td>" SKIP 
/*    "                          <td>Gender</td><td>Male<input type='radio' name='gender'tabindex=7 value='true' " male-ck ">" SKIP        */
/*    "                                           Female<input type='radio' name='gender'tabindex=7 value='false' " female-ck "></td>" SKIP*/

    "                          <td>Country</td><td><select name='rpcount' tabindex=15 >" SKIP
    "                           <option selected>" RP-country "</option>" SKIP
    "                           <option value=''></option>" SKIP.

                            FOR EACH country_mstr NO-LOCK :
                                ASSIGN
                                    coname = Country_Display_Name
                                    coabbv = Country_ISO.
{&OUT}
    "                           <option Value=" coabbv ">" coname  "</option>" SKIP.

                             END.  /* FOR EACH county_mstr */
{&OUT}
    "                    <td colspan='2'></td>" SKIP
    "                    </tr>" SKIP.
    
    
    
    
    
    
 
    
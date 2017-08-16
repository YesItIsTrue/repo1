
/*------------------------------------------------------------------------
    File        : patient_update_form.i
    Purpose     : 

    Syntax      :

    Description : HTML input form for patient updates

    Author(s)   : Mark Jacobs
    Created     : Wed Jun 03 11:12:20 EDT 2015
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
    "                    <th colspan='2'>Personal</th><th colspan='2'>Address</th><th colspan='2'>Contact</th>" SKIP
    "                    <tr>" SKIP
    "                        <td>Prefix</td><td><input type='text' name='title'tabindex=1 autofocus value=" pattitle "></td>" SKIP
    "                        <td>Address Line1</td><td><input type='text' name='addr1'tabindex=9 value='" add1 "' ></td>" SKIP  
    "                        <td>Home Number</td><td align='left'><input type='text' name='home'tabindex=16 value='" h-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                        <td>First Name</td><td><input type='text' name='fstn'tabindex=2 value='" patfstn "' DISABLED></td>" SKIP
    "                        <td>Address Line2</td><td><input type='text' name='addr2'tabindex=10 value='" add2 "'></td>" SKIP
    "                        <td>Work Number</td><td align='left'><input type='text' name='work'tabindex=17 value='" w-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                         <td>Middle Name</td><td><input type='text' name='midn'tabindex=3 value='" patmidn "'></td>" SKIP
    "                         <td>Address Line3</td><td><input type='text' name='addr3'tabindex=11 value='" add3 "'></td>" SKIP
    "                         <td>Cell Number</td><td align='left'><input type='text' name='cell'tabindex=18 value='" c-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                         <td>Last Name</td><td><input type='text' name='lstn'tabindex=4 value='" patlstn "' DISABLED></td>" SKIP
    "                         <td>City</td><td><input type='text' name='patcity'tabindex=12 value='" city "'></td>" SKIP
    "                         <td>Fax Number</td><td align='left'><input type='text' name='fax'tabindex=19 value='" fax-phone "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                          <td>Suffix</td><td><input type='text' name='suffix'tabindex=5 value='" patsuf "'></td>" SKIP

    "                          <td>State</td><td><select name='st' tabindex=13 >" SKIP
    "                              <option selected>" state-prov "</option>" SKIP
    "                              <option value=''></option>" SKIP.

                            FOR EACH state_mstr NO-LOCK:
                                ASSIGN
                                    stname = state_mstr.state_name 
                                    stabbv = state_mstr.state_abbv.
{&OUT}
    "                        <option Value=" stabbv ">" stname  "</otion>" SKIP.

                             END.  /* FOR EACH states_mstr */
{&OUT}
    "                          <td>Email Address</td><td><input type='text' name='e-mail'tabindex=20 value='" email "'DISABLED></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                          <td>Date of Birth</td>" SKIP.

                                IF patdob = ? THEN
{&OUT}
    "                          <td><input type='text' name='dob'tabindex=6 value=''></td>" SKIP.
                                    ELSE.
{&OUT}
    "                          <td><input type='text' name='dob'tabindex=6 value='" patdob "'DISABLED></td>" SKIP

    "                          <td>Zip Code</td><td><input type='text' name='zip'tabindex=14 value='" patzip "'></td>" SKIP

    "                          <td>Second Email</td><td><input type='text' name='e-mail2'tabindex=21 value='" email2 "'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "                          <td>Gender</td><td>Male<input type='radio' name='gender'tabindex=7 value='true' " male-ck ">" SKIP
    "                                           Female<input type='radio' name='gender'tabindex=7 value='false' " female-ck "></td>" SKIP

    "                          <td>Country</td><td><select name='co' tabindex=15 >" SKIP
    "                           <option selected>" country "</option>" SKIP
    "                           <option value=''></option>" SKIP.

                            FOR EACH country_mstr NO-LOCK :
                                ASSIGN
                                    coname = country_name
                                    coabbv = country_abbv.
{&OUT}
    "                           <option Value=" coabbv ">" coname  "</option>" SKIP.

                             END.  /* FOR EACH county_mstr */
{&OUT}
    "                    <td colspan='2'></td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP

    "                         <td>Doctor</td><td><select name='doctor' tabindex=8 >" SKIP.

                     IF patdoc  = 0 THEN DO: /* This keeps a (,) from displaying if Dr. field is blank */
{&OUT}
    "                          <option value=" "selected></option>" SKIP  /* patdoc */
    "                                <option value=''></option>" SKIP.
                                FOR EACH doctor_mstr NO-LOCK,
                                  EACH people_mstr WHERE people_mstr.people_id = doctor_mstr.doctor_id NO-LOCK
                                  BREAK BY people_mstr.people_lastname BY people_mstr.people_firstname:

                                   ASSIGN
                                    doc-lname = people_mstr.people_lastname
                                    doc-fname = people_mstr.people_firstname
                                    doc-id    = people_mstr.people_id.
{&OUT}
    "                                <option Value=" doc-id ">" doc-lname " , " doc-fname "</otion>" SKIP.

                                 END.  /* FOR EACH states_mstr */
                     END. /* then DO: */

                     ELSE

{&OUT}
    "                         <option value=" patdoc " selected>" doc-lname " , " doc-fname " </option>" SKIP
    "                                 <option value=''></option>" SKIP.

                            FOR EACH doctor_mstr NO-LOCK,
                                EACH people_mstr WHERE people_mstr.people_id = doctor_mstr.doctor_id NO-LOCK
                                BREAK BY people_mstr.people_lastname BY people_mstr.people_firstname:


                                   ASSIGN
                                    doc-lname = people_mstr.people_lastname
                                    doc-fname = people_mstr.people_firstname
                                    doc-id    = people_mstr.people_id.
{&OUT}
    "                                <option Value=" doc-id ">" doc-lname " , " doc-fname "</otion>" SKIP.

                             END.  /* FOR EACH states_mstr */
{&OUT}
    "                    </td>" SKIP
    "                    <td colspan='4'</td>" SKIP
    "                    </tr>" SKIP

    "                    <tr>" SKIP
    "                    <th colspan='6'>Comments</th></tr>" SKIP
    "                    <tr>" SKIP
    "                        <td>Notes</td><td colspan='3'><textarea rows='2' cols='60' NAME='notes' VALUE=~"" patnotes "~" tabindex=23>" patnotes  "</textarea></td></td><td colspan='2'</td>" SKIP
    "                    </tr>" SKIP
    "                    <tr>" SKIP
    "<TD>DOUG WAS HERE</TD>" SKIP
    "</TR>" SKIP
    "<TR>" SKIP.
         
  
    
    
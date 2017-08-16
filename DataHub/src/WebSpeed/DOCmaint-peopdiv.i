
/*------------------------------------------------------------------------
    File        : Doctor-maintenance-peoplediv.i
    Purpose     : To shorten the code.
    Description : This is an include file for the Doctor-maintenance.html program, 
                    this is the piece that has the div that reports the people_mstr.
    Author(s)   : Trae Luttrell
    Created     : Mon Oct 27 12:17:32 MDT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */

{&OUT}
                "<div class='table_2col'>" SKIP            
                "   <table>"    SKIP      
                "       <tr>"   SKIP
                "           <th colspan='2'>Name</th><th colspan='2'>Phone, etc.</th>" SKIP
                "       </tr>"  SKIP
                "       <tr>"   SKIP           
                "           <td>Prefix:</td>"       SKIP
                "           <td " .
                
            IF people_mstr.people_prefix <> v-prefix AND v-prefix <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">" people_mstr.people_prefix "</td>"     SKIP 
                "           <td>Home Number:</td>"  SKIP      
                "           <td".
            IF people_mstr.people_homephone <> v-home-phone AND v-home-phone <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_homephone "</td>"   SKIP
                "       </tr>" SKIP                          
                "       <tr>" SKIP 
                "           <td>First Name:</td>" SKIP
                "           <td".
            IF people_mstr.people_firstname <> v-firstname AND v-firstname <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_firstname "</td>" SKIP 
                "           <td>Work Number:</td>" SKIP
                "           <td".
            IF people_mstr.people_workphone <> v-work-phone AND v-work-phone <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_workphone "</td>" SKIP
                "       </tr>" SKIP
                "       <tr>" SKIP
                "           <td>Middle Name:</td>" SKIP
                "           <td".
            IF people_mstr.people_midname <> v-midname AND v-midname <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">" people_mstr.people_midname "</td>" SKIP   
                "           <td>Cell Number:</td>" SKIP
                "           <td".
            IF people_mstr.people_cellphone <> v-cell-phone AND v-cell-phone <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_cellphone "</td>" SKIP
                "       </tr>" SKIP
                "       <tr>" SKIP
                "           <td>Last Name:</td>" SKIP
                "           <td".
            IF people_mstr.people_lastname <> v-lastname AND v-lastname <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_lastname "</td>" SKIP
                "           <td>Fax Number:</td>" SKIP        
                "           <td".
            IF people_mstr.people_fax <> v-fax-phone AND v-fax-phone <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_fax   "</td>" SKIP
                "       </tr>" SKIP 
                "       <tr>" SKIP
                "           <td>Suffix:</td>" SKIP            
                "           <td".
            IF people_mstr.people_suffix <> v-suffix AND v-suffix <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_suffix "</td>" SKIP
                "           <td>Company:</td>" SKIP
                "           <td".
            IF people_mstr.people_company <> v-company AND v-company <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_company "</td>" SKIP
                "       </tr>" SKIP 
                "       <tr>" SKIP
                "           <td>Email Address:</td>" SKIP
                "           <td".
            IF people_mstr.people_email <> v-email AND v-email <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">" people_mstr.people_email "</td>" SKIP
                "           <td>Second Email Address:</td>" SKIP
                "           <td".
            IF people_mstr.people_email2 <> v-email-2 AND v-email-2 <> "" THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_email2 "</td>" SKIP
                "       </tr>" SKIP 
                "       <tr>" SKIP
                "           <td>Date of Birth:</td>" SKIP
                "           <td".
            IF people_mstr.people_DOB <> v-o-datestrip AND v-o-datestrip <> ? THEN {&OUT} " class='alt'".
            {&OUT} ">"people_mstr.people_DOB "</td>" SKIP
                "           <td></td>" SKIP
                "           <td></td>" SKIP
                "       </tr>" SKIP        
                "   </table>" SKIP
                "</div>" SKIP.
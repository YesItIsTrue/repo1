
/*------------------------------------------------------------------------
    File        : address-form-stste.i
    Purpose     : 

    Syntax      :

    Description : Form to be used to create or edit an address record.

    Author(s)   : Mark Jacobs
    Created     : Thu Mar 19 11:54:35 EDT 2015  
    Notes       : 
  ----------------------------------------------------------------------*/   
 
       
       
/* ***************************  Main Block  *************************** */     

     FIND country_mstr WHERE country_mstr.country_abbv = county NO-LOCK NO-ERROR.  
    
            IF AVAILABLE (country_mstr) THEN
            ASSIGN 
            coname = country_mstr.country_name.                          
                                                                              
         {&OUT}         
            "<tr>
                <td>Country</td><td>" coname "</td></tr>     
             <tr>    
                <td>Address Line1</td><td><input type='text' name='adress1' value=" addr1 "></td></tr>              
             <tr>   
                <td>Address Line2</td><td><input type='text' name='adress2' value=" addr2 "></td></tr>
             <tr>
                <td>Address Line3</td><td><input type='text' name='adress3' value=" addr3 "></td></tr>    
             <tr>
                <td>City</td><td><input type='text' name='ci' value=" city "></td></tr>
             <tr>
                <td>State</td><td><select name='st'>
                                            <option></option>".
                                                
                                          FOR EACH state_mstr WHERE state_mstr.state_country = country_mstr.country_abbv NO-LOCK :
                                           ASSIGN
                                                 is-select-state = IF stname = state_mstr.state_name THEN
                                                    "selected"
                                                   ELSE
                                                    "".    
/*                                                    stname = state_mstr.state_name.*/
/*                                                    stabbv = state_mstr.state_abbv.*/
                                       {&OUT} "             
                                               <option Value=" state_mstr.state_abbv " "is-select-state ">" state_mstr.state_name  "</otion> ". 
                                               
                                          END.  /* FOR EACH state_mstr NO-LOCK : */
                                              
       {&OUT}
       
            "<tr>
                <td>Zip Code</td><td><input type='text' name='zp' value=" zip "></td></tr> ".
    
      
/*------------------------------------------------------------------------
    File        : StatusListDropDown.i 
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Wed Feb 03 05:58:36 MST 2016
    Notes       :
        
        Example Code:
         {&OUT}   
            "       <tr>" SKIP
            "           <td>From Status</td>" skip 
            "           <td><select>". skip
            {../depot/src/WebSpeed/StatusListDropDown.i}.
            
         {&OUT}
            "           </select></td>" skip
            "           <td>To</td>" skip
            "           <td><select>". skip
            
            {../depot/src/WebSpeed/StatusListDropDown.i}.
            
         {&OUT} 
             "           </select></td>" skip  
            "       </tr>" skip
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 

/* ********************  Preprocessor Definitions  ******************** */
 

/* ***************************  Main Block  *************************** */
{&OUT} 
"               <option value='' ></option>" SKIP
"               <option value='CREATED' >CREATED</option>" SKIP
"               <option value='IN_STOCK' >IN_STOCK</option>" SKIP
"               <option value='SOLD' >SOLD</option>" SKIP
"               <option value='SHIPPED' >SHIPPED</option>" SKIP
"               <option value='COLLECTED' >COLLECTED</option>" SKIP
"               <option value='LAB_RCVD' >LAB_RCVD</option>" SKIP
"               <option value='LAB_PROCESS' >LAB_PROCESS (Lab Completed)</option>" SKIP
"               <option value='HHI_RCVD' >HHI_RCVD</option>" SKIP
"               <option value='LOADED' >LOADED</option>" SKIP
"               <option value='PROCESSED' >PROCESSED (HHI Processed)</option>" SKIP
"               <option value='PRINTED' >PRINTED</option>" SKIP
"               <option value='EMAILED' >EMAILED</option>" SKIP
"               <option value='COMPLETE' >COMPLETE</option>" SKIP
"               <option value='PAID_BY_CUST' >PAID_BY_CUST</option>" SKIP
"               <option value='VEND_PAID' >VEND_PAID</option>" SKIP
"               <option value='DELETED' >DELETED</option>" SKIP
"               <option value='VOID' >VOID</option>" SKIP. 
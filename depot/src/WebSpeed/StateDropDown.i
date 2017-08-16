
/*------------------------------------------------------------------------
    File        : StateDropDown.i
    Description : The WebSpeed code for a state drop down. 

    Author(s)   : Trae Luttrell
    Created     : Thu Oct 01 12:26:09 EDT 2015
    Notes       : This ought to be in the middle of the HTML <select> tag.
    
    Here is a wee-example:
    
    DEFINE VARIABLE v-state_abbv AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-state_country AS CHARACTER NO-UNDO.
    DEFINE VARIABLE isselected AS LOGICAL NO-UNDO.
    DEFINE VARIABLE v-act AS INTEGER NO-UNDO.
    ASSIGN 
        v-state_abbv = get-value("h-state")
        v-state_country = get-value ("h-country") 
        v-act = INTEGER(get-value("h-act")).
    {&OUT}
        "<form>" SKIP 
        "<table>" SKIP
        "   <tr>" SKIP
        "       <td>Choose a State</td>" SKIP
        "       <td><select name='h-state'>" SKIP.       
    {StateDropDown.i v-state_abbv v-state_country}.   
    {&OUT}    
        "       </select></td>" SKIP 
        "   </tr>" SKIP
        "   <tr>" SKIP 
        "       <td> Choose a Country </td>" SKIP
        "       <td><select name='h-country'>" SKIP
        "           <option value=''></option>" SKIP.
    FOR EACH country_mstr NO-LOCK:   
        {&OUT} "<option value='" country_mstr.country_abbv "' >" country_mstr.country_name "</option>" SKIP.
    END.
    {&OUT}    
        "</table>"
        "<button type='submit' name='h-act' value=1>Go</button>" SKIP
        "</form>". 
    IF v-act = 1 THEN DO:
        {&OUT}
            "<p><I> Awesome! You chose <b>" v-state_abbv "</b> which is in <b>" v-state_country "</b></i></p>" SKIP.
    END.
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */

FOR EACH state_mstr  WHERE                  
    state_mstr.state_deleted = ? AND 
    state_mstr.state_primary = YES AND 
    state_mstr.state_country_ISO = {2} NO-LOCK:    

    IF state_mstr.state_ISO = {1} AND state_mstr.state_country_ISO = {2} THEN    
        {&OUT}
    "<option value=~"" state_mstr.state_ISO "~" SELECTED >" state_mstr.state_display_name "</option>" SKIP.
    ELSE             
        {&OUT}
            "<option value=~"" state_mstr.state_ISO "~">" state_mstr.state_display_name "</option>" SKIP. 

END.  /** of 4ea. state_mstr **/

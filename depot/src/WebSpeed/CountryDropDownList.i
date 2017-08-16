
/*------------------------------------------------------------------------
    File        : CountryDropDownList.i
    Purpose     : Unifining code	

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Wed Feb 03 06:54:59 MST 2016
    Notes       :
        Example Code:
            define variable v-country LIKE country_mstr.Country_ISO no-undo.
            define variable isselected as character no-undo.
            
            "       <tr>" SKIP
            "            <td>Country</td>" SKIP
            "            <TD>" SKIP
            "                <SELECT name='h-country'>" SKIP
            "                    <option value=''></option>".
            
        {../depot/src/WebSpeed/CountryDropDownList.i v-country}.
        
        {&OUT}
                "           </SELECT>" SKIP
                "       </TD>" SKIP
                "           <td colspan=4></td>" SKIP
                "       </tr>" SKIP              
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

 
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

            
FOR EACH country_mstr WHERE 
    country_mstr.country_deleted = ? AND 
    country_mstr.Country_Primary = YES NO-LOCK      
    BREAK BY country_mstr.Country_Display_Name:
        
    IF country_mstr.Country_ISO = {1} THEN                                                   
        isselected = "SELECTED".
    ELSE 
        isselected = "".
                
    {&OUT}
    "<option value=~"" country_mstr.Country_ISO "~" " isselected " >" country_mstr.Country_Display_Name "</option>" SKIP.
 
END.  /* FOR EACH country_mstr */
        

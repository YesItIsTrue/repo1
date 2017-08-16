
/*------------------------------------------------------------------------
    File        : UOMDropDown.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Mon Feb 29 08:13:30 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */ 
 
FOR EACH uom_mstr  WHERE uom_mstr.uom_type = "{2}" AND            
    uom_mstr.uom_deleted = ? NO-LOCK:    
   
    IF uom_mstr.uom_uom = {1} THEN    
        {&OUT}
    "<option value='" uom_mstr.uom_uom "' SELECTED >" uom_mstr.uom_uom "</option>" SKIP.
    ELSE             
        {&OUT}
            "<option value='" uom_mstr.uom_uom "'>" uom_mstr.uom_uom "</option>" SKIP. 

END.  /** of 4ea. state_mstr **/
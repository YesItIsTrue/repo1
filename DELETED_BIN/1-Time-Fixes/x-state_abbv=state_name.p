
/*------------------------------------------------------------------------
    File        : state_abbv=state_name.p
    Purpose     : 

    Syntax      :

    Description : A small utility to be run against the state table in General database. This will fix the records 
                  that are without an value in the abbreviation field.                  
                  As of 9/11/2015 after running this utility there will be 30 records that haven't any value in the
                  abbreviation field or the name field, but have a value in the country field.This utility does not address this. 

    Author(s)   : Mark Jacobs
    Created     : Fri Sep 11 10:38:14 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE VARIABLE cout AS INTEGER INITIAL 0 NO-UNDO. 
DEFINE VARIABLE new-cout AS INTEGER NO-UNDO.


/* ***************************  Main Block  *************************** */



 FOR EACH state_mstr WHERE state_mstr.state_abbv = "" :
           
           cout = cout + 1.
           
           IF state_mstr.state_name = "" THEN 
              DISPLAY cout state_mstr.state_abbv (COUNT) state_mstr.state_name FORMAT "x(8)"
                state_mstr.state_country FORMAT "x(6)" state_mstr.state_stateID FORMAT "zzzz". 
           ELSE         
           ASSIGN 
                state_mstr.state_abbv = state_mstr.state_name
                new-cout = new-cout + 1.

  END.    
           DISPLAY cout new-cout.            
 



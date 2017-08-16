
/*------------------------------------------------------------------------
    File        : people-address-to-pal-.p
    Purpose     : Code Overhaul June 2017

    Syntax      :

    Description : Merges people_mstr adresses into pal_list

    Author(s)   : Andrew Garver
    Created     : Tue Jun 20 09:31:36 EDT 2017
    Notes       :
    
    ------------------------------------------------------------------
    Revision History:
    -----------------
    1.0 - written by ANDREW GARVER on 20/Jun/17.  Original Version.
    1.1 - written by DOUG LUTTRELL on 20/Aug/17.  Added in code to 
            respect the *_deleted field.  Marked by 1dot1.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE v-requestedkey LIKE General.pal_list.pal_people_ID NO-UNDO.
DEFINE VARIABLE v-create      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-update      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-avail       AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE VARIABLE v-successful  AS LOGICAL INITIAL NO           NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH people_mstr where people_deleted = ? NO-LOCK:          /* 1dot1 */

    IF (people_mstr.people_addr_id <> 0) THEN 
    DO:      
          
        RUN VALUE(SEARCH("SUBpal-ucU.r")) 
            (people_mstr.people_id, people_mstr.people_addr_id, "PRIMARY", 
             "people_id", NO, "",
             OUTPUT v-requestedkey, OUTPUT v-create, OUTPUT v-update, 
             OUTPUT v-avail, OUTPUT v-successful).
             
    END.    /** of if people_addr_id <> 0 **/
    
    IF (people_mstr.people_second_addr_ID <> 0 AND 
        people_mstr.people_second_addr_ID <> people_mstr.people_addr_id) THEN 
    DO:
    
        RUN VALUE(SEARCH("SUBpal-ucU.r")) 
            (people_mstr.people_id, people_mstr.people_second_addr_id, 
             "SECONDARY", "people_id", NO, "",
             OUTPUT v-requestedkey, OUTPUT v-create, OUTPUT v-update, 
             OUTPUT v-avail, OUTPUT v-successful).
    
    END.    /** of if people_second_addr_ID <> 0 and diff **/
    
    IF (people_mstr.people__dec01 <> 0 AND 
        (people_mstr.people__dec01 <> people_mstr.people_addr_id OR 
         people_mstr.people__dec01 <> people_mstr.people_second_addr_ID)) THEN 
    DO:
    
        RUN VALUE(SEARCH("SUBpal-ucU.r")) 
            (people_mstr.people_id, people_mstr.people_second_addr_id, 
             "SECONDARY", "people_id", NO, "",
             OUTPUT v-requestedkey, OUTPUT v-create, OUTPUT v-update, 
             OUTPUT v-avail, OUTPUT v-successful).
             
    end.  /** of if people__dec01 <> 0 AND diff **/
    
end.  /*** of 4ea. people_mstr ***/


/*********************  EOF  ***************************/
             

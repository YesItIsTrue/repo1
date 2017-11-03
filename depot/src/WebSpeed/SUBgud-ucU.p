
/*------------------------------------------------------------------------
    File        : SUBgud-ucU.p
    Purpose     : 

    Syntax      :

    Description : v1 simply updates a gud record with people-id, tsize, and unit

    Author(s)   : Andrew Garver
    Created     : Thu Oct 19 17:44:04 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER i-people_ID LIKE gud_det.gud_people_ID NO-UNDO.
DEFINE INPUT PARAMETER i-gud_grp_id LIKE gud_det.gud_grp_id NO-UNDO.

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND grp_mstr WHERE grp_mstr.grp_ID = i-gud_grp_id NO-ERROR.
IF AVAILABLE (grp_mstr) THEN DO: 
    CREATE gud_det.
    ASSIGN 
        gud_det.gud_people_ID = i-people_ID
        gud_det.gud_grp_id = i-gud_grp_id
        gud_det.gud_create_date = TODAY 
        gud_det.gud_created_by = USERID("Core")
        gud_det.gud_modified_date = TODAY 
        gud_det.gud_modified_by = USERID("Core")
        gud_det.gud_prog_name = THIS-PROCEDURE:FILENAME
        o-success = TRUE.
END. /* IF AVAILABLE (grp_mstr) */
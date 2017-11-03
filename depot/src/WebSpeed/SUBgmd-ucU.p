
/*------------------------------------------------------------------------
    File        : SUBgmd-ucU.p
    Purpose     : 

    Syntax      :

    Description : v1 simply creates a gmd record

    Author(s)   : Andrew Garver
    Created     : Thu Nov 2 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER i-gmd_menu_num LIKE gmd_det.gmd_menu_num NO-UNDO.
DEFINE INPUT PARAMETER i-gmd_menu_select LIKE gmd_det.gmd_menu_select NO-UNDO.
DEFINE INPUT PARAMETER i-gmd_grp_id LIKE gmd_det.gmd_grp_id NO-UNDO.

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND grp_mstr WHERE grp_mstr.grp_ID = i-gmd_grp_id NO-ERROR.
IF AVAILABLE (grp_mstr) THEN DO: 
    CREATE gmd_det.
    ASSIGN 
        gmd_det.gmd_menu_num = i-gmd_menu_num
        gmd_det.gmd_menu_select = i-gmd_menu_select
        gmd_det.gmd_grp_id = i-gmd_grp_id
        gmd_det.gmd_create_date = TODAY 
        gmd_det.gmd_created_by = USERID("Core")
        gmd_det.gmd_modified_date = TODAY 
        gmd_det.gmd_modified_by = USERID("Core")
        gmd_det.gmd_prog_name = THIS-PROCEDURE:FILENAME
        o-success = TRUE.
END. /* IF AVAILABLE (grp_mstr) */
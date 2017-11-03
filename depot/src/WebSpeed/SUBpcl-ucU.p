
/*------------------------------------------------------------------------
    File        : SUBpcl-ucU.p
    Purpose     : Update / Create pcl_det records

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Thu Oct 12 10:54:01 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER v-people-id LIKE pcl_det.pcl_patient_id NO-UNDO.
DEFINE INPUT PARAMETER v-condition-id LIKE pcl_det.pcl_cond_id NO-UNDO. 

DEFINE OUTPUT PARAMETER o-success AS LOGICAL INITIAL NO NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
CREATE pcl_det.
    ASSIGN 
         pcl_det.pcl_patient_id = v-people-id 
         pcl_det.pcl_cond_id = v-condition-id
         pcl_det.pcl_created_by = USERID("Modules")
         pcl_det.pcl_create_date = TODAY
         pcl_det.pcl_modified_by = USERID("Modules")
         pcl_det.pcl_modified_date = TODAY
         pcl_det.pcl_prog_name = THIS-PROCEDURE:FILE-NAME
         o-success = TRUE.
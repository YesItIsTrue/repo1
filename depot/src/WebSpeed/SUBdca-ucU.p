
/*------------------------------------------------------------------------
    File        : SUBdca-ucU.p
    Purpose     : 

    Syntax      :

    Description : Create or Update a record in the dca_det table

    Author(s)   : Andrew Garver
    Created     : Thu Oct 19 17:44:04 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER i-dca_event_ID LIKE dca_det.dca_event_ID NO-UNDO.
DEFINE INPUT PARAMETER i-dca_question LIKE dca_det.dca_question NO-UNDO.
DEFINE INPUT PARAMETER i-dca_people_ID LIKE dca_det.dca_people_ID NO-UNDO.
DEFINE INPUT PARAMETER i-dca_answer_datatype LIKE dca_det.dca_answer_datatype NO-UNDO.
DEFINE INPUT PARAMETER i-dca_answer_value LIKE dca_det.dca_answer_value NO-UNDO.


DEFINE OUTPUT PARAMETER o-error AS LOGICAL INITIAL YES NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND dca_det WHERE dca_det.dca_people_ID = i-dca_people_ID AND dca_det.dca_event_ID = i-dca_event_ID AND 
dca_det.dca_question = i-dca_question AND dca_det.dca_deleted = ? NO-ERROR.
    
IF AVAILABLE (dca_det) THEN DO:
/*    ASSIGN                                                 */
/*        dca_det.dca_event_ID = i-dca_event_ID              */
/*        dca_det.dca_question = i-dca_question              */
/*        dca_det.dca_people_ID = i-dca_people_ID            */
/*        dca_det.dca_answer_datatype = i-dca_answer_datatype*/
/*        dca_det.dca_answer_value = i-dca_answer_value      */
/*        dca_det.dca_modified_date = TODAY                  */
/*        dca_det.dca_modified_by = USER("Modules")          */
/*        dca_det.dca_prog_name = THIS-PROCEDURE:FILE-NAME.  */
END.
ELSE DO:
        CREATE dca_det.
        ASSIGN 
            dca_det.dca_event_ID = i-dca_event_ID
            dca_det.dca_question = i-dca_question
            dca_det.dca_people_ID = i-dca_people_ID
            dca_det.dca_answer_datatype = i-dca_answer_datatype
            dca_det.dca_answer_value = i-dca_answer_value
            dca_det.dca_create_date = TODAY 
            dca_det.dca_created_by = USER("Modules")
            dca_det.dca_modified_date = TODAY 
            dca_det.dca_modified_by = USER("Modules")
            dca_det.dca_prog_name = THIS-PROCEDURE:FILE-NAME.
END.
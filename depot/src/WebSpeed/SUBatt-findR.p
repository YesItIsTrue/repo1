
/*------------------------------------------------------------------------
    File        : SUBatt-findR.p
    Purpose     : 

    Syntax      :

    Description : The subroutine for finding records in the att_files table.

    Author(s)   : Trae Luttrell
    Created     : Mon May 09 08:30:25 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/*DEFINE VARIABLE i-att_filename LIKE att_files.att_filename INITIAL "H150130-2219-1.txt" NO-UNDO.                                 */
/*DEFINE VARIABLE i-att_filepath LIKE att_files.att_filepath INITIAL  "C:\APPS\BIOMED\AttachedFiles\22767\" FORMAT "x(50)" NO-UNDO.*/
/*DEFINE VARIABLE i-att_table LIKE att_files.att_table INITIAL "TK_mstr" NO-UNDO.                                                  */
/*DEFINE VARIABLE i-att_field1 LIKE att_files.att_field1 INITIAL  "TK_mstr.TK_lab_sample_ID" NO-UNDO.                              */
/*DEFINE VARIABLE i-att_value1 LIKE att_files.att_value1 INITIAL  "H150130-2219-1" NO-UNDO.                                        */
/*DEFINE VARIABLE i-att_field2 LIKE att_files.att_field2 INITIAL  "TK_mstr.TK_lab_seq" NO-UNDO.                                    */
/*DEFINE VARIABLE i-att_value2 LIKE att_files.att_value2 INITIAL  "1" NO-UNDO.                                                     */
/*DEFINE VARIABLE i-att_field3 LIKE att_files.att_field3 NO-UNDO.                                                                  */
/*DEFINE VARIABLE i-att_value3 LIKE att_files.att_value3 NO-UNDO.                                                                  */
/*DEFINE VARIABLE i-att_field4 LIKE att_files.att_field4 NO-UNDO.                                                                  */
/*DEFINE VARIABLE i-att_value4 LIKE att_files.att_value4 NO-UNDO.                                                                  */
/*DEFINE VARIABLE i-att_field5 LIKE att_files.att_field5 NO-UNDO.                                                                  */
/*DEFINE VARIABLE i-att_value5 LIKE att_files.att_value5 NO-UNDO.                                                                  */
/*                                                                                                                                         */
/*DEFINE VARIABLE o-att_file_id LIKE att_files.att_file_id NO-UNDO.                                                                */
/*DEFINE VARIABLE o-att-find-success AS LOGICAL NO-UNDO.                                                                                   */

DEFINE INPUT PARAMETER i-att_filename LIKE att_files.att_filename NO-UNDO.
DEFINE INPUT PARAMETER i-att_filepath LIKE att_files.att_filepath NO-UNDO.
DEFINE INPUT PARAMETER i-att_table LIKE att_files.att_table NO-UNDO.
DEFINE INPUT PARAMETER i-att_field1 LIKE att_files.att_field1 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value1 LIKE att_files.att_value1 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field2 LIKE att_files.att_field2 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value2 LIKE att_files.att_value2 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field3 LIKE att_files.att_field3 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value3 LIKE att_files.att_value3 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field4 LIKE att_files.att_field4 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value4 LIKE att_files.att_value4 NO-UNDO.
DEFINE INPUT PARAMETER i-att_field5 LIKE att_files.att_field5 NO-UNDO.
DEFINE INPUT PARAMETER i-att_value5 LIKE att_files.att_value5 NO-UNDO.

DEFINE OUTPUT PARAMETER o-att_file_id LIKE att_files.att_file_id NO-UNDO.
DEFINE OUTPUT PARAMETER o-att-find-success AS LOGICAL NO-UNDO.

/* ***************************  Main Block  *************************** */

/*UPDATE i-att_filename i-att_filepath i-att_table i-att_field1 i-att_value1 i-att_field2 i-att_value2 i-att_field3*/
/*i-att_value3                                                                                                     */
/*i-att_field4  i-att_value4                                                                                       */
/*i-att_field5 i-att_value5 WITH 1 COL WIDTH 132 .                                                                 */

FIND att_files WHERE
    att_files.att_deleted = ? AND 
    att_files.att_filename = i-att_filename AND 
    att_files.att_filepath = i-att_filepath AND 
    (att_files.att_table = i-att_table OR i-att_table = "") AND 
    att_files.att_field1 = i-att_field1 AND 
    att_files.att_value1 = i-att_value1 AND 
    (att_files.att_field2 = i-att_field2 OR i-att_field2 = "") AND 
    (att_files.att_value2 = i-att_value2 OR i-att_value2 = "") AND 
    (att_files.att_field3 = i-att_field3 OR i-att_field3 = "") AND 
    (att_files.att_value3 = i-att_value3 OR i-att_value3 = "") AND 
    (att_files.att_field4 = i-att_field4 OR i-att_field4 = "") AND 
    (att_files.att_value4 = i-att_value4 OR i-att_value4 = "") AND 
    (att_files.att_field5 = i-att_field5 OR i-att_field5 = "") AND 
    (att_files.att_value5 = i-att_value5 OR i-att_value5 = "")
    NO-LOCK NO-ERROR.
 
IF AVAILABLE (att_files) THEN DO:
 
    ASSIGN 
        o-att_file_id = att_files.att_file_id 
        o-att-find-success = YES.
    
/*    DISPLAY o-att_file_id o-att-find-success WITH FRAME apple.*/
    
END. /***  of available att_files  ***/   

ELSE DO:
    
    ASSIGN 
        o-att_file_id = 0
        o-att-find-success = NO. 
    
/*    DISPLAY o-att_file_id o-att-find-success " not-found" WITH FRAME apple.*/
    
END. 
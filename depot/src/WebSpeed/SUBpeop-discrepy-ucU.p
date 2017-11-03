
/*------------------------------------------------------------------------
    File        : SUBpeop-discrepy-ucU.p
    Purpose     : Description : Stores the input XML data when there is
                : a discrepancy between the input data and their database records.  

    Author(s)   : Harold D. Luttrell
    Created     : Jan 29, 2017
                :
    Updated:        Sept. 7, 2017
    Version:        1.1
    Author:         Harold Luttrell, Sr,
    Description:    Added ‘../HL7/src/WebSpeed/’ to the front of 
                    the ‘XML_TT_People_Data.i’ statement.
                    Identified by: /* 1dot1 */
                    
  ----------------------------------------------------------------------*/
 
/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */

{../HL7/src/WebSpeed/XML_TT_People_Data.i}.                             /* 1dot1 */ 

DEFINE INPUT PARAMETER  i-TT-People-Seq-Nbr         AS INTEGER                          NO-UNDO.
DEFINE INPUT PARAMETER  i-people-id                 LIKE people_mstr.people_id  NO-UNDO.
DEFINE INPUT PARAMETER  i-h-DOB                     AS DATE FORMAT "99/99/99"           NO-UNDO.
DEFINE INPUT PARAMETER  i-genderhold                AS LOGICAL                          NO-UNDO.

DEFINE OUTPUT PARAMETER o-peopdiscrep_ID            LIKE people_mstr.people_id  NO-UNDO.
DEFINE OUTPUT PARAMETER o-discrepy-error            AS LOGICAL INITIAL NO               NO-UNDO.

/* ***************************  Main Block  *************************** */
    
    FIND FIRST XML_TT_People_Data WHERE  TT-People-Seq-Nbr = i-TT-People-Seq-Nbr
            NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE (XML_TT_People_Data) THEN

        ASSIGN  o-discrepy-error = YES
                o-peopdiscrep_ID = 0.

    ELSE DO:  /* - 1 - IF AVAILABLE (XML_TT_People_Data)  */

        FIND FIRST D_people_mstr WHERE  D_people_firstname      = TRIM(XML_TT_People_Data.TT-people_firstname)  AND 
                                        D_people_midname        = TRIM(XML_TT_People_Data.TT-people_midname)    AND 
                                        D_people_lastname       = TRIM(XML_TT_People_Data.TT-people_lastname)   AND 
                                        D_people_prefix         = TRIM(XML_TT_People_Data.TT-people_prefix)     AND 
                                        D_people_suffix         = TRIM(XML_TT_People_Data.TT-people_suffix)     AND 
                                        D_people_gender         = i-genderhold                                  AND 
                                        D_people_homephone      = XML_TT_People_Data.TT-people_homephone        AND 
                                        D_people_workphone      = XML_TT_People_Data.TT-people_workphone        AND 
                                        D_people_DOB            = i-h-DOB                                       AND 
                                        D_people_prefname       = XML_TT_People_Data.TT-people_prefname            
                        NO-LOCK NO-ERROR.
                         
        IF  NOT AVAILABLE (D_people_mstr) THEN DO:                        
/*  Create & Store new discrepancy record.  */   

            CREATE  D_people_mstr.
            
            ASSIGN  D_people_id             = NEXT-VALUE (seq-people)               /* use the people sequencing next-value for the ID.*/
                    D_people_firstname      = TRIM(XML_TT_People_Data.TT-people_firstname)
                    D_people_midname        = TRIM(XML_TT_People_Data.TT-people_midname)
                    D_people_lastname       = TRIM(XML_TT_People_Data.TT-people_lastname)
                    D_people_prefix         = TRIM(XML_TT_People_Data.TT-people_prefix)
                    D_people_suffix         = TRIM(XML_TT_People_Data.TT-people_suffix)
                    D_people_gender         = i-genderhold
                    D_people_homephone      = XML_TT_People_Data.TT-people_homephone
                    D_people_workphone      = XML_TT_People_Data.TT-people_workphone
                    D_people_DOB            = i-h-DOB
                    D_people_prefname       = XML_TT_People_Data.TT-people_prefname
                    D_people_created_by     = USERID("Core")
                    D_people_create_date    = TODAY
                    D_people_prog_name      = SOURCE-PROCEDURE:FILE-NAME
                    D_people_Occured_Date   = TODAY  
                    D_people_Verify_Flag    = NO
                    D_people_discrep_ID     = i-people-id.     
        END. /* IF  NOT AVAILABLE (D_people_mstr) THEN DO: */
        
        ASSIGN o-peopdiscrep_ID        = D_people_id.
                                     
    END.  /*  ELSE DO: */

/*  END OF PROGRAM.  */

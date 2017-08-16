
/*------------------------------------------------------------------------
    File        : SUBproj-ucU.p
    Purpose     : Database Update

    Syntax      :

    Description : Subroutine to create and update the Proj_Mstr table in the TimeSheet database

    Version     : 1.1

    Author(s)   : Jacob Luttrell
    Created     : Fri Jan 01 08:49:53 MST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucproj-clientid        LIKE Proj_Mstr.Proj_client_ID           NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-name            LIKE Proj_Mstr.Proj_name                NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-priceadj        LIKE Proj_Mstr.Proj_price_adj           NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-priceadjdollar  LIKE Proj_Mstr.Proj_price_adj_dollar    NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-startdate       LIKE Proj_Mstr.Proj_start_date          NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-enddate         LIKE Proj_Mstr.Proj_end_date            NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-esttotal        LIKE Proj_Mstr.Proj_est_total           NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-currtotal       LIKE Proj_Mstr.Proj_curr_total          NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-esthours        LIKE Proj_Mstr.Proj_est_hours           NO-UNDO.
DEFINE INPUT PARAMETER i-ucproj-currhours       LIKE Proj_Mstr.Proj_curr_hours          NO-UNDO.
/*DEFINE INPUT PARAMETER i-ucproj-progname        LIKE Proj_Mstr.Proj_prog_name           NO-UNDO.*/

DEFINE OUTPUT PARAMETER o-ucproj-clientid       LIKE Proj_Mstr.Proj_client_ID           NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucproj-name           LIKE Proj_Mstr.Proj_name                NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucproj-create         AS LOGICAL INITIAL NO                   NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucproj-update         AS LOGICAL INITIAL NO                   NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucproj-avail          AS LOGICAL INITIAL YES                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucproj-successful     AS LOGICAL INITIAL NO                   NO-UNDO. 
DEFINE OUTPUT PARAMETER o-ucproj-error          AS LOGICAL INITIAL NO                   NO-UNDO.

/* ***************************  Main Block  *************************** */

mainblock: 
DO TRANSACTION:

    IF i-ucproj-clientid = 0 THEN 
    DO:
        ASSIGN 
            o-ucproj-error = YES.
        LEAVE mainblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST Proj_Mstr WHERE
            Proj_Mstr.Proj_client_ID = i-ucproj-clientid AND
            Proj_Mstr.Proj_name      = i-ucproj-name AND 
            Proj_Mstr.Proj_deleted   = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE Proj_Mstr THEN 
        DO:
            
            ASSIGN
                o-ucproj-update                  = YES
                o-ucproj-successful              = YES
                Proj_Mstr.Proj_modified_date     = TODAY
                Proj_Mstr.Proj_modified_by       = USERID ("General")                    
                o-ucproj-clientid                = Proj_Mstr.Proj_client_ID
                o-ucproj-name                    = Proj_Mstr.Proj_name 
/*                Proj_Mstr.Proj_prog_name         = i-ucproj-progname*/
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE Proj_Mstr.
            
            ASSIGN
                Proj_Mstr.Proj_client_ID     = i-ucproj-clientid
                Proj_Mstr.Proj_name          = i-ucproj-name
                o-ucproj-create              = YES
                o-ucproj-successful          = YES
                Proj_Mstr.Proj_create_date   = TODAY
                Proj_Mstr.Proj_created_by    = USERID ("General")                    
                Proj_Mstr.Proj_modified_date = TODAY
                Proj_Mstr.Proj_modified_by   = USERID ("General")                 
                o-ucproj-clientid            = Proj_Mstr.Proj_client_ID
                o-ucproj-name                = Proj_Mstr.Proj_name 
/*                Proj_Mstr.Proj_prog_name     = i-ucproj-progname*/
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN                
            Proj_Mstr.Proj_price_adj        = IF i-ucproj-priceadj       <> 0  THEN i-ucproj-priceadj       ELSE Proj_Mstr.Proj_price_adj 
            Proj_Mstr.Proj_price_adj_dollar = IF i-ucproj-priceadjdollar <> 0  THEN i-ucproj-priceadjdollar ELSE Proj_Mstr.Proj_price_adj_dollar
            Proj_Mstr.Proj_start_date       = IF i-ucproj-startdate      <> ?  THEN i-ucproj-startdate      ELSE Proj_Mstr.Proj_start_date
            Proj_Mstr.Proj_end_date         = IF i-ucproj-enddate        <> ?  THEN i-ucproj-enddate        ELSE Proj_Mstr.Proj_end_date  
            Proj_Mstr.Proj_est_total        = IF i-ucproj-esttotal       <> 0  THEN i-ucproj-esttotal       ELSE Proj_Mstr.Proj_est_total                 
            Proj_Mstr.Proj_curr_total       = IF i-ucproj-currtotal      <> 0  THEN i-ucproj-currtotal      ELSE Proj_Mstr.Proj_curr_total
            Proj_Mstr.Proj_est_hours        = IF i-ucproj-esthours       <> 0  THEN i-ucproj-esthours       ELSE Proj_Mstr.Proj_est_hours
            Proj_Mstr.Proj_curr_hours       = IF i-ucproj-currhours      <> 0  THEN i-ucproj-currhours      ELSE Proj_Mstr.Proj_curr_hours
            Proj_Mstr.Proj_prog_name        = SOURCE-PROCEDURE:FILE-NAME                                                                                /* 1dot1 */
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */
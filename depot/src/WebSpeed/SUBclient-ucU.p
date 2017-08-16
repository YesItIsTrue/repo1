
/*------------------------------------------------------------------------
    File        : SUBclient-ucU.p
    Purpose     : Database update

    Syntax      :

    Description : Subroutine to create and update the Client_Mstr table in the TimeSheet database

    Author(s)   : Jacob Luttrell
    Created     : Fri Jan 01 07:51:30 MST 2016
    Notes       :
    Version     : 1.1    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER i-ucclnt-peopid          LIKE Client_Mstr.Client_people_ID       NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-abbv            LIKE Client_Mstr.Client_abbv            NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-priceadj        LIKE Client_Mstr.Client_price_adj       NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-zone            LIKE Client_Mstr.Client_zone            NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-LDS             LIKE Client_Mstr.Client_LDS             NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-specdisc        LIKE Client_Mstr.Client_spec_disc       NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-specdiscnotes   LIKE Client_Mstr.Client_spec_disc_notes NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-startdate       LIKE Client_Mstr.Client_start_date      NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-enddate         LIKE Client_Mstr.Client_end_date        NO-UNDO.
DEFINE INPUT PARAMETER i-ucclnt-transdef        LIKE Client_Mstr.Client_trans_def       NO-UNDO.
/*DEFINE INPUT PARAMETER i-ucclnt-progname        LIKE Client_Mstr.Client_prog_name       NO-UNDO.*/
DEFINE INPUT PARAMETER i-ucclnt-profitmargin    LIKE Client_Mstr.Client_def_profit_margin NO-UNDO.

DEFINE OUTPUT PARAMETER o-ucclnt-id             LIKE Client_Mstr.Client_people_ID       NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucclnt-create         AS LOGICAL INITIAL NO                   NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucclnt-update         AS LOGICAL INITIAL NO                   NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucclnt-avail          AS LOGICAL INITIAL YES                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-ucclnt-successful     AS LOGICAL INITIAL NO                   NO-UNDO. 
DEFINE OUTPUT PARAMETER o-ucclnt-error          AS LOGICAL INITIAL NO                   NO-UNDO.

/* ***************************  Main Block  *************************** */

mainblock: 
DO TRANSACTION:

    IF i-ucclnt-peopid = 0 THEN 
    DO:
        ASSIGN 
            o-ucclnt-error = YES.
        LEAVE mainblock.
    END. 
    
    ELSE 
    DO:
        
        FIND FIRST Client_Mstr WHERE
            Client_Mstr.Client_people_ID = i-ucclnt-peopid AND
            Client_Mstr.Client_deleted   = ?
            EXCLUSIVE-LOCK NO-ERROR.
            
        IF AVAILABLE Client_Mstr THEN 
        DO:
            
            ASSIGN
                o-ucclnt-update                  = YES
                o-ucclnt-successful              = YES
                Client_Mstr.Client_modified_date = TODAY
                Client_Mstr.Client_modified_by   = USERID ("General")                    
                o-ucclnt-id                      = Client_Mstr.Client_people_ID 
/*                Client_Mstr.Client_prog_name     = i-ucclnt-progname*/
                Client_Mstr.Client_def_profit_margin = i-ucclnt-profitmargin          
                .
                                                
        END. /*** of IF AVAIL THEN DO: ***/
                
        ELSE 
        DO:
            
            CREATE Client_Mstr.
            
            ASSIGN
                Client_Mstr.Client_people_ID     = i-ucclnt-peopid
                Client_Mstr.Client_abbv          = i-ucclnt-abbv
                o-ucclnt-create                  = YES
                o-ucclnt-successful              = YES
                Client_Mstr.Client_create_date   = TODAY
                Client_Mstr.Client_created_by    = USERID ("General")                    
                Client_Mstr.Client_modified_date = TODAY
                Client_Mstr.Client_modified_by   = USERID ("General")                 
                o-ucclnt-id                      = Client_Mstr.Client_people_ID
/*                Client_Mstr.Client_prog_name     = i-ucclnt-progname*/
                Client_Mstr.Client_def_profit_margin = i-ucclnt-profitmargin  
                .
                
        END. /*** of not avail ELSE DO ***/
        
        /*** this is to allow blank inputs ***/
        ASSIGN 
            Client_Mstr.Client_price_adj       = IF i-ucclnt-priceadj       <> 0  THEN i-ucclnt-priceadj      ELSE Client_Mstr.Client_price_adj   
            Client_Mstr.Client_zone            = IF i-ucclnt-zone           <> 0  THEN i-ucclnt-zone          ELSE Client_Mstr.Client_zone                 
            Client_Mstr.Client_LDS             = IF i-ucclnt-LDS            <> ?  THEN i-ucclnt-LDS           ELSE Client_Mstr.Client_LDS
            Client_Mstr.Client_spec_disc       = IF i-ucclnt-specdisc       <> 0  THEN i-ucclnt-specdisc      ELSE Client_Mstr.Client_spec_disc
            Client_Mstr.Client_spec_disc_notes = IF i-ucclnt-specdiscnotes  <> "" THEN i-ucclnt-specdiscnotes ELSE Client_Mstr.Client_spec_disc_notes
            Client_Mstr.Client_start_date      = IF i-ucclnt-startdate      <> ?  THEN i-ucclnt-startdate     ELSE Client_Mstr.Client_start_date
            Client_Mstr.Client_end_date        = IF i-ucclnt-enddate        <> ?  THEN i-ucclnt-enddate       ELSE Client_Mstr.Client_end_date
            Client_Mstr.Client_trans_def       = IF i-ucclnt-transdef       <> "" THEN i-ucclnt-transdef      ELSE Client_Mstr.Client_trans_def
            Client_Mstr.Client_prog_name       = SOURCE-PROCEDURE:FILE-NAME                 /* 1dot1 */ 
            .
            
    END. /*** of the no id ELSE DO***/  

END. /*** of maineblock ***/

/* **************************  End of Line  *************************** */
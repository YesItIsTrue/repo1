/*------------------------------------------------------------------------
    File        : ISO-CleanUP-addr_mstr-state.p
    Purpose     : 

    Syntax      :  

    Description : Change the state to the ISO state value.
            
    Author(s)   : Harold Luttrell, Sr.
    Created     : Thur Feb 4, 2016

  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
/* set update-flag to YES to update data. */
DEFINE VARIABLE update-flag  AS LOGICAL   INITIAL YES NO-UNDO. 

DEFINE VARIABLE DIFF-addr-Id AS LOGICAL   INITIAL NO NO-UNDO.
DEFINE VARIABLE kount        AS INTEGER   EXTENT 30 NO-UNDO.
DEFINE VARIABLE kount-desc   AS CHARACTER EXTENT 30 NO-UNDO.
DEFINE VARIABLE xx           AS INTEGER   NO-UNDO.

DEFINE BUFFER h-address-buf FOR addr_mstr. 

DEFINE VARIABLE h-addr_ID           AS INTEGER   NO-UNDO.                 
DEFINE VARIABLE h-addr1             AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE h-addr2             AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE h-addr3             AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE h-city              AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE h-stateprov         AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE h-zip               AS CHARACTER FORMAT "x(60)" NO-UNDO.
DEFINE VARIABLE h-country           AS CHARACTER FORMAT "x(60)" NO-UNDO.

DEFINE VARIABLE i-country           LIKE state_mstr.state_country_ISO NO-UNDO. 
DEFINE VARIABLE i-state             LIKE state_mstr.state_display_name NO-UNDO.  
DEFINE VARIABLE o-fstate-ISO        LIKE country_mstr.Country_ISO NO-UNDO.
DEFINE VARIABLE o-fstate-error      AS LOGICAL   NO-UNDO.

/*DEFINE VARIABLE o-fcountry-ISO     LIKE country_mstr.Country_ISO        NO-UNDO.           */
/*DEFINE VARIABLE o-fcountry-error   AS LOGICAL                                   NO-UNDO.           */
/*DEFINE VARIABLE i-country-display-name     LIKE country_mstr.Country_Display_Name  NO-UNDO.*/

DEFINE VARIABLE o-ucaddr-id         LIKE addr_mstr.addr_id NO-UNDO.
DEFINE VARIABLE o-ucaddr-create     AS LOGICAL   INITIAL NO NO-UNDO.
DEFINE VARIABLE o-ucaddr-update     AS LOGICAL   INITIAL NO NO-UNDO.
DEFINE VARIABLE o-ucaddr-avail      AS LOGICAL   INITIAL YES NO-UNDO.
DEFINE VARIABLE o-ucaddr-successful AS LOGICAL   INITIAL NO NO-UNDO.
                
/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE xx_prog_name        AS CHARACTER NO-UNDO.
/* This is the code snippet Doug was using to update the _prog_name fields */
ASSIGN  
    xx_prog_name = SUBSTRING(THIS-PROCEDURE:FILE-NAME,R-INDEX(THIS-PROCEDURE:FILE-NAME,"\") + 1).
DISPLAY xx_prog_name FORMAT "x(60)" SKIP(2). 
/*       This way you only get the program name and not the whole path.  Not sure if that’s good or bad. :)  */

DEFINE STREAM outward1.
DEFINE VARIABLE errlog1 AS CHARACTER NO-UNDO.
ASSIGN  
    errlog1 = "C:\PROGRESS\WRK\ISO-CleanUP-addr_mstr-state-" + UPPER(STRING(update-flag)) + ".txt".   
    
OUTPUT STREAM outward1 TO value(errlog1).
EXPORT  STREAM outward1     DELIMITER ";"
    /*            "Program Name:" SUBSTRING(THIS-PROCEDURE:FILE-NAME,R-INDEX(THIS-PROCEDURE:FILE-NAME,"\") + 1) FORMAT "x(30)" "  Option 1."*/
    "Program Name: " xx_prog_name " ".
EXPORT  STREAM outward1     DELIMITER ";"
    "Start Run at:" TODAY STRING(TIME, "HH:MM:SS").
EXPORT  STREAM outward1     DELIMITER ";" 
    "***>>> update flag is set to: " + UPPER(STRING(update-flag)) + " <<<***".
EXPORT STREAM outward1 DELIMITER ";"
    "Addr_ID"
    "Addr1"
    "Addr2"
    "Addr3"
    "City"
    "StateProv"
    "Zip"
    "Country" 
    "Action taken : update-flag set to: " + UPPER(STRING(update-flag)) + ".".     

/* ***************************  Main Block  *************************** */
ASSIGN  
    kount-desc [1] = ":Total input addr_mstr records processed.".
ASSIGN  
    kount-desc [2] = ":Total state_mstr records not found.".
ASSIGN  
    kount-desc [3] = ":Total addr_mstr records flagged for deletion.". 
ASSIGN  
    kount-desc [4] = ":Total addr_mstr records updated   with new ISO state.".
ASSIGN  
    kount-desc [5] = ":Total people_mstr records people_addr_id updated with new address-ID.".               
ASSIGN  
    kount-desc [6] = ":Total people_mstr records people_second_addr_id updated with new address-ID.".
ASSIGN  
    kount-desc [7] = ":Total addr_mstr records with BLANK addr_stateprov-NOT updated.".

main-loop:
FOR EACH addr_mstr  
    WHERE  addr_mstr.addr_deleted = ? 
    EXCLUSIVE-LOCK BY addr_id:
        
    ASSIGN  
        h-addr_ID   = addr_mstr.addr_id
        h-addr1     = addr_mstr.addr_addr1
        h-addr2     = addr_mstr.addr_addr2
        h-addr3     = addr_mstr.addr_addr3
        h-city      = addr_mstr.addr_city
        h-stateprov = addr_mstr.addr_stateprov  
        h-zip       = addr_mstr.addr_zip
        h-country   = addr_mstr.addr_country.
                
    ASSIGN  
        kount [1] = (kount [1] + 1).
        
    ASSIGN  
        o-fstate-ISO   = "Not Found"
        o-fstate-error = YES.

    IF  h-stateprov = "" THEN 
    DO:
        EXPORT STREAM outward1 DELIMITER ";" 
            h-addr_ID
            h-addr1
            h-addr2
            h-addr3
            h-city
            h-stateprov  
            h-zip 
            h-country
            "addr_mstr records with BLANK addr_stateprov-NOT updated.". 
        ASSIGN  
            kount [7] = (kount [7] + 1).
        NEXT main-loop.
    END. /* IF h-stateprov = ""  */
        
    ASSIGN  
        i-country = h-country
        i-state   = h-stateprov.
                                                          
    RUN VALUE(SEARCH("SUBstate-findR.r"))
        (i-country,
        i-state,
        OUTPUT o-fstate-ISO,
        OUTPUT o-fstate-error).

    /* addr_stateprov NOT Found in state_mstr. Report error and bypass this addr_mstr record. */
    IF o-fstate-error =  YES THEN 
    DO:          /* logical YES = data is not found */
        EXPORT STREAM outward1 DELIMITER ";" 
            h-addr_ID
            h-addr1
            h-addr2
            h-addr3
            h-city
            h-stateprov  
            h-zip 
            h-country
            "state_mstr record NOT found.". 
        ASSIGN  
            kount [2] = (kount [2] + 1).
        NEXT main-loop.
    END.  /* IF o-fstate-error =  YES */

    /* Found addr_stateprov in state_mstr - check to see it a address record 
        does or does not exist with the new state_ISO. */         
    IF o-fstate-error =  NO THEN  
    DO:       /* logical NO = data is found */
        
        ASSIGN 
            DIFF-addr-Id = NO.
            
        FIND    h-address-buf  WHERE
            h-address-buf.addr_addr1    = h-addr1   AND
            h-address-buf.addr_addr2    = h-addr2   AND
            h-address-buf.addr_addr3    = h-addr3   AND
            h-address-buf.addr_city     = h-city    AND
                            
            h-address-buf.addr_stateprov  = o-fstate-ISO AND     /* new data */
                            
            h-address-buf.addr_zip      = h-zip     AND                           
            h-address-buf.addr_country  = h-country AND                               
            h-address-buf.addr_deleted  = ?
            NO-LOCK NO-ERROR. 
                         
        /* addr_mstr does not exist with new state_ISO. Update the addr_stateprov field only.*/
        IF NOT AVAILABLE (h-address-buf) THEN 
        DO: 
                
            IF update-flag = YES THEN 
                ASSIGN addr_mstr.addr_stateprov     = o-fstate-ISO
                    addr_mstr.addr_modified_by   = USERID ("General")
                    addr_mstr.addr_modified_date = TODAY
                    addr_mstr.addr_prog_name     = "ISO-CleanUP-addr_mstr-state.p - addr_mstr.addr_stateprov updated with new state_ISO.".
                                           
            ASSIGN  
                kount [4] = (kount [4] + 1).    /* addr_mstr updated with new ISO state. */
                
            NEXT main-loop.                              
        END.  /*  IF NOT AVAILABLE (h-address-buf)  */
                                    
        /* 
        If address record exist with the new state_ISO then 
            change the people_mstr where the people_addr_id and/or the people_second_addr_ID
            equals the old address_addr_ID to the new found address_addr_ID.  
        */   
        IF  AVAILABLE (h-address-buf) THEN 
        DO: 
                
            FOR EACH  people_mstr WHERE 
                people_mstr.people_addr_id = addr_mstr.addr_id  AND
                people_mstr.people_deleted = ?
                EXCLUSIVE-LOCK:

                IF  people_mstr.people_addr_id <> h-address-buf.addr_id THEN 
                DO: 
                    /* UPDATE the people_mstr WITH the NEW address-ID . */                   
                    ASSIGN  
                        kount [5] = (kount [5] + 1).    /* people_mstr records people_addr_id updated with new address-ID. */                         
                    ASSIGN 
                        DIFF-addr-Id = YES.  
                            
                    IF update-flag = YES THEN 
                        ASSIGN  
                            people_mstr.people_addr_id       = h-address-buf.addr_id
                            people_mstr.people_modified_by   = USERID ("General")
                            people_mstr.people_modified_date = TODAY
                            people_mstr.people_prog_name     = "ISO-CleanUP-addr_mstr-state.p - people_addr_id new address-ID.".
                                
                END.  /* IF  people_mstr.people_addr_id <> h-address-buf.addr_id  */
                     
            END.  /*  FOR EACH  people_mstr.people_addr_id  */
                
            /*  look in the second addr_id field. */
            FOR EACH  people_mstr WHERE 
                people_mstr.people_second_addr_ID   = addr_mstr.addr_id   AND
                people_mstr.people_deleted = ?
                EXCLUSIVE-LOCK:

                IF  people_mstr.people_second_addr_id <> h-address-buf.addr_id THEN 
                DO:
                    /* UPDATE the people_mstr WITH the NEW address-ID . */                   
                    ASSIGN  
                        kount [6] = (kount [6] + 1).    /* people_mstr records people_second_addr_id updated with new address-ID */
                    ASSIGN 
                        DIFF-addr-Id = YES.
                        
                    IF update-flag = YES THEN
                        ASSIGN  
                            people_mstr.people_second_addr_ID = h-address-buf.addr_id
                            people_mstr.people_modified_by    = USERID ("General")
                            people_mstr.people_modified_date  = TODAY
                            people_mstr.people_prog_name      = "ISO-CleanUP-addr_mstr-state.p - people_second_addr_id new address-ID.".

                END.  /* IF  people_mstr.people_second_addr_id <> h-address-buf.addr_id */
                    
            END.  /*  FOR EACH  people_mstr.people_second_addr_ID   */

            IF update-flag = YES AND 
                DIFF-addr-Id = YES THEN
                ASSIGN  addr_mstr.addr_deleted       = TODAY 
                    addr_mstr.addr_modified_by   = USERID ("General")
                    addr_mstr.addr_modified_date = TODAY 
                    addr_mstr.addr_prog_name     = "ISO-CleanUP-addr_mstr-state.p - flagged for deletion."
                    kount [3]                    = (kount [3] + 1).
            
            ASSIGN 
                DIFF-addr-Id = NO. 
                                                        
        END.  /*  IF AVAILABLE (h-address-buf)  */
                        
    END.  /**  IF o-fstate-error =  NO   */     
        
END.  /*  FOR EACH addr_mstr  */

EXPORT STREAM outward1 DELIMITER ";" 999999999 "END OF DATA.".

IF  kount [1] = 0 THEN 
DO: 
    EXPORT STREAM outward1 DELIMITER ";" kount [1] "kount [1]" kount-desc [1].         
    EXPORT STREAM outward1 DELIMITER ";" "".
END. /* IF  kount [1] = 0 */
        
DO xx = 1 TO 30 BY 1.
    IF  kount [xx] > 0 THEN 
    DO:
        EXPORT STREAM outward1 DELIMITER ";" kount [xx]  kount-desc [xx].
        EXPORT STREAM outward1 DELIMITER ";" "".
    END.  /* IF  kount [xx] > 0 */
END.  /*  DO xx = 1 TO 30 BY 1.  */
                                                             
EXPORT STREAM outward1 DELIMITER ";" "End Run at " TODAY STRING(TIME, "HH:MM:SS").

OUTPUT STREAM outward1 CLOSE.
               
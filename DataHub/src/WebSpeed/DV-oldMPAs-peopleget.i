
/*------------------------------------------------------------------------
    File        : DV-oldMPAs-peopleget.i
    Purpose     : 

    Syntax      :

    Description : Find or create a person, making the people_mstr record current.

    Author(s)   : Doug Luttrell
    Created     : Fri Feb 05 15:38:52 EST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
ASSIGN 
    o-fpe-peopleID  = 0
    o-fpe-addr_ID   = 0 
    o-fpe-error     = NO 
    o-fpat-ran      = NO
    o-created       = NO
    o-updated       = NO
    o-avail         = NO
    o-success       = NO
    o-patID         = 0
    o-error         = NO.
     
RUN value(SEARCH("SUBpeop-datefindR.r")) 
    (temppre,
     tempfn,
     tempmn, 
     templn, 
     tempsuf, 
     tempDOB,
     OUTPUT o-fpe-peopleID,         
     OUTPUT o-fpe-addr_ID,
     OUTPUT o-fpe-error,            /* YES = failed to find a people_mstr */
     OUTPUT o-fpat-ran).            /* returns a YES if it ran at all */

IF o-fpat-ran = NO THEN DO: 
    
    MESSAGE "SYSTEM ERROR!  Failed to run SUBpeop-datefindR.r."
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
    
    NEXT main-loop.
    
END.  /** of if o-fpat-ran = NO **/
        
ELSE DO: 
    
    IF o-fpe-error = NO THEN DO:
        
        IF o-fpe-peopleID = 0 THEN DO: 
             
            EXPORT STREAM errlog DELIMITER ";"
                eS_HoldID 
                sample_id
                gps_id
                batch_ID
                0                           /* VF1_ID */
                tempfn
                tempmn
                templn
                tempsampleid
                ""                          /* Customer_Type */
                ""                          /* Batch_ID */
                ""                          /* EY_nbr */
                tempdob
                temptesttype
                tempsampleid
                0                           /* TK_test_seq */
                temptesttype
                "ERROR!  Person found with people_ID of 0.".
            
            NEXT main-loop.
            
        END.  /*** of if o-fpe-peopleID = 0 ***/
            
        ELSE DO: 
                   
            FIND people_mstr WHERE people_mstr.people_id = o-fpe-peopleID AND 
                people_mstr.people_deleted = ? 
                    NO-LOCK NO-ERROR. 
        
            kount[5]    = kount[5] + 1.                                     /* Person found */
            
        END.  /** of else do -- found a person **/
            
    END.  /** of if o-fpe-error = NO **/
    
    ELSE DO: 

        kount[4]    = kount[4] + 1.                                         /* Person not found - creating one */
        
        IF updatemode = YES THEN DO: 

            RUN VALUE (SEARCH ("SUBpeop-ucU.r")) 
                (0,
                 tempfn,
                 tempmn,
                 templn, 
                 temppre,
                 tempsuf,
                 "",            /* company */
                 tempgender,
                 "",            /* home phone */
                 "",            /* work phone */
                 "",            /* cell phone */
                 "",            /* fax */
                 "",            /* email */
                 "",            /* email2 */
                 0,             /* addr_id */
                 "",            /* contact */
                 tempDOB,
                 0,             /* second_addr_ID */
                 OUTPUT o-fpe-peopleID,
                 OUTPUT o-created,
                 OUTPUT o-updated,
                 OUTPUT o-avail,
                 OUTPUT o-success).
                 
            IF o-created = YES THEN DO:
                
                ASSIGN 
                    o-created   = NO 
                    o-updated   = NO 
                    o-success   = NO. 
                
                RUN VALUE (SEARCH ("SUBpat-ucU.r"))
                    (o-fpe-peopleID,
                     "",                    /* condition */
                     "",                    /* notes */
                     0,                     /* RP_ID */
                     0,                     /* doctor_ID */
                     0,                     /* cust_ID */
                     YES,                   /* verified */
                     OUTPUT o-patID,
                     OUTPUT o-created,
                     OUTPUT o-updated,
                     OUTPUT o-error,
                     OUTPUT o-success).
                
            END.  /** of if o-created = yes **/                              

            FIND people_mstr WHERE people_mstr.people_id = o-fpe-peopleID AND 
                people_mstr.people_deleted = ? 
                    NO-LOCK NO-ERROR.
            
        END.  /*** of if updatemode = yes ***/
                
    END.  /** of else do --- people_mstr not found **/    

END.  /*** of else do --- if o-fpat-ran = YES ***/

/*****************************  END OF FILE.  ***************************/


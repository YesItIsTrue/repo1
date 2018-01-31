/*------------------------------------------------------------------------
    File        : HL7-Load-People.p
    Purpose     : Load/Update the General.people_mstr from XML data. 

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Jan 12, 2017.
    
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on & off since Jan/17.  Original version.  
          
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
  
{XML_TT_People_Data.i}.         /*  XML Extraction People Data to Load into Progress. */      
{XML_TT_PeopID_Basic_Data.i}.   /* XML Extraction People ID ONLY to be used in the XML-SUB- programs.p. */

{E-Mail_definations.i}.  

DEFINE INPUT PARAMETER  i-flab-ID               LIKE HHI.lab_mstr.lab_ID            NO-UNDO.
DEFINE INPUT PARAMETER  i-Admin-Update-OverRyde AS LOGICAL  INITIAL NO              NO-UNDO.
DEFINE OUTPUT PARAMETER o-people-id             LIKE General.people_mstr.people_id  NO-UNDO. 
DEFINE OUTPUT PARAMETER o-people-load-error     AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE OUTPUT PARAMETER o-people-error-message  AS CHARACTER FORMAT "x(200)"        NO-UNDO.

/* ***  people_mstr find output info.                                    *** */    
DEFINE VARIABLE o-fpe-peopleID      LIKE people_mstr.people_id          NO-UNDO.
DEFINE VARIABLE o-fpe-addr_ID       LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE VARIABLE o-fpe-error         AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE o-fpe-ran           AS LOGICAL INITIAL NO               NO-UNDO.
/* ***  people_mstr update output info.                                   *** */
DEFINE VARIABLE  o-ucpeople-create     AS LOGICAL INITIAL NO            NO-UNDO.
DEFINE VARIABLE  o-ucpeople-update     AS LOGICAL INITIAL NO            NO-UNDO.
DEFINE VARIABLE  o-ucpeople-avail      AS LOGICAL INITIAL YES           NO-UNDO.
DEFINE VARIABLE  o-ucpeople-successful AS LOGICAL INITIAL NO            NO-UNDO.
/* ***  patient_mstr find output info.                                          *** */
DEFINE VARIABLE  o-fpat-ID          LIKE people_mstr.people_id          NO-UNDO. 
DEFINE VARIABLE  o-fpat-addr-ID     LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE VARIABLE  o-fpat-exist       AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE  o-fpat-ran         AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE  o-fpat-error       AS LOGICAL INITIAL NO               NO-UNDO.
/*  *** patient_mstr update output info.                                  *** */
DEFINE VARIABLE  o-ucpatient-id          LIKE patient_mstr.patient_id   NO-UNDO.
DEFINE VARIABLE  o-ucpatient-create      AS LOGICAL INITIAL NO          NO-UNDO.
DEFINE VARIABLE  o-ucpatient-update      AS LOGICAL INITIAL NO          NO-UNDO.
DEFINE VARIABLE  o-ucpatient-error       AS LOGICAL INITIAL NO          NO-UNDO.
DEFINE VARIABLE  o-ucpatient-successful  AS LOGICAL INITIAL NO          NO-UNDO.

/* Counters and Stuff. */
DEFINE VARIABLE recordsprocessed               AS INTEGER               NO-UNDO.
DEFINE VARIABLE People_Mstr_created_kount      AS INTEGER               NO-UNDO.
DEFINE VARIABLE People_Mstr_updated_kount      AS INTEGER               NO-UNDO.
DEFINE VARIABLE People_Mstr_NOTcreated_kount   AS INTEGER               NO-UNDO.
DEFINE VARIABLE DOB_invalid_kount              AS INTEGER               NO-UNDO. 
DEFINE VARIABLE DOB_Blank_kount                AS INTEGER               NO-UNDO.
DEFINE VARIABLE Patient_Mstr_created_kount     AS INTEGER               NO-UNDO.
DEFINE VARIABLE Major_Error_kount              AS INTEGER               NO-UNDO.
DEFINE VARIABLE Minor_Error_kount              AS INTEGER               NO-UNDO.
DEFINE VARIABLE People_NOT_Equal_Error_kount   AS INTEGER               NO-UNDO.
DEFINE VARIABLE People_Discrepancy_Error_kount AS INTEGER               NO-UNDO.
DEFINE VARIABLE h-tyr                          AS DECIMAL FORMAT "9999" NO-UNDO.
DEFINE VARIABLE h-byr                          AS DECIMAL FORMAT "9999" NO-UNDO.
DEFINE VARIABLE h-age              AS DECIMAL INITIAL 0 FORMAT "999.99" NO-UNDO.
DEFINE VARIABLE h-RP_ID                        AS INTEGER INITIAL 0     NO-UNDO.   

DEFINE VARIABLE Temp-PeopID_B-Seq-Nbr          AS INTEGER  INITIAL 0    NO-UNDO.

DEFINE VARIABLE len                            AS INTEGER               NO-UNDO. 

DEFINE VARIABLE genderhold          AS LOGICAL                          NO-UNDO.
DEFINE VARIABLE no-update           AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE b_date              AS CHARACTER FORMAT "x(10)"         NO-UNDO.
DEFINE VARIABLE h-DOB               AS DATE FORMAT "99/99/99"           NO-UNDO.
DEFINE VARIABLE h-log-NO            AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE did-full-name-already-print AS LOGICAL INITIAL NO       NO-UNDO. 
DEFINE VARIABLE data-info           AS CHARACTER FORMAT "x(10)"         NO-UNDO.
DEFINE VARIABLE h-desc              AS CHARACTER FORMAT "X(60)"         NO-UNDO.
DEFINE VARIABLE o-discrepy-error    AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE o-peopdiscrep_ID   LIKE General.people_mstr.people_id  NO-UNDO.   
DEFINE VARIABLE Full-Name           AS CHARACTER FORMAT "X(60)"         NO-UNDO.
DEFINE VARIABLE op_text             AS CHARACTER FORMAT "x(60)"         NO-UNDO. 

DEFINE VARIABLE ITdisplay           AS LOGICAL INITIAL YES              NO-UNDO. 

/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 
   
DEFINE STREAM outwardPM.
DEFINE VARIABLE loadRpt AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\People-Load-Rpt.txt" NO-UNDO.
OUTPUT STREAM outwardPM TO value(loadRpt) PAGED.

PUT STREAM outwardPM
    "*******************************************" SKIP.
PUT STREAM outwardPM 
    "**** Begin report." TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardPM
    "*******************************************" SKIP.
PUT STREAM outwardPM 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1).
    
IF  i-Admin-Update-OverRyde = YES THEN 
    PUT STREAM outwardPM
        "Admin-Update-OverRyde Option has been turned on for this run only!" AT 5 SKIP (1).
        
PUT STREAM outwardPM 
    "Input-data:"  AT 1  "DB-NBR" AT 14 "NAME,  DOB:,  GENDER:" AT 25 SKIP. 
PUT STREAM outwardPM
    "ACTION:" AT 25 SKIP. 
PUT STREAM outwardPM
    "Discrepancy ID Number:" AT 27 SKIP. 
PUT STREAM outwardPM
    "================================================" SKIP. 
                    
/* ***************************  Main Block  *************************** */  

Main_loop:  
FOR EACH XML_TT_People_Data EXCLUSIVE-LOCK BREAK BY TT-People-Seq-Nbr: 

    ASSIGN  o-people-id         = 0
            o-people-error-message = "".
       
    ASSIGN  recordsprocessed = (recordsprocessed + 1)
            Full-Name = ""
            did-full-name-already-print = NO.

    PUT STREAM outwardPM "" SKIP.

    FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        EXCLUSIVE-LOCK NO-ERROR.
    
/* edit basic people stuff here. */

    IF  XML_TT_People_Data.TT-people_lastname   = "" OR 
        XML_TT_People_Data.TT-people_firstname  = "" OR  
        XML_TT_People_Data.TT-people_year       = "" OR    
        XML_TT_People_Data.TT-people_month      = "" OR
        XML_TT_People_Data.TT-people_day        = ""    THEN DO: 
        
            ASSIGN  data-info  = "XML I/P:"
                    h-desc     = "Major Error - 1st or last name or DOB is blank."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                                
            PUT STREAM outwardPM
                    data-info       AT 1
                    o-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
                                 
            PUT STREAM outwardPM
                    "ACTION: Major Error - 1st or last name or DOB is blank."     AT 25 SKIP.
            
            ASSIGN o-people-error-message = 
                                   Full-Name
                                 + " \n "
                                 +  " Major Error - XML input 1st or last name or DOB is blank " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                  o-people-load-error = YES.  . 
                  
            ASSIGN Major_Error_kount = (Major_Error_kount + 1). 
            
/* ERROR all of this tests result input - flag the PeopID_Basic record so 
        other programs will bypass the data for this ERROR. */
        
            FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        EXCLUSIVE-LOCK NO-ERROR.
            
            
            IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data ) THEN DO: 
                CREATE XML_TT_PeopID_Basic_Data.
                ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                       XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag       = "ERROR"
                       XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
            END. /* IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data)  */
                                   
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag    = "ERROR"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID         = "Major Error"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "". 
                                           
            NEXT Main_loop.
            
    END.  /* IF names & DOB is blank */ 
        
    ASSIGN genderhold = ?.       
   
    IF XML_TT_People_Data.TT-people_gender = "Male" THEN 
       ASSIGN  genderhold = LOGICAL("true").
    ELSE IF XML_TT_People_Data.TT-people_gender = "Female" THEN      
       ASSIGN  genderhold = LOGICAL("false").       
    ELSE DO: 
                                   
            ASSIGN  data-info  = "XML I/P:".
            ASSIGN  Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                                
            PUT STREAM outwardPM
                    data-info       AT 1
                    o-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
         
            PUT STREAM outwardPM
                    "ACTION: Minor Error - gender is not = to Male or Female."   AT 25 SKIP.
            
            ASSIGN o-people-error-message = 
                                   Full-Name
                                 + " \n "
                                 + " Minor Error - XML input gender is not = to Male or Female " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                  o-people-load-error = YES.  
                  
            ASSIGN Minor_Error_kount = (Minor_Error_kount + 1). 
                       
/* ERROR all of this tests result input - flag the PeopID_Basic record so 
        other programs will bypass the data for this ERROR. */
        
            FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        EXCLUSIVE-LOCK NO-ERROR.
            
            
            IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data ) THEN DO: 
                CREATE XML_TT_PeopID_Basic_Data.
                ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                       XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag       = "ERROR"
                       XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
            END. /* IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data)  */
                                   
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag    = "ERROR"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID         = "bad gender"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "". 
                                                      
            NEXT Main_loop.
               
    END.  /*  ELSE DO:  */  
     
    ASSIGN b_date = XML_TT_People_Data.TT-people_month + "/" + 
                    XML_TT_People_Data.TT-people_day + "/" + 
                    XML_TT_People_Data.TT-people_year.

    ASSIGN h-DOB = DATE(b_date) NO-ERROR.
                                                    
    IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 OR 
        h-DOB > TODAY                                       THEN DO:   
/** Error Message **/ 
            ASSIGN  data-info  = "XML I/P:"
                    h-desc     = "DOB incorrectly formatted or greater then TODAYs Date.  Input NOT loaded."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  + 
                                 ",  DOB: " + b_date + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ". 
                                
            PUT STREAM outwardPM
                    data-info       AT 1
                    o-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
         
            PUT STREAM outwardPM
                    "ACTION: DOB incorrectly formatted or greater then TODAYs Date.  Input NOT loaded."    AT 25 SKIP.
            
            ASSIGN o-people-error-message = 
                                   Full-Name
                                 + " \n "
                                 + " DOB incorrectly formatted or greater then TODAYs Date.  Input NOT loaded " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                  o-people-load-error = YES.  
                  
            ASSIGN DOB_invalid_kount = (DOB_invalid_kount + 1). 
            
/* ERROR all of this tests result input - flag the PeopID_Basic record so 
        other programs will bypass the data for this ERROR. */
        
            FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data ) THEN DO: 
                CREATE XML_TT_PeopID_Basic_Data.
                ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                       XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag       = "ERROR"
                       XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
            END. /* IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data)  */
                        
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag    = "ERROR"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID         = "DOB incorrect"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "". 
                                                                   
            NEXT Main_loop.
                                                      
    END.  /* IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0  */
                                                                 
    IF h-DOB = ? THEN DO:     
/** Error Message **/         
            ASSIGN  data-info  = "XML I/P:"
                    h-desc     = "DOB is BLANK.  Input NOT loaded."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + b_date + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                                                                  
            PUT STREAM outwardPM
                    data-info       AT 1
                    o-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
         
            PUT STREAM outwardPM
                    "ACTION: DOB is BLANK.  Input NOT loaded."    AT 25 SKIP.
                               
            ASSIGN o-people-error-message = 
                                   Full-Name
                                 + " \n "
                                 + " DOB is BLANK.  Input NOT loaded " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                  o-people-load-error = YES.    
                   
            ASSIGN DOB_Blank_kount = (DOB_Blank_kount + 1).  
                       
/* ERROR all of this tests result input - flag the PeopID_Basic record so 
        other programs will bypass the data for this ERROR. */
        
            FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        EXCLUSIVE-LOCK NO-ERROR.
                       
            IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data ) THEN DO: 
                CREATE XML_TT_PeopID_Basic_Data.
                ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                       XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag       = "ERROR"
                       XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
            END. /* IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data)  */
                                               
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag    = "ERROR"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID         = "DOB Blank"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "". 
                                                                         
            NEXT Main_loop.   
                                                             
    END.  /* IF h-DOB = ?  */     

    RUN VALUE(SEARCH("subr_Up_Low_Case.r")) 
                 (TT-people_prefix, OUTPUT op_text). 
    ASSIGN XML_TT_People_Data.TT-people_prefix = op_text. 
    
    RUN VALUE(SEARCH("subr_Up_Low_Case.r")) 
                 (TT-people_firstname, OUTPUT op_text). 
    ASSIGN XML_TT_People_Data.TT-people_firstname = op_text.
    
    RUN VALUE(SEARCH("subr_Up_Low_Case.r")) 
                 (TT-people_midname, OUTPUT op_text). 
    ASSIGN XML_TT_People_Data.TT-people_midname = op_text.
    
    RUN VALUE(SEARCH("subr_Up_Low_Case.r")) 
                 (TT-people_lastname, OUTPUT op_text). 
    ASSIGN XML_TT_People_Data.TT-people_lastname = op_text.
    
    RUN VALUE(SEARCH("subr_Up_Low_Case.r")) 
                 (TT-people_suffix, OUTPUT op_text). 
    ASSIGN XML_TT_People_Data.TT-people_suffix = op_text.

/* end of edit basic people stuff. */
                     
/* FIND patient_mstr */

    RUN VALUE(SEARCH("SUBpat-findR.r"))                                        
               (XML_TT_People_Data.TT-people_prefix,
                XML_TT_People_Data.TT-people_firstname,
                XML_TT_People_Data.TT-people_midname,
                XML_TT_People_Data.TT-people_lastname,
                XML_TT_People_Data.TT-people_suffix,
                h-DOB,
                OUTPUT o-people-id,
                OUTPUT o-fpe-addr_ID,
                OUTPUT o-fpat-exist,
                OUTPUT o-fpe-ran,
                OUTPUT o-fpe-error).

    IF  o-fpat-exist = YES THEN DO:
        
        FIND FIRST people_mstr WHERE 
                        people_mstr.people_ID         = o-people-id AND
                        people_mstr.people_deleted    = ?
                  EXCLUSIVE-LOCK NO-ERROR.
                  
        IF AVAILABLE (people_mstr) THEN DO: 
            
/* NOTE 1 of 2: as of today (05/18/2017) when Doug adds the People_SSN column in the General.people_mstr in the 
    next DB/Table update and gen, change the people__char01 to the correct column name for the SSN.
    Also, when this change is done, we need a one time pgm to  move the SSN from the people__char01 to the
    correct table column SSN name.   See NOTE 2 in the lower code. */
     
                ASSIGN General.people_mstr.people__char01 = XML_TT_People_Data.TT-people_SSN. 
            
            IF  did-full-name-already-print = NO THEN DO:    
                ASSIGN  data-info = "PERSON:"
                        h-desc    = ""
                        Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                     XML_TT_People_Data.TT-people_midname   + " " +
                                     XML_TT_People_Data.TT-people_lastname  +
                                     ",  DOB: " + b_date + 
                                     ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".  
                                                 
                    PUT STREAM outwardPM
                            data-info       AT 1
                            o-people-id     AT 11 FORMAT ">,>>>,>>9"
                            Full-Name       AT 25 SKIP.
     
                ASSIGN  did-full-name-already-print = YES
                        no-update = NO.
            END. /* IF  did-full-name-already-print = NO */
                       
/* Create a new XML_TT_PeopID_Basic_Data table record if it does not exist. */  
       
            FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                        EXCLUSIVE-LOCK NO-ERROR.
                        
            IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data ) THEN DO: 
                CREATE XML_TT_PeopID_Basic_Data.
                ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                       XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID.                      
            END.  /*  IF NOT AVAILABLE (XML_TT_PeopID_Basic_Data )   */
             
/*  CHECK i/p FIELDS and if differents then  CREATE a discrepancy record. */  
           
            IF  XML_TT_People_Data.TT-people_midname        <> people_mstr.people_midname    OR
                XML_TT_People_Data.TT-people_prefix         <> people_mstr.people_prefix     OR
                XML_TT_People_Data.TT-people_suffix         <> people_mstr.people_suffix     OR
                genderhold                                  <> people_mstr.people_gender     OR
                XML_TT_People_Data.TT-people_homephone      <> people_mstr.people_homephone  OR 
                XML_TT_People_Data.TT-people_workphone      <> people_mstr.people_workphone  OR 
                XML_TT_People_Data.TT-people_prefname       <> people_mstr.people_prefname   OR 
/*                XML_TT_People_Data.TT-people_SSN            <> people_mstr.people_SSN        OR*/
                XML_TT_People_Data.TT-people_SSN            <> General.people_mstr.people__char01 

/* Need to un-comment any of the following people data compares when DDI starts passing the inputs. */
/* Also, the following people data has to be coded in the MAIN pgm: XMP-DB-Updates.p to allow then into the system. */
                
/*                XML_TT_People_Data.TT-people_cellphone      <> people_mstr.people_cellphone  OR     */
/*                XML_TT_People_Data.TT-people_company        <> people_mstr.people_company    OR     */
/*                XML_TT_People_Data.TT-people_fax            <> people_mstr.people_fax        OR     */
/*                XML_TT_People_Data.TT-people_email          <> people_mstr.people_email      OR     */
/*                XML_TT_People_Data.TT-people_email2         <> people_mstr.people_email2     OR     */
/*                XML_TT_People_Data.TT-people_contact        <> people_mstr.people_contact    OR     */
/*                XML_TT_People_Data.TT-people_title          <> people_mstr.people_title             */
                
                THEN DO: 
                    
                    ASSIGN o-peopdiscrep_ID = 0.
                    
                    RUN VALUE(SEARCH("SUBpeop-discrepy-ucU.r"))
                            (TT-People-Seq-Nbr,
                             o-people-id, 
                             h-DOB,
                             genderhold,
                             OUTPUT o-peopdiscrep_ID,
                             OUTPUT o-discrepy-error).
                                          
                     ASSIGN  data-info = "XML I/P:"
                             h-desc    = "XML input data is not equal to people_mstr data."
                             Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                          XML_TT_People_Data.TT-people_midname   + " " +
                                          XML_TT_People_Data.TT-people_lastname  +
                                          ",  DOB: " + b_date + 
                                          ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                    
                     IF  did-full-name-already-print = NO THEN DO:
                          
                         PUT STREAM outwardPM
                                data-info    AT 1
                                o-people-id  AT 11 FORMAT ">,>>>,>>9"
                                Full-Name    AT 25 SKIP.
                                  
                         ASSIGN  did-full-name-already-print = YES.
                         
                     END. /* IF  did-full-name-already-print = NO  */
                     
                     PUT STREAM outwardPM
                            "ACTION: XML input data is not equal to people_mstr data."    AT 25 SKIP.
                     
                     IF  o-peopdiscrep_ID > 0 THEN 
                         PUT STREAM outwardPM
                                ">>>>>     Discrepancy ID Number: " AT 15 
                                o-peopdiscrep_ID                    AT 50 FORMAT ">,>>>,>>9" SKIP(1).
                                
                     ASSIGN People_NOT_Equal_Error_kount = (People_NOT_Equal_Error_kount + 1).
                 
                     ASSIGN o-people-error-message =  
                                        Full-Name
                                      + " \n "
                                      + h-desc                     
                            o-people-load-error = ?.
                                                   
/* ERROR all of this tests result input - flag the PeopID_Basic record so 
        other programs will bypass the data for this ERROR. */
        
                     FIND XML_TT_PeopID_Basic_Data WHERE 
                                    XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                                    XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                                    XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                                EXCLUSIVE-LOCK NO-ERROR.           
            
                     IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data) THEN DO: 
                         CREATE XML_TT_PeopID_Basic_Data.
                         ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                         ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                                XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                                XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                                XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                                XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                                XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag       = "ERROR"
                                XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
                     END. /* IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data)  */
                                           
                     IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                         ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag    = "ERROR"
                                 XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID         = "discrepancy"
                                 XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "D_people". 
                
                     NEXT Main_loop.
                               
                END.  /*  IF   NOT EQUALs to each other  then do: */

        END.  /* IF AVAILABLE (people_mstr) */  
                  
    END.  /* IF  o-fpat-exist = YES */


    ELSE IF  o-fpat-exist = NO THEN DO: 
           
                RUN VALUE(SEARCH("SUBpeop-ucU.r"))                                        
                   (o-people-id,
                    XML_TT_People_Data.TT-people_firstname,
                    XML_TT_People_Data.TT-people_midname,
                    XML_TT_People_Data.TT-people_lastname,
                    XML_TT_People_Data.TT-people_prefix,
                    XML_TT_People_Data.TT-people_suffix,
                    "",                     /* company */
                    genderhold,
                    XML_TT_People_Data.TT-people_homephone,
                    XML_TT_People_Data.TT-people_workphone,
                    "",                     /* cellphone */
                    "",                     /* fax */
                    "",                     /* email */
                    "",                     /* email2 */
                    0,                      /* addr_id */
                    "",                     /* contact */
                    h-DOB,
                    0,                      /* second_addr_ID */ 
                    XML_TT_People_Data.TT-people_prefname,     /* prefname */                                                         
                    OUTPUT o-people-id,    
                    OUTPUT o-ucpeople-create,
                    OUTPUT o-ucpeople-update,
                    OUTPUT o-ucpeople-avail,
                    OUTPUT o-ucpeople-successful).

        IF  o-ucpeople-avail = NO THEN DO:
        
            ASSIGN o-people-load-error = YES.
         
            ASSIGN  data-info = "XML I/P:"
                    h-desc    = "Major Error - People_mstr NOT avaiable."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + b_date + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ". 
            
            IF  did-full-name-already-print = NO THEN                    
                PUT STREAM outwardPM
                        data-info       AT 1
                        o-people-id     AT 11
                        Full-Name       AT 25 SKIP.
             
            ASSIGN did-full-name-already-print = YES.            
         
            PUT STREAM outwardPM
                    "ACTION: Major Error - People_mstr NOT avaiable."    AT 25 SKIP.
            
            ASSIGN  o-people-error-message = 
                                   Full-Name
                                 + " \n "
                                 + " Major Error - People_mstr NOT avaiable " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                    o-people-load-error = YES. 
            
            ASSIGN o-people-error-message =  h-desc. 
                                 
            ASSIGN Major_Error_kount = (Major_Error_kount + 1). 
                                                               
/* ERROR all of this tests result input - flag the PeopID_Basic record so 
        other programs will bypass the data for this ERROR. */
        
             FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        EXCLUSIVE-LOCK NO-ERROR.           
    
             IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data) THEN DO: 
                 CREATE XML_TT_PeopID_Basic_Data.
                 ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                 ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                        XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                        XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                        XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                        XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                        XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag       = "ERROR"
                        XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
             END. /* IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data)  */
                                   
             IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                 ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag    = "ERROR"
                         XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID         = "P-Mstr not Avail"
                         XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "D_people". 
                        
            NEXT Main_loop.  
        
        END.  /* IF o-ucpeople-avail = NO */
    
        FIND General.people_mstr            
                WHERE   General.people_mstr.people_id       = o-people-id AND 
                        General.people_mstr.people_deleted  = ?   
            EXCLUSIVE-LOCK NO-ERROR. 

/* NOTE 2 of 2: as of today (05/18/2017) when Doug adds the People_SSN column in the General.people_mstr in the 
    next DB/Table update and gen, change the people__char01 to the correct column name for the SSN.
    Also, when this change is done, we need a one time pgm to  move the SSN from the people__char01 to the
    correct table column SSN name: General.people_mstr.people_SSN ?????? . */
    
        IF AVAILABLE (General.people_mstr) THEN    
                ASSIGN General.people_mstr.people__char01 = XML_TT_People_Data.TT-people_SSN. 
           
        IF  o-ucpeople-create = YES THEN DO:
       
            ASSIGN People_Mstr_created_kount = (People_Mstr_created_kount + 1).
            
            ASSIGN  data-info = "PERSON:"
                    h-desc    = "people_mstr CREATED for this person."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + b_date + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ". 
           
            IF  did-full-name-already-print = NO THEN                    
                PUT STREAM outwardPM
                        data-info       AT 1
                        o-people-id     AT 11 FORMAT ">,>>>,>>9"
                        Full-Name       AT 25 SKIP.
             
            ASSIGN  did-full-name-already-print = YES
                    no-update = YES.
         
            PUT STREAM outwardPM
                     "ACTION: people_mstr CREATED for this person."    AT 25 SKIP.            
                       
/* Create a new XML_TT_PeopID_Basic_Data table record if it does not exist. */  
       
            FIND XML_TT_PeopID_Basic_Data WHERE 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND  
                            XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND 
                            XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                        EXCLUSIVE-LOCK NO-ERROR.
                        
            IF  NOT AVAILABLE (XML_TT_PeopID_Basic_Data ) THEN DO: 
                CREATE XML_TT_PeopID_Basic_Data.
                ASSIGN Temp-PeopID_B-Seq-Nbr   = (Temp-PeopID_B-Seq-Nbr  + 1).
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only     = Temp-PeopID_B-Seq-Nbr
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = o-people-id
                       XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID           = i-flab-ID. 
                      
            END.  /*  IF NOT AVAILABLE (XML_TT_PeopID_Basic_Data )   */
                                                  
        END.  /* IF  o-ucpeople-create = YES */
          
/********  Create the patient_mstr record if wasn't found.  **********/
    
        IF  o-fpat-exist = NO THEN DO:
                   
            ASSIGN  h-tyr = YEAR(TODAY)
                    h-byr = YEAR(h-DOB).
                    
            IF  h-byr > h-tyr THEN 
                ASSIGN h-byr = h-byr - 100.
            
            ASSIGN h-age = (h-tyr - h-byr).
            
            IF  h-age < 18 THEN 
                ASSIGN h-RP_ID = 0. 
            ELSE 
                ASSIGN h-RP_ID = o-people-id.
             
                RUN VALUE(SEARCH("SUBpat-ucU.r"))                                        
                   (o-people-id,
                    XML_TT_People_Data.TT-people-pat_mstr_notes,    /* notes */
                    h-RP_ID,                                        /* RP_ID */
                    0,                                              /* doctor_ID */
                    0,                                              /* cust_ID */
                    h-log-NO,                                       /* verified */
                    OUTPUT o-people-id,                             /* o-ucpatient-id,*/
                    OUTPUT o-ucpatient-create,
                    OUTPUT o-ucpatient-update,
                    OUTPUT o-ucpatient-error,
                    OUTPUT o-ucpatient-successful).
            
                 ASSIGN  data-info = "PERSON:"
                         h-desc    = "patient_mstr Created - for an ADD of a new person."
                         Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                      XML_TT_People_Data.TT-people_midname   + " " +
                                      XML_TT_People_Data.TT-people_lastname  +
                                      ",  DOB: " + b_date + 
                                      ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                               
                 IF  o-ucpeople-create = YES AND 
                     did-full-name-already-print = NO THEN    
                                               
                         PUT STREAM outwardPM
                                data-info       AT 1
                                o-people-id     AT 11 FORMAT ">,>>>,>>9"
                                Full-Name       AT 25 SKIP.
                 
                 ASSIGN did-full-name-already-print = YES
                       no-update = YES.
                     
                 PUT STREAM outwardPM
                           "ACTION: patient_mstr Created - for an ADD of a new person."     AT 25 SKIP.
                                  
                 ASSIGN Patient_Mstr_created_kount = (Patient_Mstr_created_kount + 1).
                        
        END.  /*** o-fpat-exist = NO ***/
    
	END.  /* ELSE IF  o-fpat-exist = NO */

/* >>>>>>>>> following CODE replaces program: RStP-patient-uC.p - Jan 2017. 

the problem as of Jan 2017, we have no inputs from XML to use the following code
so we left it incase we get an e-mail address from XML in the future. */ 

/*
    /********  create a cust_mstr record ********/        
    RUN VALUE(SEARCH("SUBcust-findR.r"))                     
                   (TRIM(XML_TT_People_Data.TT-people_prefix),
                    TRIM(XML_TT_People_Data.TT-people_firstname),
                    TRIM(XML_TT_People_Data.TT-people_midname),
                    TRIM(XML_TT_People_Data.TT-people_lastname),
                    TRIM(XML_TT_People_Data.TT-people_suffix),
                    
need E-mail address INPUT FROM XML - BUT-there isn't any ,

                    OUTPUT o-fcust-ID,
                    OUTPUT o-fcust-addr-ID,
                    OUTPUT o-fcust-exist,
                    OUTPUT o-fcust-ran,
                    OUTPUT o-fcust-error). 
    
    IF  o-fcust-error = YES THEN DO:
        
        ASSIGN 
               o-people-error-message = 
                                   " Error trying to find cust_mstr record  " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
               o-people-load-error = YES. 
        
        ASSIGN  data-info = "CUSTOMER:"
                h-desc    = "cust_mstr - Error trying to find cust_mstr record."
                    Full-Name  = TT-people_firstname + " " + TT-people_lastname + 
                                 "    DOB: " + b_date.
                                
         PUT STREAM outwardPM
                    data-info       AT 2
                    o-people-id     AT 12
                    Full-Name       AT 30 SKIP. 
                                           
         ASSIGN  Full-Name = "ACTION: " +  h-desc.
         
         PUT STREAM outwardPM
                    Full-Name       AT 30 SKIP.
                             
    END. /* IF  o-fcust-error = YES */
       
    IF  i-Admin-Update-OverRyde = YES and 
        o-fcust-ID = 0 THEN DO: 

        ASSIGN Cust_Mstr_created_kount = (Cust_Mstr_created_kount + 1).
        
        RUN VALUE(SEARCH("SUBcust-ucU.r"))     
                       (o-people-id,
                        "", 0, "", 0, 0,
                        OUTPUT o-uccust-id,
                        OUTPUT o-uccust-create,
                        OUTPUT o-uccust-update,
                        OUTPUT o-uccust-error,
                        OUTPUT o-uccust-successful). 
                        
        ASSIGN  data-info = "CUSTOMER:"
                h-desc    = "cust_mstr created."
                Full-Name  = TT-people_firstname + " " + TT-people_lastname + 
                             "    DOB: " + b_date.
                                
        PUT STREAM outwardPM
                    data-info       AT 2
                    o-people-id     AT 12
                    Full-Name       AT 30 SKIP.
        
        ASSIGN  Full-Name = "ACTION: " +  h-desc.
         
        PUT STREAM outwardPM
                    Full-Name       AT 30 SKIP.
                                     
        ASSIGN  o-fcust-ID = o-uccust-id.  
   
    /********  create a scust_shadow record to go with the cust_mstr  ********/
        
        RUN VALUE(SEARCH("SUBscust-findR.r"))                                                       
                   (TRIM(XML_TT_People_Data.TT-people_prefix),
                    TRIM(XML_TT_People_Data.TT-people_firstname),
                    TRIM(XML_TT_People_Data.TT-people_midname),
                    TRIM(XML_TT_People_Data.TT-people_lastname),
                    TRIM(XML_TT_People_Data.TT-people_suffix),
                    "",                         /* e-mail address */
                    OUTPUT o-fshadc-ID,
                    OUTPUT o-fshadc-addr-ID,
                    OUTPUT o-fshadc-magento-ID,
                    OUTPUT o-fshadc-exist,
                    OUTPUT o-fshadc-ran,
                    OUTPUT o-fshadc-error). 
    
        IF  o-fshadc-error = YES THEN DO:
        
            ASSIGN 
                o-people-error-message = 
                                   " Error trying to find scust_shadow record  " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                o-people-load-error = YES. 
            
            ASSIGN  data-info = "SCUSTOMER:"
                h-desc    = "scust_shadow - Error trying to find scust_shadow record."
                Full-Name  = TT-people_firstname + " " + TT-people_lastname + 
                             "    DOB: " + b_date.
                                
            PUT STREAM outwardPM
                        data-info       AT 2
                        o-people-id     AT 12
                        Full-Name       AT 30 SKIP.                       
            
            ASSIGN  Full-Name = "ACTION: " +  h-desc.
         
            PUT STREAM outwardPM
                    Full-Name       AT 30 SKIP.
                          
        END. /* IF  o-fshadc-error = YES */
    
        IF o-fshadc-exist = NO THEN DO: 
           
            ASSIGN SCust_shadow_created_kount = (SCust_shadow_created_kount + 1).
        
            RUN VALUE(SEARCH("SUBscust-ucU.r"))                                                  
                       (o-fshadc-ID,
                        "", NO, 0,
                        OUTPUT o-ucscust-id,
                        OUTPUT o-ucscust-create,
                        OUTPUT o-ucscust-update,
                        OUTPUT o-ucscust-error,
                        OUTPUT o-ucscust-successful). 

            ASSIGN  o-fshadc-ID = o-ucscust-id.
            
            ASSIGN  data-info = "SCUSTOMER:"
                    h-desc    = "scust_shadow created."
                    Full-Name  = TT-people_firstname + " " + TT-people_lastname + 
                                 "    DOB: " + b_date + "     ACTION: " + h-desc.
                                
            PUT STREAM outwardPM
                        data-info       AT 2
                        o-people-id     AT 12
                        Full-Name       AT 30 SKIP.
            
            ASSIGN  Full-Name = "ACTION: " +  h-desc.
         
            PUT STREAM outwardPM
                    Full-Name       AT 30 SKIP.
                                                                
        END.  /**  o-fshadc-exist = NO  **/
                                      
    END.  /**  IF o-fcust-ID = 0  **/  
*/

    IF  no-update = NO THEN DO: 
    
        ASSIGN   Full-Name = "ACTION: " +  "NO updates or creates made.".
         
        PUT STREAM outwardPM
                 Full-Name       AT 25 SKIP.    
    
    END.  /* IF no-update = NO */
    
    ASSIGN no-update = NO.
                                           
END. /* FOR EACH XML_TT_People_Data */

       
FOR EACH D_people_mstr WHERE D_people_deleted = ? NO-LOCK:
    ASSIGN People_Discrepancy_Error_kount = (People_Discrepancy_Error_kount + 1).
END.            

     
PUT STREAM outwardPM SKIP(1)
    "Information:" SKIP 
    recordsprocessed FORMAT ">,>>>"               "  :Total Input Records Processed." SKIP
    People_Mstr_updated_kount FORMAT ">,>>9"      "  :People Masters updated." SKIP
    People_Mstr_created_kount FORMAT ">,>>9"      "  :People Masters created." SKIP
    Patient_Mstr_created_kount FORMAT ">,>>9"     "  :Patient Masters created." SKIP(1)

    "Warnings:" SKIP 
    People_Discrepancy_Error_kount FORMAT ">,>>9" "  : PEOPLE DISCREPANCIES found." SKIP(1)
    
    "Errors:" SKIP 
    Major_Error_kount FORMAT ">,>>9"              "  :Major Error - 1st or last name or DOB is blank." SKIP
    DOB_invalid_kount FORMAT ">,>>9"              "  :DOB incorrectly formatted or greater then TODAYs Date.  Input NOT loaded." SKIP
    DOB_Blank_kount FORMAT ">,>>9"                "  :DOB is BLANK.  Input NOT loaded." SKIP
    Minor_Error_kount FORMAT ">,>>9"              "  :Minor Error - gender is not = to Male or Female." SKIP 
    People_NOT_Equal_Error_kount FORMAT ">,>>9"   "  :XML input data is not equal to people_mstr data." SKIP(2). 
    
PUT STREAM outwardPM
    "*******************************************" SKIP.
PUT STREAM outwardPM 
    "**** End report.  " TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardPM
    "*******************************************" SKIP(1).
PAGE STREAM outwardPM.
                
OUTPUT STREAM outwardPM CLOSE.    
                 
/*IF ITdisplay = YES THEN DISPLAY "Leaving PROG: XML-SUB-People-Load." SKIP.*/
              
/** end of program **/

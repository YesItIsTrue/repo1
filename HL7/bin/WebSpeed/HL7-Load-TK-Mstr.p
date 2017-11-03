
/*------------------------------------------------------------------------
    File        : HL7-Load-TK-Mstr.p
    Purpose     : Load/Update the HHI.TK_mstr from XML data. 

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Feb 28, 2017.
    
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on 28/Feb/17.  Original version.  
          
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
{XML_TT_TK_Mstr_Data.i}.        /*  XML Extraction TK Master Data to Load into Progress. */ 
{XML_TT_People_Data.i}.         /*  XML Extraction People Data to Load into Progress. */      
{XML_TT_PeopID_Basic_Data.i}.   /* XML Extraction People ID ONLY to be used in the XML-SUB- programs.p. */ 

{E-Mail_definations.i}.

DEFINE INPUT PARAMETER  i-people-id             LIKE General.people_mstr.people_id      NO-UNDO.
DEFINE INPUT PARAMETER  i-Admin-Update-OverRyde AS LOGICAL  INITIAL NO                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-TK-Mstr-id            LIKE HHI.TK_mstr.TK_ID                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-Lab_Sample_ID         LIKE HHI.TK_mstr.TK_lab_sample_ID       NO-UNDO.
DEFINE OUTPUT PARAMETER o-TK-Mstr-load-error    AS LOGICAL INITIAL NO                   NO-UNDO.
DEFINE OUTPUT PARAMETER o-TK-Mstr-error-message AS CHARACTER  FORMAT "x(200)"           NO-UNDO.

/* ***  TK_mstr update output info.                                      *** */
DEFINE VARIABLE  o-uctkm-id              LIKE TK_mstr.TK_id              NO-UNDO.
DEFINE VARIABLE  o-uctkm-create          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE  o-uctkm-update          AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE  o-uctkm-avail           AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE VARIABLE  o-uctkm-successful      AS LOGICAL INITIAL NO           NO-UNDO.

/* Counters and Stuff. */
DEFINE VARIABLE tkrecordsprocessed              AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TK_Mstr_updated_kount           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TK-ID-NOT-found_kount           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TK-ID-BAD-Status_kount          AS INTEGER                      NO-UNDO.  
DEFINE VARIABLE TK-ID-PREFIX-not-found_kount    AS INTEGER                      NO-UNDO.  
/*DEFINE VARIABLE TK_Mstr_Discrepancy_kount       AS INTEGER                      NO-UNDO.*/
DEFINE VARIABLE TK-ID-issued_to_someelse_kount  AS INTEGER                      NO-UNDO. 
DEFINE VARIABLE Major_Error_kount               AS INTEGER                      NO-UNDO.

DEFINE VARIABLE coll_begin_Invalid_kount        AS INTEGER                      NO-UNDO.
DEFINE VARIABLE coll_end_Invalid_kount          AS INTEGER                      NO-UNDO.
 
DEFINE VARIABLE TK_Mstr_Discrepancy_Error_kount AS INTEGER                      NO-UNDO.
DEFINE VARIABLE len                             AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TK-ID-len                       AS INTEGER                      NO-UNDO.
DEFINE VARIABLE cont-1                          AS INTEGER                      NO-UNDO. 
  
DEFINE VARIABLE data-info                       AS CHARACTER FORMAT "x(8)"      NO-UNDO.
DEFINE VARIABLE h-blank                         AS CHARACTER FORMAT "x(1)"      NO-UNDO.
                 
DEFINE VARIABLE h-full-data                     AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE did-full-name-already-print     AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE no-update                       AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE h_test_age                      AS DECIMAL FORMAT  '-999.99'    NO-UNDO. 
DEFINE VARIABLE F_date                          AS CHARACTER FORMAT "x(10)"     NO-UNDO.
DEFINE VARIABLE F-IP-Date                       AS DATE FORMAT "99/99/99"       NO-UNDO.

DEFINE VARIABLE h-desc                          AS CHARACTER FORMAT "X(80)"     NO-UNDO.
DEFINE VARIABLE Full-Name                       AS CHARACTER FORMAT "X(80)"     NO-UNDO.
DEFINE VARIABLE Info-Msg              AS CHARACTER  EXTENT 11 FORMAT "x(80)"    NO-UNDO.
DEFINE VARIABLE xy1                             AS INTEGER    INITIAL 0         NO-UNDO.  
DEFINE VARIABLE Action-Msg                      AS CHARACTER FORMAT "x(80)"     NO-UNDO. 
DEFINE VARIABLE h-TK-Mstr-error-message         AS CHARACTER                    NO-UNDO. 
DEFINE VARIABLE Temp-PeopID_B-Seq-Nbr           AS INTEGER  INITIAL 0           NO-UNDO. 
DEFINE VARIABLE i-flab-id                       LIKE HHI.lab_mstr.lab_ID        NO-UNDO.
DEFINE VARIABLE h-tk-id             LIKE XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID   NO-UNDO.
DEFINE VARIABLE h-tk-id-seq         LIKE XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq NO-UNDO.

DEFINE VARIABLE ITdisplay                       AS LOGICAL INITIAL YES          NO-UNDO. 

/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 
   
DEFINE STREAM outwardTKM.
DEFINE VARIABLE loadRpt AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\TestKits-Load-Rpt.txt" NO-UNDO.
OUTPUT STREAM outwardTKM TO value(loadRpt) PAGED.

PUT STREAM outwardTKM
    "*******************************************" SKIP.
PUT STREAM outwardTKM 
    "**** Begin report." TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardTKM
    "*******************************************" SKIP.   
PUT STREAM outwardTKM 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1).

IF  i-Admin-Update-OverRyde = YES THEN 
    PUT STREAM outwardTKM
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP (1).
        
PUT STREAM outwardTKM 
    "Input-data:"  AT 1  "DB-NBR" AT 14 "NAME,  DOB:,  GENDER:" AT 25 SKIP. 
PUT STREAM outwardTKM
    "ACTION:" AT 25 SKIP. 
PUT STREAM outwardTKM 
    "=============================================" SKIP.

/* ***************************  Main Block  *************************** */

/*IF ITdisplay = YES THEN DISPLAY "Entered PROG: XML-SUB-TK_Mstr-Load." SKIP.*/
 
Main_loop:  
FOR EACH XML_TT_TK_Mstr_Data EXCLUSIVE-LOCK BREAK BY TT-TK_mstr-Seq-Nbr:  

/* get the input XML people data. */     
    FIND FIRST XML_TT_People_Data WHERE 
                XML_TT_People_Data.TT-People-Seq-Nbr      =  TT-TK_mstr-Seq-Nbr 
          EXCLUSIVE-LOCK NO-ERROR.

    FIND FIRST XML_TT_PeopID_Basic_Data   WHERE
                XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only = TT-TK_mstr-Seq-Nbr
          EXCLUSIVE-LOCK NO-ERROR.
                  
    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) AND 
        XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR" THEN             
            NEXT Main_Loop. 
    
    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
        ASSIGN  i-people-id                                             = XML_TT_PeopID_Basic_Data.TT_PeopID_people_id
                XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID                = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID
                XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq          = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq
                XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID        = XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID
                XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID_Seq    = XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq.
        
    FIND General.people_mstr 
                WHERE   General.people_mstr.people_id       = i-people-id AND
                        General.people_mstr.people_deleted  = ?
           NO-LOCK NO-ERROR. 

    ASSIGN  o-TK-Mstr-id                                = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID.
            XML_TT_TK_Mstr_Data.TT-TK_Mstr_people_id    = i-people-id.
                                     
    ASSIGN  tkrecordsprocessed = (tkrecordsprocessed + 1)
            Full-Name   = ""
            Action-Msg  = ""   
            did-full-name-already-print = NO
            o-TK-Mstr-error-message     = ""
            h-TK-Mstr-error-message     = "".
        
    DO  xy1 = 1 TO 11 BY 1 :
            ASSIGN  Info-Msg[xy1] = "".  
    END. 
 
    PUT STREAM outwardTKM "" SKIP.
   
/* Basic edit TK stuff here. */

/* Validate of the Test-Kit-ID. */
    IF  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID              = "" OR 
        XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq          = 0  OR 
        XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID   = "" OR  
        XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq = 0   
         THEN DO: 

            ASSIGN  data-info  = "PERSON:"
                    h-desc     = ""
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                              ",  GENDER: " +
                                              XML_TT_People_Data.TT-people_gender + ". ".

            PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
                        
            ASSIGN  data-info    = "XML I/P:"
                    h-desc       = "TK-ID or Lab-Sample-ID is blank or Seq Nbrs are zero (0)."
                    Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) + "    Lab-Sample-ID: " + 
                                 TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                                
            PUT STREAM outwardTKM
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.
                         
            ASSIGN  Action-Msg = "ACTION: " +  h-desc.
         
            PUT STREAM outwardTKM
                    Action-Msg      AT 25 SKIP(1).
            
            ASSIGN h-TK-Mstr-error-message = 
                                   " TK-ID or Lab-Sample-ID is blank or Seq Nbrs are zeros (0) " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                  o-TK-Mstr-load-error = YES.  
            
            ASSIGN o-TK-Mstr-error-message = Full-Name + " \n " + Info-Msg[1] + " \n " + h-TK-Mstr-error-message.
            
            ASSIGN Major_Error_kount = (Major_Error_kount + 1). 
            
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".             
                            
            NEXT Main_loop.
            
    END.  /* IF TK-ID or Lab-Sample-ID is blank or 0 */ 

/*  Begin of the Validation of the Test-Kit-ID prefix 
        to see if it exists in the HHI.Test_mstr table. */
        
    ASSIGN TK-ID-len = (INDEX(TT-TK_Mstr_TK_ID, "-", 1) - 1).  
    
    FIND FIRST HHI.test_mstr WHERE test_type = SUBSTRING(TT-TK_Mstr_TK_ID, 1, TK-ID-len) 
                   NO-LOCK NO-ERROR.
                   
    IF  NOT AVAILABLE (HHI.test_mstr) THEN DO:
        
        ASSIGN  data-info  = "PERSON:"
                h-desc     = "TK_ID Prefix not found in HHI.test_mstr."
                Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                             XML_TT_People_Data.TT-people_midname   + " " +
                             XML_TT_People_Data.TT-people_lastname  +
                             ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                          XML_TT_People_Data.TT-people_day + "/" +
                                          XML_TT_People_Data.TT-people_year + 
                             ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".

            PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.

            ASSIGN  data-info  = "XML I/P:"
                    Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID  + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) +
                                 "  Sample ID: " + TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq)
                    Info-msg[2]  = "Test Desc: " + TT-TK_Mstr_tk_test_desc
                    o-TK-Mstr-id = TT-TK_Mstr_TK_ID
                    o-Lab_Sample_ID = TT-TK_Mstr_tk_lab_sample_ID.
                               
            PUT STREAM outwardTKM
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.

            PUT STREAM outwardTKM
                    Info-Msg[2]     AT 25 SKIP.
                         
            ASSIGN  Action-Msg = "ACTION: " +  h-desc.
         
            PUT STREAM outwardTKM
                    Action-Msg       AT 25 SKIP(1).

            ASSIGN h-TK-Mstr-error-message = 
                                   " \n "
                                 + " TK_ID Prefix not found in HHI.test_mstr " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                                 + " \n " + " "
                  o-TK-Mstr-load-error = YES.  
            
            ASSIGN o-TK-Mstr-error-message = Full-Name + " \n " + Info-Msg[1] + " \n " + Info-Msg[2] + " \n " + h-TK-Mstr-error-message.
             
            ASSIGN TK-ID-PREFIX-not-found_kount = (TK-ID-PREFIX-not-found_kount + 1).
                        
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".             
 
            NEXT Main_loop.  
              
    END.  /* IF NOT AVAILABLE (HHI.test_mstr) */

/*get the HHI.test_mstr test_type value and the test_family value. */
    
    ASSIGN  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type     = HHI.test_mstr.test_type   
            XML_TT_PeopID_Basic_Data.TT-test-family         = HHI.test_mstr.test_family
            XML_TT_PeopID_Basic_Data.TT-test-type           = HHI.test_mstr.test_type.   
 
/*  End of the Validation of the Test-Kit-ID prefix to see if it exists in the HHI.Test_mstr table. */     

/* See if the Test Kit NBR exists or not. */    
/* If found, validate the input people_Id number is equal to HHI.TK_mstr.TK_patient_ID else ERROR.
             validate the TK_status is in SOLD or SHIPPED Status else ERROR. */ 
 
    FIND FIRST HHI.TK_mstr WHERE HHI.TK_mstr.TK_ID         = TT-TK_Mstr_TK_ID AND
                                 HHI.TK_mstr.TK_test_seq   = TT-TK_Mstr_TK_ID_Seq AND 
                                 HHI.TK_mstr.TK_deleted    = ?                          
                 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE (HHI.TK_mstr) THEN DO:                  
                        
            ASSIGN  data-info  = "PERSON:"
                    h-desc     = "TK_ID Nbr not found in HHI.TK_mstr."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".

            PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.

            ASSIGN  data-info  = "XML I/P:"
                    Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID  + "  / " + STRING(TT-TK_Mstr_TK_ID_Seq) +
                                 "  Lab_Sample_ID: " + TT-TK_Mstr_tk_lab_sample_ID + "  / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                               
            PUT STREAM outwardTKM
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.

            ASSIGN  Action-Msg = "ACTION: " +  h-desc.
         
            PUT STREAM outwardTKM
                    Action-Msg       AT 25 SKIP.

            ASSIGN h-TK-Mstr-error-message = 
                                   "  \n " 
                                 + " TK_ID Nbr not found in the HHI.TK_mstr " 
                                 + " in program: " 
                                 + "  \n " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                                 + "  \n " 
                  o-TK-Mstr-load-error = YES.  
            
            ASSIGN o-TK-Mstr-error-message = Full-Name + " \n " + Info-Msg[1] + " \n " + h-TK-Mstr-error-message.           
            
            ASSIGN TK-ID-NOT-found_kount = (TK-ID-NOT-found_kount + 1).
                        
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".             
 
            NEXT Main_loop.

    END.  /*  IF NOT AVAILABLE (HHI.test_mstr)  */

    IF  AVAILABLE (HHI.TK_mstr) THEN DO: 
               
        IF  HHI.TK_mstr.TK_patient_ID > 0               THEN DO:
            
            IF  HHI.TK_mstr.TK_patient_ID <> i-people-id  THEN DO:   
        
            ASSIGN  data-info  = "PERSON:"
                    h-desc     = "Input TK_ID Nbr has already been issued to someone else.  Rejected."
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".

            PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.

            ASSIGN  data-info  = "XML I/P:"
                    Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID  + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) +
                                 "  Lab_Sample_ID: " + TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                               
            PUT STREAM outwardTKM
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.

            ASSIGN  Action-Msg = "ACTION: " +  h-desc.
         
            PUT STREAM outwardTKM
                    Action-Msg       AT 25 SKIP.
            
            Info-Msg[2]  = "      : " + TT-TK_Mstr_TK_ID  + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) +
                                    "  belongs to person: " +  STRING(HHI.TK_mstr.TK_patient_ID) + ". ".
            
            PUT STREAM outwardTKM
                    Info-msg[2]     AT 25 SKIP(1).

            ASSIGN h-TK-Mstr-error-message = 
                                   "  \n " 
                                 + " Input TK_ID Nbr has already been issued to someone else.  Rejected " 
                                 + " in program: " 
                                 + "  \n " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                                 + "  \n " 
                  o-TK-Mstr-load-error = YES.  
            
            ASSIGN o-TK-Mstr-error-message = Full-Name + " \n " + Info-Msg[1] + " \n " + h-TK-Mstr-error-message.           
            
            ASSIGN TK-ID-issued_to_someelse_kount = (TK-ID-issued_to_someelse_kount + 1).
                   
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".
 
            NEXT Main_loop.
                                      
        	END. /* IF  HHI.TK_mstr.TK_patient_ID <> i-people-id  */
        	
        END. /* IF  HHI.TK_mstr.TK_patient_ID > 0 */

/*  input Test Kit must have a status of "SOLD" or "SHIPPED" to be updated, unless
    the input admin update overryde option is set to YES! */
            
        IF  (HHI.TK_mstr.TK_status   = "SOLD"       OR   
             HHI.TK_mstr.TK_status   = "SHIPPED")   OR 
            (i-Admin-Update-OverRyde = YES)         THEN  
                cont-1 = 1.
        ELSE DO:                                                            
                ASSIGN  data-info  = "PERSON:"
                        h-desc     = "TK_ID not in SOLD or SHIPPED Status for updating in HHI.TK_mstr."
                        Full-Name  = TT-people_firstname + " " + TT-people_lastname +
                                     "    DOB: " + TT-people_month  + "/" +
                                                   TT-people_day + "/" +
                                                   TT-people_year  + 
                                                   "  gender = " +
                                                   TT-people_gender + ". ".
    
                PUT STREAM outwardTKM
                        data-info       AT 1
                        i-people-id     AT 11 FORMAT ">,>>>,>>9"
                        Full-Name       AT 25 SKIP.
    
                ASSIGN  data-info    = "XML I/P:"
                        Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID  + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) +
                                     "  Lab_Sample_ID: " + TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                                   
                PUT STREAM outwardTKM
                        data-info       AT 1
                        Info-Msg[1]     AT 25 SKIP.
    
                ASSIGN  Action-Msg = "ACTION: " +  h-desc.
             
                PUT STREAM outwardTKM
                        Action-Msg       AT 25 SKIP.
    
                ASSIGN h-TK-Mstr-error-message = 
                                       " TK_ID not in SOLD or SHIPPED Status for updating in HHI.TK_mstr "
                                     +  " \n " 
                                     + "  in program: "
                                     +  " \n "  
                                     + THIS-PROCEDURE:FILE-NAME + "." +  " \n " 
                      o-TK-Mstr-load-error = YES.  
                
                ASSIGN o-TK-Mstr-error-message = Full-Name +  " \n " + h-TK-Mstr-error-message.           
                
                ASSIGN TK-ID-BAD-Status_kount = (TK-ID-BAD-Status_kount + 1).
                            
                IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  
                    ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".             
     
                NEXT Main_loop.
    
        END.  /*  ELSE DO:  [HHI.TK_mstr.TK_status   = "SOLD" or "SHIPPED"] */
               
    END. /* IF AVAILABLE (HHI.TK_mstr)  */
    
/* End to See if the Test Kit NBR exists or not. */ 

/*  Begin the Validation of the Test Kit DATEs for when this test showed up at the labs.
    Dates are:
        1.  coll_begin.
        2.  coll_end. 
*/
/* 1.  coll_begin. */
/*DISPLAY "Pgm: XML-SUB-TK-Mstr-Load.p    "                     */
/*        XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_month + "/" +*/
/*        XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_day + "/" +  */
/*        XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_year SKIP(1).*/

    ASSIGN F_date = XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_month + "/" + 
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_day + "/" + 
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_year.

    ASSIGN F-IP-Date = DATE(F_date) NO-ERROR.

    IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 OR 
        F-IP-Date > TODAY                                   THEN DO:   
/** Error Message **/ 
        IF did-full-name-already-print = NO THEN DO: 
            
            ASSIGN  data-info  = "PERSON:"
                    h-desc     = ""
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                                 
            PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.  
                          
            ASSIGN  did-full-name-already-print = YES.

            ASSIGN  data-info    = "XML I/P:"
                    Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) + "    Lab-Sample-ID: " + 
                                     TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                             
            PUT STREAM outwardTKM
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.
       
        END. /* IF did-full-name-already-print = NO */
        
        ASSIGN  h-desc       = "Test Kit coll_begin date value is invalid.".
        ASSIGN  Info-Msg[2]  = "Test Kit coll_begin date = " + 
                                  XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_month + "/" + 
                                  XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_day + "/" + 
                                  XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_begin_year.  
                                              
        PUT STREAM outwardTKM
                Info-Msg[2]     AT 25 SKIP.
                             
        ASSIGN  Action-Msg = "ACTION: " +  h-desc.
     
        PUT STREAM outwardTKM
                Action-Msg      AT 25 SKIP.
       
        ASSIGN h-TK-Mstr-error-message = 
                               " Test Kit coll_begin date value is invalid " 
                             + " in program: " 
                             + THIS-PROCEDURE:FILE-NAME + "."
              o-TK-Mstr-load-error = YES.  
        
        ASSIGN o-TK-Mstr-error-message = Full-Name + " \n " + Info-Msg[1] + " \n " + Info-Msg[2] + " \n " + h-TK-Mstr-error-message.
        
        ASSIGN coll_begin_Invalid_kount = (coll_begin_Invalid_kount + 1). 
                         
        IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  
            ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".             
                                               
    END.  /* IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0  */
    ELSE 
/* put the test begin date in the PeopID_Basic record to be used for the trh_hist record. */

        ASSIGN XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte = F-IP-Date. 
                     
/* 1.  End coll_begin. */ 

/* 2.  coll_end. */

    ASSIGN F_date = XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_month + "/" + 
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_day + "/" + 
                    XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_year.

    ASSIGN F-IP-Date = DATE(F_date) NO-ERROR.

    IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 OR 
        F-IP-Date > TODAY                                   THEN DO:   
/** Error Message **/ 
        IF did-full-name-already-print = NO THEN DO: 
            
            ASSIGN  data-info  = "PERSON:"
                    h-desc     = ""
                    Full-Name  = XML_TT_People_Data.TT-people_firstname + " " +
                                 XML_TT_People_Data.TT-people_midname   + " " +
                                 XML_TT_People_Data.TT-people_lastname  +
                                 ",  DOB: " + XML_TT_People_Data.TT-people_month + "/" + 
                                              XML_TT_People_Data.TT-people_day + "/" +
                                              XML_TT_People_Data.TT-people_year + 
                                 ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ".
                                 
            PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.  
                          
            ASSIGN  did-full-name-already-print = YES.

            ASSIGN  data-info    = "XML I/P:"
                    Info-Msg[1]  = "TK_ID: " + TT-TK_Mstr_TK_ID + " / " + STRING(TT-TK_Mstr_TK_ID_Seq) + "    Lab-Sample-ID: " + 
                                     TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                             
            PUT STREAM outwardTKM
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.
       
        END. /* IF did-full-name-already-print = NO */
        
        ASSIGN  h-desc       = "Test Kit coll_end date value is invalid.".
        ASSIGN  Info-Msg[2]  = "Test Kit coll_end date = " + 
                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_month + "/" + 
                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_day + "/" + 
                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_coll_end_year.  
                                              
        PUT STREAM outwardTKM
                Info-Msg[2]   AT 25 SKIP.
                             
        ASSIGN  Action-Msg = "ACTION: " +  h-desc.
     
        PUT STREAM outwardTKM
                Action-Msg      AT 25 SKIP.
       
        ASSIGN h-TK-Mstr-error-message = 
                               " Test Kit coll_end date value is invalid " 
                             + " in program: " 
                             + THIS-PROCEDURE:FILE-NAME + "."
              o-TK-Mstr-load-error = YES.  
        
        ASSIGN o-TK-Mstr-error-message = Full-Name + " \n " + Info-Msg[1] + " \n " + Info-Msg[2] + " \n " + h-TK-Mstr-error-message.
        
        ASSIGN coll_end_Invalid_kount = (coll_end_Invalid_kount + 1). 
            
        IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  
            ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".             
                                                       
    END.  /* IF ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0  */
    ELSE 
/* put the test end date in the PeopID_Basic record to be used for the trh_hist record. */ 

        ASSIGN XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte = F-IP-Date.     

/* 2.  End coll-end. */

/*/*  End of the Validation of the Test Kit DATEs for when this test showed up at the labs. */                       */


            
/* End of basic edit TK stuff here. */

/* get the input XML_TT_PeopID_Basic_Data. */  
        
    FIND FIRST XML_TT_PeopID_Basic_Data  WHERE
                       XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_People_Data.TT-people_fs_atn_file_ID   AND 
                       XML_TT_PeopID_Basic_Data.TT-PeopID_fs_parent-level  = XML_TT_People_Data.TT-people_fs_parent-level  AND  
                       XML_TT_PeopID_Basic_Data.TT-PeopID_atn_node_level   = XML_TT_People_Data.TT-people_atn_node_level   AND 
                       XML_TT_PeopID_Basic_Data.TT_PeopID_people_id        = i-people-id  
         EXCLUSIVE-LOCK NO-ERROR.

    IF AVAILABLE (XML_TT_PeopID_Basic_Data) THEN DO: 
                                       
        IF  h-tk-id     <> XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID OR 
            h-tk-id-seq <> XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq THEN 
                ASSIGN  h-tk-id     = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID
                        h-tk-id-seq = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq
                        did-full-name-already-print = NO.
                        
/* if only one (1) input date move it to the coll_end_dte field. */
        IF  XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte = ? THEN 
            ASSIGN  XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_end_dte = XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte
                    XML_TT_PeopID_Basic_Data.TT-PeopID_TK_Mstr_coll_beg_dte = ?.
        
    END. /* IF AVAILABLE (XML_TT_PeopID_Basic_Data)  */ 
    
/* Calcuate the patient's AGE at the time of the tests. */
                              
    ASSIGN h_test_age = (INTERVAL (TODAY, people_DOB, 'months') / 12.0 ).   

    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN DO:

        ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_TK_ID                = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID
                XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq          = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq
                XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID        = XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID
                XML_TT_PeopID_Basic_Data.TT_PeopID_lab_sample_ID_Seq    = XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq
                Temp-PeopID_B-Seq-Nbr                                   = XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only
                i-flab-id                                               = XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID
                XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag           = "Retrieval".
                            
    END. /* IF  AVAILABLE (XML_TT_PeopID_Basic_Data)   */
                  
/* Per Doug 3/11/2017 - IF TK_mstr found THEN UPDATE FIELDS:  TK_patient_ID   TK_lab_sample_ID  TK_lab_seq   
                                                              TK_test_age  TK_status  TK_lab_id.  */
             
    IF  i-Admin-Update-OverRyde = YES AND 
        XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag <> "ERROR" THEN DO: 
                                  
        RUN VALUE(SEARCH("SUBtkmstr-ucU.r"))        
                        (XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID, 
                         XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type,       /* test_type */
                         ?,                                                 /* prof */
                         XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq,
                         ?,                                                 /* domestic */
                         0,                                                 /* TK_cust_ID */
                         i-people-id,                                                 /* Tk_patient_Id */
                         XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID,             /* Tk_lab_sample_ID */
                         XML_TT_TK_Mstr_Data.TT-TK_Mstr_tk_lab_sample_ID_Seq,         /* TK_lab_seq */
                         h_test_age,                                                  /* TK_test_age */
                         XML_TT_PeopID_Basic_Data.TT_PeopID_lab_ID,                   /* TK_lab_ID */
                         "PROCESSED",                                                 /* TK_status */
                         "",                                                /* TK_comments */
                         "",                                                /* TK_notes */
                         ?,                                                 /* TK_cust_paid */
                         ?,                                                 /* TK_lbl_print */
                         ?,                                                 /* TK_lab_paid */
                         "",                                                /* TK_magento_order */
                         ?,                                                 /* TK_cust_paid_date */
                         OUTPUT o-uctkm-id,
                         OUTPUT o-uctkm-create,
                         OUTPUT o-uctkm-update,
                         OUTPUT o-uctkm-avail, 
                         OUTPUT o-uctkm-successful).
                       
        FIND TK_mstr WHERE
                            TK_mstr.TK_id       = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID      AND 
                            TK_mstr.TK_test_seq = XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq  AND
                            TK_mstr.TK_deleted  = ?
                 NO-LOCK NO-ERROR.
        
        IF  AVAILABLE (HHI.TK_mstr)                 AND 
            AVAILABLE (XML_TT_PeopID_Basic_Data)    THEN
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag           = HHI.TK_mstr.TK_status.
        ELSE 
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag           = "ERROR".
                      
        IF  o-uctkm-update              = YES AND 
            o-uctkm-successful          = YES AND 
            XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag = "PROCESSED"  THEN DO:   
                                               
                ASSIGN  TK_Mstr_updated_kount   = (TK_Mstr_updated_kount + 1)
                        no-update               = YES.
                            
                IF did-full-name-already-print = NO THEN DO:            
                    FIND FIRST people_mstr WHERE
                                people_mstr.people_ID         = i-people-id AND
                                people_mstr.people_deleted    = ?
                          NO-LOCK NO-ERROR.
        
                        ASSIGN  data-info = "PERSON:"      
                                Full-Name = people_mstr.people_firstname    + " " + 
                                            people_mstr.people_midname      + " " +
                                            people_mstr.people_lastname     + 
                                            ",  DOB: " + STRING(people_mstr.people_DOB) + 
                                            ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ". 
                                                   
                        PUT STREAM outwardTKM
                            data-info       AT 1
                            i-people-id     AT 11 FORMAT ">,>>>,>>9"
                            Full-Name       AT 25 .
        
                        ASSIGN  did-full-name-already-print = YES.
             
                END. /* IF did-full-name-already-print = NO  */
                    
                ASSIGN  Info-Msg[1] = "TK Master updated: " + 
                                      XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID + " / " + STRING(XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_ID_Seq) +
                                      "     TK Status = " + XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag.
                        Info-Msg[2] = "    Lab-Sample-ID: " + 
                                      TT-TK_Mstr_tk_lab_sample_ID + " / " + STRING(TT-TK_Mstr_tk_lab_sample_ID_Seq).
                             
                PUT STREAM outwardTKM
                         Info-Msg[1]       AT 25 . 
                
                PUT STREAM outwardTKM
                         Info-Msg[2]       AT 25 SKIP.
                                    
            END. /* IF  o-uctkm-update   = YES */ 
            
        ELSE DO: 
            
            ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag           = "ERROR"
                    no-update = NO.  
                    
            IF ITdisplay = YES   THEN
                DISPLAY "Prog: SUB-TK_mstr-Load: :Error from SUBtkmstr-ucU.r." SKIP
                  "TT_PeopID_TK_ID 1 = " TT_PeopID_TK_ID " / "   TT_PeopID_Tk_test_seq SKIP          
                  "TT_PeopID_TK_ID 2 = " TT_PeopID_lab_sample_ID " / "   TT_PeopID_lab_sample_ID_Seq SKIP(2).
        END. /* ELSE DO:  o-uctkm-update              = YES */

    END. /* IF  i-Admin-Update-OverRyde = YES and XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag <> "ERROR" */
          
    IF  no-update = NO THEN DO: 
        
        IF did-full-name-already-print = NO THEN DO: 
            
            FIND FIRST people_mstr WHERE
                        people_mstr.people_ID         = i-people-id AND
                        people_mstr.people_deleted    = ?
                  NO-LOCK NO-ERROR.

                ASSIGN  data-info = "PERSON:"      
                        Full-Name = people_mstr.people_firstname    + " " + 
                                    people_mstr.people_midname      + " " +
                                    people_mstr.people_lastname     + 
                                    ",  DOB: " + STRING(people_mstr.people_DOB) + 
                                    ",  GENDER: " + XML_TT_People_Data.TT-people_gender + ". ". 
 
                PUT STREAM outwardTKM
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.

                ASSIGN  did-full-name-already-print = YES.
     
        END. /* IF did-full-name-already-print = NO  */
        
        ASSIGN   Full-Name = "ACTION: " +  "NO updates or creates made.".
                         
        PUT STREAM outwardTKM
                 Full-Name       AT 25 SKIP(1).    
    
    END.  /* IF no-update = NO */
    
    ASSIGN  no-update = NO
            did-full-name-already-print = NO.
                                       
END. /* FOR EACH XML_TT_TK_Mstr_Data */
                                        
      
PUT STREAM outwardTKM SKIP(1)
    "Information:" SKIP 
    tkrecordsprocessed FORMAT ">,>>>"               "  :Total Input Test Kits." SKIP
    TK_Mstr_updated_kount FORMAT ">,>>9"            "  :Test Kit Masters updated." SKIP(1)

    "Errors:" SKIP 
    Major_Error_kount FORMAT ">,>>9"                "  :TK-ID or Lab-Sample-ID is blank or Seq Nbrs are zeros (0)." SKIP 
    TK-ID-NOT-found_kount FORMAT ">,>>9"            "  :TK_ID Nbr not found in HHI.TK_mstr." SKIP 
    TK-ID-issued_to_someelse_kount FORMAT ">,>>9"   "  :Input TK_ID Nbr has already been issued to someone else.  Rejected." SKIP 
    " " SKIP   
    TK-ID-BAD-Status_kount FORMAT ">,>>9"           "  :TK_ID Nbr not in SOLD or SHIPPED Status for updating in HHI.TK_mstr." SKIP
    TK-ID-PREFIX-not-found_kount FORMAT ">,>>9"     "  :TK_ID Prefix not found in HHI.test_mstr." SKIP 
    " " SKIP 
    coll_begin_Invalid_kount FORMAT ">,>>9"         "  :Test Kit Collected Begin Date value is invalid." SKIP
    coll_end_Invalid_kount FORMAT ">,>>9"           "  :Test Kit Collected End Date value is invalid." SKIP(2).

PUT STREAM outwardTKM
    "*******************************************" SKIP.
PUT STREAM outwardTKM 
    "**** End report.  " TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardTKM
    "*******************************************" SKIP(1).
PAGE STREAM outwardTKM.
                
OUTPUT STREAM outwardTKM CLOSE. 
  
/*                                                                                       */
/*IF  ITDisplay = YES THEN                                                               */
/*        FOR EACH XML_TT_TK_Mstr_Data         NO-LOCK BY  TT-TK_Mstr-Seq-Nbr:           */
/*            IF  TT-TK_Mstr-Seq-Nbr = 1 THEN                                            */
/*                PUT STREAM DBUTrace3U                                                  */
/*                    "Updated in Prog: XML-SUB-TK-Mstr-Load: XML_TT_TK_Mstr_Data:" SKIP.*/
/*    PUT STREAM DBUTrace3U                                                              */
/*        TT-TK_Mstr-Seq-Nbr              FORMAT ">>>>>9" " "                            */
/*        TT-TK_Mstr_fs_atn_file_ID       FORMAT ">>>>>9" " "                            */
/*        TT-TK_Mstr_fs_parent-level      FORMAT ">>>9"   " "                            */
/*        TT-TK_Mstr_atn_node_level       FORMAT ">>>9"   "  "                           */
/*        TT-TK_Mstr_TK_ID                FORMAT "x(20)"  " "                            */
/*        TT-TK_Mstr_TK_ID_Seq            FORMAT ">>9"    "  "                           */
/*        TT-TK_Mstr_tk_lab_sample_ID     FORMAT "x(20)"  " "                            */
/*        TT-TK_Mstr_tk_lab_sample_ID_Seq FORMAT ">>9"    " "                            */
/*        TT-TK_Mstr_tk_test_desc         FORMAT "x(30)"  " " SKIP                       */
/*        "                           "                                                  */
/*        "Begin-Date i/p fields: "                                                      */
/*                TT-TK_Mstr_coll_begin_month     FORMAT "99"                            */
/*                "/"                                                                    */
/*                TT-TK_Mstr_coll_begin_day       FORMAT "99"                            */
/*                "/"                                                                    */
/*                TT-TK_Mstr_coll_begin_year      FORMAT "9999"        "  "              */
/*        "  End-Date i/p fields: "                                                      */
/*                TT-TK_Mstr_coll_end_month       FORMAT "99"                            */
/*                "/"                                                                    */
/*                TT-TK_Mstr_coll_end_day         FORMAT "99"                            */
/*                "/"                                                                    */
/*                TT-TK_Mstr_coll_end_year        FORMAT "9999"        "  "              */
/*                                                                                       */
/*                TT-TK_Mstr_volume                               SKIP(1)                */
/*                .                                                                      */
/*END. /* 4 each */                                                                      */
/*IF  ITDisplay = YES THEN DO:                                                           */
/*        PUT STREAM DBUTrace3U                                                          */
/*            "End report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1).         */
/*        OUTPUT STREAM DBUTrace3U CLOSE.                                                */
/*END. /* 4-each. */                                                                     */

/* IF ITdisplay = YES THEN DISPLAY "Leaving PROG: XML-SUB-TK_Mstr-Load." SKIP.*/
              
/** end of program **/

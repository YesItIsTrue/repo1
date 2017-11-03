
/*------------------------------------------------------------------------
    File        : HL7-Load-TKR-det.p
    Purpose     : Load/Update the HHI.TKR_det data from the XML data. 

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : May 11, 2017.
    
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on 11/May/17.  Original version.  
          
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
 
{XML_TT_tkr_det_Data.i}.        /* XML Extraction TK Detail Data to Load into Progress. */ 
/*{XML_TT_People_Data.i}.         /* XML Extraction People Data to Load into Progress. */*/
{XML_TT_PeopID_Basic_Data.i}.   /* XML Extraction People ID ONLY to be used in the XML-SUB- programs.p. */
{XML_TT_TK_Mstr_Data.i}.        /*  XML Extraction TK Master Data to Load into Progress. */ 

{E-Mail_definations.i}.

DEFINE INPUT PARAMETER  i-people-id             LIKE General.people_mstr.people_id      NO-UNDO.
DEFINE INPUT PARAMETER  i-Admin-Update-OverRyde AS LOGICAL  INITIAL NO                  NO-UNDO.
DEFINE OUTPUT PARAMETER o-TKR-det-id            LIKE HHI.TKR_det.TKR_ID                 NO-UNDO.
DEFINE OUTPUT PARAMETER o-TKR-det-fs-atn-file-ID LIKE XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID  NO-UNDO.
DEFINE OUTPUT PARAMETER o-TKR-det-load-error    AS LOGICAL INITIAL NO                   NO-UNDO.
DEFINE OUTPUT PARAMETER o-TKR-det-error-message AS CHARACTER  FORMAT "x(200)"           NO-UNDO.

/* ***  TKR_det update output info.                                      *** */
DEFINE VARIABLE  o-ucTKRdet-id                  LIKE TKR_det.TKR_id             NO-UNDO.
DEFINE VARIABLE  o-ucTKRdet-create              AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE  o-ucTKRdet-update              AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE  o-ucTKRdet-avail               AS LOGICAL INITIAL YES          NO-UNDO.
DEFINE VARIABLE  o-ucTKRdet-successful          AS LOGICAL INITIAL NO           NO-UNDO.

/* Counters and Stuff. */
DEFINE VARIABLE tkrecordsprocessed              AS INTEGER                      NO-UNDO.
DEFINE VARIABLE tkDrecordsprocessed             AS INTEGER                      NO-UNDO.
DEFINE VARIABLE Element_Symbol_Error_kount      AS INTEGER                      NO-UNDO.

DEFINE VARIABLE TKR_det_created_kount           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TKR_det_updated_kount           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TKR_det_NOT_updated_kount       AS INTEGER                      NO-UNDO. 

DEFINE VARIABLE BFM_mstr_created_kount          AS INTEGER                      NO-UNDO.
DEFINE VARIABLE BFM_mstr_updated_kount          AS INTEGER                      NO-UNDO.

DEFINE VARIABLE BHE_mstr_created_kount          AS INTEGER                      NO-UNDO.
DEFINE VARIABLE BHE_mstr_updated_kount          AS INTEGER                      NO-UNDO.

DEFINE VARIABLE BUTEE_mstr_created_kount        AS INTEGER                      NO-UNDO.
DEFINE VARIABLE BUTEE_mstr_updated_kount        AS INTEGER                      NO-UNDO.

DEFINE VARIABLE BMPA_det_created_kount          AS INTEGER                      NO-UNDO.
DEFINE VARIABLE BMPA_det_updated_kount          AS INTEGER                      NO-UNDO.
 

DEFINE VARIABLE Major_Error_kount               AS INTEGER                      NO-UNDO.

DEFINE VARIABLE len                             AS INTEGER                      NO-UNDO.
DEFINE VARIABLE x-do                            AS INTEGER                      NO-UNDO. 
DEFINE VARIABLE first-space                     AS INTEGER                      NO-UNDO.
DEFINE VARIABLE last-space                      AS INTEGER                      NO-UNDO.
DEFINE VARIABLE TKR-item-aftDash-position       AS INTEGER INITIAL 0            NO-UNDO.
DEFINE VARIABLE TKR-item-beforeSlash-position   AS INTEGER INITIAL 0            NO-UNDO.
DEFINE VARIABLE xy1                             AS INTEGER INITIAL 0            NO-UNDO.

DEFINE VARIABLE data-info                       AS CHARACTER FORMAT "x(8)"      NO-UNDO.
DEFINE VARIABLE h-blank                         AS CHARACTER FORMAT "x(1)"      NO-UNDO.
DEFINE VARIABLE did-full-name-already-print     AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE no-update                       AS LOGICAL INITIAL NO           NO-UNDO.

DEFINE VARIABLE h-desc                          AS CHARACTER FORMAT "X(80)"     NO-UNDO.
DEFINE VARIABLE h-uom                           AS CHARACTER FORMAT "x(60)"     NO-UNDO.
DEFINE VARIABLE h-ref                           AS CHARACTER FORMAT "x(60)"     NO-UNDO.
DEFINE VARIABLE Full-Name                       AS CHARACTER FORMAT "X(80)"     NO-UNDO.
DEFINE VARIABLE h-TKR_ID                        AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE h-TKR_ID_Seq                    AS INTEGER INITIAL 0            NO-UNDO.
DEFINE VARIABLE h-TKR_item                      AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE h-FILE_ID                       AS INTEGER INITIAL 0            NO-UNDO.
DEFINE VARIABLE v-people-firstname              LIKE  General.people_mstr.people_firstname NO-UNDO.
DEFINE VARIABLE v-people-midname                LIKE  General.people_mstr.people_midname   NO-UNDO. 
DEFINE VARIABLE v-people-lastname               LIKE  General.people_mstr.people_lastname  NO-UNDO.
DEFINE VARIABLE v-people-dob                    LIKE  General.people_mstr.people_DOB       NO-UNDO.                  
DEFINE VARIABLE v-tkid                          LIKE TK_mstr.TK_ID              NO-UNDO.           
DEFINE VARIABLE v-tkseq                         LIKE TK_mstr.TK_test_seq        NO-UNDO. 

DEFINE VARIABLE Info-Msg              AS CHARACTER EXTENT 11 FORMAT "x(132)"    NO-UNDO. 

DEFINE VARIABLE first-results                   AS INTEGER INITIAL 0            NO-UNDO.
DEFINE VARIABLE Action-Msg                      AS CHARACTER FORMAT "x(80)"     NO-UNDO.  
DEFINE VARIABLE h-TKR-det-error-message         AS CHARACTER  FORMAT "x(200)"   NO-UNDO.

DEFINE VARIABLE ITdisplay                       AS LOGICAL INITIAL  YES           NO-UNDO. 

/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).                 
   
DEFINE STREAM outwardTKR.
DEFINE VARIABLE loadRpt AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\TestsDetails-Load-Rpt.txt" NO-UNDO.
OUTPUT STREAM outwardTKR TO value(loadRpt) PAGED.

PUT STREAM outwardTKR
    "*******************************************" SKIP.
PUT STREAM outwardTKR 
    "**** Begin report." TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardTKR
    "*******************************************" SKIP.
PUT STREAM outwardTKR 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1).

IF  i-Admin-Update-OverRyde = YES THEN 
    PUT STREAM outwardTKR
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP (1).
        
PUT STREAM outwardTKR 
    "Input-data:"  AT 1  "DB-NBR" AT 14 "NAME,  DOB:" AT 25 SKIP. 
PUT STREAM outwardTKR
    "ACTION:" AT 25 SKIP(1). 
PUT STREAM outwardTKR
    "===================================" SKIP. 
           
IF ITdisplay = YES THEN  DO:
    DEFINE STREAM TKRdumpR.
    DEFINE VARIABLE dumpRptR AS CHARACTER 
        INITIAL "C:\PROGRESS\WRK\XML-SUB-TKR_det-Dump.txt" NO-UNDO.
    OUTPUT STREAM TKRdumpR TO value(dumpRptR).
    PUT STREAM TKRdumpR 
        "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP.
    PUT STREAM TKRdumpR 
        "Begin report." TODAY AT 15 STRING(TIME, "HH:MM:SS") AT 25 SKIP (1). 
    IF  i-Admin-Update-OverRyde = YES THEN 
        PUT STREAM TKRdumpR
            "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP (1).       
END.

/* ***************************  Main Block  *************************** */

IF ITdisplay = YES THEN PUT STREAM TKRdumpR "Entered PROG: XML-SUB-TKR-det-Load." SKIP.

Main_loop:  
FOR EACH XML_TT_tkr_det_Data NO-LOCK        BREAK BY TT-tkr_det_fs_atn_file_ID 
                                                  BY TT-tkr_det_fs_parent-level :

    IF ITdisplay = YES  AND  XML_TT_tkr_det_Data.TT-tkr_det-Seq-Nbr = 1 THEN
        PUT STREAM TKRdumpR "In PROG: XML-SUB-TKR-det-Load: XML_TT_tkr_det_Data:" SKIP.
    IF ITdisplay = YES  THEN
        PUT STREAM TKRdumpR
            XML_TT_tkr_det_Data.TT-tkr_det-Seq-Nbr          FORMAT ">>>>>9" " "
            XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID   FORMAT ">>>>>9" " "
            TT-tkr_det_fs_parent-level                      FORMAT ">>>9"   " "
            TT-tkr_det_atn_node_level                       FORMAT ">>>9"   "  "
            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID           FORMAT "x(15)"  " "
            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq       FORMAT ">>9"    "  "
            XML_TT_tkr_det_Data.TT-tkr_det_TKR_item         FORMAT "x(15)"  " "
            TT-tkr_det_TKR_lab_result                       FORMAT "x(10)"  " "
            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom      FORMAT "x(10)"  " "
            XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref      FORMAT "x(10)" SKIP .
            
    FIND FIRST XML_TT_PeopID_Basic_Data WHERE 
                    XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID 
                NO-LOCK NO-ERROR.
                
    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) AND  
        XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR"  THEN 
            NEXT Main_Loop. 
        
    FIND FIRST XML_TT_PeopID_Basic_Data   WHERE
                XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_ID            = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID     AND 
                XML_TT_PeopID_Basic_Data.TT_PeopID_Tk_test_seq      = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq AND     
                XML_TT_PeopID_Basic_Data.TT_PeopID_fs_atn_file_id   = XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID   
          EXCLUSIVE-LOCK NO-ERROR.
         
    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN DO: 
        
        ASSIGN  i-people-id             =  XML_TT_PeopID_Basic_Data.TT_PeopID_people_id
                v-people-firstname      = "unknown" 
                v-people-midname        = ""
                v-people-lastname       = "unknown"
                v-people-dob            = DATE("01/01/1900").
                        
    END. /* IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN  */
        
    FIND General.people_mstr 
                WHERE   General.people_mstr.people_id       = i-people-id AND
                        General.people_mstr.people_deleted  = ?
           NO-LOCK NO-ERROR. 

    IF  AVAILABLE (general.people_mstr) THEN 
     
        ASSIGN  v-people-firstname      = General.people_mstr.people_firstname 
                v-people-midname        = General.people_mstr.people_midname
                v-people-lastname       = General.people_mstr.people_lastname
                v-people-dob            = General.people_mstr.people_DOB.    
                  
    ASSIGN  o-TKR-det-id  = TT-tkr_det_TKR_ID.
                                     
    ASSIGN  tkDrecordsprocessed = (tkDrecordsprocessed + 1)
            Full-Name   = ""
            Action-Msg  = ""
            h-uom       = ""
            h-ref       = "".  
 
    DO  xy1 = 1 TO 11 BY 1 :
            ASSIGN  Info-Msg[xy1] = "".  
    END. 
    
/* Basic edit TK stuff here. */

    ASSIGN o-TKR-det-fs-atn-file-ID =  XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID.
    
/* Validate of the Test-Kit-ID. */
    IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID           = "" OR 
        XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq       = 0  OR 
        XML_TT_tkr_det_Data.TT-tkr_det_TKR_item         = ""   
         THEN DO: 
   
            ASSIGN  data-info  = "PERSON:"
                    h-desc     = ""
                    Full-Name  = v-people-firstname + " " +
                                 v-people-midname   + " " + 
                                 v-people-lastname +
                                 ",  DOB: " + string(v-people-dob).

            PUT STREAM outwardTKR
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
                        
            ASSIGN  data-info    = "XML I/P:"
                    h-desc       = "TKR-ID or TKR_item is blank or TKR_ID_Seq is zero (0)."
                    Info-Msg[1]  = "TKR_ID: " + TT-TKR_det_TKR_ID + " / " + STRING(TT-tkr_det_TKR_ID_Seq) 
                    Info-Msg[2]  = "TKR_item: " + TT-tkr_det_TKR_item  
                    Info-Msg[3]  = "TKR_lab_result: " + TT-tkr_det_TKR_lab_result 
                    Info-Msg[4]  = "TKR_ref_uom: " + TT-tkr_det_TKR_ref_uom 
                    Info-Msg[5]  = "TKR_lab_ref: " + TT-tkr_det_TKR_lab_ref.
                                
            PUT STREAM outwardTKR
                    data-info       AT 1
                    Info-Msg[1]     AT 25 SKIP.
            PUT STREAM outwardTKR
                    Info-Msg[2]     AT 25 SKIP. 
            PUT STREAM outwardTKR
                    Info-Msg[3]     AT 25 SKIP.
            PUT STREAM outwardTKR
                    Info-Msg[4]     AT 25 SKIP.
            PUT STREAM outwardTKR
                    Info-Msg[5]     AT 25 SKIP.
                                
            ASSIGN  Action-Msg = "ACTION: " +  h-desc.
         
            PUT STREAM outwardTKR
                    Action-Msg      AT 25 SKIP(1).
            
            ASSIGN h-TKR-det-error-message = 
                                   " TKR-ID or TKR_item is blank or TKR_ID_Seq is zero (0) " 
                                 + " in program: " 
                                 + THIS-PROCEDURE:FILE-NAME + "."
                  o-TKR-det-load-error = YES.  
            
            ASSIGN o-TKR-det-error-message  = Full-Name + " \n " + Info-Msg[1] + " \n " + Info-Msg[2] + " \n " + Info-Msg[3] + " \n "
                                            + Info-Msg[4] + " \n " + Info-Msg[5] + " \n "
                                            + h-TKR-det-error-message.
            
            ASSIGN Major_Error_kount = (Major_Error_kount + 1). 

            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN   
                XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR".
        
            NEXT Main_loop.
            
    END.  /* IF TKR-ID or TKR_item or TKR_lab_result or TKR_ref_uom or TKR_lab_ref is blank or Seq Nbr is zero (0) */ 

    IF  did-full-name-already-print = NO THEN DO:
         
            ASSIGN  data-info  = "PERSON:"
                    h-desc     = ""
                    Full-Name  = v-people-firstname + " " +
                                 v-people-midname   + " " + 
                                 v-people-lastname +
                                 ",  DOB: " + string(v-people-dob).

            PUT STREAM outwardTKR
                    data-info       AT 1
                    i-people-id     AT 11 FORMAT ">,>>>,>>9"
                    Full-Name       AT 25 SKIP.
            
            ASSIGN did-full-name-already-print = YES.
                    
    END. /* IF  did-full-name-already-print = NO THEN  */                    
                         
/* Change the greek character in the 1st character/position in the tkr_ref_uom value from:  µg/g Creat to Microgram/g Creat */

    ASSIGN  h-uom = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom
            len = LENGTH(h-uom).
    
    IF SUBSTRING(h-uom, 1, 5) = 'µg/g ' THEN 
            ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom = 'Microgram/g ' + SUBSTRING(h-uom, 6, len).
                     


/* Remove the extra spaces in the tkr_lab_ref value between the <    and  the  number: 
                                                  "<     35" change to: "< 35"
                                              or  "30-   225" change to:  "30 - 225".       */
/*                                            or  "0.0002-0.002" chg to"  "0.0002 - 0.002"  */  

    IF  XML_TT_PeopID_Basic_Data.TT-test-family = "BIOMED" THEN DO: 
    
        ASSIGN  h-ref = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref
                len = LENGTH(h-ref).
    
        ASSIGN  first-space  = 0
                last-space   = 0.  
                          
        DO  x-do = 1 TO len BY 1:
            IF SUBSTRING(h-ref, x-do, 1) = "" THEN DO:
               IF first-space = 0 THEN ASSIGN first-space = x-do    last-space = (x-do).
               ASSIGN last-space = (last-space + 1).
            END.  /* IF SUBSTRING(h-ref, x-do, 1) = "" */
        END. /* DO  x-do = 1 TO len BY 1: */
    
        IF first-space = 0 THEN ASSIGN first-space = INDEX(h-ref, "-", 1).
    
        IF last-space = 0 THEN ASSIGN last-space = first-space.
    
        IF first-space <> last-space THEN DO:    
            IF  SUBSTRING(h-ref,(first-space - 1 ), 1) = "-" THEN
                ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref =
                        SUBSTRING(h-ref, 1, (first-space - 2 ) ) + " - " + SUBSTRING(h-ref, last-space, len).
            ELSE
                ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref =
                        SUBSTRING(h-ref, 1, first-space) + SUBSTRING(h-ref, last-space, len).
        END. 
        ELSE 
            ASSIGN XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref = 
                        SUBSTRING(h-ref, 1, (first-space - 1 ) ) + " - " + SUBSTRING(h-ref, (first-space + 1 ),len).
    
    END. /* IF  XML_TT_PeopID_Basic_Data.TT-test-family = "BIOMED"  */
    
    IF  XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID   <> h-FILE_ID   AND 
        XML_TT_tkr_det_Data.TT-tkr_det-Seq-Nbr          >  3           THEN 
            ASSIGN  did-full-name-already-print = NO.
        
    IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID           <> h-TKR_ID       OR 
        XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq       <> h-TKR_ID_Seq   OR 
        XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID   <> h-FILE_ID      THEN 
        
            ASSIGN  first-results   = 0 
                    h-TKR_ID        = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID 
                    h-TKR_ID_Seq    = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq 
                    h-TKR_item      = XML_TT_tkr_det_Data.TT-tkr_det_TKR_item
                    h-FILE_ID       = XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID.


/* ******************************************* */ 
/* Store the TKR_det data and Brother records. */
/* ******************************************* */ 

    IF  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag <> "ERROR" THEN DO: 
                        
/* get the TK_Mstr.TK_test_type from the  XML_TT_TK_Mstr_Data record for each tests to
    determine if it is a brother record: FM, HE, UTEE or MPA. */
      
        FIND FIRST XML_TT_TK_Mstr_Data WHERE 
                           XML_TT_TK_Mstr_Data.TT-TK_Mstr_fs_atn_file_ID   = XML_TT_tkr_det_Data.TT-tkr_det_fs_atn_file_ID 
                       NO-LOCK NO-ERROR.
                               
        IF  AVAILABLE (XML_TT_TK_Mstr_Data)  THEN DO: 
                              
            IF  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type = "FM"  AND 
               
               (XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "DetoxificationAgent" OR 
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Dosage"              OR 
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Provocation"         OR 
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "DentalAmalgams"      OR 
                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "AmalgamQuantity")
                 
                    THEN DO:
/* process the Brother FM record. */                             
/*                     {BFM-U.i}.*/
                        ASSIGN 
                                v-tkid  = ""
                                v-tkseq = 1.
                                
                        IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID < "A" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "CPR" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "NN" THEN DO: 
                
                            ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + "-" + 
                                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type + "-" + "OAH"
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq. 
        
                        END.  /** of old style testkit **/ 
        
                        ELSE DO: 
                                
                                ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID 
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq.
                                
                        END.  /** of else do --- current style testkit **/
                                
                        FIND BFM_mstr WHERE BFM_mstr.BFM_ID         = v-tkid AND 
                                            BFM_mstr.BFM_test_seq   = v-tkseq AND 
                                            BFM_mstr.BFM_deleted    = ? 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                           
                        IF  NOT AVAILABLE (BFM_mstr) THEN DO:
                            
/* See if the BFM_mstr was deleted and if so then UN-DELETE it by setting the deleted flag to ?. */ 
                            
                            FIND BFM_mstr WHERE BFM_mstr.BFM_ID         = v-tkid AND 
                                                BFM_mstr.BFM_test_seq   = v-tkseq 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                                
                            IF AVAILABLE (BFM_mstr) THEN DO:      /** undelete the BFM_mstr **/
                            
                                ASSIGN   
                                    BFM_mstr.BFM_deleted            = ?
                                    BFM_mstr.BFM_modified_by        = USERID("HHI")
                                    BFM_mstr.BFM_modified_date      = TODAY 
                                    BFM_mstr.BFM_prog_name          = THIS-PROCEDURE:FILE-NAME.
                                    
                            END.  /** of if avail BFM_mstr **/
                            
                            ELSE DO:        /* go ahead and create the new BFM_mstr */
                                
                                CREATE BFM_mstr.
                                    
                                ASSIGN 
                                    BFM_mstr.BFM_ID              = v-tkid
                                    BFM_mstr.BFM_test_seq        = v-tkseq
                                    BFM_mstr.BFM_created_by      = USERID("HHI")
                                    BFM_mstr.BFM_create_date     = TODAY 
                                    BFM_mstr.BFM_prog_name       = THIS-PROCEDURE:FILE-NAME.   
                                
                            END.  /** of else do --- create butee_mstr **/
                                                                                    
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "DetoxificationAgent" THEN 
                                ASSIGN BFM_mstr.BFM_detox_agent             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result. 
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Dosage" THEN 
                                ASSIGN BFM_mstr.BFM_dosage                  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Provocation" THEN 
                                ASSIGN BFM_mstr.BFM_provocation             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "DentalAmalgams" THEN 
                                ASSIGN BFM_mstr.BFM_dent_amal               = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "AmalgamQuantity" THEN 
                                ASSIGN BFM_mstr.BFM_qty                     = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            
                            ASSIGN  BFM_mstr.BFM_modified_by     = USERID("HHI")
                                    BFM_mstr.BFM_modified_date   = TODAY 
                                    BFM_mstr.BFM_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Created BFM Master: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                   
                            ASSIGN  first-results           = (first-results + 1)
                                    BFM_mstr_created_kount  = (BFM_mstr_created_kount + 1). 
                                    
                        END.  /** IF NOT AVAILABLE (BFM_mstr) **/
                            
                        IF  AVAILABLE (BFM_mstr)            AND 
                            i-Admin-Update-OverRyde = YES   THEN DO:
                             
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "DetoxificationAgent" THEN 
                                ASSIGN BFM_mstr.BFM_detox_agent             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result. 
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Dosage" THEN 
                                ASSIGN BFM_mstr.BFM_dosage                  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Provocation" THEN 
                                ASSIGN BFM_mstr.BFM_provocation             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "DentalAmalgams" THEN 
                                ASSIGN BFM_mstr.BFM_dent_amal               = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "AmalgamQuantity" THEN 
                                ASSIGN BFM_mstr.BFM_qty                     = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            
                            ASSIGN  BFM_mstr.BFM_modified_by     = USERID("HHI")
                                    BFM_mstr.BFM_modified_date   = TODAY 
                                    BFM_mstr.BFM_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Updated BFM Master: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results           = (first-results + 1)
                                    BFM_mstr_updated_kount  = (BFM_mstr_updated_kount + 1). 
                                                              
                        END. /* IF  AVAILABLE (BFM_mstr) */ 
                        
                        NEXT Main_loop.
                                                                            
                END. /* IF   XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "FM"  */
            ELSE                     
                IF  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "HE" AND  
                    
                   (XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-CaMg ratio"    OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-CaP ratio"     OR  
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-NaK ratio"     OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCu ratio"    OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCd ratio"    OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Special note"    OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "sample weight"   OR  
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "sample type"     OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "hair color"      OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "treatment"       OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "shampoo")
                 
                    THEN DO:
/* process the Brother HE record. */                             
/*                     {BHE-U.i}.*/
                        ASSIGN 
                                v-tkid  = ""
                                v-tkseq = 1.
                                
                        IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID < "A" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "CPR" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "NN" THEN DO: 
                
                            ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + "-" + 
                                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type + "-" + "OAH"
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq. 
        
                        END.  /** of old style testkit **/ 
        
                        ELSE DO: 
                                
                                ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID 
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq.
                                
                        END.  /** of else do --- current style testkit **/
                                
                        FIND BHE_mstr WHERE BHE_mstr.BHE_ID         = v-tkid AND 
                                            BHE_mstr.BHE_test_seq   = v-tkseq AND 
                                            BHE_mstr.BHE_deleted    = ? 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                            
                        IF  NOT AVAILABLE (BHE_mstr) THEN DO:
                            
/* See if the BFM_mstr was deleted and if so then UN-DELETE it by setting the deleted flag to ?. */ 
                            
                            FIND BHE_mstr WHERE BHE_mstr.BHE_ID         = v-tkid AND 
                                                BHE_mstr.BHE_test_seq   = v-tkseq 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                                
                            IF AVAILABLE (BHE_mstr) THEN DO:      /** undelete the BHE_mstr **/
                            
                                ASSIGN   
                                    BHE_mstr.BHE_deleted            = ?
                                    BHE_mstr.BHE_modified_by        = USERID("HHI")
                                    BHE_mstr.BHE_modified_date      = TODAY 
                                    BHE_mstr.BHE_prog_name          = THIS-PROCEDURE:FILE-NAME.
                                    
                            END.  /** of if avail BHE_mstr **/
                            
                            ELSE DO:        /* go ahead and create a BHE_mstr */
                                
                                CREATE BHE_mstr.
                                    
                                ASSIGN 
                                    BHE_mstr.BHE_ID              = v-tkid
                                    BHE_mstr.BHE_test_seq        = v-tkseq
                                    BHE_mstr.BHE_created_by      = USERID("HHI")
                                    BHE_mstr.BHE_create_date     = TODAY 
                                    BHE_mstr.BHE_prog_name       = THIS-PROCEDURE:FILE-NAME.   
                                
                            END.  /** of else do --- create butee_mstr **/
                            
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-CaMg ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_ca_mg             = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result). 
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-CaP ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_ca_p              = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE    
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-NaK ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_na_k              = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCu ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_zn_cu             = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE     
/*   > 999   */             IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCd ratio" AND 
                                SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result, 1, 1) = ">" THEN 
                                    ASSIGN  BHE_mstr.BHE_ratio_zn_cd = DECIMAL(SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result, 2, 20)).                            
                            ELSE 
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCd ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_zn_cd             = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Special note" THEN 
                                ASSIGN BHE_mstr.BHE_total_toxics            = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "sample weight" THEN 
                                ASSIGN BHE_mstr.BHE_sample_weight           = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "sample type" THEN 
                                ASSIGN BHE_mstr.BHE_sample_type             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "hair color" THEN 
                                ASSIGN BHE_mstr.BHE_hair_color              = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "treatment" THEN 
                                ASSIGN BHE_mstr.BHE_treatment               = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "shampoo" THEN 
                                ASSIGN BHE_mstr.BHE_shampoo                 = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                                       
                            ASSIGN  BHE_mstr.BHE_modified_by     = USERID("HHI")
                                    BHE_mstr.BHE_modified_date   = TODAY 
                                    BHE_mstr.BHE_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Created BHE Master: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results           = (first-results + 1)
                                    BHE_mstr_created_kount  = (BHE_mstr_created_kount + 1). 
                                   
                        END.  /** IF NOT AVAILABLE (BHE_mstr) **/
                            
                        IF  AVAILABLE (BHE_mstr) AND 
                            i-Admin-Update-OverRyde = YES   THEN DO:
                             
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-CaMg ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_ca_mg             = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result). 
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-CaP ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_ca_p              = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE    
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-NaK ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_na_k              = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE     
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCu ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_zn_cu             = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE     
/*   > 999   */             IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCd ratio" AND 
                                SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result, 1, 1) = ">" THEN 
                                    ASSIGN  BHE_mstr.BHE_ratio_zn_cd = DECIMAL(SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result, 2, 20)).                            
                            ELSE 
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "H-ZnCd ratio" THEN 
                                ASSIGN BHE_mstr.BHE_ratio_zn_cd             = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Special note" THEN 
                                ASSIGN BHE_mstr.BHE_total_toxics            = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "sample weight" THEN 
                                ASSIGN BHE_mstr.BHE_sample_weight           = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "sample type" THEN 
                                ASSIGN BHE_mstr.BHE_sample_type             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "hair color" THEN 
                                ASSIGN BHE_mstr.BHE_hair_color              = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "treatment" THEN 
                                ASSIGN BHE_mstr.BHE_treatment               = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "shampoo" THEN 
                                ASSIGN BHE_mstr.BHE_shampoo                 = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                                       
                            ASSIGN  BHE_mstr.BHE_modified_by     = USERID("HHI")
                                    BHE_mstr.BHE_modified_date   = TODAY 
                                    BHE_mstr.BHE_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Updated BHE Master: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results           = (first-results + 1)
                                    BHE_mstr_updated_kount  = (BHE_mstr_updated_kount + 1). 
                                                              
                        END. /* IF  AVAILABLE (BHE_mstr) */ 
                             
                        NEXT Main_loop.
                                                            
                END. /* IF   XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "HE"  */ 
            ELSE        
                IF  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "UTEE" AND  
                    
                   (XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "U-CREAT"         OR
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "CC"              OR    
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "pH upon receip"  OR  
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "U-Vol 24hr"      OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Col Period"      OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "provocation"     OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "provoking agent")
                 
                    THEN DO:
/* process the Brother UTEE record. */                             
/*                     {BUTEE-U.i}.*/
                        ASSIGN 
                                v-tkid  = ""
                                v-tkseq = 1.
                                
                        IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID < "A" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "CPR" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "NN" THEN DO: 
                
                            ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + "-" + 
                                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type + "-" + "OAH"
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq. 
        
                        END.  /** of old style testkit **/ 
        
                        ELSE DO: 
                                
                                ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID 
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq.
                                
                        END.  /** of else do --- current style testkit **/
                                
                        FIND BUTEE_mstr WHERE BUTEE_mstr.BUTEE_ID         = v-tkid AND 
                                              BUTEE_mstr.BUTEE_test_seq   = v-tkseq AND 
                                              BUTEE_mstr.BUTEE_deleted    = ? 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                            
                        IF  NOT AVAILABLE (BUTEE_mstr) THEN DO:
 
 /* See if the BFM_mstr was deleted and if so then UN-DELETE it by setting the deleted flag to ?. */ 
                            
                            FIND BUTEE_mstr WHERE BUTEE_mstr.BUTEE_ID       = v-tkid AND 
                                                  BUTEE_mstr.BUTEE_test_seq = v-tkseq 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                                
                            IF AVAILABLE (BUTEE_mstr) THEN DO:      /** undelete the BUTEE_mstr **/
                            
                                ASSIGN   
                                    BUTEE_mstr.BUTEE_deleted            = ?
                                    BUTEE_mstr.BUTEE_modified_by        = USERID("HHI")
                                    BUTEE_mstr.BUTEE_modified_date      = TODAY 
                                    BUTEE_mstr.BUTEE_prog_name          = THIS-PROCEDURE:FILE-NAME.
                                    
                            END.  /** of if avail BUTEE_mstr **/
                            
                            ELSE DO:        /* go ahead and create a BUTEE_mstr */
                                
                                CREATE BUTEE_mstr.
                                    
                                ASSIGN 
                                    BUTEE_mstr.BUTEE_ID              = v-tkid
                                    BUTEE_mstr.BUTEE_test_seq        = v-tkseq
                                    BUTEE_mstr.BUTEE_created_by      = USERID("HHI")
                                    BUTEE_mstr.BUTEE_create_date     = TODAY 
                                    BUTEE_mstr.BUTEE_prog_name       = THIS-PROCEDURE:FILE-NAME.   
                                
                            END.  /** of else do --- create butee_mstr **/ 
                            
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "U-CREAT" OR 
                                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "CC"      THEN 
                                ASSIGN BUTEE_mstr.BUTEE_creatinine          = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "pH upon receip" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_rcpt_pH             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_item, 1, 5) = "U-Vol" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_volume              = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Col Period" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_coll_per            = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Provocation" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_provocation         = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "provoking agent" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_prov_agent          = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                                                                        
                            ASSIGN  BUTEE_mstr.BUTEE_modified_by     = USERID("HHI")
                                    BUTEE_mstr.BUTEE_modified_date   = TODAY 
                                    BUTEE_mstr.BUTEE_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Created BUTEE Master: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results              = (first-results + 1)
                                    BUTEE_mstr_created_kount   = (BUTEE_mstr_created_kount + 1). 
                                
                        END.  /** IF NOT AVAILABLE (BUTEE_mstr) **/
                            
                        IF  AVAILABLE (BUTEE_mstr) AND 
                            i-Admin-Update-OverRyde = YES   THEN DO:
                             
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "U-CREAT" OR 
                                XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "CC"      THEN 
                                ASSIGN BUTEE_mstr.BUTEE_creatinine          = DECIMAL(XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result).
                            ELSE      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "pH upon receip" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_rcpt_pH             = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_item, 1, 5) = "U-Vol" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_volume              = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                       
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Col Period" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_coll_per            = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Provocation" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_provocation         = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                            ELSE                                      
                            IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "provoking agent" THEN 
                                ASSIGN BUTEE_mstr.BUTEE_prov_agent          = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result.
                                                                        
                            ASSIGN  BUTEE_mstr.BUTEE_modified_by     = USERID("HHI")
                                    BUTEE_mstr.BUTEE_modified_date   = TODAY 
                                    BUTEE_mstr.BUTEE_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Updated BUTEE Master: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results              = (first-results + 1)
                                    BUTEE_mstr_updated_kount   = (BUTEE_mstr_updated_kount + 1). 
                                                              
                        END. /* IF  AVAILABLE (BUTEE_mstr) */ 
                        
                        NEXT Main_loop.
                                                            
                END. /* IF   XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "UTEE"  */
            ELSE     
                IF  XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "MPA"  THEN DO:
                    
/* process the Brother MPA record. */                             
/*                     {BMPA-U.i}.*/

                        ASSIGN 
                                v-tkid  = ""
                                v-tkseq = 1.
                                
                        IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID < "A" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "CPR" OR 
                            XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID BEGINS "NN" THEN DO: 
                
                            ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + "-" + 
                                              XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type + "-" + "OAH"
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq. 
        
                        END.  /** of old style testkit **/ 
        
                        ELSE DO: 
                                
                                ASSIGN 
                                    v-tkid  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID 
                                    v-tkseq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq.
                                
                        END.  /** of else do --- current style testkit **/
                               
                        FIND BMPA_det WHERE BMPA_det.BMPA_ID            = v-tkid    AND 
                                            BMPA_det.BMPA_test_seq      = v-tkseq   AND
                                            BMPA_det.BMPA_item          = XML_TT_tkr_det_Data.TT-tkr_det_TKR_item   AND  
                                            BMPA_det.BMPA_deleted       = ? 
                                    EXCLUSIVE-LOCK NO-ERROR. 
                            
                        IF  NOT AVAILABLE (BMPA_det) THEN DO:

/* See if the BFM_mstr was deleted and if so then UN-DELETE it by setting the deleted flag to ?. */ 
                            
                            FIND BMPA_det WHERE BMPA_det.BMPA_ID        = v-tkid    AND 
                                                BMPA_det.BMPA_test_seq  = v-tkseq   AND 
                                                BMPA_det.BMPA_item      = XML_TT_tkr_det_Data.TT-tkr_det_TKR_item  
                                    EXCLUSIVE-LOCK NO-ERROR. 
                                
                            IF  AVAILABLE (BMPA_det) THEN DO:      /** undelete the BMPA_det **/
                            
                                ASSIGN   
                                    BMPA_det.BMPA_deleted            = ?
                                    BMPA_det.BMPA_modified_by        = USERID("HHI")
                                    BMPA_det.BMPA_modified_date      = TODAY 
                                    BMPA_det.BMPA_prog_name          = THIS-PROCEDURE:FILE-NAME.
                                    
                            END.  /** of if avail BMPA_det **/
                            
                            ELSE DO:        /* go ahead and create a BMPA_det */
                                
                                CREATE BMPA_det.
                                    
                                ASSIGN 
                                    BMPA_det.BMPA_ID              = v-tkid
                                    BMPA_det.BMPA_test_seq        = v-tkseq
                                    BMPA_det.BMPA_item            = XML_TT_tkr_det_Data.TT-tkr_det_TKR_item 
                                    BMPA_det.BMPA_created_by      = USERID("HHI")
                                    BMPA_det.BMPA_create_date     = TODAY 
                                    BMPA_det.BMPA_prog_name       = THIS-PROCEDURE:FILE-NAME.   
                                
                            END.  /** of else do --- create butee_mstr **/
                            
                            ASSIGN  BMPA_det.BMPA_dispcall        = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result 
                                    BMPA_det.BMPA_modified_by     = USERID("HHI")
                                    BMPA_det.BMPA_modified_date   = TODAY 
                                    BMPA_det.BMPA_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Created BMPA detail: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results            = (first-results + 1)
                                    BMPA_det_created_kount   = (BMPA_det_created_kount + 1). 
                                                              
                        END.  /** IF NOT AVAILABLE (BMPA_mstr) **/
                            
                        IF  AVAILABLE (BMPA_det) AND 
                            i-Admin-Update-OverRyde = YES   THEN DO:

                            ASSIGN  BMPA_det.BMPA_dispcall        = XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result 
                                    BMPA_det.BMPA_modified_by     = USERID("HHI")
                                    BMPA_det.BMPA_modified_date   = TODAY 
                                    BMPA_det.BMPA_prog_name       = THIS-PROCEDURE:FILE-NAME. 
                
                            ASSIGN   Info-Msg[1]  = "Updated BMPA detail: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                            PUT STREAM outwardTKR
                                Info-Msg[1]     AT 41. 
                
                            ASSIGN  first-results            = (first-results + 1)
                                    BMPA_det_updated_kount   = (BMPA_det_updated_kount + 1). 
                                                              
                        END. /* IF  AVAILABLE (BMPA_det) */  
                                                       
                        NEXT Main_loop.
                                                            
                END. /* IF   XML_TT_TK_Mstr_Data.TT-TK_Mstr_TK_test_type    = "MPA"  */ 
                            
/* 1st check to see if we have an short marker_item and if so then */                    
/* validate the   tkr_item   field against the marker_list table for valid test/marker_item values/names. */
/* Change the 2-char data (position 3 & 4) in the tkr_item FIELD AND make it the LONG NAME > e.g. U-Al/Creat:  Al = Aluminun, etc */     

            ASSIGN  len                           = LENGTH(XML_TT_tkr_det_Data.TT-tkr_det_TKR_item)
                    TKR-item-aftDash-position     = (INDEX(XML_TT_tkr_det_Data.TT-tkr_det_TKR_item, "-", 1) + 1 )
                    TKR-item-beforeSlash-position = (INDEX(XML_TT_tkr_det_Data.TT-tkr_det_TKR_item, "/", 1) ).
        
            IF  TKR-item-beforeSlash-position = 0 THEN
                TKR-item-beforeSlash-position = (len + 1).
                
        /* 1st find for marker_item. */
        
            FIND HHI.marker_list    WHERE 
                        marker_list.marker_item  = 
                                SUBSTRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_item, TKR-item-aftDash-position, 
                                         (TKR-item-beforeSlash-position - TKR-item-aftDash-position) )
                        NO-LOCK  NO-ERROR.
                
            IF NOT AVAILABLE (HHI.marker_list) THEN DO:
                
        /* 2nd look for marker_item. */ 
               
                IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "Creatinine-CREAT"    OR 
                    XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "U-CREAT"             THEN
                        ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item = "cc".
                            
                IF  (XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "hg"    OR
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "F-Hg1" OR 
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_item     = "F-Hg2")   THEN DO:   
                        IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref  = "< 0.05"   THEN  
                            ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item = "hg-w/o".
                        ELSE 
                        IF  XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref  = "< 0.5"   THEN       
                            ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item = "hg-with".
                END. /* IF's */
                
                FIND  HHI.marker_list WHERE
                                  marker_list.marker_item  = XML_TT_tkr_det_Data.TT-tkr_det_TKR_item  
                            NO-LOCK  NO-ERROR. 
                            
            END. /* IF NOT AVAILABLE 2nd (HHI.marker_list)  */
                                       
            IF  NOT AVAILABLE (HHI.marker_list) THEN DO:  
               
                ASSIGN  Element_Symbol_Error_kount = (Element_Symbol_Error_kount + 1). 
                                      
                IF  did-full-name-already-print = NO THEN DO: 
                    ASSIGN  data-info  = "PERSON:"
                            h-desc     = ""
                            Full-Name  = v-people-firstname + " " +
                                         v-people-midname   + " " + 
                                         v-people-lastname +
                                         ",  DOB: " + string(v-people-dob)
                            Info-Msg[1] = "TKR_ID: " + TT-TKR_det_TKR_ID + " / " + STRING(TT-tkr_det_TKR_ID_Seq).
                                         
                    PUT STREAM outwardTKR
                            data-info       AT 1
                            i-people-id     AT 11 FORMAT ">,>>>,>>9"
                            Full-Name       AT 25 SKIP.
                    
                    PUT STREAM outwardTKR
                            Info-Msg[1]     AT 25 SKIP.
                                
                    ASSIGN did-full-name-already-print = YES.
                    
                END. /* IF  did-full-name-already-print = NO THEN  */  
                         
/*                ASSIGN  data-info   = "XML I/P:"                                                                */
/*                        Info-Msg[2] = "TKR_item (position " + STRING(TKR-item-aftDash-position) + " - " +       */
/*                                       STRING(TKR-item-beforeSlash-position - 1) + ") : " + TT-tkr_det_TKR_item.*/
        
                PUT STREAM outwardTKR
                        " "     AT 32 SKIP.

                ASSIGN   Info-Msg[1]  = "WARNING: Element-Symbol '" + 
                                        XML_TT_tkr_det_Data.TT-tkr_det_TKR_item + 
                                        "' not found in the HHI.marker_list.".
                                                        
                PUT STREAM outwardTKR
                        Info-Msg[1]     AT 32 SKIP(1).  
                 
                NEXT Main_loop.
                                                    
            END.  /* IF NOT AVAILABLE (HHI.marker_list) */
        
            ELSE DO:
        
                ASSIGN  XML_TT_tkr_det_Data.TT-tkr_det_TKR_item = HHI.marker_list.marker_desc.
        
            END.  /* ELSE DO: */
/* End of input element-name/marker_item validation. */    
                         
        END. /* IF AVAILABLE (XML_TT_TK_Mstr_Data) */


/* See if the input TKR_det record exist or not. */
              
        FIND TKR_det WHERE  TKR_det.TKR_ID       = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID        AND 
                            TKR_det.TKR_test_seq = XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq    AND 
                            TKR_det.TKR_item     = XML_TT_tkr_det_Data.TT-tkr_det_TKR_item      AND 
                            TKR_det.TKR_deleted  = ?
            EXCLUSIVE-LOCK NO-ERROR.
       
        IF  NOT AVAILABLE (TKR_det) THEN DO: 
        
            RUN VALUE(SEARCH("SUBtkrdet-ucU.r"))        
                    (XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID, 
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq,
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_item,
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result,
                     0,
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref,  
                     0,
                     0,
                     XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom,
                     "",
                     "",
                     "",
                     OUTPUT o-ucTKRdet-id,
                     OUTPUT o-ucTKRdet-create,
                     OUTPUT o-ucTKRdet-update,
                     OUTPUT o-ucTKRdet-avail, 
                     OUTPUT o-ucTKRdet-successful).
                   
             IF  o-ucTKRdet-update           = YES AND 
                 o-ucTKRdet-successful       = YES THEN  DO:  
                    
                    ASSIGN no-update = YES.
        
                    IF  did-full-name-already-print = NO THEN DO: 
        
                        ASSIGN  data-info  = "PERSON:"
                                h-desc     = ""
                                Full-Name  = v-people-firstname + " " +
                                             v-people-midname   + " " + 
                                             v-people-lastname +
                                             ",  DOB: " + string(v-people-dob).
        
                        PUT STREAM outwardTKR
                                " "             AT 1 SKIP.
                        PUT STREAM outwardTKR
                                data-info       AT 1
                                i-people-id     AT 11 FORMAT ">,>>>,>>9"
                                Full-Name       AT 25 SKIP.
                                
                        ASSIGN did-full-name-already-print = YES.
                            
                    END. /* IF  did-full-name-already-print = NO THEN  */
                            
                    IF first-results = 0 THEN DO: 
                        
                        ASSIGN tkrecordsprocessed   = (tkrecordsprocessed + 1).
                        ASSIGN   Info-Msg[1]= "TKR_ID: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + " / " + 
                                                  STRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq).              
                        PUT STREAM outwardTKR
                            Info-Msg[1]     AT 25.                  
                        ASSIGN first-results = 1.  
                                                       
                    END. /* IF first-results = 0 THEN */
                    
                    IF first-results = 1 THEN DO:
                        
                        ASSIGN   Info-Msg[1]  = "ACTION: " +  "Created TKR_item: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.
                        PUT STREAM outwardTKR
                            Info-Msg[1]     AT 33.
                            
                    END. /* IF first-results = 1 THEN */
                            
                    IF first-results > 1 THEN DO: 
                        
                        ASSIGN   Info-Msg[2]  = "Created TKR_item: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                        PUT STREAM outwardTKR
                            Info-Msg[2]     AT 41.  
                                      
                    END. /* IF first-results > 1 THEN */
                    
                    ASSIGN  first-results           = (first-results + 1)
                            TKR_det_created_kount   = (TKR_det_created_kount + 1). 
                              
             END. /* IF  o-ucTKRdet-update = YES */
                    
             ELSE DO:   
    
                ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag = "ERROR".
                
                IF ITdisplay = YES   THEN
                    PUT STREAM outwardTKR "Prog: HL7-Load-TKR-Det: :Error from SUBtkrdet-ucU.r." SKIP
                      "TT-tkr_det_TKR_ID = " TT-tkr_det_TKR_ID "   "   "TT-tkr_det_TKR_ID_Seq = " TT-tkr_det_TKR_ID_Seq SKIP          
                      "TT-tkr_det_TKR_item = " TT-tkr_det_TKR_item  SKIP(2).
        
        	 END. /* else do: */

        END. /* IF  NOT AVAILABLE (TKR_det) */
        
        ELSE
         
        IF  AVAILABLE (TKR_det) AND 
            i-Admin-Update-OverRyde = YES   THEN DO: 
   
                RUN VALUE(SEARCH("SUBtkrdet-ucU.r"))        
                            (XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID, 
                             XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq,
                             XML_TT_tkr_det_Data.TT-tkr_det_TKR_item,
                             XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_result,
                             0,
                             XML_TT_tkr_det_Data.TT-tkr_det_TKR_lab_ref,  
                             0,
                             0,
                             XML_TT_tkr_det_Data.TT-tkr_det_TKR_ref_uom,
                             "",
                             "",
                             "",
                             OUTPUT o-ucTKRdet-id,
                             OUTPUT o-ucTKRdet-create,
                             OUTPUT o-ucTKRdet-update,
                             OUTPUT o-ucTKRdet-avail, 
                             OUTPUT o-ucTKRdet-successful).
                   
                     IF  o-ucTKRdet-update           = YES AND 
                         o-ucTKRdet-successful       = YES THEN  DO:  
                            
                            ASSIGN no-update = YES.
                
                            IF  did-full-name-already-print = NO THEN DO: 
                
                                ASSIGN  data-info  = "PERSON:"
                                        h-desc     = ""
                                        Full-Name  = v-people-firstname + " " +
                                                     v-people-midname   + " " + 
                                                     v-people-lastname +
                                                     ",  DOB: " + string(v-people-dob).
                
                                PUT STREAM outwardTKR
                                        " "             AT 1 SKIP.
                                PUT STREAM outwardTKR
                                        data-info       AT 1
                                        i-people-id     AT 11 FORMAT ">,>>>,>>9"
                                        Full-Name       AT 25 SKIP.
                                        
                                ASSIGN did-full-name-already-print = YES.
                                    
                            END. /* IF  did-full-name-already-print = NO THEN  */
                                    
                            IF first-results = 0 THEN DO: 
                                
                                ASSIGN tkrecordsprocessed   = (tkrecordsprocessed + 1).
                                ASSIGN   Info-Msg[1]= "TKR_ID: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + " / " + 
                                                          STRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq).              
                                PUT STREAM outwardTKR
                                    Info-Msg[1]     AT 25.                  
                                ASSIGN first-results = 1.  
                                                               
                            END. /* IF first-results = 0 THEN */
                            
                            IF first-results = 1 THEN DO:
                                
                                ASSIGN   Info-Msg[1]  = "ACTION: " +  "Updated TKR_item: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.
                                PUT STREAM outwardTKR
                                    Info-Msg[1]     AT 33.
                                    
                            END. /* IF first-results = 1 THEN */
                                    
                            IF first-results > 1 THEN DO: 
                                
                                ASSIGN   Info-Msg[2]  = "Updated TKR_item: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                                PUT STREAM outwardTKR
                                    Info-Msg[2]     AT 41.  
                                              
                            END. /* IF first-results > 1 THEN */
                            
                            ASSIGN  first-results           = (first-results + 1)
                                    TKR_det_updated_kount   = (TKR_det_updated_kount + 1). 
                              
                     END. /* IF  o-ucTKRdet-update = YES */
                            
                     ELSE DO:   
            
                        ASSIGN  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag = "ERROR".
                        
                        IF ITdisplay = YES   THEN
                            PUT STREAM outwardTKR "Prog: SUB-TKR_det-Load: :Error from SUBtkrdet-ucU.r." SKIP
                              "TT-tkr_det_TKR_ID = " TT-tkr_det_TKR_ID "   "   "TT-tkr_det_TKR_ID_Seq = " TT-tkr_det_TKR_ID_Seq SKIP          
                              "TT-tkr_det_TKR_item = " TT-tkr_det_TKR_item  SKIP(2).
                
                     END. /* else do: */
                       
        END. /* IF  AVAILABLE (TKR_det) THEN DO:  */

        ELSE 
                
        IF  AVAILABLE (TKR_det) AND 
            i-Admin-Update-OverRyde = NO   THEN DO: 

                ASSIGN no-update = NO.
                            
                IF  did-full-name-already-print = NO THEN DO: 
                
                    ASSIGN  data-info  = "PERSON:"
                            h-desc     = ""
                            Full-Name  = v-people-firstname + " " +
                                         v-people-midname   + " " + 
                                         v-people-lastname +
                                         ",  DOB: " + string(v-people-dob).
    
                    PUT STREAM outwardTKR
                            " "             AT 1 SKIP.
                    PUT STREAM outwardTKR
                            data-info       AT 1
                            i-people-id     AT 11 FORMAT ">,>>>,>>9"
                            Full-Name       AT 25 SKIP.
                            
                    ASSIGN did-full-name-already-print = YES.
                        
                END. /* IF  did-full-name-already-print = NO THEN  */
                                    
                IF first-results = 0 THEN DO: 
                    
                    ASSIGN tkrecordsprocessed   = (tkrecordsprocessed + 1).
                    ASSIGN   Info-Msg[1]= "TKR_ID: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID + " / " + 
                                              STRING(XML_TT_tkr_det_Data.TT-tkr_det_TKR_ID_Seq).              
                    PUT STREAM outwardTKR
                        Info-Msg[1]     AT 25.                  
                    ASSIGN first-results = 1.  
                                                   
                END. /* IF first-results = 0 THEN */
                            
                IF first-results = 1 THEN DO:
                    
                    ASSIGN   Info-Msg[1]  = "ACTION: " +  "NOT Updated TKR_item: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.
                    PUT STREAM outwardTKR
                        Info-Msg[1]     AT 33.
                        
                END. /* IF first-results = 1 THEN */
                        
                IF first-results > 1 THEN DO: 
                    
                    ASSIGN   Info-Msg[2]  = "NOT Updated TKR_item: " + XML_TT_tkr_det_Data.TT-tkr_det_TKR_item.            
                    PUT STREAM outwardTKR
                        Info-Msg[2]     AT 41.  
                                  
                END. /* IF first-results > 1 THEN */
                
                ASSIGN  first-results               = (first-results + 1)
                        TKR_det_NOT_updated_kount   = (TKR_det_NOT_updated_kount + 1). 
                                               
        END. /* IF  AVAILABLE (TKR_det) AND i-Admin-Update-OverRyde = NO THEN DO:  */
                        
    END. /*  IF  XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag <> "ERROR" */
       
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
                            ",  DOB: " + STRING(people_mstr.people_DOB).

            PUT STREAM outwardTKR
                data-info       AT 1
                i-people-id     AT 11 FORMAT ">,>>>,>>9"
                Full-Name       AT 25 SKIP.

            ASSIGN  did-full-name-already-print = YES.
             
            ASSIGN   Info-Msg[1] = "ACTION: " +  "NO updates or creates made.".
            
            PUT STREAM outwardTKR
                Info-Msg[1]     AT 25 SKIP(1).
                
        END. /* IF did-full-name-already-print = NO  */    
    
    END.  /* IF no-update = NO */
    
    ASSIGN  no-update = NO.
                                       
END. /* Main_loop: FOR EACH XML_TT_tkr_det_Data */

IF ITdisplay = YES THEN DO: 
    PUT STREAM TKRdumpR "Leaving PROG: XML-SUB-TKR-det-Load." SKIP. 
    OUTPUT STREAM TKRdumpR CLOSE. 
END. /* IF ITdisplay = YES  */

IF  tkrecordsprocessed = 0 THEN 
    PUT STREAM outwardTKR SKIP(1)
        "No Test Kit Detail data was selected during this scheduled run." AT 11 SKIP (1). 
         
PUT STREAM outwardTKR SKIP(1)
    "Information:" SKIP 
    tkrecordsprocessed FORMAT ">,>>9"               "  :Total Input Test Kits." SKIP
    tkDrecordsprocessed FORMAT ">,>>9"              "  :Total Input Test Details." SKIP(1)
    TKR_det_created_kount FORMAT ">,>>9"            "  :Test Details Created." SKIP
    TKR_det_updated_kount FORMAT ">,>>9"            "  :Test Details Updated." SKIP(1)
    
    BFM_mstr_created_kount FORMAT ">,>>9"           "  :Test BFM Details Created." SKIP
    BFM_mstr_updated_kount FORMAT ">,>>9"           "  :Test BFM Details Updated." SKIP(1)
    
    BHE_mstr_created_kount FORMAT ">,>>9"           "  :Test BHE Details Created." SKIP
    BHE_mstr_updated_kount FORMAT ">,>>9"           "  :Test BHE Details Updated." SKIP(1)
    
    BMPA_det_created_kount FORMAT ">,>>9"           "  :Test BMPA Details Created." SKIP
    BMPA_det_updated_kount FORMAT ">,>>9"           "  :Test BMPA Details Updated." SKIP(1)
    
    BUTEE_mstr_created_kount FORMAT ">,>>9"         "  :Test BUTEE Details Created." SKIP
    BUTEE_mstr_updated_kount FORMAT ">,>>9"         "  :Test BUTEE Details Updated." SKIP(1)
    
    "Errors:" SKIP 
    TKR_det_NOT_updated_kount FORMAT ">,>>9"        "  :TKR_item(s) found but NOT Updated." SKIP
    Major_Error_kount FORMAT ">,>>9"                "  :TKR-ID or TKR_item is blank or TKR_ID_Seq is zero (0)." SKIP
    Element_Symbol_Error_kount FORMAT ">,>>9"       "  :TKR_item Element-Symbol not found in the HHI.marker_list." SKIP(2).
    
PUT STREAM outwardTKR
    "*******************************************" SKIP.
PUT STREAM outwardTKR 
    "**** End report.  " TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardTKR
    "*******************************************" SKIP(1).
PAGE STREAM outwardTKR.
              
OUTPUT STREAM outwardTKR CLOSE.    
         
/** end of program **/

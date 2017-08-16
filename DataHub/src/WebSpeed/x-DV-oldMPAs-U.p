
/*------------------------------------------------------------------------
    File        : DV-oldMPAs-U.p
    Purpose     : 

    Syntax      :

    Description : Find all the old MPAs and make sure that their records are properly created in the database.

    Author(s)   : Doug Luttrell
    Created     : Tue Sep 29 21:20:39 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE x AS INTEGER LABEL "Total" NO-UNDO.
DEFINE VARIABLE y AS INTEGER LABEL "Less Matched" NO-UNDO.
DEFINE VARIABLE z AS INTEGER LABEL "Not Matched" NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.

/*** vars for the fullname search ***/ 
DEFINE  VARIABLE     io-prefix        LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE  VARIABLE     io-firstname     LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE  VARIABLE     io-middlename    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE  VARIABLE     io-lastname      LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE  VARIABLE     io-suffix        LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE  VARIABLE     o-title_desc    LIKE people_mstr.people_title       NO-UNDO.
DEFINE  VARIABLE     o-prefname      LIKE people_mstr.people_prefname    NO-UNDO.
DEFINE  VARIABLE     o-gender        LIKE people_mstr.people_gender      NO-UNDO.
DEFINE  VARIABLE     o-unstring-error AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE  VARIABLE     o-field-in-error AS CHARACTER FORMAT "X(30)"        NO-UNDO.

DEFINE VARIABLE tempDOB AS DATE NO-UNDO.

DEFINE VARIABLE  o-fpe-peopleID  LIKE people_mstr.people_id          NO-UNDO.
DEFINE VARIABLE  o-fpe-addr_ID   LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE VARIABLE  o-fpe-error     AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE  o-fpat-ran      AS LOGICAL INITIAL NO               NO-UNDO.

/*** vars for the broken up name search ***/
DEFINE  VARIABLE     io-prefix2        LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE  VARIABLE     io-firstname2     LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE  VARIABLE     io-middlename2    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE  VARIABLE     io-lastname2      LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE  VARIABLE     io-suffix2        LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE  VARIABLE     o-title_desc2    LIKE people_mstr.people_title       NO-UNDO.
DEFINE  VARIABLE     o-prefname2      LIKE people_mstr.people_prefname    NO-UNDO.
DEFINE  VARIABLE     o-gender2        LIKE people_mstr.people_gender      NO-UNDO.
DEFINE  VARIABLE     o-unstring-error2 AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE  VARIABLE     o-field-in-error2 AS CHARACTER FORMAT "X(30)"        NO-UNDO.

DEFINE VARIABLE tempDOB2 AS DATE NO-UNDO.

DEFINE VARIABLE  o-fpe-peopleID2  LIKE people_mstr.people_id          NO-UNDO.
DEFINE VARIABLE  o-fpe-addr_ID2   LIKE people_mstr.people_addr_id     NO-UNDO.
DEFINE VARIABLE  o-fpe-error2     AS LOGICAL INITIAL NO               NO-UNDO.
DEFINE VARIABLE  o-fpat-ran2      AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE STREAM outward.
OUTPUT STREAM outward TO "C:\progress\wrk\exports\OldMPAs_Semi_Matching.txt".
EXPORT STREAM outward DELIMITER ";"
    "exportSample_HoldID" "sample_ID" "gps_id" "batch_ID"
    "VF1_ID" "Firstname" "Middlename" "Lastname" 
    "AcctNbr_TKID_SampleID" 
    "Customer_Type" 
    "Batch_ID" "EY_nbr"
    "DOB"
    "MPA_Test_Type".
    
DEFINE STREAM out2.
OUTPUT STREAM out2 TO "C:\progress\wrk\exports\OldMPAs_Non_Matching.txt".
EXPORT STREAM out2 DELIMITER ";"
    "sample_id" 
    "gps_id" 
    "batch_id".    
    
DEFINE STREAM goodstuff.
OUTPUT STREAM goodstuff TO "C:\progress\wrk\exports\OldMPAs_Matched.txt".
EXPORT STREAM goodstuff DELIMITER ";"
    "VF1_ID" "Fullname" "Firstname" "Middlename" "Lastname" "DOB"
    "FN-PatientID" "FN-prefix" "FN-firstname" "FN-middlename" "FN-lastname" "FN-suffix" "FN-DOB"
    "P-PatientID" "P-prefix" "P-firstname" "P-middlename" "P-lastname" "P-suffix" "P-DOB".   
    
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
PAUSE 0 BEFORE-HIDE.

FOR EACH exportSampleMMDDYYYY NO-LOCK:  
    
    x = x + 1.
    
    FIND FIRST VF1_det WHERE VF1_det.VF1_EY_nbr = exportSampleMMDDYYYY.sample_id AND 
                        VF1_det.VF1_TKID_SampleID = exportSampleMMDDYYYY.gps_id AND 
                        VF1_det.VF1_batch_ID = exportSampleMMDDYYYY.batch_id NO-LOCK NO-ERROR.
                        
    IF NOT AVAILABLE (VF1_det) THEN DO:  
        
        y = y + 1.
                                
         /*
        DISPLAY exportSampleMMDDYYYY.sample_id exportSampleMMDDYYYY.gps_id exportSampleMMDDYYYY.batch_id.
        */
        
        i = 0.
        
        FOR EACH VF1_det WHERE VF1_det.VF1_EY_nbr = exportSampleMMDDYYYY.sample_id NO-LOCK:
            
            i = i + 1.
            
            /*
            DISPLAY VF1_det.VF1_lastname FORMAT "x(20)" 
/*                VF1_det.VF1_firstname FORMAT "x(20)"*/
                SKIP 
                VF1_det.VF1_TKID_SampleID 
                exportSampleMMDDYYYY.gps_id SKIP 
                VF1_det.VF1_batch_ID 
                exportSampleMMDDYYYY.batch_id SKIP(1)
                    WITH FRAME vf1dets WIDTH 132 DOWN 
                        TITLE "From VF1_det by VF1_EY_Nbr".
            DOWN WITH FRAME vf1dets.
            */
            
            EXPORT STREAM outward DELIMITER ";"
                eS_HoldID sample_ID gps_id batch_ID
                VF1_det.VF1_ID VF1_det.vf1_firstname VF1_det.vf1_middlename VF1_det.vf1_lastname 
                VF1_det.vf1_TKID_SampleID VF1_det.vf1_custtype 
                VF1_det.vf1_batch_ID VF1_det.vf1_EY_nbr
                VF1_det.vf1_good_dob
                VF1_det.vf1_mpa_test_type.
            
        END.  /** of 4ea. vf1_det **/
        
        IF i > 0 THEN DO: 
            z = z + 1.

        END.                
        
        ELSE DO:
            
/*            i = 0.                                                                                                 */
/*                                                                                                                   */
/*            FOR EACH VF1_det WHERE exportSampleMMDDYYYY.sample_id MATCHES ("*" + VF1_det.VF1_EY_nbr + "*") NO-LOCK:*/
/*                                                                                                                   */
/*                i = i + 1.                                                                                         */
/*                                                                                                                   */
/*                /*                                                                                                 */
/*                DISPLAY VF1_det.VF1_lastname FORMAT "x(20)"                                                        */
/*    /*                VF1_det.VF1_firstname FORMAT "x(20)"*/                                                       */
/*                    SKIP                                                                                           */
/*                    VF1_det.VF1_TKID_SampleID                                                                      */
/*                    exportSampleMMDDYYYY.gps_id SKIP                                                               */
/*                    VF1_det.VF1_batch_ID                                                                           */
/*                    exportSampleMMDDYYYY.batch_id SKIP(1)                                                          */
/*                        WITH FRAME vf1dets WIDTH 132 DOWN                                                          */
/*                            TITLE "From VF1_det by VF1_EY_Nbr".                                                    */
/*                DOWN WITH FRAME vf1dets.                                                                           */
/*                */                                                                                                 */
/*                                                                                                                   */
/*                EXPORT STREAM outward DELIMITER ";"                                                                */
/*                    eS_HoldID sample_ID gps_id batch_ID                                                            */
/*                    VF1_det.VF1_ID VF1_det.vf1_firstname VF1_det.vf1_middlename VF1_det.vf1_lastname               */
/*                    VF1_det.vf1_TKID_SampleID VF1_det.vf1_custtype                                                 */
/*                    VF1_det.vf1_batch_ID VF1_det.vf1_EY_nbr                                                        */
/*                    VF1_det.vf1_good_dob                                                                           */
/*                    VF1_det.vf1_mpa_test_type.                                                                     */
/*                                                                                                                   */
/*            END.  /** of 4ea. vf1_det **/                                                                          */
/*                                                                                                                   */
/*            IF i > 0 THEN DO:                                                                                      */
/*                z = z + 1.                                                                                         */
/*                                                                                                                   */
/*            END.                                                                                                   */
/*                                                                                                                   */
/*            ELSE DO:                                                                                               */
            
                EXPORT STREAM out2 DELIMITER ";"
                    exportSampleMMDDYYYY.sample_id  
                    exportSampleMMDDYYYY.gps_id  
                    exportSampleMMDDYYYY.batch_id.
            
/*            END.  /** else do -- no vf1_dets found again **/*/
                
        END.  /** of else do -- i=0 **/
        
    END.  /** of if not can-find **/    

    ELSE DO:
        
        RUN VALUE(SEARCH("SUB-UnString-Name.r"))
            (VF1_det.VF1_fullname,
             NO,
             OUTPUT io-prefix,
             OUTPUT io-firstname,
             OUTPUT io-middlename,
             OUTPUT io-lastname,
             OUTPUT io-suffix,
             OUTPUT o-title_desc,
             OUTPUT o-prefname,
             OUTPUT o-gender,
             OUTPUT o-unstring-error,
             OUTPUT o-field-in-error
            ).
            
        IF o-unstring-error = NO THEN DO: 
            
            RUN value(SEARCH("SUBpeop-findR.p"))
                (io-prefix,
                 io-firstname,
                 io-middlename, 
                 io-lastname, 
                 io-suffix, 
                 OUTPUT o-fpe-peopleID,
                 OUTPUT o-fpe-addr_ID,
                 OUTPUT o-fpe-error,
                 OUTPUT o-fpat-ran 
                ).
                
            IF o-fpe-error = NO THEN DO:  
                FIND people_mstr WHERE people_mstr.people_id = o-fpe-peopleID
                    NO-LOCK NO-ERROR.
                tempDOB = people_mstr.people_DOB.
            END.    /** of if o-fpe-error = no **/
                
        END.  /** of if o-unstring-error = no **/                 
        
        
        RUN VALUE(SEARCH("SUB-UnString-Name.r"))
            ((VF1_det.VF1_firstname + " " + VF1_det.VF1_middlename + " " + VF1_det.VF1_lastname),
             NO,
             OUTPUT io-prefix2,
             OUTPUT io-firstname2,
             OUTPUT io-middlename2,
             OUTPUT io-lastname2,
             OUTPUT io-suffix2,
             OUTPUT o-title_desc2,
             OUTPUT o-prefname2,
             OUTPUT o-gender2,
             OUTPUT o-unstring-error2,
             OUTPUT o-field-in-error2
            ).
            
        IF o-unstring-error2 = NO THEN DO: 
            
            RUN value(SEARCH("SUBpeop-findR.p"))
                (io-prefix2,
                 io-firstname2,
                 io-middlename2, 
                 io-lastname2, 
                 io-suffix2, 
                 OUTPUT o-fpe-peopleID2,
                 OUTPUT o-fpe-addr_ID2,
                 OUTPUT o-fpe-error2,
                 OUTPUT o-fpat-ran2 
                ).
                
            IF o-fpe-error2 = NO THEN DO:  
                FIND people_mstr WHERE people_mstr.people_id = o-fpe-peopleID2
                    NO-LOCK NO-ERROR.
                tempDOB2 = people_mstr.people_DOB.
            END.    /** of if o-fpe-error = no **/
                
        END.  /** of if o-unstring-error = no **/                 
        
        EXPORT STREAM goodstuff DELIMITER ";"
            VF1_det.VF1_ID VF1_det.VF1_Fullname VF1_det.VF1_Firstname VF1_det.VF1_Middlename VF1_det.VF1_Lastname VF1_det.VF1_GOOD_DOB
            o-fpe-peopleID io-prefix io-firstname io-middlename io-lastname io-suffix tempDOB
            o-fpe-peopleID2 io-prefix2 io-firstname2 io-middlename2 io-lastname2 io-suffix2 tempDOB2.
        
    END.  /*** of else do --- can-find vf1_det ***/

END.    /**** OF 4ea. exportSampleMMDDYYYY ****/

OUTPUT STREAM goodstuff CLOSE.
OUTPUT STREAM out2 CLOSE.
OUTPUT STREAM outward CLOSE.

DISPLAY x y z.
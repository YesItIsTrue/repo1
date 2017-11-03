
/*------------------------------------------------------------------------
    File        : RS-SQL-Loads-Run.p
    Purpose     : Reads the SQL extracted .txt data files and
                : stores/updates the RS database records. 

    Description : Program to run each of the RS SQL Load programs everyday.

    Author(s)   : Harold Luttrell, Sr.
    Created     : May 20, 2015
    
    Version: 1.0    By Harold Luttrell, Sr.
        Original code - 20/May/15.
        
    Version: 1.1    By Harold Luttrell, Sr.
        Date: 21/Nov/15.
        Changed RUN statement paths to use the rcode folder and to
            use the .r program extensions.
        Identified by /** 1dot1 **/
      
    1.2 - written by HAROLD LUTTRELL JR. on 03/Oct/17.  Changed to use
            single rcode PROPATH settings pursuant to the rules of
            Release 12 (CMC structure).  Need to include the RUN VALUE(SEARCH
            style commands and eliminate the C: vs. P: business.  Marked by 1dot2. 
                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                              
DEFINE VARIABLE ITmessages AS LOGICAL INITIAL NO NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

{UTIL-set_propath-HHI_TEST-U.i}.
DEFINE VARIABLE x AS INTEGER NO-UNDO.
 
/* ***************************  Main Block  *************************** */
IF ITmessages = YES THEN DO: 

  OUTPUT TO "C:\progress\wrk\RS-SQL-Loads_path-test-R.txt".
  PUT UNFORMATTED  "Inside " THIS-PROCEDURE:FILE-NAME FORMAT "x(232)" SKIP(1).

  DO x = 1 TO NUM-ENTRIES(PROPATH):

    DISPLAY ENTRY(x,PROPATH) FORMAT "x(60)" SKIP 
          WITH FRAME currpropath WIDTH 80 DOWN 
              TITLE "Current PROPATH".
    DOWN WITH FRAME currpropath.
   
  END.    /* of do x = 1 to PROPATH */

  OUTPUT CLOSE.

END.    /** of if ITmessages = YES **/

/*IF drive_letter = "C" THEN DO:*/
    
    PUT UNFORMATTED "Starting RS-SQL Loads on Drive " drive_letter "." SKIP.
    
    PUT UNFORMATTED "1 of 10. : PATIENT_RCD-Load.r" SKIP.                       /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/PATIENT_RCD-Load.r".      /** 1dot1 **/*/
    RUN VALUE(SEARCH("PATIENT_RCD-Load.r")).        /* 1dot2 */
    
    PUT UNFORMATTED "2 of 10. : PATIENT_FILES-Load.r" SKIP.                     /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/PATIENT_FILES-Load.r".    /** 1dot1 **/*/
    RUN VALUE(SEARCH("PATIENT_FILES-Load.r")).      /* 1dot2 */

    PUT UNFORMATTED "3 of 10. : MPA_RCD-Load.r" SKIP.                           /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/MPA_RCD-Load.r".          /** 1dot1 **/*/
    RUN VALUE(SEARCH("MPA_RCD-Load.r")).            /* 1dot2 */
    
    PUT UNFORMATTED "4 of 10. : MPA_TESTS_DETAILS_RCD-Load.r" SKIP.                     /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/MPA_TESTS_DETAILS_RCD-Load.r".    /** 1dot1 **/*/
    RUN VALUE(SEARCH("MPA_TESTS_DETAILS_RCD-Load.r")).          /* 1dot2 */
                                               
    PUT UNFORMATTED "5 of 10. : TESTS_RESULT_RCD-Load.r" SKIP.                  /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_RESULT_RCD-Load.r". /** 1dot1 **/*/
    RUN VALUE(SEARCH("TESTS_RESULT_RCD-Load.r")).               /* 1dot2 */

    PUT UNFORMATTED "6 of 10. : TESTS_DETAIL_RCD-Load.r" SKIP.                  /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_DETAIL_RCD-Load.r". /** 1dot1 **/*/
    RUN VALUE(SEARCH("TESTS_DETAIL_RCD-Load.r")).               /* 1dot2 */

    PUT UNFORMATTED "7 of 10. : TESTS_FM_SPECIMEN_RCD-Load.r" SKIP.                     /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_FM_SPECIMEN_RCD-Load.r".    /** 1dot1 **/*/
    RUN VALUE(SEARCH("TESTS_FM_SPECIMEN_RCD-Load.r")).          /* 1dot2 */

    PUT UNFORMATTED "8 of 10. : TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r" SKIP.                      /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r".     /** 1dot1 **/*/
    RUN VALUE(SEARCH("TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r")).                  /* 1dot2 */

    PUT UNFORMATTED "9 of 10. : TESTS_UTM_UEE_SPECIMEN_RCD-Load.r" SKIP.                        /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_UTM_UEE_SPECIMEN_RCD-Load.r".       /** 1dot1 **/*/
    RUN VALUE(SEARCH("TESTS_UTM_UEE_SPECIMEN_RCD-Load.r")).     /* 1dot2 */
 
    PUT UNFORMATTED "10 of 10. : PATIENT_DELETED_RCD-Load.r     -  On HOLD as of 11/20/2015." SKIP.     /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/PATIENT_DELETED_RCD-Load.r".*/                  /** 1dot1 **/
    
    PUT UNFORMATTED "  End of RS-SQL Loads." SKIP.

/*END.  /* IF drive_letter = "C" THEN DO: */                                                                           */
/*                                                                                                                     */
/*                                                                                                                     */
/*IF drive_letter = "P" THEN DO:                                                                                       */
/*                                                                                                                     */
/*    PUT UNFORMATTED "Starting RS-SQL Loads on Drive P:" SKIP.                                                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "1 of 10. : PATIENT_RCD-Load.r" SKIP.                       /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/PATIENT_RCD-Load.r".            /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "2 of 10. : PATIENT_FILES-Load.r" SKIP.                     /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/PATIENT_FILES-Load.r".          /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "3 of 10. : MPA_RCD-Load.r" SKIP.                           /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/MPA_RCD-Load.r".                /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "4 of 10. : MPA_TESTS_DETAILS_RCD-Load.r" SKIP.             /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/MPA_TESTS_DETAILS_RCD-Load.r".  /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "5 of 10. : TESTS_RESULT_RCD-Load.r" SKIP.                  /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_RESULT_RCD-Load.r".       /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "6 of 10. : TESTS_DETAIL_RCD-Load.r" SKIP.                  /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_DETAIL_RCD-Load.r".       /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "7 of 10. : TESTS_FM_SPECIMEN_RCD-Load.r" SKIP.             /** 1dot1 **/                        */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_FM_SPECIMEN_RCD-Load.r".  /** 1dot1 **/                        */
/*                                                                                                                     */
/*    PUT UNFORMATTED "8 of 10. : TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r" SKIP.                  /** 1dot1 **/            */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r".       /** 1dot1 **/            */
/*                                                                                                                     */
/*    PUT UNFORMATTED "9 of 10. : TESTS_UTM_UEE_SPECIMEN_RCD-Load.r" SKIP.                    /** 1dot1 **/            */
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_UTM_UEE_SPECIMEN_RCD-Load.r".         /** 1dot1 **/            */
/*                                                                                                                     */
/*    PUT UNFORMATTED "10 of 10. : PATIENT_DELETED_RCD-Load.r     -  On HOLD as of 11/20/2015." SKIP.     /** 1dot1 **/*/
/*/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/PATIENT_DELETED_RCD-Load.r".*/                        /** 1dot1 **/*/
/*                                                                                                                     */
/*    PUT UNFORMATTED "  End of RS-SQL Loads." SKIP.                                                                   */
/*                                                                                                                     */
/*END.  /*  IF drive_letter = "P" THEN DO: */                                                                          */




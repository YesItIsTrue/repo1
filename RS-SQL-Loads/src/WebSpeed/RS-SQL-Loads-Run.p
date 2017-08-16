
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
      
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                              

/* ********************  Preprocessor Definitions  ******************** */
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

/* ***************************  Main Block  *************************** */

IF drive_letter = "C" THEN DO: 
    
    PUT UNFORMATTED "Starting RS-SQL Loads on Drive C." SKIP.
    
    PUT UNFORMATTED "1 of 10. : PATIENT_RCD-Load.r" SKIP.                       /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/PATIENT_RCD-Load.r".      /** 1dot1 **/
    
    PUT UNFORMATTED "2 of 10. : PATIENT_FILES-Load.r" SKIP.                     /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/PATIENT_FILES-Load.r".    /** 1dot1 **/ 

    PUT UNFORMATTED "3 of 10. : MPA_RCD-Load.r" SKIP.                           /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/MPA_RCD-Load.r".          /** 1dot1 **/ 
    
    PUT UNFORMATTED "4 of 10. : MPA_TESTS_DETAILS_RCD-Load.r" SKIP.                     /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/MPA_TESTS_DETAILS_RCD-Load.r".    /** 1dot1 **/  
                  
    PUT UNFORMATTED "5 of 10. : TESTS_RESULT_RCD-Load.r" SKIP.                  /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_RESULT_RCD-Load.r". /** 1dot1 **/            

    PUT UNFORMATTED "6 of 10. : TESTS_DETAIL_RCD-Load.r" SKIP.                  /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_DETAIL_RCD-Load.r". /** 1dot1 **/ 

    PUT UNFORMATTED "7 of 10. : TESTS_FM_SPECIMEN_RCD-Load.r" SKIP.                     /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_FM_SPECIMEN_RCD-Load.r".    /** 1dot1 **/             

    PUT UNFORMATTED "8 of 10. : TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r" SKIP.                      /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r".     /** 1dot1 **/ 

    PUT UNFORMATTED "9 of 10. : TESTS_UTM_UEE_SPECIMEN_RCD-Load.r" SKIP.                        /** 1dot1 **/
    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/TESTS_UTM_UEE_SPECIMEN_RCD-Load.r".       /** 1dot1 **/ 
 
    PUT UNFORMATTED "10 of 10. : PATIENT_DELETED_RCD-Load.r     -  On HOLD as of 11/20/2015." SKIP.     /** 1dot1 **/
/*    RUN     "C:/OpenEdge/Workspace/RS-SQL-Loads/rcode/PATIENT_DELETED_RCD-Load.r".*/                  /** 1dot1 **/
    
    PUT UNFORMATTED "  End of RS-SQL Loads." SKIP.

END.  /* IF drive_letter = "C" THEN DO: */ 


IF drive_letter = "P" THEN DO:      

    PUT UNFORMATTED "Starting RS-SQL Loads on Drive P:" SKIP.
    
    PUT UNFORMATTED "1 of 10. : PATIENT_RCD-Load.r" SKIP.                       /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/PATIENT_RCD-Load.r".            /** 1dot1 **/    
    
    PUT UNFORMATTED "2 of 10. : PATIENT_FILES-Load.r" SKIP.                     /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/PATIENT_FILES-Load.r".          /** 1dot1 **/
                                                                                             
    PUT UNFORMATTED "3 of 10. : MPA_RCD-Load.r" SKIP.                           /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/MPA_RCD-Load.r".                /** 1dot1 **/                               
                                                                                             
    PUT UNFORMATTED "4 of 10. : MPA_TESTS_DETAILS_RCD-Load.r" SKIP.             /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/MPA_TESTS_DETAILS_RCD-Load.r".  /** 1dot1 **/                 
                                                                                             
    PUT UNFORMATTED "5 of 10. : TESTS_RESULT_RCD-Load.r" SKIP.                  /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_RESULT_RCD-Load.r".       /** 1dot1 **/                      
                                                                                             
    PUT UNFORMATTED "6 of 10. : TESTS_DETAIL_RCD-Load.r" SKIP.                  /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_DETAIL_RCD-Load.r".       /** 1dot1 **/                      
                                                                                             
    PUT UNFORMATTED "7 of 10. : TESTS_FM_SPECIMEN_RCD-Load.r" SKIP.             /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_FM_SPECIMEN_RCD-Load.r".  /** 1dot1 **/               
                                                                                             
    PUT UNFORMATTED "8 of 10. : TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r" SKIP.                  /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_HE_SPECIMEN_RATIOS_RCD-Load.r".       /** 1dot1 **/         
                                                                                             
    PUT UNFORMATTED "9 of 10. : TESTS_UTM_UEE_SPECIMEN_RCD-Load.r" SKIP.                    /** 1dot1 **/
    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/TESTS_UTM_UEE_SPECIMEN_RCD-Load.r".         /** 1dot1 **/           
 
    PUT UNFORMATTED "10 of 10. : PATIENT_DELETED_RCD-Load.r     -  On HOLD as of 11/20/2015." SKIP.     /** 1dot1 **/
/*    RUN     "P:/OpenEdge/WRK/RS-SQL-Loads/rcode/PATIENT_DELETED_RCD-Load.r".*/                        /** 1dot1 **/

    PUT UNFORMATTED "  End of RS-SQL Loads." SKIP.
                
END.  /*  IF drive_letter = "P" THEN DO: */


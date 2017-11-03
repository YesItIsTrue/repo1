
/*------------------------------------------------------------------------
    File        : RStP_Batch.p
    Purpose     : To save Harold's life.

    Description : This program will run all the RStP programs that process the RS database into the PROGRESS database.

    Author(s)   : Harold, III
    Created     : Mon May 25 22:41:16 EDT 2015
    Notes       :
    
    Version 1.2 : 05/26/2015 - by Harold, Sr.
                : Added the RUN statements for 
                : RStP-patient-UA.p, RStP-patient-UB.p & RStP-patient-UC.p.
                : Identified by: /* 1dot2 */
    
    Version 1.3 : 09/14/2015 - by Harold, Sr.
                : Modified the RUN statements to use the new Run SEARCH 
                : instead of the long pathing name.
                : Identified by: /* 1dot3 */
                
    Version 1.4 : 09/30/2015 - by Harold, Sr.
                : Added two (2) new programs that MUST be run before
                : any of the other RStP programs.
                : Identified by: /* 1dot4 */        
                                   
    Version 2.0 : 03/04/2016 - by Harold, Sr.
                : Changed the order or sequence of the MPA and BIOMED 
                : details/child programs to run before
                : their main/parent programs are run.
                : Identified by: /* 2dot0 */ 
                                  
    Version 2.1 : 02/Jun/2016 - by Harold, Jr.
                : Changed the PROPATH so it puts it back like it was when
                : it is done.  Marked by 2dot1.                                  
    
    Version 3.0 : 03/Oct/2017 - by Harold, Sr.
                : Commented out the 2dot1 PROPATH and C: drive code 
                : in hopes that it works.  
                : Marked by 3dot0.                  
                
    Version 3.2 : 04/Oct/17 - by Harold, Jr.           
                : Removed PROPATH changes for Release 12 (CMC structure).
                : These settings are part of the overall process flow
                : that get set when Progress is started using the *.pf 
                : files if necessary.
                : Not marked.           
                        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                

/*DEFINE VARIABLE hold-propath AS CHARACTER NO-UNDO.                              /* 2dot1 */*/

ASSIGN
    drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).
/*    hold-propath = PROPATH.                                                     /* 2dot1 */*/

OUTPUT TO "C:\Progress\WRK\RStP-allbatch-log.txt".
 
/*IF drive_letter = "P" THEN DO:                                                                 */
/*    PROPATH =   "P:\OpenEdge\PROD\rcode\," +                                    /* 2dot1 */    */
/*/*                "P:\OpenEdge\WRK\RStP\src\," +                                  /* 3dot0 */*/*/
/*/*                "P:\OpenEdge\WRK\depot\rcode\," +                               /* 3dot0 */*/*/
/*/*                "P:\OpenEdge\WRK\depot\src\WebSpeed\," +                        /* 3dot0 */*/*/
/*/*                "P:\OpenEdge\WRK\RStP\," +                                      /* 3dot0 */*/*/
/*                PROPATH.                                                        /* 2dot1 */    */
/*END. /* IF drive_letter = "P" THEN  */                                                         */
/*/*                                                                                           */*/
/*/*ELSE IF drive_letter = "C" THEN DO:                                             /* 3dot0 */*/*/
/*/*    PROPATH =   "C:\OpenEdge\Workspace\RStP\rcode\," +                          /* 3dot0 */*/*/
/*/*                "C:\OpenEdge\Workspace\RStP\src\," +                            /* 3dot0 */*/*/
/*/*                "C:\OpenEdge\Workspace\depot\rcode\," +                         /* 3dot0 */*/*/
/*/*                "C:\OpenEdge\Workspace\depot\src\WebSpeed\," +                  /* 3dot0 */*/*/
/*/*                "C:\OpenEdge\Workspace\RStP\," +                                /* 3dot0 */*/*/
/*/*                PROPATH.                                                        /* 3dot0 */*/*/
/*/*END.                                                                                       */*/

/*DEFINE VARIABLE xx AS INTEGER NO-UNDO.                */
/*DO xx = 1 TO num-entries(PROPATH):                    */
/*    DISPLAY entry(xx,PROPATH) FORMAT "x(70)" SKIP with*/
/*    FRAME outpath DOWN.                               */
/*    DOWN WITH FRAME outpath.                          */
/*END.                                                  */

/* ***************************  Main Block  *************************** */
PUT "*************************************************************" SKIP
    "* * * * * * * *    START OF MAIN PROGRAM    * * * * * * * * *" SKIP
    "*************************************************************" SKIP SKIP 
    "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "**                                                         **" SKIP(2) .

/* 1dot4 */
PUT "******** Start of RStP-GENERAL-deleted-date-Rcds ************" SKIP.   

RUN VALUE(SEARCH("RStP-GENERAL-deleted-date-Rcds.r")).                            

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP  
    "****************************  End   *************************" SKIP(2).          

PUT "********** Start of RStP-HHI-deleted-date-Rcds **************" SKIP.         

RUN VALUE(SEARCH("RStP-HHI-deleted-date-Rcds.r")).                               

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP 
    "****************************  End   *************************" SKIP(2).          
/* 1dot4 */

    
PUT "****************** Start of patient UA **********************" SKIP.           /* 1dot2 */   

RUN VALUE(SEARCH("RStP-patient-UA.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP  /* 1dot2 */
    "****************************  End   *************************" SKIP(2).           /* 1dot2 */ 
PUT "****************** Start of patient UB **********************" SKIP.     /* 1dot2 */   

RUN VALUE(SEARCH("RStP-patient-UB.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP  /* 1dot2 */
    "****************************  End   *************************" SKIP(2).           /* 1dot2 */
PUT "****************** Start of patient UC **********************" SKIP.     /* 1dot2 */   

RUN VALUE(SEARCH("RStP-patient-UC.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP  /* 1dot2 */
    "****************************  End   *************************" SKIP(2).        /* 1dot2 */    

       
PUT "****************** Start of attfiles U 1 ********************" SKIP.   

RUN VALUE(SEARCH("RStP-attfiles-U-1.r")).                                           /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "****************************  End   *************************" SKIP(2).         
PUT "****************** Start of attfiles U 2 ********************" SKIP.   

RUN VALUE(SEARCH("RStP-attfiles-U-2.r")).                                           /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).
    

PUT "************ Start of MPA_TEST_DETAILS_RCD U 1 **************" SKIP.   

RUN VALUE(SEARCH("RStP-MPA_TEST_DETAILS_RCD-U-1.r")).                               /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).       
PUT "************ Start of MPA_TEST_DETAILS_RCD U 2 **************" SKIP.   

RUN VALUE(SEARCH("RStP-MPA_TEST_DETAILS_RCD-U-2.r")).                               /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).


/* 2dot0 */
PUT "****************** Start of MPA_RCD U 1 *********************" SKIP.   

RUN VALUE(SEARCH("RStP-MPA_RCD-U-1.r")).                                            /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).
    
PUT "****************** Start of MPA_RCD U 2 *********************" SKIP.   

RUN VALUE(SEARCH("RStP-MPA_RCD-U-2.r")).                                            /* 1dot3 */
                        
PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).
/* 2dot0 */


    
PUT "************** Start of TESTS_DETAIL_RCD U 1 ****************" SKIP.   

RUN VALUE(SEARCH("RStP-TESTS_DETAIL_RCD-U-1.r")).                                  /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2). 
    
PUT "************** Start of TESTS_DETAIL_RCD U 2 ****************" SKIP.   

RUN VALUE(SEARCH("RStP-TESTS_DETAIL_RCD-U-2.r")).                                  /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).

PUT "********************* Start of FM U 1 ***********************" SKIP.   

RUN VALUE(SEARCH("RStP-FM-U-1.r")).                                                /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).  
     
PUT "********************* Start of FM U 2 ***********************" SKIP.   

RUN VALUE(SEARCH("RStP-FM-U-2.r")).                                                /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).

PUT "********************* Start of HE U 1 ***********************" SKIP.   

RUN VALUE(SEARCH("RStP-HE-U-1.r")).                                                /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).
    
PUT "********************* Start of HE U 2 ***********************" SKIP.   

RUN VALUE(SEARCH("RStP-HE-U-2.r")).                                                /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).

PUT "******************* Start of BUTEE U 1 **********************" SKIP.   

RUN VALUE(SEARCH("RStP-BUTEE-U-1.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).
        
PUT "******************* Start of BUTEE U 2 **********************" SKIP.   

RUN VALUE(SEARCH("RStP-BUTEE-U-2.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).

PUT "******************* Start of BUTEE U 3  *********************" SKIP.   

RUN VALUE(SEARCH("RStP-BUTEE-U-3.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
   "***************************  End   **************************" SKIP(2). 
      
PUT "******************* Start of BUTEE U 4  *********************" SKIP.   

RUN VALUE(SEARCH("RStP-BUTEE-U-4.r")).                                             /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).



/* 2dot0 */
PUT "************** Start of TESTS_RESULT_RCD U 1 ****************" SKIP.   

RUN VALUE(SEARCH("RStP-TESTS_RESULT_RCD-U-1.r")).                                   /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).   
PUT "************** Start of TESTS_RESULT_RCD U 2 ****************" SKIP.  

RUN VALUE(SEARCH("RStP-TESTS_RESULT_RCD-U-2.r")).                                   /* 1dot3 */

PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "***************************  End   **************************" SKIP(2).
/* 2dot0 */



PUT "**          Date: " TODAY "         Time: " STRING(TIME,"HH:MM:SS") "          **" SKIP
    "* * * * * * * *     END OF MAIN PROGRAM     * * * * * * * * *" SKIP (2).

/*ASSIGN                                                                                         */
/*    PROPATH = hold-propath.                                                         /* 2dot1 */*/
        
OUTPUT CLOSE.    

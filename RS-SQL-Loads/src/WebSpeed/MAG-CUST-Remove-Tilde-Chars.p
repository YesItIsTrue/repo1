/*------------------------------------------------------------------------
    File        : MAG-CUST-Remove-Tilde-Chars.p
                :
    Purpose     : Replaces any tilde and double quote character  
                : [  ~" ] or [ ~"c] (the c is any character) in  
                : the MAG-CUST-RCD-Extracted.txt file. By finding the  
                : tilde and " (~") and replacing it with two single quotes (''),
                : and then move the input data to the output data file, 
                : 1 position at a time.
                : This should keep the Magento data from erroring off
                : during the input conversion process, saving Solsource
                : man power to research and find the data record or records
                : that have the tilde's and then having someone removing them
                : in the Magento System so the data will be processed the
                : next day. 

    Author(s)   : Harold Luttrell
    Created     : April 3, 2015
                
                : Original code - April 3, 2015.
                : Finished code - October 17, 2017.
                    Implemented this program
                    into the MAG-CUST-Extract-Load-Run.p program.
                    This program replaces the Tilde's (anywhere within
                    each input data record) with two (2) single quote marks.
                    When a Tilde was present it would not process the rest
                    of the input data for that record.
                    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.
/*                                                                 */    

DEFINE VARIABLE ip-image-len AS INTEGER NO-UNDO. 
DEFINE VARIABLE starting-position AS INTEGER  NO-UNDO.
DEFINE VARIABLE xx-loop AS INTEGER NO-UNDO. 
DEFINE VARIABLE xx-input AS INTEGER NO-UNDO.
DEFINE VARIABLE xx-output AS INTEGER NO-UNDO.
DEFINE VARIABLE h-new-record-image AS CHARACTER  FORMAT "x(2000)" NO-UNDO. 

DEFINE VARIABLE cmdline  AS CHARACTER INITIAL "copy /V /Y "         NO-UNDO.
DEFINE VARIABLE from-file AS CHARACTER INITIAL "C:\APPS\RStP\Input-Files\NoTILDIEs-MAG-CUST-Extracted.txt " NO-UNDO.
DEFINE VARIABLE to-file AS CHARACTER INITIAL "C:\APPS\RStP\Input-Files\MAG-CUST-RCD-Extracted.txt" NO-UNDO.

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.              
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

/* ********************  Preprocessor Definitions  ******************** */
  
OUTPUT TO "C:\APPS\RStP\Input-Files\NoTILDIEs-MAG-CUST-Extracted.txt".

/* ***************************  Main Block  *************************** */

DEFINE  TEMP-TABLE tildelist_data  
        FIELD IP_record-image  AS CHARACTER  FORMAT "x(2000)".         
 
INPUT FROM VALUE(SEARCH("Input-Files\MAG-CUST-RCD-Extracted.txt")).

REPEAT:  
    
    CREATE   tildelist_data.                                                                 
    
    IMPORT DELIMITER "]"  tildelist_data.
    
    IF  /* IP_record-nbr = ""              OR  
        IP_record-nbr = "----------"    OR */
        IP_record-image = " "            THEN 
            DELETE tildelist_data. 

END.  /** REPEAT **/    

INPUT CLOSE. 

FOR EACH tildelist_data NO-LOCK: 
    ASSIGN  ip-image-len        = LENGTH(IP_record-image)
            xx-input            = 0
            xx-output           = 0
            h-new-record-image  = "".

    ASSIGN starting-position = INDEX(IP_record-image, "~176").                           

        DO xx-loop = 1 TO (ip-image-len + 1):
                    
            ASSIGN  xx-input  = (xx-loop)
                    xx-output = (xx-loop). 
                            
            IF  SUBSTRING(IP_record-image, xx-loop, 1) = "~176" THEN DO:

                IF  SUBSTRING(IP_record-image, (xx-loop + 1), 2) = '" ' THEN DO: 
                    ASSIGN SUBSTRING(IP_record-image, (xx-loop + 1), 2) = "".
                    ASSIGN  xx-input  = (xx-input  + 4)
                            xx-output = (xx-output  + 1).
                END. /* IF  SUBSTRING(IP_record-image, (xx-loop + 1), 2) = '" ' */ 
                ELSE DO:    
                    ASSIGN SUBSTRING(IP_record-image, (xx-loop + 0), 2) = "''".
                    ASSIGN  xx-input  = (xx-input)
                            xx-output = (xx-output).
                END. /* ELSE DO: */

            END.  /* IF  SUBSTRING(IP_record-image, xx-loop, 1) = "~176" */
               
            ASSIGN   SUBSTRING(h-new-record-image, xx-output, 1) = SUBSTRING(IP_record-image, xx-input, 1).  
             
        END. /* DO xx = 1 TO ip-image-len: */
    
/* export the new data to be import in MAG_CUST-Load.p - here */    

    PUT UNFORMATTED  h-new-record-image SKIP.
    
END. /* FOR EACH tildelist_data */
 
OUTPUT CLOSE. 

/*  Copy the output NoTILDIEs-MAG-CUST-Extracted.txt file back over the
    MAG-CUST-RCD-Extracted.txt file to be used as input to the 
    MAG_CUST-Load-  TEST or PROD programs. */
     
OS-COMMAND SILENT
    VALUE(cmdline + from-file + to-file).  

/* End of Program. */

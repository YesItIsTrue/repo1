/*------------------------------------------------------------------------
    File        : SUBerrorCK.p
    Purpose     : Standardized processing for ALL system error messages
                :   and notifications. 

    Syntax      : 
                    RUN VALUE (SEARCH ("SUBerrorCK.r")) 
                                    (THIS-PROCEDURE:FILE-NAME,
                                     ERROR-STATUS:NUM-MESSAGES).   

    Description : Send error notifications to tech support where problems
                :   error(s) are encountered.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Feb 08, 2016
    Notes       :
        
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
ROUTINE-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER  i-calling-program       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER  i-error-number          AS INTEGER NO-UNDO.

DEFINE VARIABLE xxx   AS INTEGER NO-UNDO.
DEFINE VARIABLE h-pgm-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE starting-position AS INTEGER NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.                            

ASSIGN drive_letter = SUBSTRING(i-calling-program, 1, 1).                 

DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from program: "                   NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

DEFINE VARIABLE it-message AS LOGICAL INITIAL NO NO-UNDO.

ASSIGN starting-position = R-INDEX (i-calling-program, "\").

ASSIGN h-pgm-name = SUBSTRING(i-calling-program, (starting-position + 1), LENGTH (i-calling-program) ).

ASSIGN subjtxt = subjtxt + h-pgm-name.  /* i-calling-program. */
ASSIGN messagetxt = messagetxt  + "\n"
                                + i-calling-program
                                + "\n"
                                + "End of message.".
   
DEFINE STREAM EXPORTERROR.
DEFINE VARIABLE errorlog AS CHARACTER NO-UNDO.

ASSIGN errorlog = "C:\PROGRESS\WRK\" + h-pgm-name + "-log.txt".

OUTPUT STREAM EXPORTERROR TO value(errorlog).

DISPLAY STREAM EXPORTERROR 
          "Program Name:" 
          i-calling-program FORMAT "x(100)"  SKIP    
          "Start of Error encountered at:" TODAY STRING(TIME, "HH:MM:SS")
     WITH FRAME outheader WIDTH 132 SIDE-LABELS.
         
DISPLAY STREAM EXPORTERROR  "Error Number:"  AT 10  
                            "Error Message:" AT 25 SKIP
                            "-------------"  AT 10 
                            "--------------------------------------" AT 25 SKIP
    WITH FRAME Heading NO-LABELS WIDTH 132.  
           
/* ***************************  Main Block  *************************** */

IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 THEN DO:                        
                                       
    DO  xxx = 1 TO   ERROR-STATUS:NUM-MESSAGES :              

         DISPLAY STREAM EXPORTERROR
                ERROR-STATUS:GET-NUMBER(xxx)  AT 10
                ERROR-STATUS:GET-MESSAGE(xxx) AT 25  FORMAT "x(80)"
            WITH FRAME outdetailE1 WIDTH 132 DOWN.
            DOWN WITH FRAME outdetailE1.                     
            
    END.  /** of do xxx = 1 to num-messages **/ 
    
END.  /** IF  ERROR-STATUS:ERROR OR ERROR-STATUS:NUM-MESSAGES > 0 **/    


DISPLAY STREAM EXPORTERROR 
        "  End of Error encountered at:" TODAY STRING(TIME, "HH:MM:SS") SKIP
        "End of Report." 
    WITH FRAME outtrailer WIDTH 132 SIDE-LABELS. 
      
OUTPUT STREAM EXPORTERROR CLOSE.

OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errorlog).
/* END OF program. */


/*------------------------------------------------------------------------
    File        : Send-EMAIL-Message.p
    Purpose     : Send E-Mail Messages from Progress programs (.p & .HTML)
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* 
    Syntax      : To use this program, Apply the following code starting with the DEFINE statement
                  thru the last variable on the RUN Statement to your program.
NOTE 1:  If you want to see this program work, copy the following lines of code, starting 
         with the DEFINE statement thru the last variable on the RUN Statement and 
         paste it in your ABL Scratchpad and execute.
         
NOTE 2:  If you want to send an attachment with the message, put the file-name in the 
         variable  'msg-attach-file-name'  else leave it blank. 
                      
        DEFINE VARIABLE From-Calling-Pgm            AS CHARACTER  FORMAT "x(118)"       NO-UNDO.
        DEFINE VARIABLE e_subject                   AS CHARACTER  FORMAT "x(80)"        NO-UNDO.
        DEFINE VARIABLE e_to-whom                   AS CHARACTER FORMAT "x(120)"        NO-UNDO. 
        DEFINE VARIABLE e_message                   AS CHARACTER  FORMAT "x(4000)"      NO-UNDO.
        DEFINE VARIABLE msg-attach-file-name        AS CHARACTER  FORMAT "x(4000)"      NO-UNDO.
                        
        ASSIGN  From-Calling-Pgm = THIS-PROCEDURE:FILE-NAME
                e_to-whom    = ""
                e_message    = ""
                msg-attach-file-name = "". 

        ASSIGN  e_subject = " (enter the SUBJECT you want to use here).  From ".
        
        ASSIGN  e_message = "This is where you set up the message you want to e-mail." 
                + " \n  "   /* << this code forces the message to go to the next line for continuing the message.  Makes it look nice. */ 
                + "Set up as much information you want to send."
                + " \n  "
                + " You can sent up to 4,000 characters, but that size has not been tested as of: 01/02/2017.".
                
        RUN VALUE(SEARCH("Send-EMAIL-Message.r")) 
                            (From-Calling-Pgm,
                             e_to-whom,
                             e_subject,
                             e_message,
                             msg-attach-file-name).
*/        
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    Description : External subroutine used to send out E-Mail's messages 
                : about errors, warnings or information about the 
                : status of processing data, with or without an attached file. 
                :
                : The errormail.exe program and its configuration file: errormail.exe.config 
                : MUST be in the same folder to execute correctly.
                : On your PC - load email program and config into: "C:\OpenEdge\Batch-Runs\".
                : These files are on HHI-DC-4 as of 11/10/2015 in: "P:\OpenEdge\Batch-Runs\".
                 
    Author(s)   : Harold Luttrell
    Created     : Fri Dec 30 18:02:19 CST 2016
    Notes       :
        
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 15/Sept/17. 
          Changed database names for the CMC Release 12.0 & 12.1.
          Changed:  GENERAL to CORE,
                    HHI     to MODULES,
                    RS      to CUSTOM_ALL.
          Marked by /* 1dot1 */.
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.  

/* ********************  Preprocessor Definitions  ******************** */
DEFINE INPUT  PARAMETER From-Calling-Pgm        AS CHARACTER FORMAT "x(118)"        NO-UNDO.
DEFINE INPUT  PARAMETER e_to-whom               AS CHARACTER FORMAT "x(120)"        NO-UNDO. 
DEFINE INPUT  PARAMETER e_subject               AS CHARACTER FORMAT "x(80)"         NO-UNDO.
DEFINE INPUT  PARAMETER e_message               AS CHARACTER FORMAT "x(4000)"       NO-UNDO.
DEFINE INPUT  PARAMETER msg-attach-file-name    AS CHARACTER FORMAT "x(4000)"       NO-UNDO.

DEFINE VARIABLE what_drive_letter               AS CHARACTER FORMAT "x(01)" NO-UNDO.

/* ***************************  E-Mail  Definitions  *************************** */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\Apps\Utils\errormail.exe"                  NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"           NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s "                                          NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m  "                                         NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                           NO-UNDO.

/* ***************************  Main Block  *************************** */
/*DISPLAY THIS-PROCEDURE:FILE-NAME FORMAT "x(70)".*/

/* Check the Calling-Pgm value incase it is empty/blank-not submitted. */
IF From-Calling-Pgm = "" THEN
    ASSIGN From-Calling-Pgm = ": ! Pgm Name NOT supplied by calling program !".

/* Check the to-whom input value for non-blanks and use it for the to emailaddress. */
IF e_to-whom <> "" THEN 
    ASSIGN emailaddr = "-r " + e_to-whom.
         
/* Build the Subject line from the passed parameter. */
IF e_subject = "" THEN 
    ASSIGN e_subject = "Error/Warning/Info From Program: ".
ASSIGN subjtxt     = subjtxt + e_subject + From-Calling-Pgm. 

/* Build the Message from the passed parameter. */
IF e_message = "" THEN  
    ASSIGN e_message =    " No message was supplied." + " \n  " 
                        + "Notify SolSource about this e-mail message." + " \n  " 
                        + "Thank you.".
    
/*ASSIGN messagetxt  = messagetxt + From-Calling-Pgm + " : " + " \n  " + e_message.*/
ASSIGN messagetxt  = messagetxt + e_message.

ASSIGN what_drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).

IF what_drive_letter = "C" THEN DO:
/*  Drive_letter C logic is for when Solsource employees are testing
    programs on their PC's/Laptop's then if an e-mail is generated it will go to 
    their MySolsource.com e-mail account. */
    
    ASSIGN cmdname   = "C:\Apps\Utils\errormail.exe".
    
    IF  e_to-whom <> "" THEN 
            ASSIGN emailaddr = "-r " + e_to-whom.
            
    ELSE IF  USERID("CORE")         = "Doug.Luttrell"   OR 
             USERID("MODULES")      = "Doug.Luttrell"   OR 
             USERID("CUSTOM")   = "Doug.Luttrell"   THEN 
                ASSIGN 
                    emailaddr = "-r doug.luttrell@mysolsource.com".
            
    ELSE IF USERID("CORE")          = "Harold.Luttrell"  OR  
            USERID("MODULES")       = "Harold.Luttrell"  OR  
            USERID("CUSTOM")    = "Harold.Luttrell"  THEN  
                ASSIGN 
/*                    emailaddr = "-r harold.luttrell@mysolsource.com".*/
                    emailaddr = "-r harold.luttrell@att.net".
            
    ELSE IF USERID("CORE")          = "Trae.Luttrell"  OR  
            USERID("MODULES")       = "Trae.Luttrell"  OR
            USERID("CUSTOM")    = "Trae.Luttrell"  THEN  
                ASSIGN 
                    emailaddr = "-r trae.luttrell@mysolsource.com".
                
    ELSE IF USERID("CORE")          = "Andrew.Garver"  OR  
            USERID("MODULES")       = "Andrew.Garver"  OR
            USERID("CUSTOM")    = "Andrew.Garver"  THEN 
                ASSIGN 
                    emailaddr = "-r Andrew.Garver@mysolsource.com".
           
    ELSE 
        ASSIGN 
            emailaddr = "-r hhi.techsupport@mysolsource.com".

END.  /* of if what_drive_letter = C */            
 
OS-COMMAND SILENT   
            VALUE(cmdname)  
            VALUE(emailaddr)
            VALUE(messagetxt) 
            VALUE(subjtxt)
            VALUE(cmdparams)
            VALUE(msg-attach-file-name). 
                    
/* end of program. */
            
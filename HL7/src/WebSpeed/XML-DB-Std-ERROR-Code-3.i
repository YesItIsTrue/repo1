
/*------------------------------------------------------------------------
    File        : XML-DB-Std-ERROR-Code-3.i
    Purpose     : 

    Syntax      :

    Description : Standard E-Mail error message when returning from 
                : SUB programs that encountered some type of processing error.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Mar 14,2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

        ASSIGN  msg-attach-file-name    = "".
        
        IF h-TK_ID = "" THEN DO:
            FIND FIRST h-XML_TT-buf WHERE h-XML_TT-buf.TT-1-File-ID      =  h-File-ID AND
                                          h-XML_TT-buf.TT-1-Field-Name   = "TK_ID"
                        EXCLUSIVE-LOCK NO-ERROR.
            IF  NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN h-TK_ID = "?".
            ELSE
                ASSIGN h-TK_ID = TRIM(h-XML_TT-buf.TT-1-Field-Value).
        END. /* IF h-TK_ID = "" */

        IF h-Lab_Sample_ID = "" THEN DO:
            FIND NEXT h-XML_TT-buf WHERE    h-XML_TT-buf.TT-1-File-ID      =  h-File-ID  AND
                                            h-XML_TT-buf.TT-1-Field-Name = "tk_lab_sample_ID"
                        EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE (h-XML_TT-buf) THEN
                ASSIGN h-Lab_Sample_ID = "?".
            ELSE
                ASSIGN h-Lab_Sample_ID = TRIM(h-XML_TT-buf.TT-1-Field-Value).
        END. /* IF h-Lab_Sample_ID = "" */
            
        IF  h-TK_test_seq = "" OR h-Lab_Samp_seq = "" THEN DO: 
            ASSIGN  h-TK_test_seq        = "1"
                    h-Lab_Samp_seq       = "1".
        END. /* IF  h-TK_test_seq = "" OR h-Lab_Sample_seq = "" */
        
              
        ASSIGN e_subject =  "Major Error for DB-NBR: " + "'" + STRING(o-people-id) + "'" + ".  Output from: ".
        IF  o-people-id = 0 THEN  
            ASSIGN e_subject =  "Major Error for HL7-NBR: " + "'" + STRING(h-File-ID) + "'" + ".  Output from: ".
        ASSIGN e_message =  "-m " 
                            + o-error-message
                            + " \n "
                            + " Test Kit ID = " + h-TK_ID + " / " + h-TK_test_seq + "."
                            + " \n "
                            + " Lab Sample ID = " + h-Lab_Sample_ID + " / " + h-Lab_Samp_seq + "." 
                            + " \n "
                            + "The above test kit needs to be researched to determine what" + " "
                            + " \n "  
                            + "the problem is in the InfoMatrix System." + " "
                            + " \n " 
                            + "This e-mail was sent from program: " + THIS-PROCEDURE:FILE-NAME + "."
                            + " \n "    
                            + "End of message.".
                                 
        RUN VALUE(SEARCH("Send-EMAIL-Message.r"))
                (From-Calling-Pgm,
                 e_to-whom,                                   
                 e_subject,
                 e_message,
                 msg-attach-file-name). 
        
        FIND NEXT h-XML_TT-buf WHERE 
                        SUBSTRING(h-XML_TT-buf.TT-1-Field-Value, 1, 9) = "END TEST-"  NO-LOCK NO-ERROR.

/* END OF .i CODE. */

 
/*------------------------------------------------------------------------
    File        : XML-DB-Std-ERROR-Code-2.i
    Purpose     : 

    Syntax      :

    Description : Standard code to change the processed field to 'ERROR'  
                : in the fs_mstr & atn_det table records
                : that have some type of processing error.

    Author(s)   : Harold Luttrell, Sr.
    Created     : Mar 14, 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

        ASSIGN  From-Calling-Pgm        = "XML-DB-Updates.r".
        ASSIGN  e_subject =  "Major Error in program: ".
        ASSIGN  e_message =  "-m " 
                        + "Paragraph SecondLoopie: has an processing error with XML File_ID Nbr: " 
                        + STRING(h-File-ID) + ","
                        + " \n "
                        + "Parent-Level: " + STRING(XML_TT_1_Data.TT-1-parent-level) 
                        + ",   Child-Level: " + STRING(XML_TT_1_Data.TT-1-p-child-node-level) + ", "
                        + " \n "
                        + "Field-Name:   '" + XML_TT_1_Data.TT-1-Field-Name 
                        + "'   is NOT defined/coded for processing."
                        + " \n "   
                        + "Notify MySolsource Admin asap to code for new Field-Name data for Table:   '" 
                        + XML_TT_1_Data.TT-1-Table-Name 
                        + "'   data to process."
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
                          
/* End of .i code. */ 
             
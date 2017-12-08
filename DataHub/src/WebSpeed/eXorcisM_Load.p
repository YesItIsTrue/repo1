    
/*------------------------------------------------------------------------
    File        : XMLextractor_0-dot-5.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Jacob Luttrell
    Created     : Thu Oct 20 10:35:39 MDT 2016
    Notes       :
    
    Revision History:
    -----------------
    1.1 - written by Harold Luttrell, Sr. on 15/Sept/17.
          Changed "C:\apps\HL7\Error_log\WhatTheHeck.txt" to 
          "C:\apps\HL7\ErrorLog\WhatTheHeck.txt" to match the 
          HL7 Phase 1 (Converter) process.
          Marked by /* 1dot1 */  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER file_path LIKE att_files.att_filepath NO-UNDO.
DEFINE INPUT PARAMETER file_name LIKE att_files.att_filename NO-UNDO.
DEFINE OUTPUT PARAMETER o-fileid  AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER o-fail    AS LOGICAL NO-UNDO.

DEFINE VARIABLE file_loc AS CHARACTER NO-UNDO.

DEFINE VARIABLE hDoc    AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot   AS HANDLE NO-UNDO.

DEFINE VARIABLE cnt     AS INTEGER INITIAL 1 NO-UNDO.
DEFINE VARIABLE fileid  AS INTEGER NO-UNDO.

DEFINE VARIABLE o-par       AS INTEGER   NO-UNDO.
DEFINE VARIABLE o-cnt       AS INTEGER   NO-UNDO.
DEFINE VARIABLE o-atnname   AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-atnvalue  AS CHARACTER NO-UNDO.
DEFINE VARIABLE o-created   AS LOGICAL   NO-UNDO.
DEFINE VARIABLE o-error     AS LOGICAL   NO-UNDO.

DEFINE VARIABLE wellDefined AS LOGICAL INITIAL NO NO-UNDO.

DEFINE VARIABLE ITmessages AS LOGICAL INITIAL NO NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
 
/* ***********************  Starting Procedure  *********************** */
PROCEDURE parseXML: 

    DEFINE INPUT PARAMETER par          AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER hWorkingNode AS HANDLE  NO-UNDO.
                                                                                    IF ITmessages = YES THEN
                                                                                        MESSAGE "par = " par SKIP
                                                                                                "hWorkingNode = " hWorkingNode SKIP
                                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                                            TITLE "Inside parseXML".
    RUN getXMLkids (cnt,hWorkingNode). 

    RUN getXMLattr (par,hWorkingNode).

    RUN getXMLtext (par,hWorkingNode,hWorkingNode:NAME).

END PROCEDURE. /* of parseXML */
/* *************************  Grab Elements  ************************** */
PROCEDURE getXMLkids: 

    DEFINE INPUT PARAMETER par AS INTEGER NO-UNDO.
    DEFINE INPUT PARAMETER hPar AS HANDLE NO-UNDO.
                                                                                    IF ITmessages = YES THEN
                                                                                        MESSAGE "par = " par SKIP
                                                                                                "hPar = " hPar SKIP
                                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                                            TITLE "Inside getXM:kids".
    DEFINE VARIABLE x               AS INTEGER NO-UNDO.
    DEFINE VARIABLE hWorkingNode    AS HANDLE  NO-UNDO.
    DEFINE VARIABLE ok2go           AS LOGICAL NO-UNDO.
    
    CREATE X-NODEREF hWorkingNode.
    
    DO x = 1 TO hPar:NUM-CHILDREN: 
        
        ok2go = hPar:GET-CHILD(hWorkingNode,x).
        
        IF NOT ok2go THEN NEXT. 
        
        IF hWorkingNode:SUBTYPE = "ELEMENT" THEN DO:
            
            RUN createrecords (par,hWorkingNode:NAME,"","ELEMENT").
            
            RUN parseXML (cnt,hWorkingNode). 
            
        END. /* of element */   
    END. /* do x = 1 to hPar */
END PROCEDURE. /* of getXMLkids */
/* *************************  Create Records  ************************* */
PROCEDURE createrecords:
    
    DEFINE INPUT PARAMETER par      AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER xmlname  AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER xmlvalue AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER xmltype  AS CHARACTER NO-UNDO.
                                                                                    IF ITmessages = YES THEN
                                                                                        MESSAGE "fileid = " fileid SKIP
                                                                                                "par = " par SKIP
                                                                                                "xmlname = " xmlname SKIP
                                                                                                "xmlvalue = " xmlvalue SKIP
                                                                                                "xmltype = " xmltype SKIP
                                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                                            TITLE "Inside createrecords".
/*    PUT UNFORMATTED "fileid = " fileid SKIP    */
/*                    "par = " par SKIP          */
/*                    "xmlname = " xmlname SKIP  */
/*                    "xmlvalue = " xmlvalue SKIP*/
/*                    "xmltype = " xmltype SKIP. */
    ASSIGN 
        o-fail = YES
        cnt = cnt + 1.
    
    RUN VALUE(SEARCH("SUBfs-ucU.r")) (
        fileid,
        par,
        cnt,
  
        OUTPUT o-fileid,
        OUTPUT o-par,
        OUTPUT o-cnt,
        OUTPUT o-created,
        OUTPUT o-error
        ).

    RUN VALUE(SEARCH("SUBatn-ucU.r")) (
        fileid,
        cnt,
        xmlname,
        xmlvalue,
        xmltype,

        OUTPUT o-fileid,
        OUTPUT o-cnt,
        OUTPUT o-atnname,         
        OUTPUT o-atnvalue,
        OUTPUT o-created,
        OUTPUT o-error
        ).
     
     IF o-error = NO THEN

        o-fail = NO.
      
END PROCEDURE. /* of createrecords */  
/* *************************  Grab Attributes  ************************ */
PROCEDURE getXMLattr: 
    
    DEFINE INPUT PARAMETER par          AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER hWorkingNode AS HANDLE    NO-UNDO.
    DEFINE VARIABLE x                   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE attrname            AS CHARACTER NO-UNDO.
                                                                                    IF ITmessages = YES THEN
                                                                                        MESSAGE "par = " par SKIP
                                                                                                "hWorkingNode = " hWorkingNode SKIP
                                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                                            TITLE "Inside getXMLattr".
    DO x = 1 TO NUM-ENTRIES (hWorkingNode:ATTRIBUTE-NAMES): 
        
        attrname = ENTRY (x,hWorkingNode:ATTRIBUTE-NAMES).
        
        RUN createrecords (par,attrname,hWorkingNode:GET-ATTRIBUTE(attrname),"ATTR").
        
    END. /* of do 1 to # attr */
END PROCEDURE. /* of getXMLattr */
/* ****************************  Grab Text  *************************** */
PROCEDURE getXMLtext: 
    
    DEFINE INPUT PARAMETER par          AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER hWorkingNode AS HANDLE    NO-UNDO.
    DEFINE INPUT PARAMETER elname       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE x                   AS INTEGER   NO-UNDO. 
    DEFINE VARIABLE ok2go               AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE hText               AS HANDLE    NO-UNDO.
    DEFINE VARIABLE nodetype            AS CHARACTER NO-UNDO.
    
    CREATE X-NODEREF hText.
    
    DO x = 1 TO hWorkingNode:NUM-CHILDREN: 
        
        ok2go = hWorkingNode:GET-CHILD(hText,x).
        
        IF NOT ok2go THEN NEXT.
        
        IF hText:SUBTYPE = "COMMENT" THEN 
        
            nodetype = "COMMENT". 
        ELSE 
            nodetype = "TEXT".     
               
                                                                                IF ITmessages = YES THEN
                                                                                    MESSAGE "par = " par SKIP
                                                                                        "cnt = " cnt SKIP
                                                                                        "hWorkingNode = " hWorkingNode:NODE-VALUE SKIP
                                                                                        "hText = " hText:NODE-VALUE SKIP
                                                                                        "elname = " elname  SKIP
                                                                                        "type = " hText:TYPE SKIP
                                                                                        "subtype = " hText:SUBTYPE SKIP 
                                                                                        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                                        TITLE "Inside getXMLtext".  

        IF hText:NODE-VALUE = "" THEN NEXT.
    
        IF ASC(SUBSTRING(hText:NODE-VALUE, 1, 1 )) = 10 THEN NEXT.           /** to get past hidden characters **/ 
            
        
        RUN createrecords (par,elname,hText:NODE-VALUE,nodetype).

    END.
    
    DELETE OBJECT hText. 
        
END PROCEDURE. /* of getXMLtext */
/* ***************************  Main Block  *************************** */

CREATE X-DOCUMENT hDoc.
CREATE X-NODEREF hRoot. 

ASSIGN
    file_loc = file_path + file_name /* "C:\OpenEdge\workspace\DataHub\src\WebSpeed\Sample UTOX HL7.xml" */
    .

ASSIGN wellDefined = hDoc:LOAD ("file",file_loc,FALSE).

IF wellDefined = NO THEN DO:
    ASSIGN o-fail = YES.
    RETURN.
END.
/*hDoc:LOAD ("file","C:\apps\HL7\src\SS_XML_Files\18JAN17_SS_UTOX.xml",TRUE).*/
/*hDoc:LOAD("file","C:\OpenEdge\workspace\DataHub\src\WebSpeed\XMLtestDADSAMPLE.xml",TRUE).*/
/*hDoc:LOAD("file","C:\OpenEdge\workspace\DataHub\src\WebSpeed\XMLtestSIMPLE.xml",TRUE).*/
/*hDoc:LOAD("file","C:\OpenEdge\workspace\DataHub\src\WebSpeed\XMLtestMODERATE.xml",TRUE).*/
/*hDoc:LOAD("file","C:\OpenEdge\workspace\DataHub\src\WebSpeed\XMLtestCOMPLICATED.xml",TRUE).*/
/*hDoc:LOAD("file","C:\OpenEdge\workspace\DataHub\src\WebSpeed\diagnosticreport-example-f001-bloodexam(f001).xml",TRUE).*/

hDoc:GET-DOCUMENT-ELEMENT(hRoot).
                                                                                    IF ITmessages = YES THEN
                                                                                        MESSAGE "hRoot = " hRoot SKIP
                                                                                            VIEW-AS ALERT-BOX INFORMATION BUTTONS OK
                                                                                            TITLE "Inside Main Block".
ASSIGN 
    fileid = NEXT-VALUE(seq-attfile).


RUN VALUE(SEARCH("SUBfs-ucU.r")) (
    fileid,
    0,
    cnt,
  
    OUTPUT o-fileid,
    OUTPUT o-par,
    OUTPUT o-cnt,
    OUTPUT o-created,
    OUTPUT o-error
    ).

RUN VALUE(SEARCH("SUBatn-ucU.r")) (
    fileid,
    cnt,
    hRoot:NAME,
    "",
    "ROOT",

    OUTPUT o-fileid,
    OUTPUT o-cnt,
    OUTPUT o-atnname,         
    OUTPUT o-atnvalue,
    OUTPUT o-created,
    OUTPUT o-error
    ).

RUN parseXML(cnt,hRoot).

DELETE OBJECT hRoot.
DELETE OBJECT hDoc.

IF  ITmessages = YES THEN                                                                   /* 1dot1 */                         
    OUTPUT TO "C:\apps\HL7\ErrorLog\WhatTheHeck.txt".                                       /* 1dot1 */

IF ITmessages = YES THEN 
    FOR EACH fs_mstr NO-LOCK,
        EACH atn_det WHERE atn_det.atn_file_ID = fs_mstr.fs_file_ID AND 
            atn_det.atn_node_level = fs_mstr.fs_child_level NO-LOCK 
        BY fs_mstr.fs_child_level:
    
        DISPLAY fs_mstr.fs_parent_level fs_mstr.fs_child_level atn_det.atn_name atn_det.atn_value FORMAT "x(24)" atn_det.atn_type.
    
    END.    /** of 4ea. fs_mstr, etc. **/

IF  ITmessages = YES THEN                                                                   /* 1dot1 */ 
    OUTPUT CLOSE.                                                                           /* 1dot1 */

/** EOF **/
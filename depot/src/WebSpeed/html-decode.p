/*------------------------------------------------------------------------
    File        : html-decode.p
    Purpose     : To implement a function that clearly should have already been
                    implemented natively 

    Syntax      :

    Description : Decodes an encoded html string

    Author(s)   : Andrew Garver
    Created     : Wed Nov 22 06:43:13 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE INPUT PARAMETER encoded-string AS CHARACTER NO-UNDO.

DEFINE OUTPUT PARAMETER decoded-string AS CHARACTER NO-UNDO.

ASSIGN 
    decoded-string = encoded-string
    decoded-string = REPLACE(decoded-string, "&amp;lt;", "<")
    decoded-string = REPLACE(decoded-string, "&amp;gt;", ">")
    decoded-string = REPLACE(decoded-string, "&amp;amp;", "&")
    decoded-string = REPLACE(decoded-string, "&amp;quot;", "~"").
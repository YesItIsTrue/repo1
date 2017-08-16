
/*------------------------------------------------------------------------
    File        : people-layout-form.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Doug Luttrell
    Created     : Wed Oct 29 10:53:42 EDT 2014
    Notes       :
        
    <TITLE>People Layout Form</TITLE>
    <META NAME="AUTHOR" CONTENT="Doug Luttrell">
    <META NAME="VERSION" CONTENT="1.0">
    <META NAME="COPYRIGHT" CONTENT="Solsource">
    <META NAME="CREATE_DATE" CONTENT="29/Oct/14">
    <META NAME="LAST_UPDATED" CONTENT="29/Oct/14">    
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/core.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/table.css' />
    <LINK rel='stylesheet' type='text/css' href='/depot/src/HTMLContent/stylesheets/quinton2.css' />
    
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/*******************  Uncomment to see the layout without another program **********************/
DEFINE VARIABLE v-prefix        AS CHARACTER    INITIAL "Mr."                               NO-UNDO.
DEFINE VARIABLE v-firstname     AS CHARACTER    INITIAL "Harold"                            NO-UNDO.
DEFINE VARIABLE v-midname       AS CHARACTER    INITIAL "Douglas"                           NO-UNDO.
DEFINE VARIABLE v-lastname      AS CHARACTER    INITIAL "Luttrell"                          NO-UNDO.
DEFINE VARIABLE v-suffix        AS CHARACTER    INITIAL "Jr."                               NO-UNDO.
DEFINE VARIABLE v-dob           AS DATE         INITIAL 12/28/69                            NO-UNDO.
DEFINE VARIABLE v-picturepath   AS CHARACTER    INITIAL "PICTURE HERE"                      NO-UNDO.
DEFINE VARIABLE v-gender        AS LOGICAL      INITIAL YES                                 FORMAT "Male/Female" NO-UNDO.   /* Male = YES */
DEFINE VARIABLE v-company       AS CHARACTER    INITIAL "Solsource"                         NO-UNDO.
DEFINE VARIABLE v-contact       AS CHARACTER    INITIAL "Bobbi Luttrell"                    NO-UNDO.
DEFINE VARIABLE v-pri-email     AS CHARACTER    INITIAL "Doug.Luttrell@mysolsource.com"     NO-UNDO.
DEFINE VARIABLE v-sec-email     AS CHARACTER    INITIAL "Doug.Luttrell@gmail.com"           NO-UNDO.
DEFINE VARIABLE v-notes         AS CHARACTER    INITIAL "Sassy"                             NO-UNDO.

DEFINE VARIABLE ismale AS CHARACTER NO-UNDO.        /** value gets set to "CHECKED" **/
DEFINE VARIABLE isfemale AS CHARACTER NO-UNDO.      /** value gets set to "CHECKED" **/


IF get-value('h-gender') = "MALE" THEN 
    ASSIGN 
        v-gender    = YES 
        ismale      = "CHECKED"
        isfemale    = "".
ELSE IF get-value('h-gender') = "FEMALE" THEN 
    ASSIGN 
        v-gender    = NO 
        ismale      = ""
        isfemale    = "CHECKED".
ELSE
    ASSIGN 
        v-gender    = ? 
        ismale      = ""
        isfemale    = "".


/***********************************************************************************************/




/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<DIV class='table_2col'>" SKIP
    "   <TABLE>" SKIP
    "       <TR>" SKIP                                                          /** Row 1 **/
    "           <TD>Prefix</TD>" SKIP
    "           <TD>" v-prefix "</TD>" SKIP
    "           <TD>DOB</TD>" SKIP
    "           <TD>" v-dob "</TD>" SKIP
    "           <TD rowspan=7><img src='" v-picturepath "' /></TD>" SKIP
    "       </TR>" SKIP
    "       <TR>" SKIP                                                          /** Row 2 **/
    "           <TD>First Name</TD>" SKIP
    "           <TD>" v-firstname "</TD>" SKIP
    "           <TD>Age</TD>" SKIP
    "           <TD>" ((TODAY - v-dob) / 365) FORMAT "-999.9"  "</TD>" SKIP
    "       </TR>" SKIP
    "       <TR>" SKIP                                                          /** Row 3 **/
    "           <TD>Middle Name</TD>" SKIP
    "           <TD>" v-midname "</TD>" SKIP
    "           <TD>Gender</TD>" SKIP
    "           <TD>" SKIP 
    "               <INPUT TYPE='radio' name='h-gender' value='MALE' " ismale " />" SKIP
    "               <input type='radio' name='h-gender' value='FEMALE' " isfemale " />" SKIP
    "           </TD>" SKIP
    "       </TR>" SKIP
    "       <TR>" SKIP                                                          /** Row 4 **/
    "           <TD>Last Name</TD>" SKIP
    "           <TD>" v-lastname "</TD>" SKIP
    "           <TD>Company</TD>" SKIP
    "           <TD>" v-company "</TD>" SKIP
    "       </TR>" SKIP
    "       <TR>" SKIP                                                          /** Row 5 **/
    "           <TD>Suffix</TD>" SKIP
    "           <TD>" v-suffix "</TD>" SKIP
    "           <TD>Contact</TD>" SKIP
    "           <TD>" v-contact "</TD>" SKIP
    "       </TR>" SKIP
    "       <TR>" SKIP                                                          /** Row 6 **/
    "           <TD>Email</TD>" SKIP
    "           <TD>" v-pri-email "</TD>" SKIP
    "           <TD>Email 2</TD>" SKIP
    "           <TD>" v-sec-email "</TD>" SKIP
    "       </TR>" SKIP
    "       <TR>" SKIP                                                          /** Row 7 **/
    "           <TD>Notes</TD>" SKIP
    "           <TD colspan=3>" v-notes "</TD>" SKIP
    "       </TR>" SKIP
    "   </TABLE>" SKIP
    "</DIV>" SKIP.



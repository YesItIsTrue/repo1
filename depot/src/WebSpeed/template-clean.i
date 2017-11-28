
/*------------------------------------------------------------------------
    File        : template-clean.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Nov 17 12:56:20 EST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}            
"    <link rel='stylesheet' href='https://www.w3schools.com/w3css/4/w3.css'>" SKIP
"    <link rel='stylesheet' href='/depot/src/HTMLContent/stylesheets/timesheet.css'>" SKIP
"   <link rel='stylesheet' href='https://fonts.googleapis.com/css?family=Montserrat'>" SKIP
"   <link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css'>" SKIP
"   <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'>" SKIP
"   <script src='https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js'></script>" SKIP
"   <script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js'></script>" SKIP
"   <script src='https://cdnjs.cloudflare.com/ajax/libs/jquery.matchHeight/0.7.2/jquery.matchHeight-min.js'></script>" SKIP.

{&OUT}
"   <style>" SKIP
"   #reports-content ~{" SKIP
"     margin-top: 10%;" SKIP
"   ~}" SKIP
"   #maint-content ~{" SKIP
"     margin-top: 10%;" SKIP
"     min-height: 100%;" SKIP
"   ~}" SKIP
"   .page-component ~{" SKIP
"     margin-bottom: 90px;" SKIP
"   ~}" SKIP
"   </style>" SKIP.

{&OUT}
"   <script>" SKIP
"        $(function() ~{" SKIP
"           $('.col-md-4').matchHeight();" SKIP
"       ~});" SKIP
"   </script>" SKIP.

DEFINE VARIABLE i-template-clean-people-id AS INTEGER NO-UNDO.
DEFINE VARIABLE i-menu-number AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-num-items AS INTEGER INITIAL 0 NO-UNDO.
DEFINE VARIABLE i-items AS CHARACTER INITIAL "" NO-UNDO.
DEFINE VARIABLE i-template-clean-counter AS INTEGER NO-UNDO.

DEFINE BUFFER menu_mstr2 FOR menu_mstr.
DEFINE BUFFER menu_mstr3 FOR menu_mstr.
DEFINE BUFFER gud_det2 FOR gud_det.
DEFINE BUFFER gmd_det2 FOR gmd_det.
DEFINE BUFFER gud_det3 FOR gud_det.
DEFINE BUFFER gmd_det3 FOR gmd_det.

RUN VALUE(SEARCH("session-get-user-id.r")) (
    get-cookie("c-session-token"),
    OUTPUT i-template-clean-people-id
).
    
{&OUT}
"<div class='w3-padding-large'>" SKIP.

    DEFINE VARIABLE i-section-number AS INTEGER INITIAL 0 NO-UNDO.
    FOR EACH menu_mstr WHERE menu_mstr.menu_hidden = FALSE AND menu_mstr.menu_num = "{1}" NO-LOCK,
    EACH gud_det WHERE gud_det.gud_people_ID = i-template-clean-people-id NO-LOCK,
    FIRST gmd_det WHERE gmd_det.gmd_menu_num = menu_mstr.menu_num AND gmd_det.gmd_menu_select = menu_mstr.menu_select AND gmd_det.gmd_grp_id = gud_det.gud_grp_id NO-LOCK
    BREAK BY menu_mstr.menu_num BY menu_mstr.menu_select:
        IF FIRST-OF (menu_mstr.menu_select) THEN DO:
            i-section-number = i-section-number + 1.
            
            {&OUT}
            "<div id='section-" i-section-number "' class='page-component'>" SKIP
            "   <div class='section-header'><i class='" menu_mstr.menu__char01 "'></i> " menu_mstr.menu_title "</div>" SKIP
            "   <div class='row'>" SKIP.
            
            ASSIGN 
                i-items = ""
                i-num-items = 0.

            FOR EACH menu_mstr2 WHERE menu_mstr2.menu_num = (menu_mstr.menu_num + "." + STRING(menu_mstr.menu_select)) AND menu_mstr2.menu_hidden = FALSE NO-LOCK,
            EACH gud_det2 WHERE gud_det2.gud_people_ID = i-template-clean-people-id NO-LOCK,
            FIRST gmd_det2 WHERE gmd_det2.gmd_menu_num = menu_mstr2.menu_num AND gmd_det2.gmd_menu_select = menu_mstr2.menu_select AND gmd_det2.gmd_grp_id = gud_det2.gud_grp_id NO-LOCK
            BREAK BY menu_mstr2.menu_select:
                IF FIRST-OF (menu_mstr2.menu_select) THEN DO:
                    ASSIGN 
                        i-num-items = i-num-items + 1
                        i-items = IF i-items <> "" THEN "," + (menu_mstr.menu_num + "." + STRING(menu_mstr.menu_select)) ELSE (menu_mstr.menu_num + "." + STRING(menu_mstr.menu_select)).
                END. /* IF FIRST-OF (menu_mstr2.menu_select) */
            END. /* FOR EACH menu_mstr2 */
            
            IF i-num-items > 6 THEN DO:
            
                {&OUT}
                "<ul class='w3-ul w3-card-4 w3-white w3-xxlarge'>" SKIP.
    
                DO i-template-clean-counter = 1 TO NUM-ENTRIES(i-items):
                    FOR EACH menu_mstr3 WHERE menu_mstr3.menu_num = ENTRY(i-template-clean-counter, i-items) AND menu_mstr3.menu_hidden = FALSE NO-LOCK,
                    EACH gud_det3 WHERE gud_det3.gud_people_ID = i-template-clean-people-id NO-LOCK,
                    FIRST gmd_det3 WHERE gmd_det3.gmd_menu_num = menu_mstr3.menu_num AND gmd_det3.gmd_menu_select = menu_mstr3.menu_select AND gmd_det3.gmd_grp_id = gud_det3.gud_grp_id NO-LOCK
                    BREAK BY menu_mstr3.menu_title BY menu_mstr3.menu_select:
                        IF FIRST-OF (menu_mstr3.menu_select) THEN DO:
                
                            {&OUT}
                            "<a href='" menu_mstr3.menu_exprog "'><li class='w3-hover-theme'>" menu_mstr3.menu_title "<span class='w3-margin w3-right w3-xlarge'><i class='fa fa-angle-double-right'></i></span></li></a>" SKIP.
    
                        END. /* IF FIRST-OF (menu_mstr.menu_select) */
                    END. /* FOR EACH menu_mstr3 */
                END. /* DO i-template-clean-counter = 1 TO NUM-ENTRIES(i-items) */
            
                {&OUT}
                "</ul>" SKIP.
    
            END. /* IF i-num-items > 6 */
            ELSE DO:
                DO i-template-clean-counter = 1 TO NUM-ENTRIES(i-items):
                    FOR EACH menu_mstr3 WHERE menu_mstr3.menu_num = ENTRY(i-template-clean-counter, i-items) AND menu_mstr3.menu_hidden = FALSE NO-LOCK,
                    EACH gud_det3 WHERE gud_det3.gud_people_ID = i-template-clean-people-id NO-LOCK,
                    FIRST gmd_det3 WHERE gmd_det3.gmd_menu_num = menu_mstr3.menu_num AND gmd_det3.gmd_menu_select = menu_mstr3.menu_select AND gmd_det3.gmd_grp_id = gud_det3.gud_grp_id NO-LOCK
                    BREAK BY menu_mstr3.menu_title BY menu_mstr3.menu_select:
                        IF FIRST-OF (menu_mstr3.menu_select) THEN DO:
    
                            {&OUT}
                            "<a href='" menu_mstr3.menu_exprog "'> " SKIP
                            "    <div class='col-md-4'>" SKIP
                            "         <div class='w3-container w3-card-4 w3-white w3-hover-theme w3-round w3-content col-md-12'> " SKIP
                            "             <div class='component-card'> " SKIP
                            "                 <div class='icon'><i class='" menu_mstr3.menu__char01 "'></i></div> " SKIP
                            "              <h1>" menu_mstr3.menu_title "</h1> " SKIP
                            "             </div> " SKIP
                            "       </div> " SKIP
                            "   </div> " SKIP
                            "</a>" SKIP.

    
                        END. /* IF FIRST-OF (menu_mstr3.menu_select) */
                    END. /* FOR EACH menu_mstr3 */                    
                END. /* DO i-template-clean-counter = 1 TO NUM-ENTRIES(i-items) */
            END.
            
    {&OUT}
    "   </div>" SKIP
    "</div>" SKIP.
    
    END. /* IF FIRST-OF (menu_mstr.menu_select) */
END. /* FOR EACH menu_mstr */

{&OUT}
"</div>" SKIP.
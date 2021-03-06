
/*------------------------------------------------------------------------
    File        : login-header.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Oct 20 17:20:26 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
DEFINE VARIABLE i-invalid-creds-error AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE i-user-locked-error AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE i-password-expired-error AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE i-password-warning AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE i-login-success AS LOGICAL INITIAL NO NO-UNDO.
CREATE WIDGET-POOL.
    
PROCEDURE Output-Header:
    DEFINE VARIABLE username AS CHARACTER NO-UNDO.
    DEFINE VARIABLE password AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i-session-token AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i-empid AS INTEGER NO-UNDO.
    
    set-cookie(
        "c-ss-app",
        "{1}",
        ?,
        ?,
        "/",
        ?,
        ?
    ).
    
    RUN VALUE(SEARCH("session-get-user-id.r")) (
        get-cookie("c-session-token"),
        OUTPUT i-empid
    ).
    
    i-session-token = get-cookie("c-session-token").
    FIND session_det WHERE session_det.session_token = i-session-token NO-ERROR.
    IF i-session-token <> "" AND AVAILABLE(session_det) AND session_det.session_expiration > NOW THEN DO:
        FIND FIRST gud_det WHERE gud_det.gud_people_ID = i-empid AND gud_det.gud_grp_id = "RegisAdmin" NO-ERROR.
        IF AVAILABLE (gud_det) THEN DO:
           RUN VALUE(SEARCH("cookie-redirect.r")) (
                "regis-admin-portal.r"
            ).
        END.
        ELSE DO:
            FIND FIRST gud_det WHERE gud_det.gud_people_ID = i-empid AND gud_det.gud_grp_id = "RegisEmp" NO-ERROR.
            IF AVAILABLE (gud_det) THEN DO:
                RUN VALUE(SEARCH("cookie-redirect.r")) (
                    "regis-emp-portal.r"
                ).
            END.
        END. 
    END.

    ASSIGN 
        username = get-value('username')
        password = get-value('password').
    
    IF get-value('act') = "Login" THEN DO:
        /* Check the user's credentials */
        FIND usr_mstr WHERE usr_mstr.usr_name = username AND usr_mstr.usr_password = ENCODE(password) AND usr_deleted = ? NO-ERROR.
        
        /* If the credentials are good, set the user id and navigate to the menu */
        IF AVAILABLE (usr_mstr) THEN DO:
            IF usr_mstr.usr_locked = FALSE THEN DO:
                FIND FIRST sec_ctrl WHERE sec_ctrl.sec_deleted = ? NO-ERROR.
                IF NOT AVAILABLE (sec_ctrl) THEN DO:
                    RUN Login.
                    i-login-success = TRUE.
                END. /* if not available (sec_ctrl) */
                ELSE DO:
                    IF sec_ctrl.sec_password_exp <> 0 THEN DO:
                        DEFINE VARIABLE i-last-password-reset-date AS DATE NO-UNDO.
                        DEFINE VARIABLE i-password-expiry-date AS DATE NO-UNDO.
                        DEFINE VARIABLE i-password-grace-date AS DATE NO-UNDO.
                        DEFINE VARIABLE i-password-warning-date AS DATE NO-UNDO.
                        
                        ASSIGN 
                            i-last-password-reset-date = IF usr_mstr.usr_password_reset <> ? THEN usr_mstr.usr_password_reset ELSE usr_mstr.usr_create_date.
                            
                        IF i-last-password-reset-date <> ? THEN DO:
                            ASSIGN 
                                i-password-expiry-date = ADD-INTERVAL(i-last-password-reset-date, sec_ctrl.sec_password_exp, "days")
                                i-password-grace-date = ADD-INTERVAL(i-password-expiry-date, sec_ctrl.sec_password_grace, "days")
                                i-password-warning-date = ADD-INTERVAL(i-password-expiry-date, -(sec_ctrl.sec_password_warn), "days").
                                
                            IF i-password-expiry-date > TODAY THEN DO:
                                IF i-password-warning-date <= TODAY THEN
                                    i-password-warning = TRUE.
                                
                                RUN Login.
                                i-login-success = TRUE.
                            END. /* i-password-expiry-date > today */
                            ELSE DO:
                                i-password-expired-error = TRUE.
                                IF i-password-grace-date < TODAY THEN DO:
                                    ASSIGN
                                        usr_mstr.usr_locked = TRUE 
                                        usr_mstr.usr_modified_date = TODAY 
                                        usr_mstr.usr_modified_by = USERID("Core")
                                        usr_mstr.usr_prog_name = THIS-PROCEDURE:FILE-NAME
                                        i-user-locked-error = TRUE.
                                END. /* if i-password-grace-date > TODAY */
                            END.
                        END. /* if i-last-password-reset-date <> ? */
                        ELSE DO:
                            i-password-expired-error = TRUE.
                        END.
                    END. /* if sec_ctrl.sec_password_exp <> 0 */
                    ELSE DO:
                        RUN Login.
                        i-login-success = TRUE.
                    END.
                END.
            END. /* if usr_locked = false */
            ELSE DO:
                ASSIGN i-user-locked-error = TRUE.
            END.
        END. /* if available (usr_mstr) */
        ELSE DO:
            ASSIGN i-invalid-creds-error = TRUE.
        END.
    END. /* IF get-value('act') = "Login" */
END PROCEDURE.

PROCEDURE Login:
    /* Create a CLIENT-PRINCIPAL object to store the user's domain information, which links them to a tenant */
    /* Note: This is quite unnecessary until we switch over to multi-tenancy, but it doesn't hurt to have it in here now */
    DEFINE VARIABLE dbc AS HANDLE NO-UNDO.
    DEFINE VARIABLE uuid AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i-success AS LOGICAL NO-UNDO.
    
    CREATE CLIENT-PRINCIPAL dbc.
    
    /* Make sure we are getting a truly unique session id */
    uuid = REPLACE(SUBSTRING(BASE64-ENCODE(GENERATE-UUID),1,22), "+", "_").
    FIND session_det WHERE session_det.session_token = uuid NO-ERROR.
    DO WHILE AVAILABLE (session_det):
        uuid = REPLACE(SUBSTRING(BASE64-ENCODE(GENERATE-UUID),1,22), "+", "_").
        FIND session_det WHERE session_det.session_token = uuid.
    END.
    
    ASSIGN 
        dbc:USER-ID = STRING(usr_mstr.usr_people_ID)
        dbc:SESSION-ID = uuid.
        
    dbc:SEAL("").
    
    /*TODO: We'll need a way to persist the CLIENT-PRINCIPAL when we move onto multi-tenancy. I haven't figured out how to do that yet.*/
    
    /* Create a session_det record for this user's current session */
    FIND session_det WHERE session_det.session_user_id = usr_mstr.usr_people_ID NO-ERROR.
    IF NOT AVAILABLE (session_det) THEN DO:
        CREATE session_det.
        ASSIGN session_det.session_user_id = usr_mstr.usr_people_ID.
    END.

    FIND FIRST sec_ctrl WHERE sec_ctrl.sec_deleted = ? NO-ERROR.

    IF AVAILABLE (session_det) THEN
        ASSIGN
            session_det.session_token = dbc:SESSION-ID
            session_det.session_expiration = IF AVAILABLE (sec_ctrl) AND sec_ctrl.sec_cookie_exp <> 0 THEN ADD-INTERVAL(TODAY, sec_ctrl.sec_cookie_exp, "days") ELSE ADD-INTERVAL(TODAY, 100, "years").
    ELSE
        DISPLAY "Something went horribly wrong.".

    /* Store the CLIENT-PRINCIPAL's session id in a cookie to tie back to the user's info (like people_id). */
    IF AVAILABLE (sec_ctrl) THEN
        set-cookie(
            "c-session-token",
            dbc:SESSION-ID,
            IF sec_ctrl.sec_cookie_exp <> 0 THEN ADD-INTERVAL(TODAY, sec_ctrl.sec_cookie_exp, "days") ELSE ?,
            IF sec_ctrl.sec_cookie_time <> 0 THEN sec_ctrl.sec_cookie_time ELSE ?,
            "/",
            ?,
            ?
        ).
    ELSE
        set-cookie("c-session-token", dbc:SESSION-ID, ?, ?, "/", ?, ?).
END PROCEDURE.
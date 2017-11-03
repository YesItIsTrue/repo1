
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
DEFINE VARIABLE v-invalid-creds-error AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-user-locked-error AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-password-expired-error AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-password-warning AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE v-login-success AS LOGICAL INITIAL NO NO-UNDO.
CREATE WIDGET-POOL.
    
PROCEDURE Output-Header:
    DEFINE VARIABLE username AS CHARACTER NO-UNDO.
    DEFINE VARIABLE password AS CHARACTER NO-UNDO.

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
                    RUN SetUserCookie.
                    RUN SetGroupsCookie.
                    v-login-success = TRUE.
                END. /* if not available (sec_ctrl) */
                ELSE DO:
                    IF sec_ctrl.sec_password_exp <> 0 THEN DO:
                        DEFINE VARIABLE v-last-password-reset-date AS DATE NO-UNDO.
                        DEFINE VARIABLE v-password-expiry-date AS DATE NO-UNDO.
                        DEFINE VARIABLE v-password-grace-date AS DATE NO-UNDO.
                        DEFINE VARIABLE v-password-warning-date AS DATE NO-UNDO.
                        
                        ASSIGN 
                            v-last-password-reset-date = IF usr_mstr.usr_password_reset <> ? THEN usr_mstr.usr_password_reset ELSE usr_mstr.usr_create_date.
                            
                        IF v-last-password-reset-date <> ? THEN DO:
                            ASSIGN 
                                v-password-expiry-date = ADD-INTERVAL(v-last-password-reset-date, sec_ctrl.sec_password_exp, "days")
                                v-password-grace-date = ADD-INTERVAL(v-password-expiry-date, sec_ctrl.sec_password_grace, "days")
                                v-password-warning-date = ADD-INTERVAL(v-password-expiry-date, -(sec_ctrl.sec_password_warn), "days").
                                
                            IF v-password-expiry-date > TODAY THEN DO:
                                IF v-password-warning-date <= TODAY THEN
                                    v-password-warning = TRUE.
                                
                                RUN SetUserCookie.
                                RUN SetGroupsCookie.
                                v-login-success = TRUE.
                            END. /* v-password-expiry-date > today */
                            ELSE DO:
                                v-password-expired-error = TRUE.
                                IF v-password-grace-date < TODAY THEN DO:
                                    ASSIGN
                                        usr_mstr.usr_locked = TRUE 
                                        usr_mstr.usr_modified_date = TODAY 
                                        usr_mstr.usr_modified_by = USERID("Core")
                                        usr_mstr.usr_prog_name = THIS-PROCEDURE:FILE-NAME
                                        v-user-locked-error = TRUE.
                                END. /* if v-password-grace-date > TODAY */
                            END.
                        END. /* if v-last-password-reset-date <> ? */
                        ELSE DO:
                            v-password-expired-error = TRUE.
                        END.
                    END. /* if sec_ctrl.sec_password_exp <> 0 */
                    ELSE DO:
                        RUN SetUserCookie.
                        RUN SetGroupsCookie.
                        v-login-success = TRUE.
                    END.
                END.
            END. /* if usr_locked = false */
            ELSE DO:
                ASSIGN v-user-locked-error = TRUE.
            END.
        END. /* if available (usr_mstr) */
        ELSE DO:
            ASSIGN v-invalid-creds-error = TRUE.
        END.
    END.  
END PROCEDURE.

PROCEDURE SetGroupsCookie:
    DEFINE VARIABLE v-group-ids AS CHARACTER NO-UNDO.
    FOR EACH gud_det WHERE gud_det.gud_people_ID = usr_mstr.usr_people_ID AND gud_det.gud_deleted = ? NO-LOCK:
        ASSIGN v-group-ids = v-group-ids + IF v-group-ids <> "" THEN "," + gud_det.gud_grp_id ELSE gud_det.gud_grp_id. 
    END.
    IF v-group-ids <> "" THEN DO:
        FIND FIRST sec_ctrl WHERE sec_ctrl.sec_deleted = ? NO-ERROR.
        IF AVAILABLE (sec_ctrl) THEN
            set-cookie(
            "c-groups", 
            v-group-ids, 
            IF sec_ctrl.sec_cookie_exp <> 0 THEN ADD-INTERVAL(TODAY, sec_ctrl.sec_cookie_exp, "days") ELSE ?, 
            IF sec_ctrl.sec_cookie_time <> 0 THEN sec_ctrl.sec_cookie_time ELSE ?, 
            "/", 
            ?, 
            ?
        ).
        ELSE
            set-cookie("c-groups", v-group-ids, ?, ?, "/", ?, ?).
    END.
END PROCEDURE.

PROCEDURE SetUserCookie:
    FIND FIRST sec_ctrl WHERE sec_ctrl.sec_deleted = ? NO-ERROR.
    IF AVAILABLE (sec_ctrl) THEN 
        set-cookie(
            "c-user-id",
            STRING(usr_mstr.usr_people_ID), 
            IF sec_ctrl.sec_cookie_exp <> 0 THEN ADD-INTERVAL(TODAY, sec_ctrl.sec_cookie_exp, "days") ELSE ?, 
            IF sec_ctrl.sec_cookie_time <> 0 THEN sec_ctrl.sec_cookie_time ELSE ?, 
            "/", 
            ?, 
            ?
        ).
    ELSE
        set-cookie("c-user-id", STRING(usr_mstr.usr_people_ID), ?, ?, "/", ?, ?).
END PROCEDURE.
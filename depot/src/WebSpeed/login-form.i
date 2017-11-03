/*------------------------------------------------------------------------
    File        : login-form.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Oct 20 17:04:44 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
    "<style>" SKIP
    "   .error-msg ~{color: red;~}" SKIP
    "   .w3-select ~{" SKIP
    "       margin: 5px 0px 10px 0px;" SKIP
    "       padding-left: 10px;" SKIP
    "   ~}" SKIP
    "   .center-buttons ~{text-align: center~}" SKIP
    "   .create-account ~{" SKIP
    "       float: right;" SKIP
    "       position: relative;" SKIP
    "       top: 15px;" SKIP
    "       right: 10px;" SKIP
    "   ~}" SKIP
    "</style>" SKIP.

    DEFINE VARIABLE v-act AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-username AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-password AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-last-password-reset-date2 AS DATE. /* This is some voodoo with the cookies. Even though this v-last-password-reset-date is defined above, we can't reuse it here*/
    DEFINE VARIABLE v-user-id AS CHARACTER NO-UNDO.
    
    ASSIGN 
        v-act = get-value('act')
        v-username = get-value('username')
        v-password = get-value('password').
        
    FIND usr_mstr WHERE usr_mstr.usr_name = v-username AND usr_mstr.usr_password = ENCODE(v-password) AND usr_deleted = ? NO-ERROR.
    IF AVAILABLE (usr_mstr) THEN
        ASSIGN v-user-id = STRING(usr_mstr.usr_people_ID).
    
    IF v-login-success = TRUE THEN DO:
        IF v-password-warning = FALSE THEN DO:
            {&OUT}
                "<script>" SKIP
                "       (function() ~{" SKIP
                "           window.location = '{1}';" SKIP
                "       ~})();" SKIP
                "</script>" SKIP.
        END.
        ELSE DO:
            {&OUT}
                "<script>" SKIP
                "  $(document).ready(function() ~{" SKIP
                "      $('#warning-modal').show();" SKIP
                "      $('#no-reset-btn').click(function() ~{" SKIP
                "          window.location = '{1}';" SKIP
                "      ~});" SKIP
                "  ~});" SKIP
                "</script>" SKIP
                "<div id='warning-modal' class='w3-modal'>" SKIP
                "   <div class='w3-modal-content w3-card-4 w3-animate-top'>" SKIP
                "       <div class='w3-container'>" SKIP
                "           <center>" SKIP
                "               <h2>Warning!</h2>" SKIP
                "               <h4>Your password will expire soon. Please reset it when you get the chance.</h4>" SKIP
                "           </center>" SKIP
                "           <form action='password-reset-form.r' method='post'>" SKIP
                "               <input type='hidden' name='h-user-id' value='`v-user-id`'/>" SKIP
                "               <div class='center-buttons'>" SKIP
                "                   <button type='submit' class='w3-btn-block w3-green w3-round' style='max-width:250px;'>I'll reset it now</button>" SKIP
                "                   <button id='no-reset-btn' type='button' class='w3-btn-block w3-dark-grey w3-round' style='max-width:250px;'>Continue without resetting</button>" SKIP
                "               </div>" SKIP
                "           </form>" SKIP
                "       </div>" SKIP
                "   </div>" SKIP
                "</div>" SKIP.
        END.
    END.
    ELSE IF v-password-expired-error = TRUE AND v-user-locked-error = FALSE THEN DO:
        {&OUT}
            "<script>" SKIP
            "       $(document).ready(function() ~{" SKIP
            "           $('#expired-modal').show();" SKIP
            "       ~});" SKIP
            "</script>" SKIP
            "<div id='expired-modal' class='w3-modal'>" SKIP
            "   <div class='w3-modal-content w3-card-4 w3-animate-top'>" SKIP
            "           <div class='w3-container'>" SKIP
            "           <center>" SKIP
            "               <h2>Password Expired</h2>" SKIP
            "               <p>Your password has expired. In order to continue, please update it.</p>" SKIP
            "           </center>" SKIP
            "           <form action='password-reset-form.r' method='post'>" SKIP
            "               <input type='hidden' name='h-user-id' value='`v-user-id`'/>" SKIP
            "               <div class='center-buttons'>" SKIP
            "                       <button type='submit' class='w3-btn-block w3-green w3-round' style='max-width:250px;'>Ok</button>" SKIP
            "               </div>" SKIP
            "           </form>" SKIP
            "           </div>" SKIP
            "   </div>" SKIP
            "</div>" SKIP.
    END.
    {&OUT}
        "<div class='w3-container w3-card-4 w3-light-grey w3-round w3-content' style='max-width:1000px; position:relative; top:20%;'>" SKIP
        "   <a href='register-user.r' class='create-account'>Create an account</a><br/>" SKIP
        "   <div class='w3-center'>" SKIP
        "       <div id='company-logo'>" SKIP
        "           <img class='w3-margin-top w3-image' src='{2}' alt='Company Logo'>" SKIP
        "       </div>" SKIP.
         
    IF v-invalid-creds-error = YES THEN 
        {&OUT}
        "       <p class='error-msg'>Either your username or password is incorrect. Please try again.</p>" SKIP.
    IF v-user-locked-error = YES THEN 
        {&OUT}
        "       <p class='error-msg'>Your account has been locked. Please contact your administrator to gain access.</p>" SKIP.          
            
    {&OUT}        
        "   </div>" SKIP
        "   <form class='login-form' method=''post''>" SKIP
        "      <div class='w3-row'>" SKIP
        "          <label>Username</label>" SKIP
        "          <input type='text' name='username' class='w3-border w3-round-large w3-select' required/>" SKIP         
        "          <label>Password</label>" SKIP
        "          <input type='password' name='password' class='w3-border w3-round-large w3-select' required/>" SKIP
        "      </div>" SKIP 
        "      <div class='w3-row-padding w3-margin'>" SKIP
        "          <div class='w3-center'>" SKIP
        "              <center><button type='submit' name='act' value='Login' class='w3-btn w3-block w3-green w3-round' style='max-width:400px;'><b>Login</b></button></center>" SKIP
        "              <br/><br/>" SKIP
        "              <a href='forgot-password-page.r'>Forgot your password?</a>" SKIP
        "          </div>" SKIP
        "      </div>" SKIP
        "   </form>" SKIP
        "</div>" SKIP. 
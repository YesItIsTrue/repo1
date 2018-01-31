
/*------------------------------------------------------------------------
    File        : AJAX-address-picker.p
    Purpose     : Endpoint for address select2

    Syntax      :

    Description : Returns address data dynamically based on address line 1

    Author(s)   : Andrew Garver
    Created     : Fri Sep 01 23:08:59 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
USING progress.json.objectmodel.*.
 
CREATE WIDGET-POOL.
DEF VAR cOut AS LONGCHAR.

{src/web2/wrap-cgi.i}
 
RUN process-web-request.
PROCEDURE createJson :
    DEFINE VARIABLE jObj AS jsonObject.
    
    DEFINE VARIABLE v-clientid       LIKE Proj_Mstr.Proj_client_ID        NO-UNDO.
    DEFINE VARIABLE v-projname       LIKE Proj_Mstr.Proj_name     NO-UNDO.
    DEFINE VARIABLE v-start-date AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-end-date AS CHARACTER NO-UNDO.
        
    ASSIGN
        jObj = NEW jsonObject()
        v-clientid = INTEGER(html-encode(get-value("clientID")))
        v-projname = html-encode(get-value("projName")).
        
    FIND Proj_Mstr WHERE Proj_Mstr.Proj_client_ID = v-clientid AND Proj_Mstr.Proj_name = v-projname NO-ERROR.
    IF AVAILABLE(Proj_Mstr) THEN DO:
        RUN VALUE(SEARCH("subr_YY_to_CCYY.r")) (                                   
            Proj_Mstr.Proj_start_date,                                                                 
            OUTPUT v-start-date                                                               
        ).
        
        RUN VALUE(SEARCH("subr_YY_to_CCYY.r")) (                                   
            Proj_Mstr.Proj_end_date,                                                                 
            OUTPUT v-end-date                                                               
        ).
        
        jObj:add("success", "true").
        jObj:add("hourAdjustment", Proj_Mstr.Proj_price_adj).
        jObj:add("priceAdjustment", Proj_Mstr.Proj_price_adj_dollar).
        jObj:add("estProjHours", Proj_Mstr.Proj_est_hours).
        jObj:add("curProjHours", Proj_Mstr.Proj_curr_hours).
        jObj:add("estPriceTotal", Proj_Mstr.Proj_est_total).
        jObj:add("curPriceTotal", Proj_Mstr.Proj_curr_total).
        jObj:add("startDate", v-start-date).
        jObj:add("endDate", v-end-date).
        jObj:add("sortOrder", Proj_Mstr.Proj_sort).
        jObj:add("adminOnly", Proj_Mstr.Proj_admin_only).
    END.
    ELSE
        jObj:add("error", "No project found with clientid:" + STRING(v-clientid) + " and projname: " + v-projname).
        
    jObj:write(OUTPUT cOut).
END PROCEDURE.
 
PROCEDURE outputHeader :
    output-content-type ("application/json":U).  
END PROCEDURE.
 
PROCEDURE process-web-request :
    RUN outputHeader.
    RUN createJson.
 
    {&OUT} STRING(cOut).
END PROCEDURE.
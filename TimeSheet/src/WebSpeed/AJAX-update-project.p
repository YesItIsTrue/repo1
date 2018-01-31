
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
    
    DEFINE VARIABLE clientid            LIKE Proj_Mstr.Proj_client_ID           NO-UNDO.
    DEFINE VARIABLE projname            LIKE Proj_Mstr.Proj_name                NO-UNDO.
    DEFINE VARIABLE price-adj           LIKE Proj_Mstr.Proj_price_adj           NO-UNDO.
    DEFINE VARIABLE price-adj-dollar    LIKE Proj_Mstr.Proj_price_adj_dollar    NO-UNDO.
    DEFINE VARIABLE est-total           LIKE Proj_Mstr.Proj_est_total           NO-UNDO.
    DEFINE VARIABLE est-hours           LIKE Proj_Mstr.Proj_est_hours           NO-UNDO.
    DEFINE VARIABLE curr-total          LIKE Proj_Mstr.Proj_curr_total          NO-UNDO.
    DEFINE VARIABLE curr-hours          LIKE Proj_Mstr.Proj_curr_hours          NO-UNDO.
    DEFINE VARIABLE sortorder           LIKE Proj_Mstr.Proj_sort                NO-UNDO.
    
    DEFINE VARIABLE disp-start          AS CHARACTER                            NO-UNDO.
    DEFINE VARIABLE startdate           LIKE Proj_Mstr.Proj_start_date          NO-UNDO.
    DEFINE VARIABLE disp-end            AS CHARACTER                            NO-UNDO.
    DEFINE VARIABLE enddate             LIKE Proj_Mstr.Proj_end_date            NO-UNDO.
    
    DEFINE VARIABLE o-create      AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-update      AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-avail       AS LOGICAL                                NO-UNDO. 
    DEFINE VARIABLE o-successful  AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-startdate   AS CHARACTER                              NO-UNDO. 
    DEFINE VARIABLE o-fpat-ran    AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-clientid    AS INTEGER                                NO-UNDO.
    DEFINE VARIABLE o-projname    AS CHARACTER                              NO-UNDO.
    
    DEFINE VARIABLE admin-only    LIKE Proj_Mstr.proj_admin_only            NO-UNDO.
    DEFINE VARIABLE admin-control AS LOGICAL INITIAL YES                    NO-UNDO.
    
    ASSIGN 
        jObj                = NEW jsonObject() 
        clientid            = INTEGER(html-encode(get-value("h-clientid")))
        projname            = html-encode(get-value("h-projname"))
        price-adj           = DECIMAL(html-encode(get-value("h-price-adj")))
        price-adj-dollar    = DECIMAL(html-encode(get-value("h-price-adj-dollar")))
        est-total           = DECIMAL(html-encode(get-value("h-est-total")))
        est-hours           = DECIMAL(html-encode(get-value("h-est-hours")))
        curr-total          = DECIMAL(html-encode(get-value("h-curr-total")))
        curr-hours          = DECIMAL(html-encode(get-value("h-curr-hours")))
        sortorder           = INTEGER(html-encode(get-value("h-sortorder")))
        admin-only          = IF get-value("h-admin-only") = "YES" THEN YES ELSE NO
        disp-start    = get-value("html5-start")
        disp-end      = get-value("html5-end")
        .
        
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                           
        disp-start,                                                               
        OUTPUT startdate                                                             
        ).                                                                          
    
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                   
        disp-end,                                                                 
        OUTPUT enddate                                                               
        ).    
        
    IF clientid = 9999999 THEN DO:
        
        FOR EACH Client_Mstr NO-LOCK: 
          
            RUN VALUE(SEARCH("SUBproj-ucU.r")) (    
                Client_Mstr.Client_people_ID,  /*Proj_Mstr.Proj_client_ID       */
                projname,                      /*Proj_Mstr.Proj_name            */
                price-adj,                     /*Proj_Mstr.Proj_price_adj       */
                price-adj-dollar,              /*Proj_Mstr.Proj_price_adj_dollar*/
                startdate,                     /*Proj_Mstr.Proj_start_date      */
                enddate,                       /*Proj_Mstr.Proj_end_date        */
                est-total,                     /*Proj_Mstr.Proj_est_total       */
                curr-total,                    /*Proj_Mstr.Proj_curr_total      */             
                est-hours,                     /*Proj_Mstr.Proj_est_hours       */
                curr-hours,                    /*Proj_Mstr.Proj_curr_hours      */              
                admin-only,                    /*Proj_Mstr.Proj_admin_only      */
                sortorder,                     /*Proj_Mstr.Proj_sort            */
    
                OUTPUT o-clientid,                  
                OUTPUT o-projname,
                OUTPUT o-startdate,                            
                OUTPUT o-create,                  
                OUTPUT o-update,                   
                OUTPUT o-avail,                  
                OUTPUT o-successful
                ).    

        END.                
        
                                                                                                 
    END. 
    ELSE DO:  
                                                                                                                    
        RUN VALUE(SEARCH("SUBproj-ucU.r")) (    
            clientid,                   /*Proj_Mstr.Proj_client_ID       */
            projname,                   /*Proj_Mstr.Proj_name            */
            price-adj,                  /*Proj_Mstr.Proj_price_adj       */
            price-adj-dollar,           /*Proj_Mstr.Proj_price_adj_dollar*/
            startdate,                  /*Proj_Mstr.Proj_start_date      */
            enddate,                    /*Proj_Mstr.Proj_end_date        */
            est-total,                  /*Proj_Mstr.Proj_est_total       */
            curr-total,                 /*Proj_Mstr.Proj_curr_total      */             
            est-hours,                  /*Proj_Mstr.Proj_est_hours       */
            curr-hours,                 /*Proj_Mstr.Proj_curr_hours      */              
            admin-only,                 /*Proj_Mstr.Proj_admin_only      */
            sortorder,                     /*Proj_Mstr.Proj_sort            */

            OUTPUT o-clientid,                  
            OUTPUT o-projname,
            OUTPUT o-startdate,                            
            OUTPUT o-create,                  
            OUTPUT o-update,                   
            OUTPUT o-avail,                  
            OUTPUT o-successful
            ).  
    END.    
    
    IF o-successful = YES THEN DO:
        jObj:add("success", "true").
        jObj:add("clientId", o-clientid).
        jObj:add("projName", o-projname).
        jObj:add("startDate", o-startdate).
    END.
    ELSE DO:
        jObj:add("error", "Something went wrong while creating that project. Please contact customer support.").
    END.
        
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
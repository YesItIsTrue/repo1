/*------------------------------------------------------------------------
    File        : AJAX-check-email-availability.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri Oct 17 10:43:53 EDT 2017
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
    DEF VAR jObj AS jsonObject.
    jObj = NEW jsonObject().
    
    /* Begin logic */
    DEFINE VARIABLE clientid        LIKE Client_Mstr.Client_people_ID       NO-UNDO.
    DEFINE VARIABLE clientabbv      LIKE Client_Mstr.Client_abbv            NO-UNDO.
    DEFINE VARIABLE price-adj       LIKE Client_Mstr.Client_price_adj       NO-UNDO.
    DEFINE VARIABLE zone            LIKE Client_Mstr.Client_zone            NO-UNDO.
    DEFINE VARIABLE lds             LIKE Client_Mstr.Client_LDS             NO-UNDO.
    DEFINE VARIABLE spec-disc       LIKE Client_Mstr.Client_spec_disc       NO-UNDO.
    DEFINE VARIABLE spec-disc-notes LIKE Client_Mstr.Client_spec_disc_notes NO-UNDO.
    DEFINE VARIABLE translation     LIKE Client_Mstr.Client_trans_def       NO-UNDO.
    DEFINE VARIABLE profit-margin   LIKE Client_Mstr.Client_def_profit_margin NO-UNDO.
    
    DEFINE VARIABLE firstname       LIKE people_mstr.people_firstname       NO-UNDO.
    DEFINE VARIABLE lastname        LIKE people_mstr.people_lastname        NO-UNDO.
    DEFINE VARIABLE company         LIKE people_mstr.people_company         NO-UNDO.
    DEFINE VARIABLE gender          LIKE people_mstr.people_gender          NO-UNDO. 
    DEFINE VARIABLE homephone       LIKE people_mstr.people_homephone       NO-UNDO.
    DEFINE VARIABLE cellphone       LIKE people_mstr.people_cellphone       NO-UNDO.
    DEFINE VARIABLE workphone       LIKE people_mstr.people_workphone       NO-UNDO.
    DEFINE VARIABLE workemail       LIKE people_mstr.people_email           NO-UNDO.
    DEFINE VARIABLE otheremail      LIKE people_mstr.people_email2          NO-UNDO.   
    
    DEFINE VARIABLE addr1           LIKE addr_mstr.addr_addr1               NO-UNDO.
    DEFINE VARIABLE addr2           LIKE addr_mstr.addr_addr2               NO-UNDO.
    DEFINE VARIABLE addr3           LIKE addr_mstr.addr_addr3               NO-UNDO.
    DEFINE VARIABLE city            LIKE addr_mstr.addr_city                NO-UNDO.
    DEFINE VARIABLE state           LIKE addr_mstr.addr_stateprov           NO-UNDO.
    DEFINE VARIABLE zip             LIKE addr_mstr.addr_zip                 NO-UNDO.
    DEFINE VARIABLE cntry           LIKE addr_mstr.addr_country             NO-UNDO.
    DEFINE VARIABLE addrid          LIKE addr_mstr.addr_id                  NO-UNDO.
    
    DEFINE VARIABLE act             AS CHARACTER                            NO-UNDO.
    
    DEFINE VARIABLE disp-start      AS CHARACTER                            NO-UNDO.
    DEFINE VARIABLE startdate       LIKE Client_Mstr.Client_start_date      NO-UNDO.
    DEFINE VARIABLE disp-end        AS CHARACTER                            NO-UNDO.
    DEFINE VARIABLE enddate         LIKE Client_Mstr.Client_end_date        NO-UNDO.
    
    DEFINE VARIABLE addrline      AS CHARACTER                              NO-UNDO.   
    DEFINE VARIABLE x             AS INTEGER                                NO-UNDO.
    DEFINE VARIABLE isdisabled    AS CHARACTER                              NO-UNDO.
    
    DEFINE VARIABLE clientname    AS CHARACTER                              NO-UNDO.
    DEFINE VARIABLE lastnamehold  AS CHARACTER                              NO-UNDO.
    DEFINE VARIABLE progname      AS CHARACTER                              NO-UNDO.
    
    DEFINE VARIABLE error-count   AS INTEGER                                NO-UNDO.
    
    DEFINE VARIABLE o-create      AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-update      AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-avail       AS LOGICAL                                NO-UNDO. 
    DEFINE VARIABLE o-successful  AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-error       AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-emph-action AS CHARACTER                              NO-UNDO.
    DEFINE VARIABLE o-fpat-ran    AS LOGICAL                                NO-UNDO.
    DEFINE VARIABLE o-addrid      AS INTEGER                                NO-UNDO.
    DEFINE VARIABLE o-clientid    AS INTEGER                                NO-UNDO.
    
    DEFINE VARIABLE pass-act       AS CHARACTER                             NO-UNDO.
    
    DEFINE BUFFER contact_buff FOR people_mstr. 
    
    ASSIGN 
        clientid        = INTEGER(html-encode(get-value("h-clientid")))
        clientabbv      = html-encode(get-value("h-clientabbv"))
        price-adj       = DECIMAL(html-encode(get-value("h-price-adj")))
        zone            = INTEGER(html-encode(get-value("h-zone")))
        profit-margin   = DECIMAL(html-encode(get-value("h-profit-margin")))
        lds             = IF html-encode(get-value("h-lds")) = "yes" THEN YES ELSE NO
        translation     = html-encode(get-value("h-translation"))
        spec-disc       = DECIMAL(html-encode(get-value("h-spec-disc")))
        spec-disc-notes = html-encode(get-value("h-spec-disc-notes"))
        homephone   = html-encode(get-value("h-homephone"))
        cellphone   = html-encode(get-value("h-cellphone"))
        workphone   = html-encode(get-value("h-workphone"))
        workemail   = html-encode(get-value("h-workemail"))
        otheremail  = html-encode(get-value("h-otheremail"))
        company     = html-encode(get-value("h-company"))
        gender      = IF html-encode(get-value("h-gender")) = "YES" THEN YES ELSE NO    
        firstname = html-encode(get-value("h-firstname"))
        lastname  = html-encode(get-value("h-lastname"))
        
        addr1   = html-encode(get-value("h-addr1"))
        addr2   = html-encode(get-value("h-addr2"))
        addr3   = html-encode(get-value("h-addr3"))
        city    = html-encode(get-value("h-city"))
        state   = html-encode(get-value("h-state"))
        cntry   = html-encode(get-value("h-cntry"))
        addrid  = INTEGER(html-encode(get-value("h-address-id")))
        
        act           = html-encode(get-value("h-act"))
        lastnamehold  = html-encode(get-value("h-lastnamehold"))
        disp-start    = html-encode(get-value("html5-start"))
        disp-end      = html-encode(get-value("html5-end"))
        progname      = SUBSTRING(THIS-PROCEDURE:FILE-NAME,R-INDEX(THIS-PROCEDURE:FILE-NAME,"\") + 1)
        .
        
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                           
        disp-start,                                                               
        OUTPUT startdate                                                             
        ).                                                                          
    
    RUN VALUE(SEARCH("subr_CCYY_to_YY.r")) (                                   
        disp-end,                                                                 
        OUTPUT enddate                                                               
        ).          
        
        DISPLAY addrid.
        
    RUN VALUE(SEARCH("SUBpeop-ucU.r")) (
            clientid,               /*people_mstr.people_id       */
            firstname,              /*people_mstr.people_firstname*/
            "",                     /*people_mstr.people_midname  */
            lastname,               /*people_mstr.people_lastname */
            "",                     /*people_mstr.people_prefix   */
            "",                     /*people_mstr.people_suffix   */ 
            company,                /*people_mstr.people_company  */
            gender,                 /*people_mstr.people_gender   */
            homephone,              /*people_mstr.people_homephone*/
            workphone,              /*people_mstr.people_workphone*/
            cellphone,              /*people_mstr.people_cellphone*/
            "",                     /*people_mstr.people_fax      */
            workemail,              /*people_mstr.people_email    */
            otheremail,             /*people_mstr.people_email2   */
            addrid,                 /*people_mstr.people_addr_id  */
            "",                     /*people_mstr.people_contact  */
            ?,                      /*people_mstr.people_DOB      */
            "",                     /*people_mstr.people_second_addr_ID   */
            "",                     /*people_mstr.people_prefname         */                   
            "",                     /*people_mstr.people_title            */
            OUTPUT clientid,
            OUTPUT o-create, 
            OUTPUT o-update,
            OUTPUT o-avail,
            OUTPUT o-successful
            ).          
            
        IF o-successful = NO THEN DO:
            jObj:add("error", "Error updating people record with SUBpeop-ucU.").
            RETURN.
        END.
                                                                                           
        RUN VALUE(SEARCH("SUBclient-ucU.r")) (    
            clientid,               /*Client_Mstr.Client_people_ID      */
            clientabbv,             /*Client_Mstr.Client_abbv           */
            price-adj,              /*Client_Mstr.Client_price_adj      */
            zone,                   /*Client_Mstr.Client_zone           */
            lds,                    /*Client_Mstr.Client_LDS            */
            spec-disc,              /*Client_Mstr.Client_spec_disc      */
            spec-disc-notes,        /*Client_Mstr.Client_spec_disc_notes*/
            startdate,              /*Client_Mstr.Client_start_date     */
            enddate,                /*Client_Mstr.Client_end_date       */
            translation,            /*Client_Mstr.Client_trans_def      */
            profit-margin,          /*Client_Mstr.Client_def_profit_margin */

            OUTPUT clientid,         
            OUTPUT o-create,                  
            OUTPUT o-update,                   
            OUTPUT o-avail,                  
            OUTPUT o-successful,
            OUTPUT o-error
            ).         
            
        IF o-successful = NO THEN DO:
            jObj:add("error", "Error updating client record with SUBclient-ucU.").
            RETURN.
        END.
                                                                                                                                         
        RUN VALUE(SEARCH("SUBcust-ucU.r")) (
            clientid,               /*people_mstr.people_id       */
            "",                     /*cust_mstr.cust_card_nbr     */
            0,                      /*cust_mstr.cust_card_seccode */
            "",                     /*cust_mstr.cust_card_type    */
            0,                      /*cust_mstr.cust_card_expmonth*/
            0,                      /*cust_mstr.cust_card_expyear */
            
            OUTPUT clientid,         
            OUTPUT o-create,            
            OUTPUT o-update,            
            OUTPUT o-error,             
            OUTPUT o-successful
            ).      
            
        IF o-successful = NO THEN DO:
            jObj:add("error", "Error updating customer record with SUBcust-ucU.").
            RETURN.
        END.   
        
        IF o-successful THEN 
            jObj:add("success", "true").
    /* End logic */
 
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
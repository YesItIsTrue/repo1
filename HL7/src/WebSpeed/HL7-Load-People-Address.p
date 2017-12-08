 
/*------------------------------------------------------------------------
    File        : HL7-Load-People-Address.p
    Purpose     : Load/Update the addr_mstr from XML data.  

    Description : 

    Author(s)   : Harold Luttrell, Sr.
    Created     : Jan 14, 2017.
    
    Revision History:        
    -----------------
    1.0 - written by Harold LUTTRELL on 14/Jan/17.  Original version.  
          
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

{XML_TT_Address_Data.i}.        /* XML Extraction Address Data to Load into Progress. */
{XML_TT_People_Data.i}.         /*  XML Extraction People Data to Load into Progress. */    
{XML_TT_PeopID_Basic_Data.i}.   /* XML Extraction People ID to be used in the XML-SUB- programs.p. */   
{Logs_Rpts_Paths_Folders.i}.    /* Logs/Reports folder path. */ 

{E-Mail_definations.i}.  

DEFINE INPUT PARAMETER  i-people-id           LIKE people_mstr.people_id    NO-UNDO.
DEFINE INPUT PARAMETER  i-Admin-Update-OverRyde AS LOGICAL  INITIAL NO      NO-UNDO.

DEFINE OUTPUT PARAMETER o-addr-id             LIKE addr_mstr.addr_id        NO-UNDO.
DEFINE OUTPUT PARAMETER o-addr-load-error     AS LOGICAL INITIAL NO         NO-UNDO.
DEFINE OUTPUT PARAMETER o-addr-error-message  AS CHARACTER  FORMAT "x(200)" NO-UNDO.
                        
/* ***  Country find output info.                                        *** */
DEFINE VARIABLE  o-fcountry-ISO          LIKE country_mstr.Country_ISO      NO-UNDO. 
DEFINE VARIABLE  o-fcountry-error        AS LOGICAL                         NO-UNDO.
/* ***  State find output info.                                          *** */
DEFINE VARIABLE  o-fstate-ISO            LIKE state_mstr.state_ISO          NO-UNDO.
DEFINE VARIABLE  o-fstate-error          AS LOGICAL                         NO-UNDO.

/* ***  Address find output info.                                        *** */
DEFINE VARIABLE  o-faddr-ran     AS LOGICAL INITIAL NO                      NO-UNDO.
/* ***  Address update output info.                                      *** */
DEFINE VARIABLE  o-ucaddr-id         LIKE addr_mstr.addr_id                 NO-UNDO.
DEFINE VARIABLE  o-ucaddr-create     AS LOGICAL INITIAL NO                  NO-UNDO.
DEFINE VARIABLE  o-ucaddr-update     AS LOGICAL INITIAL NO                  NO-UNDO.
DEFINE VARIABLE  o-ucaddr-avail      AS LOGICAL INITIAL YES                 NO-UNDO.
DEFINE VARIABLE  o-ucaddr-successful AS LOGICAL INITIAL NO                  NO-UNDO.

/* ***  pal-list parameters.                                              *** */
DEFINE VARIABLE  o-requestedkey      LIKE pal_list.pal_people_ID NO-UNDO.
DEFINE VARIABLE  o-create            AS LOGICAL INITIAL NO                  NO-UNDO.
DEFINE VARIABLE  o-update            AS LOGICAL INITIAL NO                  NO-UNDO.
DEFINE VARIABLE  o-avail             AS LOGICAL INITIAL YES                 NO-UNDO.
DEFINE VARIABLE  o-successful        AS LOGICAL INITIAL NO                  NO-UNDO.

/* Counters and Stuff. */
DEFINE VARIABLE arecordsprocessed           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE Address_Mstr_created_kount  AS INTEGER                      NO-UNDO.
DEFINE VARIABLE Address_Mstr_updated_kount  AS INTEGER                      NO-UNDO.
DEFINE VARIABLE Address_Mstr_billedto_kount AS INTEGER                      NO-UNDO.
DEFINE VARIABLE People_Mstr_updated_kount   AS INTEGER                      NO-UNDO.   
DEFINE VARIABLE NO_address_kount            AS INTEGER                      NO-UNDO.
DEFINE VARIABLE Address_NOT_Equal_Error_kount AS INTEGER                    NO-UNDO.
DEFINE VARIABLE BadBState-kount             AS INTEGER                      NO-UNDO.
DEFINE VARIABLE BadBCountry-kount           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE BlankState-kount            AS INTEGER                      NO-UNDO.
DEFINE VARIABLE Address_Discrepancy_kount   AS INTEGER                      NO-UNDO.

DEFINE VARIABLE h-country_iso           LIKE country_mstr.country_ISO       NO-UNDO.
DEFINE VARIABLE h-state_iso             LIKE state_mstr.state_ISO           NO-UNDO. 
DEFINE VARIABLE h-bill-type             LIKE addr_mstr.addr_type            NO-UNDO.  
DEFINE VARIABLE h-RPT-message           AS CHARACTER FORMAT "x(60)"         NO-UNDO.  
DEFINE VARIABLE data-info               AS CHARACTER FORMAT "x(8)"          NO-UNDO.
DEFINE VARIABLE h-blank                 AS CHARACTER FORMAT "x(1)"          NO-UNDO.
DEFINE VARIABLE o-addrdiscrep_ID        LIKE addr_mstr.addr_id              NO-UNDO.                 
DEFINE VARIABLE h-full-data             AS CHARACTER                        NO-UNDO.
DEFINE VARIABLE did-full-name-already-print AS LOGICAL INITIAL NO           NO-UNDO.
DEFINE VARIABLE no-update               AS LOGICAL INITIAL NO               NO-UNDO.

DEFINE VARIABLE Full-TT-XML     AS CHARACTER FORMAT "x(55)"                 NO-UNDO.
DEFINE VARIABLE Full-Name       AS CHARACTER FORMAT "X(55)"                 NO-UNDO.
DEFINE VARIABLE Full-DOB        AS CHARACTER FORMAT "99/99/9999"            NO-UNDO.
DEFINE VARIABLE Full-Addr       AS CHARACTER FORMAT "X(55)"                 NO-UNDO.

DEFINE VARIABLE ITdisplay               AS LOGICAL INITIAL NO           NO-UNDO. 

/* ********************  Preprocessor Definitions  ******************** */
 
DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)"                    NO-UNDO.              
ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1). 

FIND Logs_Rpts_Paths_Folders WHERE TT-Logs-Rpts-Seq_Nbr_only = 1 NO-LOCK NO-ERROR. 
   
DEFINE STREAM outwardAM.
/*DEFINE VARIABLE loadRpt AS CHARACTER                                                */
/*    INITIAL "C:\PROGRESS\WRK\Address-Load-Rpt.txt"                          NO-UNDO.*/
DEFINE VARIABLE loadRpt AS CHARACTER NO-UNDO. 
ASSIGN loadRPT = TT-Logs-Rpts-Path-Folder + "Address-Load-Rpt.txt".
OUTPUT STREAM outwardAM TO value(loadRpt) PAGED.

PUT STREAM outwardAM
    "*******************************************" SKIP.
PUT STREAM outwardAM 
    "**** Begin report." TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardAM
    "*******************************************" SKIP.
            
PUT STREAM outwardAM 
    "Program Name:" THIS-PROCEDURE:FILE-NAME FORMAT "x(70)" AT 15 SKIP(1).

IF  i-Admin-Update-OverRyde = YES THEN 
    PUT STREAM outwardAM
        "Admin-Update-OverRyde Option has been turned on for this run only!" SKIP (1). 
PUT STREAM outwardAM 
    "PERSON:"  AT 1  "DB-NBR" AT 13  "NAME,  DOB:" AT 21 SKIP.
PUT STREAM outwardAM 
    "ADDRESS:" AT 2  "DB-NBR" AT 13  "ADDRESS 1,  CITY,  STATE,  ZIP-CODE,  COUNTRY" AT 21 SKIP.
PUT STREAM outwardAM
    "ACTION:" AT 21 SKIP.
PUT STREAM outwardAM
    "Discrepancy ID Number:" AT 23 SKIP(1).
PUT STREAM outwardAM
    "=================================================================" SKIP.
                                   
/* ***************************  Main Block  *************************** */

IF ITdisplay = YES THEN DISPLAY "Entered PROG: XML-SUB-Address-Load." SKIP.

Main_loop:  
FOR EACH XML_TT_Address_Data NO-LOCK BREAK BY TT-address-Seq-Nbr:

    FIND FIRST XML_TT_PeopID_Basic_Data   WHERE
                XML_TT_PeopID_Basic_Data.TT_PeopID_Seq_Nbr_only = TT-address-Seq-Nbr
          NO-LOCK NO-ERROR.
    
    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) AND 
        XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Flag  = "ERROR" THEN             
            NEXT Main_Loop. 
                        
    IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
        ASSIGN  i-people-id =  XML_TT_PeopID_Basic_Data.TT_PeopID_people_id.
        
    ASSIGN  o-addr-id = 0
            did-full-name-already-print = NO.          
                                     
    ASSIGN arecordsprocessed = (arecordsprocessed + 1).
    
/******  check for address data ******/
         
    IF  XML_TT_Address_Data.TT-addr_addr1 =   "" OR   
        XML_TT_Address_Data.TT-addr_city  =   "" OR  
        XML_TT_Address_Data.TT-state_iso  =   "" OR  
        XML_TT_Address_Data.TT-addr_zip   =   ""    THEN DO:         
/** ERROR - required input(s) missing **/  
 
            ASSIGN  data-info     = "XML I/P:" 
                    h-RPT-message = "Warning: Missing input address data (or blank) infor."
                    Full-TT-XML   = XML_TT_Address_Data.TT-addr_addr1  + ", " +
                                    XML_TT_Address_Data.TT-addr_addr2  + " "  +
                                    XML_TT_Address_Data.TT-addr_addr3  + " "  + 
                                    XML_TT_Address_Data.TT-addr_city   + ", "  +
                                    XML_TT_Address_Data.TT-state_iso   + ", "  +
                                    XML_TT_Address_Data.TT-addr_zip    + ", "  +
                                    XML_TT_Address_Data.TT-country_iso.
            
            IF  i-people-id > 0 THEN DO: 
               
                FIND people_mstr WHERE 
                                    people_mstr.people_id  = i-people-id  AND 
                                    people_mstr.people_deleted = ? 
                        NO-LOCK NO-ERROR.
            
                IF  AVAILABLE (people_mstr) THEN DO:     

                    ASSIGN  Full-DOB = STRING(people_mstr.people_DOB, "99/99/9999").

                    ASSIGN  Full-Name = people_mstr.people_firstname + " " + people_mstr.people_midname
                            Full-Name = Full-Name + " " + people_mstr.people_lastname + " " + people_mstr.people_suffix
                            Full-Name = Full-Name + "   DOB: " + STRING(Full-DOB) + "$$". 
                    
                    ASSIGN h-full-data =  RIGHT-TRIM(Full-Name, "$$").
                                           
                    PUT STREAM outwardAM
                          "PERSON:"     AT 1
                          i-people-id   AT 10 FORMAT ">,>>>,>>9"
                          h-full-data   AT 21 FORMAT "x(55)" SKIP. 
                        
                END.  /*  IF  AVAILABLE (people_mstr) */        
         
            END.  /*  IF  i-people-id > 0  */
            
            IF  i-people-id = 0 THEN                  
                PUT STREAM outwardAM
                      "PERSON:"      AT 1
                      i-people-id    AT 10 FORMAT ">,>>>,>>9"
                      ":<< People Master DB-NBR."   AT 21 SKIP.     
                      
            PUT STREAM outwardAM
                      data-info     AT 2
                      o-addr-id     AT 10 FORMAT ">,>>>,>>9"
                      Full-TT-XML   AT 21 SKIP.                         
            
            ASSIGN  Full-Addr = "ACTION: " +  h-RPT-message.
         
            PUT STREAM outwardAM
                     Full-Addr       AT 21 SKIP. 
                    
            ASSIGN NO_address_kount = (NO_address_kount + 1).
            
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc    = "Warning: Missing input address data (or blank) infor.". 
            
            ASSIGN o-addr-load-error = YES.
        
            NEXT Main_loop.     
          
    END.  /**  XML_TT_Address_Data.TT-addr_addr1 =   "" OR   */                                    
 
       
/* Check input Country for ISO Validation. */  

    IF XML_TT_Address_Data.TT-country_iso <> "" THEN DO:
                                                                                                                                      
        RUN VALUE(SEARCH("SUBcountry-findR.r")) 
                           (XML_TT_Address_Data.TT-country_iso,
                            OUTPUT o-fcountry-ISO,
                            OUTPUT o-fcountry-error). 

/*  Country NOT Found in country_mstr. Report error. */                        
        IF  o-fcountry-error =  YES THEN DO:                /* logical YES = data is not found */
 
            ASSIGN  data-info     = "XML I/P:"
                    h-RPT-message = "Warning: Country not found in ISO country_mstr."
                    Full-TT-XML   = XML_TT_Address_Data.TT-addr_addr1  + ", " +
                                    XML_TT_Address_Data.TT-addr_addr2  + " "  +
                                    XML_TT_Address_Data.TT-addr_addr3  + " "  + 
                                    XML_TT_Address_Data.TT-addr_city   + ", "  +
                                    XML_TT_Address_Data.TT-state_iso   + ", "  +
                                    XML_TT_Address_Data.TT-addr_zip    + ", "  +
                                    XML_TT_Address_Data.TT-country_iso.
                              
            IF  i-people-id > 0 THEN DO: 
               
                FIND people_mstr WHERE 
                                    people_mstr.people_id  = i-people-id  AND 
                                    people_mstr.people_deleted = ? 
                        NO-LOCK NO-ERROR.
            
                IF  AVAILABLE (people_mstr) THEN DO:     

                    ASSIGN  Full-DOB = STRING(people_mstr.people_DOB, "99/99/9999").

                    ASSIGN  Full-Name = people_mstr.people_firstname + " " + people_mstr.people_midname
                            Full-Name = Full-Name + " " + people_mstr.people_lastname + " " + people_mstr.people_suffix
                            Full-Name = Full-Name + "   DOB: " + STRING(Full-DOB) + "$$". 
                    
                    ASSIGN h-full-data =  RIGHT-TRIM(Full-Name, "$$").
                                           
                    PUT STREAM outwardAM
                          "PERSON:"     AT 1
                          i-people-id   AT 10 FORMAT ">,>>>,>>9"
                          h-full-data   AT 21 FORMAT "x(55)" SKIP. 
                        
                END.  /*  IF  AVAILABLE (people_mstr) */        
         
            END.  /*  IF  i-people-id > 0  */
            
            IF  i-people-id = 0 THEN                  
                PUT STREAM outwardAM
                      "PERSON:"      AT 1
                      i-people-id    AT 10 FORMAT ">,>>>,>>9"
                      ":<< People Master DB-NBR."   AT 21 SKIP.     
                      
            PUT STREAM outwardAM
                      data-info     AT 2
                      o-addr-id     AT 10 FORMAT ">,>>>,>>9"
                      Full-TT-XML   AT 21 SKIP.                         
            
            ASSIGN  Full-Addr = "ACTION: " +  h-RPT-message.
         
            PUT STREAM outwardAM
                     Full-Addr       AT 21 SKIP. 
            
            IF  o-addrdiscrep_ID = 0 THEN
                    PUT STREAM outwardAM
                            " "     AT 16 SKIP.
                               
            ASSIGN  BadBCountry-kount = (BadBCountry-kount + 1).
            
            IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc    = "Warning: Country not found in ISO country_mstr.". 
                
            ASSIGN o-addr-load-error = YES.  

            NEXT Main_loop. 
                                                                               
        END.  /* IF o-fcountry-error =  YES */ 
                                             
    END.  /* IF XML_TT_Address_Data.TT-country_iso <> "" */
    
                         
/* Check input State for ISO Validation. */ 
    
    ASSIGN h-state_iso = "".
    
    IF  XML_TT_Address_Data.TT-country_iso = "" THEN
        ASSIGN h-country_iso = "USA".
    ELSE 
        ASSIGN h-country_iso = o-fcountry-ISO.
                                                                                                                              
    RUN VALUE(SEARCH("SUBstate-findR.r"))
                   (h-country_iso,                       /* XML_TT_Address_Data.TT-country_iso, */
                    XML_TT_Address_Data.TT-state_iso,
                    OUTPUT o-fstate-ISO,
                    OUTPUT o-fstate-error).             

/* State NOT Found in state_mstr. Report error. */                             
    IF  o-fstate-error =  YES THEN DO:                /* logical YES = data is not found */
            
        ASSIGN  o-addr-load-error = YES.
        
        ASSIGN  data-info     = "XML I/P:"
                h-RPT-message = "Warning: State not found in ISO state_mstr."
                Full-TT-XML   = XML_TT_Address_Data.TT-addr_addr1  + ", " + 
                                XML_TT_Address_Data.TT-addr_addr2  + " "  +
                                XML_TT_Address_Data.TT-addr_addr3  + " "  + 
                                XML_TT_Address_Data.TT-addr_city   + ", "  +
                                XML_TT_Address_Data.TT-state_iso   + ", "  +
                                XML_TT_Address_Data.TT-addr_zip    + ", "  +
                                XML_TT_Address_Data.TT-country_iso.
                              
        IF  i-people-id > 0 THEN DO: 
               
                FIND people_mstr WHERE 
                                    people_mstr.people_id  = i-people-id  AND 
                                    people_mstr.people_deleted = ? 
                        NO-LOCK NO-ERROR.
            
                IF  AVAILABLE (people_mstr) THEN DO:     

                    ASSIGN  Full-DOB = STRING(people_mstr.people_DOB, "99/99/9999").

                    ASSIGN  Full-Name = people_mstr.people_firstname + " " + people_mstr.people_midname
                            Full-Name = Full-Name + " " + people_mstr.people_lastname + " " + people_mstr.people_suffix
                            Full-Name = Full-Name + "   DOB: " + STRING(Full-DOB) + "$$". 
                    
                    ASSIGN  h-full-data =  RIGHT-TRIM(Full-Name, "$$").
                                           
                    PUT STREAM outwardAM
                          "PERSON:"     AT 1
                          i-people-id   AT 10 FORMAT ">,>>>,>>9"
                          h-full-data   AT 21 FORMAT "x(55)" SKIP. 
                        
                END.  /*  IF  AVAILABLE (people_mstr) */        
         
        END.  /*  IF  i-people-id > 0  */
        
        IF  i-people-id = 0 THEN                  
            PUT STREAM outwardAM
                  "PERSON:"      AT 1
                  i-people-id    AT 10 FORMAT ">,>>>,>>9"
                  ":<< People Master DB-NBR."   AT 21 SKIP.     
                  
        PUT STREAM outwardAM
                  data-info     AT 2
                  o-addr-id     AT 10 FORMAT ">,>>>,>>9"
                  Full-TT-XML   AT 21 SKIP.                         
        
        ASSIGN  Full-Addr = "ACTION: " +  h-RPT-message.
     
        PUT STREAM outwardAM
                 Full-Addr       AT 21 SKIP(1). 
                     
        ASSIGN  BadBState-kount = (BadBState-kount + 1) 
                o-addr-load-error = YES.   

        IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
            ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc    = "Warning: State not found in ISO state_mstr.".
                
        NEXT Main_loop.
                                                                
    END.  /* IF o-fstate-error =  YES */                                     
   
    IF o-fstate-error =  NO THEN     
                                           
        ASSIGN  h-state_iso = o-fstate-ISO.
        
    IF  XML_TT_Address_Data.TT-state_iso = "" THEN DO: 
        
        ASSIGN  data-info     = "XML I/P:"
                h-RPT-message = "Warning: Input state is blank (no data)."
                Full-TT-XML   = XML_TT_Address_Data.TT-addr_addr1  + ", " + 
                                XML_TT_Address_Data.TT-addr_addr2  + " "  +
                                XML_TT_Address_Data.TT-addr_addr3  + " "  + 
                                XML_TT_Address_Data.TT-addr_city   + ", "  +
                                XML_TT_Address_Data.TT-state_iso   + ", "  +
                                XML_TT_Address_Data.TT-addr_zip    + ", "  +
                                XML_TT_Address_Data.TT-country_iso.
                              
        IF  i-people-id > 0 THEN DO: 
               
                FIND people_mstr WHERE 
                                    people_mstr.people_id  = i-people-id  AND 
                                    people_mstr.people_deleted = ? 
                        NO-LOCK NO-ERROR.
            
                IF  AVAILABLE (people_mstr) THEN DO:     

                    ASSIGN  Full-DOB = STRING(people_mstr.people_DOB, "99/99/9999").

                    ASSIGN  Full-Name = people_mstr.people_firstname + " " + people_mstr.people_midname
                            Full-Name = Full-Name + " " + people_mstr.people_lastname + " " + people_mstr.people_suffix
                            Full-Name = Full-Name + "   DOB: " + STRING(Full-DOB) + "$$". 
                    
                    ASSIGN h-full-data =  RIGHT-TRIM(Full-Name, "$$").
                                           
                    PUT STREAM outwardAM
                          "PERSON:"     AT 1
                          i-people-id   AT 10 FORMAT ">,>>>,>>9"
                          h-full-data   AT 21 FORMAT "x(55)" SKIP. 
                    
                    ASSIGN did-full-name-already-print = YES.
                        
                END.  /*  IF  AVAILABLE (people_mstr) */        
         
        END.  /*  IF  i-people-id > 0  */
            
        IF  i-people-id = 0 THEN                  
            PUT STREAM outwardAM
                  "PERSON:"      AT 1
                  i-people-id    AT 10 FORMAT ">,>>>,>>9"
                  ":<< People Master DB-NBR."   AT 21 SKIP.     
                  
        PUT STREAM outwardAM
                  data-info     AT 2
                  o-addr-id     AT 10 FORMAT ">,>>>,>>9"
                  Full-TT-XML   AT 21 SKIP.                         
        
        ASSIGN  Full-Addr = "ACTION: " +  h-RPT-message.
     
        PUT STREAM outwardAM
                 Full-Addr       AT 21 SKIP(1). 
                 
        IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
            ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc    = "Warning: Input state is blank (no data).". 
                    
        ASSIGN  BlankState-kount = (BlankState-kount + 1) 
                o-addr-load-error = YES.   

        NEXT Main_loop.
                    
    END.  /* IF  XML_TT_Address_Data.TT-state_iso = "" */ 
                                            
    RUN VALUE(SEARCH("SUBaddr-findR.r"))                                     
        (XML_TT_Address_Data.TT-addr_addr1, 
         XML_TT_Address_Data.TT-addr_addr2,
         XML_TT_Address_Data.TT-addr_addr3,
         XML_TT_Address_Data.TT-addr_city, 
         h-state_iso,  
         XML_TT_Address_Data.TT-addr_zip, 
         h-country_iso,      
         OUTPUT o-addr-id, 
         OUTPUT o-addr-load-error, 
         OUTPUT o-faddr-ran).
    
    IF  o-addr-load-error = YES AND                                   
        o-fcountry-error =  NO AND                               
        o-fstate-error =  NO                                      
            THEN DO: 
     
            RUN VALUE(SEARCH("SUBaddr-ucU.r"))                       
                (0, 
                 XML_TT_Address_Data.TT-addr_addr1, 
                 XML_TT_Address_Data.TT-addr_addr2,
                 XML_TT_Address_Data.TT-addr_addr3,
                 XML_TT_Address_Data.TT-addr_city, 
                 h-state_iso,     
                 XML_TT_Address_Data.TT-addr_zip , 
                 h-country_iso,             
                 "", 
                 OUTPUT o-ucaddr-id, 
                 OUTPUT o-ucaddr-create, 
                 OUTPUT o-ucaddr-update,
                 OUTPUT o-ucaddr-avail, 
                 OUTPUT o-ucaddr-successful).
                                       
            ASSIGN  o-addr-id = o-ucaddr-id. 
              
/* Update the pal_list table with the new addr-id. */

            RUN VALUE(SEARCH("SUBpal-ucU.r"))
                (i-people-id,
                 o-addr-id,
                 "Primary",                         /* i-type */
                 "",                                /* i-requestedkey */
                 NO,                                /* i-update */
                 "",                                /* i-new-type */
                 OUTPUT o-requestedkey,
                 OUTPUT o-create,
                 OUTPUT o-update,
                 OUTPUT o-avail,
                 OUTPUT o-successful).
                    
    END.  /**  IF o-addr-load-error = YES AND  **/

/*  store the address-id in its people_mstr record. */
    FIND people_mstr WHERE 
                                    people_mstr.people_id  = i-people-id  AND 
                                    people_mstr.people_deleted = ? 
            EXCLUSIVE-LOCK NO-ERROR.
           
    IF  AVAILABLE (people_mstr) THEN DO: 
         
         ASSIGN  o-addrdiscrep_ID = 0.
         ASSIGN  Full-DOB = STRING(people_mstr.people_DOB, "99/99/9999").
         ASSIGN  data-info     = "PERSON:"
                 Full-Name = people_mstr.people_firstname + " " + people_mstr.people_midname + " " +
                             people_mstr.people_lastname  + " " + people_mstr.people_suffix  + " " +
                             ",  DOB: " + STRING(Full-DOB) + "$$".

        ASSIGN  h-full-data =  RIGHT-TRIM(Full-Name, "$$")
                did-full-name-already-print = YES
                no-update = NO.

        PUT STREAM outwardAM
                  data-info     AT 1
                  i-people-id   AT 10  FORMAT ">,>>>,>>9"
                  h-full-data   AT 21  FORMAT "x(55)" SKIP.  
                 
         IF  o-addr-id <> 0 AND  
             people_mstr.people_addr_id <> o-addr-id THEN DO: 

/* Update the pal_list table with the new addr-id. */

               RUN VALUE(SEARCH("SUBpal-ucU.r"))
                            (i-people-id,
                             o-addr-id,
                             "Primary",                         /* i-type */
                             "",                                /* i-requestedkey */
                             NO,                                /* i-update */
                             "",                                /* i-new-type : Secondary or blank*/
                             OUTPUT o-requestedkey,
                             OUTPUT o-create,
                             OUTPUT o-update,
                             OUTPUT o-avail,
                             OUTPUT o-successful).
                
                 ASSIGN  people_mstr.people_second_addr_ID   = people_mstr.people_addr_id
                         people_mstr.people_addr_id = o-addr-id
                         h-RPT-message = "people_mstr Updated with addr_id: " + STRING(o-addr-id).        
                    
                 ASSIGN 
                    people_mstr.people_modified_by      = USERID ("General")
                    people_mstr.people_modified_date    = TODAY                                     
                    people_mstr.people_prog_name        = THIS-PROCEDURE:FILE-NAME.
            
                 ASSIGN h-full-data = "".
                            
                 ASSIGN  Full-Addr = "ACTION: " +  h-RPT-message + "$$".
                
                 ASSIGN h-full-data =  RIGHT-TRIM(Full-Addr, "$$")
                        no-update = YES.
                
                 PUT STREAM outwardAM
                         h-full-data      AT 21 FORMAT "x(55)" SKIP. 
                                                    
                 ASSIGN  People_Mstr_updated_kount = (People_Mstr_updated_kount + 1)
                         o-addr-load-error = NO.
                         
                 ASSIGN  data-info     = "ADDRESS:"
                         Full-Addr     = XML_TT_Address_Data.TT-addr_addr1  + ", " +
                                         XML_TT_Address_Data.TT-addr_addr2  + " "  +
                                         XML_TT_Address_Data.TT-addr_addr3  + " "  + 
                                         XML_TT_Address_Data.TT-addr_city   + ", " +
                                         XML_TT_Address_Data.TT-state_iso   + ", " +
                                         XML_TT_Address_Data.TT-addr_zip    + ", " +
                                         XML_TT_Address_Data.TT-country_iso.
                                  
                 PUT STREAM outwardAM
                          data-info     AT 2
                          o-addr-id     AT 10   FORMAT ">,>>>,>>9"
                          Full-Addr     AT 21 SKIP.                         
            
                 ASSIGN  h-RPT-message = "addr_mstr Created & type set as 'billed to'."
                         Full-Addr = "ACTION: " +  h-RPT-message.
             
                 PUT STREAM outwardAM
                          Full-Addr       AT 21 SKIP. 
                                         
                 ASSIGN  Address_Mstr_created_kount = (Address_Mstr_created_kount + 1)  
                         o-addr-load-error = NO.
                                             
                 IF  o-addrdiscrep_ID = 0 THEN
                        PUT STREAM outwardAM
                                " "     AT 16 SKIP.
                                    
         END.  /*  IF  o-addr-id <> 0  */
         ELSE DO:
             ASSIGN  data-info     = "ADDRESS:"
                     no-update = NO
                     Full-Addr     = XML_TT_Address_Data.TT-addr_addr1 + ", "  +
                                     XML_TT_Address_Data.TT-addr_addr2 + " "  +
                                     XML_TT_Address_Data.TT-addr_addr3 + " "  +
                                     XML_TT_Address_Data.TT-addr_city  + ", " +
                                     XML_TT_Address_Data.TT-state_iso  + ",   " +
                                     XML_TT_Address_Data.TT-addr_zip   + ",  " +
                                     XML_TT_Address_Data.TT-country_iso.

             PUT STREAM outwardAM
                      data-info     AT 2
                      o-addr-id     AT 10   FORMAT ">,>>>,>>9"
                      Full-Addr     AT 21 SKIP.
                         
         END. /*  ELSE DO:  */ 
         
         IF  people_mstr.people_second_addr_ID   = people_mstr.people_addr_id THEN
                ASSIGN  people_mstr.people_second_addr_ID   = 0.
                          
    END.  /* IF  AVAILABLE (people_mstr) THEN */
                                                   
    FIND  addr_mstr WHERE 
                   addr_mstr.addr_id = o-addr-id AND 
                   addr_mstr.addr_deleted  = ?
                EXCLUSIVE-LOCK NO-ERROR.
               
    IF o-ucaddr-create THEN DO:
             
            ASSIGN h-bill-type = addr_mstr.addr_type.
          
            IF  h-bill-type = "" THEN DO:       
                ASSIGN  h-bill-type = "billed to"
                        addr_mstr.addr_type = h-bill-type
                        Address_Mstr_billedto_kount = (Address_Mstr_billedto_kount + 1)
                        o-addr-load-error = NO
                        no-update = YES.
            END.  /*  IF  h-bill-type = ""  */
                              
    END.  /*  IF o-ucaddr-create THEN  */

             
/*  CHECK i/p FIELDS and if differents then  CREATE a discrepancy record. */  
           
    IF  XML_TT_Address_Data.TT-addr_addr2      <> addr_mstr.addr_addr2      OR
        XML_TT_Address_Data.TT-addr_addr3      <> addr_mstr.addr_addr3      OR 
        XML_TT_Address_Data.TT-country_iso     <> addr_mstr.addr_country    THEN DO: 
            
            ASSIGN  o-addrdiscrep_ID = 0.
                              
            RUN VALUE(SEARCH("SUBaddr-discrepy-ucU.r"))
                            (TT-address-Seq-Nbr,
                             o-addr-id,
                             OUTPUT o-addrdiscrep_ID,                          
                             OUTPUT o-addr-load-error).

            FIND people_mstr WHERE 
                                    people_mstr.people_id  = i-people-id  AND 
                                    people_mstr.people_deleted = ? 
                        EXCLUSIVE-LOCK NO-ERROR.
           
            IF  AVAILABLE (people_mstr) AND 
                o-addrdiscrep_ID > 0            THEN  DO: 
                                         
                    IF  XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "D_people" THEN 
                        ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "D_both". 
                    ELSE 
                        XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table = "D_Addr".  
                                                   
                    ASSIGN  
                        people_mstr.people_second_addr_ID   = people_mstr.people_addr_id 
                        people_mstr.people_addr_id          = o-addrdiscrep_ID.   
            
                    PUT STREAM outwardAM
                            "^^^^^  Discrepancy ID Number: "    AT 14 
                            o-addrdiscrep_ID                    AT 46 FORMAT ">,>>>,>>9" SKIP(2). 
                                   
/* Update the pal_list table with the new discrepancy address-id. */

                RUN VALUE(SEARCH("SUBpal-ucU.r"))
                            (i-people-id,
                             o-addrdiscrep_ID,
                             XML_TT_PeopID_Basic_Data.TT_PeopID_Discrep_Table,  /* "Primary",     /* i-type */  */
                             "",                                /* i-requestedkey */
                             NO,                                /* i-update */
                             "",                                /* i-new-type */
                             OUTPUT o-requestedkey,
                             OUTPUT o-create,
                             OUTPUT o-update,
                             OUTPUT o-avail,
                             OUTPUT o-successful).

            END. /* IF  AVAILABLE (people_mstr) AND 
                        o-addrdiscrep_ID > 0  */    
                                                              
            IF  o-addr-load-error = YES THEN DO: 
             
                ASSIGN  data-info = "XML DATA:"
                        h-RPT-message = "XML input data is not equal to addr_mstr data."
                        Full-TT-XML   = XML_TT_Address_Data.TT-addr_addr1  + ", " + 
                                        XML_TT_Address_Data.TT-addr_addr2  + " " + 
                                        XML_TT_Address_Data.TT-addr_addr3  + " " +
                                        XML_TT_Address_Data.TT-addr_city   + ", "  +
                                        XML_TT_Address_Data.TT-state_iso   + ", "  +
                                        XML_TT_Address_Data.TT-addr_zip    + ", "  +
                                        XML_TT_Address_Data.TT-country_iso.
                        
                 IF  did-full-name-already-print = NO THEN        
                     PUT STREAM outwardAM
                            data-info       AT 1
                            i-people-id     AT 10 FORMAT ">,>>>,>>9"
                            h-full-data     AT 21 SKIP.         /* Full_Name */
                              
                 ASSIGN  Full-Name = "ACTION: " +  h-RPT-message
                         did-full-name-already-print = YES
                         no-update = NO.
             
                 PUT STREAM outwardAM
                         Full-Name       AT 21 SKIP.
                          
                ASSIGN Address_NOT_Equal_Error_kount = (Address_NOT_Equal_Error_kount + 1).

                IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
                    ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc    = "Warning: Discrepancy address-id load error.".
            
            END.  /*  IF o-addr-load-error = YES  */
                                   
            IF  o-addrdiscrep_ID = 0 THEN
                    PUT STREAM outwardAM
                            " "     AT 16 SKIP.
             
            NEXT Main_loop.
                               
    END.  /*  IF   NOT EQUALs    */

    IF  no-update = NO THEN DO: 

/* Update the pal_list table with the new addr-id. */

        RUN VALUE(SEARCH("SUBpal-ucU.r"))
            (i-people-id,
             o-addr-id,
             "Primary",                         /* i-type */
             "",                                /* i-requestedkey */
             NO,                                /* i-update */
             "",                                /* i-new-type */
             OUTPUT o-requestedkey,
             OUTPUT o-create,
             OUTPUT o-update,
             OUTPUT o-avail,
             OUTPUT o-successful).
        
        ASSIGN   Full-Name = "ACTION: " +  "NO updates or creates made.".
     
        PUT STREAM outwardAM
             Full-Name       AT 21 SKIP.    
    
    END.  /* IF no-update = NO */
    
    ASSIGN no-update = NO.
    
    IF LAST-OF (TT-address-Seq-Nbr) THEN
        PUT STREAM outwardAM SKIP(1).
                                       
END. /* FOR EACH XML_TT_Address_Data */


IF  o-addr-load-error = YES THEN DO: 
        ASSIGN o-addr-error-message = " Unknown error encountered with input data in " 
                                 + " program: " 
                                 + THIS-PROCEDURE:FILE-NAME + ".".
                                 
        IF  AVAILABLE (XML_TT_PeopID_Basic_Data) THEN 
            ASSIGN XML_TT_PeopID_Basic_Data.TT_PeopID_ERROR_Desc    = "Unknown error encountered with input data in " 
                                                                    + " program"
                                                                    + THIS-PROCEDURE:FILE-NAME + ".".
                                 
END.  /*  IF  o-addr-load-error = YES   */
ELSE 
    ASSIGN o-addr-error-message = "".
                                     
FOR EACH D_addr_mstr WHERE D_addr_deleted = ? NO-LOCK:
    ASSIGN Address_Discrepancy_kount = (Address_Discrepancy_kount + 1).        
END.
    
PUT STREAM outwardAM SKIP (1)
    "Information:" SKIP
    arecordsprocessed FORMAT ">,>>9"           "  :Total Input Records Processed." SKIP
    Address_Mstr_updated_kount FORMAT ">,>>9"  "  :Address Masters updated." SKIP
    Address_Mstr_created_kount FORMAT ">,>>9"  "  :Address Masters created." SKIP
    Address_Mstr_billedto_kount FORMAT ">,>>9" "  :Address Masters type set as 'billed to'." SKIP
    People_Mstr_updated_kount FORMAT ">,>>9"   "  :People Masters updated with addr_id." SKIP(1)

    "Warnings:" SKIP 
    Address_Discrepancy_kount FORMAT ">,>>9"   "  : ADDRESS DISCREPANCIES found." SKIP 
    NO_address_kount FORMAT ">,>>9"            "  : Missing input address data (or blank) infor." SKIP 
    BadBCountry-kount FORMAT ">,>>9"           "  : Country not found in ISO country_mstr. NOT processed." SKIP  
    BadBState-kount FORMAT ">,>>9"             "  : State not found in ISO state_mstr. NOT processed." SKIP
    BlankState-kount FORMAT ">,>>9"            "  : Input state is blank (no data). NOT processed." SKIP
    Address_NOT_Equal_Error_kount FORMAT ">,>>9"   "  : XML input data is not equal to addr_mstr data." SKIP(2).

PUT STREAM outwardAM
    "*******************************************" SKIP.
PUT STREAM outwardAM 
    "**** End report.  " TODAY AT 21 STRING(TIME, "HH:MM:SS") AT 31 " ****" SKIP.
PUT STREAM outwardAM
    "*******************************************" SKIP(1).
PAGE STREAM outwardAM.
   
OUTPUT STREAM outwardAM CLOSE.

IF ITdisplay = YES THEN DISPLAY "Leaving PROG: XML-SUB-Address-Load." SKIP.
              
/** end of program **/

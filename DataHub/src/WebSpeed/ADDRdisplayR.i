
/*------------------------------------------------------------------------
    File        : ADDRdisplayR.i
    Purpose     : Minimizing code

    Syntax      :

    Description : display portion of ADDR__R files

    Author(s)   : Jacob Luttrell
    Created     : Tue Jul 07 11:15:20 MDT 2015
    Notes       :
  ----------------------------------------------------------------------*/  

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
IF AVAILABLE (morepeople) THEN DO:

    RUN VALUE(SEARCH("SUBcountry-findR.r")) (                                              /* 1dot2 */
        addr_mstr.addr_country,                                                            /* 1dot2 */
        OUTPUT o-fcountry-ISO,                                                             /* 1dot2 */
        OUTPUT o-fcountry-error                                                            /* 1dot2 */
        ).                                                                                 /* 1dot2 */

    RUN VALUE(SEARCH("SUBstate-findR.r")) (                                                /* 1dot2 */
        o-fcountry-ISO,                                                                    /* 1dot2 */
        addr_mstr.addr_stateprov,                                                          /* 1dot2 */
        OUTPUT o-fstate-ISO,                                                               /* 1dot2 */
        OUTPUT o-fstate-error                                                              /* 1dot2 */
        ).                                                                                 /* 1dot2 */

    RUN VALUE(SEARCH("SUBcountry-disp-name-findR.r")) (                                    /* 1dot2 */
        o-fcountry-ISO,                                                                    /* 1dot2 */
        OUTPUT o-fcountry-disp-name,                                                       /* 1dot2 */
        OUTPUT o-fcountry-disp-error                                                       /* 1dot2 */
        ).                                                                                 /* 1dot2 */
       
    RUN VALUE(SEARCH("SUBstate-disp-name-findR.r")) (                                      /* 1dot2 */
        o-fcountry-ISO,                                                                    /* 1dot2 */
        o-fstate-ISO,                                                                      /* 1dot2 */                    
        OUTPUT o-fstate-disp-name,                                                         /* 1dot2 */ 
        OUTPUT o-fstate-disp-error                                                         /* 1dot2 */
        ).                                                                                 /* 1dot2 */
   
    IF morepeople.people_firstname = "" OR morepeople.people_lastname = "" OR
    morepeople.people_firstname = "NEW" OR morepeople.people_lastname = "PATIENT" THEN

        ASSIGN
            x            = x + 1
            labelline[x] = people_mstr.people_firstname + " " + people_mstr.people_lastname.
        
    ELSE
        IF morepeople.people_firstname <> "" OR morepeople.people_lastname <> "" THEN
            ASSIGN
                x            = x + 1  
                labelline[x] = morepeople.people_firstname + " " + morepeople.people_lastname.
END. /** if avail **/
ELSE
    
    ASSIGN
        x            = x + 1
        labelline[x] = people_mstr.people_firstname + " " + people_mstr.people_lastname.
    
IF addr_mstr.addr_addr1 <> "" THEN
    ASSIGN
        x            = x + 1
        labelline[x] = addr_mstr.addr_addr1.

IF addr_mstr.addr_addr2 <> "" THEN
    ASSIGN
        x            = x + 1
        labelline[x] = addr_mstr.addr_addr2.

IF addr_mstr.addr_addr3 <> "" THEN
    ASSIGN
        x            = x + 1
        labelline[x] = addr_mstr.addr_addr3.

IF addr_mstr.addr_city <> "" OR addr_mstr.addr_stateprov <> "" OR addr_mstr.addr_zip <> "" THEN
    ASSIGN
        x            = x + 1
        labelline[x] = addr_mstr.addr_city + ", " +   addr_mstr.addr_stateprov /* o-fstate-ISO */ + "  " + addr_mstr.addr_zip.     /* 1dot2 */

IF addr_mstr.addr_country <> "" THEN
    ASSIGN
        x            = x + 1
        labelline[x] = addr_mstr.addr_country /* o-fcountry-ISO*/.           /* 1dot2 */

/*------------------------------------------------------------------------
    File        : SUBaddr-discrepy-ucU.p
    Purpose     : Description : Stores the input XML data when there is
                : a discrepancy between the input data and their database records.  

    Author(s)   : Harold D. Luttrell
    Created     : Feb 14, 2017
                :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */

{XML_TT_Address_Data.i}.      /*  XML Extraction Address Data to Load into Progress. */
/*{XML_TT_PeopID_only.i}.       /* XML Extraction People ID to be used in the XML-SUB- programs.p. */*/
 
DEFINE INPUT PARAMETER i-TT-Address-Seq-Nbr         AS INTEGER                         NO-UNDO.
DEFINE INPUT PARAMETER i-addr-id                    LIKE addr_mstr.addr_id     NO-UNDO.

DEFINE OUTPUT PARAMETER o-addrdiscrep_ID            LIKE addr_mstr.addr_id     NO-UNDO.
DEFINE OUTPUT PARAMETER o-addrdiscrepy-error        AS LOGICAL INITIAL NO              NO-UNDO.

/* ***************************  Main Block  *************************** */
    
    FIND FIRST XML_TT_Address_Data WHERE  TT-Address-Seq-Nbr = i-TT-Address-Seq-Nbr
            NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE (XML_TT_Address_Data) THEN  
    
        ASSIGN  o-addrdiscrepy-error = YES
                o-addrdiscrep_ID     = 0.    
    
    ELSE DO:  /* - 1 - IF AVAILABLE (XML_TT_Address_Data)  */       
    
        FIND FIRST D_addr_mstr WHERE    D_addr_addr1          = TRIM(XML_TT_Address_Data.TT-addr_addr1)     AND 
                                        D_addr_addr2          = TRIM(XML_TT_Address_Data.TT-addr_addr2)     AND 
                                        D_addr_addr3          = TRIM(XML_TT_Address_Data.TT-addr_addr3)     AND 
                                        D_addr_city           = TRIM(XML_TT_Address_Data.TT-addr_city)      AND 
                                        D_addr_stateprov      = TRIM(XML_TT_Address_Data.TT-state_iso)      AND 
                                        D_addr_zip            = TRIM(XML_TT_Address_Data.TT-addr_zip)       AND 
                                        D_addr_country        = TRIM(XML_TT_Address_Data.TT-country_iso)            
                        NO-LOCK NO-ERROR.
                        
        IF  NOT AVAILABLE (D_addr_mstr) THEN DO:     
/*  Create & Store new discrepancy record.  */        
            CREATE  D_addr_mstr.
        
            ASSIGN  D_addr_id             = NEXT-VALUE (seq-addr)
                    D_addr_addr1          = TRIM(XML_TT_Address_Data.TT-addr_addr1)
                    D_addr_addr2          = TRIM(XML_TT_Address_Data.TT-addr_addr2)
                    D_addr_addr3          = TRIM(XML_TT_Address_Data.TT-addr_addr3)
                    D_addr_city           = TRIM(XML_TT_Address_Data.TT-addr_city)
                    D_addr_stateprov      = TRIM(XML_TT_Address_Data.TT-state_iso)
                    D_addr_zip            = TRIM(XML_TT_Address_Data.TT-addr_zip)
                    D_addr_country        = TRIM(XML_TT_Address_Data.TT-country_iso)
                    D_addr_created_by     = USERID ("General")
                    D_addr_create_date    = TODAY
                    D_addr_prog_name      = SOURCE-PROCEDURE:FILE-NAME
                    D_addr_Occured_Date   = TODAY  
                    D_addr_Verify_Flag    = NO
                    D_addr_discr_ID       = i-addr-id.
        END. /* IF  NOT AVAILABLE (D_addr_mstr) THEN DO: */
                   
        ASSIGN  o-addrdiscrep_ID      = D_addr_id.
         
    END.  /*  ELSE DO: */

/*  END OF PROGRAM.  */

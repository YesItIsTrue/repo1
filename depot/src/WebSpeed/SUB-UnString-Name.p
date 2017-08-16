   				 
/*------------------------------------------------------------------------
    File        : SUB-UnString-Name.p
    Project     : depot.
    Author(s)   : Harold Luttrell, Sr.
    Created     : Thurs Dec 30 2014.
    Notes       : A routine to un-string or seperate out a person's name.
    
    Description : Takes the input character string that contains a person's
                : name (e.g. first middle last or prefix first middle last or
                :            first last or first last suffix title, etc)
                : and seperates the input into dofferent fields as the: 
                : prefix, firstname, middlename, lastname, suffix, title,
                : prefname and gender, 
                : the best we can and returns those seperated fields.
                :
                : Remember this - garbage in is garbage out and this problem
                : with users that never enter the data in the same format makes
                : is difficult to keep the data looking structured correctly.
                    
    NOTE        : In the second input, if you pass the logical YES,
                : this subroutine will display the resulting output data fields
                : before returning to the calling program, else pass the logical NO.
                                 
    Usage format:    RUN "../depot/rcode/SUB-UnString-Name.r" 
                        (i-String-Pat-Name,
                         it-message,                        /* logical NO or YES. A YES displays the results at the end of this program. */
                         OUTPUT o-prefix,
                         OUTPUT o-firstname,
                         OUTPUT o-middlename,
                         OUTPUT o-lastname,
                         OUTPUT o-suffix,
                         OUTPUT o-title_desc,
                         OUTPUT o-prefname,
                         OUTPUT o-gender,
                         OUTPUT o-unstring-error,           /*  YES = errors / NO = no errors. */
                         OUTPUT o-field-in-error).          /*  Field input name in error, if any. */
  
    - - Version History - -
      
          1.0 - Dec 29, 2014 - Original code.

    Version 2.0 - Harold Luttrell - 17/Mar/16.  
            Added code to look for certain names with special characters
                in them and to allow them to process, not rejecting them.
                Example: First Name  " Takuya li".
            Identified by:  /* 2dot0 */
                                                   
    Version 2.01 - written by DOUG LUTTRELL on 02/Apr/16.  Finally tracked down the cause of the 
                    "incompatible display type" error.  Apparently the standard Client semi-GUI 
                    environment on a Windows 2012 server is sufficiently different from the 
                    DevStudio interface that it triggers this error when attempting to run a 
                    sub-procedure that has DISPLAYs in it.  Commenting out the two displays in
                    this program resolved the issue.  If they are needed for local development
                    you can just uncomment them back in.  Marked by 2.01.                                                   
     
    Version 2.2 - Harold Luttrell - 24/May/16.
            Initialize the o-gender (female/male) variable to ?.  
            Added code to set the o-gender logical for female to NO and for male to YES.
            Identified by:  /* 2dot2 */       
                                                                      
  ----------------------------------------------------------------------*/ 				 
ROUTINE-LEVEL ON ERROR UNDO, THROW.

/*   input string example: "Mr. tom E. jones jr. MD."  or 
                           "tom jones"   */
                      	  
DEFINE  INPUT    PARAMETER    i-String-Pat-Name   AS CHARACTER FORMAT "x(70)"     NO-UNDO.
DEFINE  INPUT    PARAMETER    it-message          AS LOGICAL INITIAL NO           NO-UNDO.

DEFINE  OUTPUT   PARAMETER    o-prefix        LIKE people_mstr.people_prefix      NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-firstname     LIKE people_mstr.people_firstname   NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-middlename    LIKE people_mstr.people_midname     NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-lastname      LIKE people_mstr.people_lastname    NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-suffix        LIKE people_mstr.people_suffix      NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-title_desc    LIKE people_mstr.people_title       NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-prefname      LIKE people_mstr.people_prefname    NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-gender        LIKE people_mstr.people_gender      NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-unstring-error AS LOGICAL INITIAL NO              NO-UNDO.
DEFINE  OUTPUT   PARAMETER    o-field-in-error AS CHARACTER FORMAT "X(30)"        NO-UNDO.


DEFINE VARIABLE x                              AS CHARACTER FORMAT "x(70)"        NO-UNDO.
DEFINE VARIABLE x-hold                         AS CHARACTER FORMAT "x(70)"        NO-UNDO.  /* 2dot0 */
DEFINE VARIABLE hold-firstname                 AS CHARACTER FORMAT "x(70)"        NO-UNDO.  /* 2dot0 */
DEFINE VARIABLE hold-lastname                  AS CHARACTER FORMAT "x(70)"        NO-UNDO.  /* 2dot0 */
DEFINE VARIABLE multiple_titles                AS CHARACTER FORMAT "x(60)"        NO-UNDO.
DEFINE VARIABLE len                            AS INTEGER                         NO-UNDO.
DEFINE VARIABLE len2                           AS INTEGER                         NO-UNDO.
DEFINE VARIABLE len3                           AS INTEGER                         NO-UNDO.
DEFINE VARIABLE comma_location                 AS INTEGER                         NO-UNDO.
DEFINE VARIABLE prefname_loc_left              AS INTEGER                         NO-UNDO.
DEFINE VARIABLE prefname_loc_right             AS INTEGER                         NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */
DEFINE VARIABLE pref-src-list AS CHARACTER NO-UNDO  
    INITIAL "Dr,Dr.,Mr,Mr.,Mrs,Mrs.,Ms,Ms.,Hon,Hon.,Rev,Rev.,Miss".
    
DEFINE VARIABLE pref-dest-list AS CHARACTER NO-UNDO 
    INITIAL "Dr.,Dr.,Mr.,Mr.,Mrs.,Mrs.,Ms.,Ms.,Hon,Hon,Rev,Rev,Miss".
    
DEFINE VARIABLE suff-src-list AS CHARACTER NO-UNDO 
    INITIAL "Sr,Sr.,1st,Jr,Jr.,2nd,II,3rd,III,4th,IV,5th,V".    
    
DEFINE VARIABLE suff-dest-list AS CHARACTER NO-UNDO 
    INITIAL "Sr.,Sr.,Sr.,Jr.,Jr.,Jr.,Jr.,III,III,IV,IV,V.,V".

DEFINE VARIABLE title-src-list AS CHARACTER NO-UNDO 
    INITIAL "BSN,C,CNC,CNHP,CRNP,DC,DC ND,DDO,DMD,DO,DSS,FNPC,LPN,L.Ac,MD,M.D.,ND,ND CCN,ND-DC,NMD,NP,PC,PhD,PHN,RN,RN NMD,RPN".   


/* ***************************  Main Sub-Program Block  *************************** */

/************* commented out in version 2.01 ***************/
/*IF it-message = YES THEN                                                */                            
/*    DISPLAY "ENTERING: SUB-UnString-Name. " SKIP i-String-Pat-Name SKIP.*/                            
 
ASSIGN o-field-in-error = ""
       o-unstring-error = NO.

/*  Move the input string to the work area.  */   
ASSIGN  x  = TRIM(i-String-Pat-Name)
        x-hold = x.                                                             /* 2dot0 */

/** look for comma and remove if found.  */
ASSIGN comma_location = R-INDEX(x,",").

IF comma_location > 0 THEN DO:
    ASSIGN  SUBSTRING(x, comma_location, 1) = SUBSTRING("", 1, 1). 
END.  /**  comma_location > 0  **/

/** look for prefer name within ( ) and move if found.  */
ASSIGN prefname_loc_right  = R-INDEX(x,")").

IF prefname_loc_right > 0 THEN DO:
    ASSIGN prefname_loc_left = R-INDEX(x,"(").
    ASSIGN  o-prefname = SUBSTRING(x, (prefname_loc_left + 1), (prefname_loc_right - prefname_loc_left - 1) ).
    ASSIGN  len = LENGTH(o-prefname).
    ASSIGN  SUBSTRING(x, (prefname_loc_left), (len + 3) ) = SUBSTRING("", 1, (len + 3)) .  
END.  /**  prefname_loc_right > 0  **/

/** look for prefer name within " " and move if found.  */
ASSIGN prefname_loc_right  = R-INDEX(x,'" ').

IF prefname_loc_right > 0 THEN DO:
    ASSIGN prefname_loc_left = R-INDEX(x,' "')
           prefname_loc_left = (prefname_loc_left + 1).    
    ASSIGN  o-prefname = SUBSTRING(x, (prefname_loc_left + 1), (prefname_loc_right - prefname_loc_left - 1) ).
    ASSIGN  len = LENGTH(o-prefname).
    ASSIGN  SUBSTRING(x, (prefname_loc_left), (len + 3) ) = SUBSTRING("", 1, (len + 3)) . 
END.  /**  prefname_loc_right > 0  **/

/* Unstring the input. */
o-firstname  = TRIM(SUBSTRING(x,1,INDEX(x," "))).
o-middlename = TRIM(SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," "))).
o-lastname   = TRIM(SUBSTRING(x,R-INDEX(x," ") + 1)).

/* Set the 1st character of each field to uppercase - to make the data look professional. */
o-firstname  = CAPS(SUBSTRING(o-firstname, 1, 1) ) + (SUBSTRING(o-firstname, 2) ).
o-middlename = CAPS(SUBSTRING(o-middlename, 1, 1) ) + (SUBSTRING(o-middlename, 2) ).
o-lastname   = CAPS(SUBSTRING(o-lastname, 1, 1) ) + (SUBSTRING(o-lastname, 2) ).

ASSIGN  hold-firstname = o-firstname                                            /* 2dot0 */
        hold-lastname  = o-lastname.                                            /* 2dot0 */
        
IF  o-lastname   = "" THEN 
    ASSIGN  o-lastname   = o-middlename
            o-middlename = "".
            
/** Pre-edits - no need to execute the code if we have an error up front.  **/

IF o-firstname = "" THEN DO:
        ASSIGN  o-unstring-error = YES
                o-field-in-error = "firstname".
END.  /** IF o-firstname = ""   **/         

IF o-lastname   = "" THEN DO:
        ASSIGN  o-unstring-error = YES
                o-field-in-error = "lastname".
END.  /** IF o-lastname = ""   **/         


/*  Main code.  */

IF  o-unstring-error = NO  THEN DO: 
 
    
/**  Look for any prefix in front of the first name.  **/
    ASSIGN o-gender     = NO.
    ASSIGN o-prefix     = "".
    
    IF LOOKUP(o-firstname,pref-src-list) > 0 THEN DO:                              /*  means found it */
        ASSIGN  o-prefix      = ENTRY(LOOKUP(o-firstname,pref-src-list),pref-dest-list).
        ASSIGN  o-firstname   = o-middlename
                o-middlename  = " ".
                
        ASSIGN  x = o-firstname + o-middlename + o-lastname.

        o-firstname  = TRIM(SUBSTRING(x,1,INDEX(x," "))).
        o-middlename = TRIM(SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," "))).
        o-lastname   = TRIM(SUBSTRING(x,R-INDEX(x," ") + 1)).
        
        IF (TRIM(o-prefix)   = "Mr" OR 
            TRIM(o-prefix)   = "Mr.") THEN 
                ASSIGN o-gender = YES.
        END.  /**  IF LOOKUP(o-firstname,pref-src-list) > 0  **/  
  
/** Look again in case the user put another prefix after the 1st prefix.
    An example of this is: "Mr. Dr. Tom Jones".    **/
    
    IF LOOKUP(o-firstname,pref-src-list) > 0 THEN DO:                              /*  means found it */
        ASSIGN  o-prefix      = ENTRY(LOOKUP(o-firstname,pref-src-list),pref-dest-list).
        ASSIGN  o-firstname   = o-middlename
                o-middlename  = " ".
                
        ASSIGN  x = o-firstname + o-middlename + o-lastname.

        o-firstname  = SUBSTRING(x,1,INDEX(x," ")).
        o-middlename = SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," ")).
        o-lastname   = SUBSTRING(x,R-INDEX(x," ") + 1).
            
    END.  /**  IF LOOKUP(o-firstname,pref-src-list) > 0  **/                                     

      
/**  Look for any title after the last name.  **/    
    ASSIGN  o-title_desc = "".
    
    IF LOOKUP(o-lastname,title-src-list) > 0 THEN DO:                                /*  means found it */    
/** 1st occurence.  **/
        ASSIGN  o-title_desc = ENTRY(LOOKUP(o-lastname,title-src-list),title-src-list). 
        ASSIGN  o-lastname = o-middlename
                o-middlename  = " ". 
                
        ASSIGN  x = o-firstname + o-middlename + o-lastname.
        
/** look for comma and remove if found.  */
        ASSIGN comma_location = R-INDEX(x,",").
        IF comma_location > 0 THEN DO:
            ASSIGN  SUBSTRING(x, comma_location, 1) = SUBSTRING("", 1, 1). 
        END.  /**  comma_location > 0  **/
        
        o-firstname  = SUBSTRING(x,1,INDEX(x," ")).
        o-middlename = SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," ")).
        o-lastname   = SUBSTRING(x,R-INDEX(x," ") + 1).
      
        IF  o-lastname = "" THEN 
            ASSIGN  o-lastname = o-middlename
                    o-middlename  = "".
                    
        ASSIGN multiple_titles = o-title_desc.
                
        ASSIGN  x = o-firstname + o-middlename + o-lastname.
/** look for comma and remove if found. */
        ASSIGN comma_location = R-INDEX(x,",").
        IF comma_location > 0 THEN DO:
            ASSIGN  SUBSTRING(x, comma_location, 1) = SUBSTRING("", 1, 1). 
        END.  /**  comma_location > 0  **/  
          
        o-firstname  = SUBSTRING(x,1,INDEX(x," ")).
        o-middlename = SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," ")).
        o-lastname   = SUBSTRING(x,R-INDEX(x," ") + 1).
         
        IF LOOKUP(o-lastname,title-src-list) > 0 THEN DO:                                /*  means found it */  
/** 2nd occurence.  **/          
            ASSIGN  o-title_desc = ENTRY(LOOKUP(o-lastname,title-src-list),title-src-list). 
            ASSIGN  o-lastname = o-middlename
                    o-middlename  = "".    
                             
            ASSIGN  len = LENGTH(o-title_desc).
            ASSIGN  len = (len + 1).
            ASSIGN  SUBSTRING(o-title_desc, len, 2) = SUBSTRING(", ", 1, 2). 
            ASSIGN  len = LENGTH(o-title_desc)
                    len2 = LENGTH(multiple_titles).
            ASSIGN  len = (len + 1).        
            ASSIGN  SUBSTRING(o-title_desc, len, len2) = SUBSTRING(multiple_titles, 1, len2). 
                        
            ASSIGN multiple_titles = o-title_desc.
 
            ASSIGN  x = o-firstname + o-middlename + o-lastname.
       
            o-firstname  = SUBSTRING(x,1,INDEX(x," ")).
            o-middlename = SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," ")).
            o-lastname   = SUBSTRING(x,R-INDEX(x," ") + 1).  
            
            IF  o-lastname = "" THEN 
                ASSIGN  o-lastname = o-middlename
                        o-middlename  = "".
                               
        END.  /** 2nd occurence.  **/       
  
    END.  /**  1st occurence.  IF LOOKUP(o-lastname,title-src-list) > 0  **/
 
        
/**  Look for any suffix after the last name.  **/
    ASSIGN  o-suffix = "".
    
    IF LOOKUP(o-lastname,suff-src-list) > 0 THEN DO:                                /*  means found it */    
        ASSIGN  o-suffix = ENTRY(LOOKUP(o-lastname,suff-src-list),suff-src-list). 
        ASSIGN  o-lastname = o-middlename
                o-middlename  = " ".
                
        ASSIGN  x = o-firstname + o-middlename + o-lastname.
    
        o-firstname  = SUBSTRING(x,1,INDEX(x," ")).
        o-middlename = SUBSTRING(x,INDEX(x," ") + 1,R-INDEX(x," ") - index(x," ")).
        o-lastname   = SUBSTRING(x,R-INDEX(x," ") + 1).
        
        IF  o-lastname = "" THEN 
            ASSIGN  o-lastname = o-middlename
                    o-middlename  = "".  
        
        IF  o-suffix <> "" THEN                                                 /* 2dot2 */
            ASSIGN o-gender = YES.                                              /* 2dot2 */             
       
    END.  /**  IF LOOKUP(o-lastname,suff-src-list) > 0  **/       

END.  /**  IF  o-unstring-error = NO  **/

    IF (TRIM(o-prefix)   = "Mr" OR                                              /* 2dot2 */
        TRIM(o-prefix)   = "Mr.") THEN                                          /* 2dot2 */ 
                ASSIGN o-gender = YES.                                          /* 2dot2 */
                
    IF (TRIM(o-prefix)   = "Mrs" OR                                             /* 2dot2 */
        TRIM(o-prefix)   = "Mrs." OR                                            /* 2dot2 */
        TRIM(o-prefix)   = "Ms" OR                                              /* 2dot2 */
        TRIM(o-prefix)   = "Ms." OR                                             /* 2dot2 */
        TRIM(o-prefix)   = "Miss"                                               /* 2dot2 */ 
       ) THEN                                                                   /* 2dot2 */
                ASSIGN o-gender = NO.                                           /* 2dot2 */               


/*  getting ready to leave the subroutine.  */

IF o-firstname = "" THEN 
        ASSIGN  o-unstring-error = YES
                o-field-in-error = "firstname".
ELSE           
IF o-lastname   = "" THEN
        ASSIGN  o-unstring-error = YES
                o-field-in-error = "lastname".

/*  Check for certain names with special characters  */                         /* 2dot0 */
/*    in them and to allow them to process, not rejecting them.  */             /* 2dot0 */
IF  x-hold  = "Takuya Ii" THEN                                                  /* 2dot0 */
        ASSIGN  o-lastname   = TRIM(hold-lastname)                              /* 2dot0 */
                o-firstname = hold-firstname                                    /* 2dot0 */
                o-middlename = ""                                               /* 2dot0 */ 
                o-prefix = ""                                                   /* 2dot0 */ 
                o-suffix = ""                                                   /* 2dot0 */
                o-title_desc = ""                                               /* 2dot0 */
                o-prefname = ""                                                 /* 2dot0 */              
                o-unstring-error = NO                                           /* 2dot0 */
                o-field-in-error = "accept I/P".                                /* 2dot0 */                                             
    
   
   /**************  commented out in version 2.01  *******************/
/*IF it-message = YES THEN                                                                                     */
/*    DISPLAY "LEAVING: SUB-UnString-Name. " SKIP "OUTPUTs follow:" SKIP                                       */
/*             o-prefix           FORMAT "x(12)"   SKIP                                                        */
/*             o-firstname        FORMAT "x(24)"   SKIP                                                        */
/*             o-middlename       FORMAT "x(24)"   SKIP                                                        */
/*             o-lastname         FORMAT "x(24)"   SKIP                                                        */
/*             o-suffix           FORMAT "x(24)"   SKIP                                                        */
/*             o-title_desc       FORMAT "x(24)"   SKIP                                                        */
/*             o-prefname         FORMAT "x(24)"   SKIP                                                        */
/*             o-gender                            SKIP         /*  "Gender (logical Male/Female-YES/NO) ="  */*/
/*             " "                                 SKIP                                                        */
/*             o-unstring-error                    SKIP                                                        */
/*             o-field-in-error   FORMAT "x(30)"   SKIP                                                        */
/*        WITH FRAME a SIDE-LABELS.                                                                            */
/*                                                                                                             */

 /* End of SUBROUTINE code. */
 

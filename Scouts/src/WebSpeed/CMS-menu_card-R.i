
/*------------------------------------------------------------------------
    File        : CMS-menu_card-R.i
    Purpose     : 

    Syntax      :

    Description : Makes a W3 card of a particular menu that is passed to it.

    Author(s)   : Doug Luttrell
    Created     : Fri Oct 06 10:36:21 EDT 2017
    Usage       : {CMS-menu_card-R.i "15.99"}.
                    Where 15.99 is the menu start point that you want to use.
        
  ********************************************************************
  
  Revision History:
  -----------------
  1.0  -  written by DOUG LUTTRELL on 06/Oct/17.  Original Version.
          
          
  ******************************************************************** 
  
  Notes:
  ------
  1) If this include is referenced more than once in a program then
        these variable definitions will need to be moved to the calling
        procedure.  Seems like I've gone down a bad path, but my head
        doesn't work anymore.
                  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE v-incoming AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-menu-start LIKE menu_mstr.menu_num NO-UNDO.
DEFINE VARIABLE v-menu-end LIKE menu_mstr.menu_select NO-UNDO.
DEFINE VARIABLE ITmessages AS LOG NO-UNDO. 

v-incoming = "{1}".
/*v-incoming = "15.99".*/

IF INDEX(v-incoming,".") = 0 THEN 
    ASSIGN 
        v-menu-start    = "0"
        v-menu-end      = INTEGER(v-incoming).
 ELSE 
    ASSIGN 
        v-menu-start    = SUBSTRING(v-incoming,1,R-INDEX(v-incoming,".") - 1)
        v-menu-end      = INTEGER(SUBSTRING(v-incoming,R-INDEX(v-incoming,".") + 1)).
        
IF ITmessages = YES THEN 
    {&OUT}
        "v-menu_num = " v-menu-start "<BR>" SKIP
        "v-menu_select = " v-menu-end "<BR>" SKIP(1).
        

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND menu_mstr WHERE menu_mstr.menu_num = v-menu-start AND 
    menu_mstr.menu_select = v-menu-end AND 
    menu_mstr.menu_deleted = ? 
        NO-LOCK NO-ERROR.
        
IF AVAILABLE (menu_mstr) THEN DO: 
    
    {&OUT}
        "           <div class='w3-card-4 w3-white'>" SKIP
        "               <DIV class='w3-theme-accent w3-container'>" SKIP
        "                   <H2>" menu_mstr.menu_title "</H2>" SKIP
        "               </DIV>" SKIP
        "              <ul class='w3-ul'>" SKIP.    
    
END.  /** of if avail menu_mstr **/

ELSE DO:
    
    {&OUT}
        "           <div class='w3-card-4 w3-white'>" SKIP
        "               <DIV class='w3-theme-accent w3-container'>" SKIP
        "                   <H2>Supposedly Useful Links</H2>" SKIP 
        "               </DIV>" SKIP
        "              <ul class='w3-ul'>" SKIP.             
    
END.  /** of else do --- not avail menu_mstr **/ 
        

FOR EACH menu_mstr WHERE menu_mstr.menu_num = v-incoming AND 
    menu_mstr.menu_hidden = NO AND 
    menu_mstr.menu_deleted = ? NO-LOCK
        BREAK BY menu_mstr.menu_num BY menu_mstr.menu_select:
                            
    {&OUT}            
        "               <a href='" menu_mstr.menu_exprog "' target='_top'>" 
        "                  <li class='w3-bar w3-hover-theme'>" SKIP
        "                      <div class='w3-bar-item'>" SKIP
        "                          <span class='w3-large'>" menu_mstr.menu_title "</span>" SKIP
        "                      </div>" SKIP 
        "                  </li></a>" SKIP.        
        
END.  /** of 4ea. menu_mstr **/


/********************************  End of File.  **************************************/


/*------------------------------------------------------------------------
    File        : menu-hyperlinkR.i
    Purpose     : 

    Syntax      :

    Description : This is very much like the what to run include file, however for the destination of a hyperlink or button.

    Author(s)   : Trae Luttrell
    Created     : Wed Sep 14 15:54:09 EDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


        
FIND FIRST menu_mstr WHERE 
    menu_mstr.menu_exprog = "{1}" AND 
    menu_mstr.menu_deleted = ?
    NO-LOCK NO-ERROR.
   
IF AVAILABLE (menu_mstr) THEN {&OUT} "" menu_mstr.menu_num + "." + STRING(menu_mstr.menu_select) "".


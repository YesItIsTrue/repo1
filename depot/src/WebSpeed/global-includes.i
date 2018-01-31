
/*------------------------------------------------------------------------
    File        : global-css.i
    Purpose     : Reduce code by having one include file handle all global css links and scripts

    Syntax      :

    Description : Include for all Global Styles

    Author(s)   : Andrew Garver
    Created     : Thu Jan 25 09:39:28 EST 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FOR EACH att_files WHERE att_files.att_category = "global-include" NO-LOCK:
    {&OUT}
        att_files.att_value5.
END.
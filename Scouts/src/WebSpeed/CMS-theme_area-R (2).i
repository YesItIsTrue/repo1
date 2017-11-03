/*------------------------------------------------------------------------
    File        : MC-theme_area-R.i
    Purpose     : 

    Syntax      :

    Description : Upper THEME area of Man College!!! pages.

    Author(s)   : Doug Luttrell
    Created     : Sun Mar 26 17:23:02 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE v-event_ID AS INTEGER NO-UNDO.

ASSIGN 
    v-event_ID = INTEGER(get-value('h-event_id')).
    
    
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/*IF v-event_ID = 0 THEN DO:*/
IF v-event_ID = 0 THEN ASSIGN v-event_ID = 201704.
IF v-event_ID = 201704 THEN DO:
 
    {&OUT}
        "<BODY class='w3-black'>" SKIP
        "<!-- Header / Home-->" SKIP
        "<DIV class='w3-display-container w3-wide w3-grayscale-min w3-black' id='home'>" SKIP
        "   <div class='w3-display-top w3-text-white w3-center'>" SKIP
        "       <img src='/depot/src/HTMLContent/images/Youth-CMS/ManCollege_logo.jpg' class='w3-padding' width='100%'></img>" SKIP      
        "       <h1 class='w3-jumbo'>Year 2 - Builders in Zion</h1>" SKIP 
        "       <H2>20-22/Apr/2017</H2>" SKIP
        "   </div>" SKIP
        "</DIV>" SKIP(1). 

END.  /** of if v-event_id = blank **/

ELSE DO:

    FIND event_mstr WHERE event_mstr.event_id = v-event_ID AND 
        event_mstr.event_deleted = ? NO-LOCK NO-ERROR.

    IF AVAILABLE (event_mstr) THEN DO:
        
/*                      ADD IN THE STUFF FOR THE THEME CSS OR OTHER CODE                      */
/*                      Add in some sort of optional code to make the event_name appear or not*/
            
                      
        {&OUT}
            "<!-- Header / Home-->" SKIP
            "<DIV class='w3-display-container w3-wide w3-grayscale-min' id='home'>" SKIP
            "   <div class='w3-display-top w3-center'>" SKIP.
            
        {&OUT}
            "<!-- Event Basic Info -->" SKIP 
            "   <H1 class='w3-jumbo w3-center'>" event_mstr.event_name "</H1>" SKIP
            "   <H3 class='w3-xxlarge w3-center'>" event_mstr.event_slogan "</H3>" SKIP(1).
             
        IF event_mstr.event_start_date <> event_mstr.event_end_date THEN
            {&OUT}
                "       <H5>" event_mstr.event_start_date " - " event_mstr.event_end_date "</H5>" SKIP.

        ELSE
            {&OUT}
                "       <H5>" event_mstr.event_start_date "</H5>" SKIP.                
                

        FIND FIRST att_files WHERE att_files.att_table = "event_mstr" AND
            att_files.att_field1 = "event_ID" AND
            att_files.att_field2 = "LOGO" AND 
            att_files.att_field3 = "SORT_ORDER" AND 
            att_files.att_value1 = STRING(v-event_ID) AND 
            att_files.att_deleted = ?
                NO-LOCK NO-ERROR.

        IF AVAILABLE (att_files) THEN
            {&OUT}
                "       <img src=~"" att_files.att_filepath att_files.att_filename "~" class='w3-padding' width='100%'></img>" SKIP.

        ELSE
            {&OUT}
                "       <A href='http://www.mysolsource.com/'>" SKIP
                "<img src='/depot/src/HTMLContent/images/Solsource_logo.jpg' class='w3-padding' width='25%' alt='Solsource_logo'></img>" SKIP
                "</A>" SKIP.




        {&OUT}
            "   </div>" SKIP
            "</DIV>" SKIP(1).

    END.  /** OF IF AVAILABLE event_mstr **/

END.  /*** OF ELSE DO --- v-event_ID <> "" ***/


/***************************  END OF INCLUDE FILE  ****************************/

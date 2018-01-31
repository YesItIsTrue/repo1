/*------------------------------------------------------------------------
    File        : MB_card_period.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Trae Luttrell
    Created     : Thu Sep 07 13:03:07 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/


/*------------------------------------------------------------------------
  
  Input Parameters:
  -----------------
  {1}   = MB_mstr.MB_BSA_ID                 /* Merit Badge ID */
  {2}   = period                            /* ex: s12 m6 l3 */
  {3}   = numeric count of seats open.      /* open seat count */
  {4}   = w3-col mpecifications             /* ex: s12 m6 l3 */
  {5}   = actual sched_class_ID             /* Class ID in case a class is taught more than once per event */
  
  ----------------------------------------------------------------------
  
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 05/Sep/17.  Based off of layout code
            developed by TRAE LUTTRELL in several versions of the 
            AMSmerit2U.html code.
  1.1 - written by TRAE LUTTRELL on 08/Sep/17.  Got this working with 
            the MBW2 code (AMSmerit2U.html at time of this writing).
  1.11 - written by DOUG LUTTRELL on 08/Sep/17.  Found a bug in the display 
            of the MBs that had to do with the value being passed into 
            quotes instead of into a string command.  Added support for 
            standard ITmessages from calling program to show in this one.
            Marked by 111.
  1.2 - written by DOUG LUTTRELL on 09/Sep/17.  Realized that you can have
            a class being taught more than once at an event which is why
            we actually have a class_ID instead of just the event_ID and 
            the MB_BSA_ID.  Doh!  Added in squiggly 5.  Marked by 1dot2.
                        
  ----------------------------------------------------------------------*/  

/* ***************************  Definitions  ************************** */ 


/* ********************  Preprocessor Definitions  ******************** */
  

/* ***************************  Main Block  *************************** */
FIND FIRST att_files WHERE att_files.att_table = "MB_mstr" AND 
    att_files.att_field1 = "MB_BSA_ID" AND 
    att_files.att_value1 = STRING({1}) AND                                                                  /* 111 */
    att_files.att_deleted = ? AND 
    att_files.att_category = "IMAGE"
        NO-LOCK NO-ERROR.
    
{&OUT}
    "       <div class='w3-col {4} w3-padding'>" SKIP 
    "           <div class='w3-row w3-padding w3-card-4 w3-white w3-center'>" SKIP
    "               <div id='card-head'>" SKIP
    "                   <div class='w3-col m1 m1'>" SKIP
    "                       <input type='radio' class='w3-radio' name='".

IF {2} = "1" THEN {&OUT} "h-period-1".
 
ELSE IF {2} = "2" THEN {&OUT} "h-period-2".

{&OUT}
    "' value='" {5} "'></input>" SKIP.                                           /* 1dot2 --- used to be squiggly 1 */
    
/*** 1dot2 -- adding in ITmessages support to be thorough ***/
IF ITmessages = YES THEN                                                        /* 1dot2 */
    {&OUT} {5} SKIP.                                                      /* 1dot2 */


{&OUT}    
    "                   </div>  <!-- end of div --- radio -->" SKIP
    "                   <div class='w3-col m8 m8'>" SKIP
    "                       <p class='w3-large'><b> ".
    
IF ITmessages = YES THEN                                                                                    /* 111 */
    {&OUT} {1} " - ".                                                                                       /* 111 */

{&OUT}
    MB_mstr.MB_name " </b></p>" SKIP
    "                   </div>  <!-- end of div --- MB Name -->" SKIP
    "                   <div class='w3-col m3 m3'>" SKIP 
    "                       <img src='".
    
IF AVAILABLE (att_files) THEN {&OUT} " " att_files.att_filepath "/" att_files.att_filename " ".
ELSE {&OUT} "/depot/src/HTMLContent/images/Scouting/Emergency_Preparedness.jpg".

{&OUT}
    "' class='w3-right w3-circle' style='width:100%; padding-bottom: 4%'/>" SKIP
    "                   </div>  <!-- end of DIV --- image / icon -->" SKIP
    "                   <div class='w3-row'>" SKIP
    "                       <span class='w3-small'>".
    
IF AVAILABLE (mb_mstr) THEN {&OUT} " " MB_mstr.MB_desc " " .
ELSE {&OUT} "This class is undoubtably going to be awesome and earn your praise and approval.".

{&OUT}              
    "</span>" SKIP
    "                   </div>  <!-- end of DIV --- MB Description -->" SKIP
    "                   <br>" SKIP
    "                   <div class='w3-row'>" SKIP
    .
    
IF AVAILABLE (mb_mstr) AND MB_mstr.MB__log01 = YES THEN 
{&OUT}
    "                       <div class='w3-col m2 m1 w3-padding-bottom '>" SKIP
    "                           <img src='/depot/src/HTMLContent/images/Scouting/50px-EagleMedal.jpg' class='w3-right' style='width:100%' />" SKIP
    "                       </div>" SKIP
    "                       <div class='w3-col m10 m11' style='color:grey; text-align:right'> Open Seats: " {3} "</div>" SKIP.  

ELSE 
{&OUT} 
    "                       <div class='w3-col m12' style='color:grey; text-align:right'> Open Seats: " {3} "</div>" SKIP.
    
{&OUT}
    "                   </div>  <!-- end of DIV --- card footer row - icons, etc. -->" SKIP
    "               </div>  <!-- end of DIV --- card head -->" SKIP
    "           </div>  <!-- end of DIV --- card row -->" SKIP
    "       </DIV>  <!-- end of DIV --- card main -->" SKIP (2)
    .
    
/*******************  End of File.  ***************************/
    
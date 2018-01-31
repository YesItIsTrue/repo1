
/*------------------------------------------------------------------------
    File        : MB_card.i
    Purpose     : 

    Syntax      :

    Description : Makes an individual MB Card for use in the form.

    Author(s)   : Doug Luttrell
    Created     : Tue Sep 05 16:41:27 EDT 2017
    Notes       :
  
  ----------------------------------------------------------------------
  
  Input Parameters:
  -----------------
  {1}   = MB_mstr.MB_BSA_ID                 /* Merit Badge ID */
  {2}   = numeric order in array for MB.    /* array counter */
            Depends on the presence of a 
            variable called v-MB_Name that is an array holding MB variable 
            names.  Example: v-MB_Name[4] = "h-Communications".
  {3}   = numeric count of seats open.      /* open seat count */
  
  ----------------------------------------------------------------------
  
  Revision History:
  -----------------
  1.0 - written by DOUG LUTTRELL on 05/Sep/17.  Based off of layout code
            developed by TRAE LUTTRELL in several versions of the 
            AMSmerit2U.html code.
            
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
FIND MB_mstr WHERE MB_mstr.MB_BSA_ID = {1} AND 
    MB_mstr.MB_deleted = ?
        NO-LOCK NO-ERROR.
    
FIND FIRST att_files WHERE att_files.att_table = "MB_mstr" AND 
    att_files.att_field1 = "MB_BSA_ID" AND 
    att_files.att_deleted = ? 
        NO-LOCK NO-ERROR.

    
{&OUT}
    "       <div class='w3-col m12 l4 w3-padding'>" SKIP 
    "           <div class='w3-row w3-padding w3-card-4 w3-white w3-center'>" SKIP
    "               <div id='card-head'>" SKIP
    "                   <div class='w3-col m1 m1'>" SKIP
    "                       <input type='checkbox' class='w3-check' name='" v-MB_Name[{2}] "' value='" MB_mstr.MB_name "'></input>" SKIP
    "                   </div>  <!-- end of div --- checkbox -->" SKIP
    "                   <div class='w3-col m8 m8'>" SKIP
    "                       <p class='w3-large'><b>" MB_mstr.MB_name "</b></p>" SKIP
    "                   </div>  <!-- end of div --- MB Name -->" SKIP
    "                   <div class='w3-col m3 m3'>" SKIP 
    "                       <img src='" 
    att_files.att_filepath "/" att_files.att_filename 
    "' class='w3-right w3-circle' style='width:100%; padding-bottom: 4%'/>" SKIP
    "                   </div>  <!-- end of DIV --- image / icon -->" SKIP
    "                   <div class='w3-row'>" SKIP
    "                       <span class='w3-small'>" MB_mstr.MB_desc "</span>" SKIP
    "                   </div>  <!-- end of DIV --- MB Description -->" SKIP
    "                   <br>" SKIP
    "                   <div class='w3-row'>" SKIP
    "                           <div class='w3-col m2 m1 w3-padding-bottom '>".
    
IF MB_mstr.MB__log01 = YES THEN 
    {&OUT}
        "<img src='/depot/src/HTMLContent/images/Scouting/50px-EagleMedal.jpg' class='w3-right' style='width:100%' /></div>" SKIP.   /* should be tied to an att_files record */
    
{&OUT}
    "                           <div class='w3-col m10 m11' style='color:grey; text-align:right'> Open Seats: " 
    {3}     /* open seat count */    
    "</div> <!-- end of DIV --- open seats -->" SKIP
    "                   </div>  <!-- end of DIV --- card footer row - icons, etc. -->" SKIP
    "               </div>  <!-- end of DIV --- card head -->" SKIP
    "           </div>  <!-- end of DIV --- card row -->" SKIP
    "       </DIV>  <!-- end of DIV --- card main -->" SKIP(1).
    
/*******************  End of File.  ***************************/
    

/*------------------------------------------------------------------------
    File        : TKnuclearDelU-form.i
    Description : .i file for Solsource Maintenance Template.  Needs to be resaved as a new file when being used with a program.

    Author(s)   : Jacob Luttrell
    Created     : Tue Apr 19 08:41:29 MDT 2016
    Notes       :
        {1} = Next act
 
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
"<form>" SKIP
    "<DIV class='row'>" SKIP
    "<DIV class='grid_3'> </DIV>" SKIP
    "<DIV class='grid_6'>" SKIP
    "<div class='table_2col'>" SKIP
    "   <table>" SKIP(1)
    "       <tr>" SKIP
    "           <th colspan=4>Testkit Delete</th>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Testkit ID / Sequence</td>" SKIP
    "           <td>" TK_mstr.TK_ID " / " TK_mstr.TK_test_seq "</td>" SKIP
    "           <td>Test Type</td>" SKIP
    "           <td>" TK_mstr.TK_test_type "</td>" SKIP        
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Domestic?</td>" SKIP
    "           <td>" TK_mstr.TK_domestic "</td>" SKIP
    "           <td>Professional?</td>" SKIP
    "           <td>" TK_mstr.TK_prof "</td>" SKIP
    "       </tr>" SKIP(1)
    "       <tr>" SKIP
    "           <td>Created By</td>" SKIP
    "           <td>" TK_mstr.TK_created_by "</td>" SKIP
    "           <td>Date Created</td>" SKIP
    "           <td>" TK_mstr.TK_create_date "</td>" SKIP
    "       </tr>" SKIP(1)
    "   </table>" SKIP 
    "</div>" SKIP
    "</DIV>         <!-- end of grid_6 -->" SKIP
    "<DIV class='grid_3'> </DIV>" SKIP  
    "</DIV>     <!-- end of row -->" SKIP    
    "<BR>"  SKIP.

    
IF "{1}" = "INITIAL" THEN   
   
    {&OUT}
"<div class='row'>" SKIP
        "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP          
        "<INPUT type='hidden' name='h-tk-id' value='" v-tk-id "' />" SKIP
        "<INPUT type='hidden' name='h-tk-seq' value='" v-tk-seq "' />" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>Search Again</BUTTON></div>" SKIP
        "   <div class='grid_5'> </DIV>" SKIP
        "</div>" SKIP
        "</form>" SKIP.

ELSE    
    {&OUT}    
        "<div class='row'>" SKIP
        "<INPUT type='hidden' name='h-tk-id' value='" v-tk-id "' />" SKIP
        "<INPUT type='hidden' name='h-tk-seq' value='" v-tk-seq "' />" SKIP
        "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP 
        "<INPUT type='hidden' name='h-new' value='" v-new "' />" SKIP         
        "   <div class='grid_3'> </DIV>" SKIP
        "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='INITIAL' class='btn'>Search Again</BUTTON></div>" SKIP
        "   <div class='grid_2'> </DIV>" SKIP
        "   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>Delete</BUTTON></div>" SKIP
        "   <div class='grid_3'> </DIV>" SKIP
        "</div>" SKIP   
        "</form>" SKIP.  
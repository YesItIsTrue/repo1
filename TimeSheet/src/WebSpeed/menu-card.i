
/*------------------------------------------------------------------------
    File        : menu-card.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Sat Oct 28 13:50:37 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/* {menu-card.i menu_mstr.menu_exprog menu_mstr.menu_title menu_mstr.menu_icon. */
{&OUT}
    "<a href='{1}'>" SKIP
    "   <div class='col-md-4'>" SKIP
    "       <div class='w3-container w3-card-4 w3-white w3-hover-theme w3-round w3-content col-md-12'>" SKIP
    "           <div class='component-card'>" SKIP
    "               <div class='icon'><i class='{3}'></i></div>" SKIP
    "               <h1>{2}</h1>" SKIP
    "           </div>" SKIP
    "       </div>" SKIP
    "   </div>" SKIP
    "</a>" SKIP.
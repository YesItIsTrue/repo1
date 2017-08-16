
/*------------------------------------------------------------------------
    File        : RP-rec-display.i
    Purpose     : 

    Syntax      :

    Description : Responsible Person short record display for user feedback.

    Author(s)   : Mark Jacobs
    Created     : Thu Jun 11 11:19:39 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


{&OUT}   
/*                "<div ciass='grid_12'>" SKIP*/
                " <div class='row'>" SKIP
                " <div class='grid_2'></div>" SKIP    
                " <div class='grid_8'>" SKIP
                "    <div class='pancake'>" SKIP
                "      <table>" SKIP
                "          <thead>" SKIP
                "              <tr>" SKIP
                "                  <th colspan='3'>Responsible Person</th>" SKIP /*  For&nbsp;&nbsp;<i> " patfstn ", " patlstn " */
                "                  </tr>" SKIP
                "          </thead>" SKIP
                "              <tr>" SKIP
                "                  <td>ID</td>" SKIP
                "                  <td>Name</td>" SKIP
                "                  <td>Address</td>" SKIP
                "              </tr>" SKIP
                "              <tr>" SKIP
                "                  <td>" RP-peop-id "</td>" SKIP
                "                  <td>" RP-fstn ", " RP-lstn "</td>" SKIP.
                
                   IF RP-add1 = "" THEN
{&OUT}                    
                "                  <td></td>" SKIP
                "              </tr>" SKIP
                "      </table>" SKIP
                "    </div>" SKIP 
                "    <br>" SKIP 
                " </div>" SKIP
                " <div class='grid_2'></div>" SKIP
                " </div>" SKIP 
                " </div>" SKIP. 
                
                    ELSE 
{&OUT}                       
                "                  <td>" RP-add1 ", " RP-city ", " RP-state-prov " </td>" SKIP
                "              </tr>" SKIP
                "      </table>" SKIP
                "    </div>" SKIP 
                "    <br>" SKIP 
                " </div>" SKIP
                " <div class='grid_2'></div>" SKIP
/*                " </div>" SKIP*/
                " </div>" SKIP.   
                                                                              
                
                
                
                
                
                     

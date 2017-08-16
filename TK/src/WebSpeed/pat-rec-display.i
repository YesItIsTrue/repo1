
/*------------------------------------------------------------------------
    File        : pat-rec-display.i
    Purpose     : 

    Syntax      :

    Description : Displays short patient record for user feedback.

    Author(s)   : Mark Jacobs
    Created     : Thu Jun 11 08:55:41 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


{&OUT}   
                " <div ciass='grid_12'>" SKIP               
                " <div class='row'>" SKIP                 
                " <div class='grid_2'></div>" SKIP    
                " <div class='grid_8'>" SKIP
                "    <div class=pancake>" SKIP
                "      <table>" SKIP
                "          <thead>" SKIP
                "              <tr>" SKIP
                "                  <th colspan='3'>Patient </th>" SKIP /*  For&nbsp;&nbsp;<i> " patfstn ", " patlstn " */
                "                  </tr>" SKIP
                "          </thead>" SKIP
                "              <tr>" SKIP
                "                  <td>Patient ID</td>" SKIP
/*                "                  <td>Patient Age</td>" SKIP*/
                "                  <td>Name</td>" SKIP
                "                  <td>Address</td>" SKIP
                "              </tr>" SKIP
                "              <tr>" SKIP
                "                  <td>" peop-ID "</td>" SKIP
/*                "                  <td>" patientage " </td>" SKIP*/
                "                  <td>" patfstn ", " patlstn "</td>" SKIP.
                
                    IF add1 = "" THEN
{&OUT}                    
                "                  <td></td>" SKIP
                "              </tr>" SKIP
                "      </table>" SKIP
                "    </div>" SKIP 
                "    <br>" SKIP 
                " </div>" SKIP
                " <div class='grid_2'></div>" SKIP
                " </div>" SKIP. 
                 
                    ELSE 
{&OUT}                       
                "                  <td>" add1 ", " city ", " state-prov " </td>" SKIP
                "              </tr>" SKIP
                "      </table>" SKIP
                "    </div>" SKIP 
                "    <br>" SKIP 
                " </div>" SKIP
                " <div class='grid_2'></div>" SKIP
                " </div>" SKIP.  
                
                
                
                
                    
 
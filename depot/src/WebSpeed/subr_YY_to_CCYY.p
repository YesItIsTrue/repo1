   				 
/*------------------------------------------------------------------------
    File        : subr_YY_to_CCYY.p
    Project     : depot.
    Author(s)   : Harold Luttrell, Sr.
    Created     : Sept 3, 2014.
    Notes       : A routine to re-format the Progress date to the HTML5
                :   date pop-up calendar box display.
    
    Description : Takes the input date (mm-dd-yy) to a temp field as mm-dd-ccyy 
                    and then move the temp field back to the input date field.
                    
                  The maximum input text field length is set to 10 characters. 
                    
    Usage format:    ASSIGN ip_text = ip-date field.
                     RUN "../depot/rcode/subr_YY_to_CCYY.r" (Progress-Date, OUTPUT html5-date). 
                     ASSIGN Display-html5-date-field = html5-date.
                     "<input type='date' name='html5-date' value='" Display-html5-date-field "' />"
      - - Version History - -
      
          1.0 - Sept 2014 - Original code.

          1.1 - Oct. 3, 2014 - Changed format NOT to use "20" hard-coded for the
                    century.  Trae found that the century was not correct before 
                    a certain year.
                    Modified code to use the entire date data from a Progress date field and
                    re-format it to fit the HTML5 Calendar date pop-up format dispay box.
                                                                                 
  ----------------------------------------------------------------------*/ 				 

DEFINE  INPUT    PARAMETER    Progress-Date  AS DATE                         NO-UNDO.

DEFINE  OUTPUT   PARAMETER    html5-date     AS CHARACTER FORMAT "x(10)"     NO-UNDO. 

/*  convert progress date to HTML5 date format.  */

ASSIGN html5-date = STRING(YEAR(Progress-Date), "9999") + "-" + STRING(MONTH(Progress-Date), "99") + "-" + STRING(DAY(Progress-Date), "99").
       
 /* End of SUBROUTINE code. */

/*------------------------------------------------------------------------
    File        : Java_ClickableRow.i
    Purpose     : Code Unification

    Syntax      :

    Description : Java Script for highlighting and clicking rows.

    Author(s)   : Jacob Luttrell
    Created     : Thu Apr 21 09:15:53 MDT 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

/********** * * * JAVASCRIPT * * * *************/
</script> 

<script TYPE='text/javascript'>

$(document).ready(function() {

                // Get an array of all element heights

                var elementHeights = $('.btn').map(function() {
                    return $(this).height();
                }).get();

                // Math.max takes a variable number of arguments

                var maxHeight = Math.max.apply(null, elementHeights);

                // Set each height to the max height

                $('.btn').height(maxHeight);
            });

$(document).ready(function() {
   //change .table to the table class being used.
    $('.table_report tbody tr').click(function(event) {
        if (event.target.type !== 'radio') {
            $(':radio', this).trigger('click');
        }
    });
});

</script>

<SCRIPT language='SpeedScript'>
/********** * * * END OF JAVA * * * *************/ 
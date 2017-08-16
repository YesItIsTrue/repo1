
/*------------------------------------------------------------------------
    File        : UOMmaintU-form.i
    Purpose     : hold repeated code

    Syntax      :

    Description : include file for UOMmaintU.html	

    Author(s)   : Jacob Luttrell
    Created     : Wed Mar 04 14:38:31 MST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */ 

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{&OUT}
"<DIV class='row'>" SKIP
"<DIV class='grid_2'> </DIV>" SKIP
"<DIV class='grid_8'>" SKIP
    "<FORM method='get' id='UOMmaintU-form'>" SKIP 
    
    "<DIV class='table_col'>" SKIP
    "<TABLE>" SKIP 
    "   <TR>" SKIP
    "       <TH colspan=2>Unit of Measure Maintenance</TH>" SKIP
    "   <TR>" SKIP
    "       <TD>Unit of Measure</TD>" SKIP 
    "       <TD class='REQ'>" SKIP.
     
IF "{2}" = "DISABLED" THEN 
    {&OUT}
        "<input type='hidden' name='h-uomuom' value='" uomuom "' >" SKIP  
        uomuom "</td>" SKIP.
        
ELSE DO:
    IF "{1}" = "CREATE_UOM" THEN DO:
    {&OUT}                                                                                                       
            "         <input type='text' name='h-uomuom' value='" uomuom "' size=8 />" SKIP 
            "       </TD>" SKIP.
    END. /* 1 = CREATE */
    ELSE DO: 
    {&OUT}
        "           <select name='h-uomuom' value='" uomuom "' {2} >" SKIP.  /*** start of drop down ***/
        
    IF "{4}" <> "DELETE" THEN
        {&OUT}
            "               <option value=''> </option>" SKIP.                          /* 1dot2 */
   
    FOR EACH uom_mstr WHERE uom_mstr.uom_deleted = ? NO-LOCK
        BY uom_mstr.uom_uom:                                               /* 1dot2 - bonus fix on sort */ 
        
        IF uom_mstr.uom_uom = uomuom THEN 
            thisuom  = "SELECTED".
        ELSE 
            thisuom  = "".
            
        {&OUT}
            "               <option value='" uom_mstr.uom_uom "' " thisuom " > " uom_mstr.uom_uom " </option>" SKIP.
            
    END.  /** of 4ea. uom_mstr **/
    
    
    {&OUT} 
        "           </select>" SKIP
        "       </TD>" SKIP.
     END. /* else do 1 <> CREATE */    
END.  /** of else do --- {2} <> "DISABLED" **/

{&OUT}                                                                                              
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Unit of Measure Type</TD>" SKIP
    "       <TD>" SKIP 
    "           <select name='h-uomtype' {3} >" SKIP.
    
IF uomtype = "DOSAGE" THEN 
  {&OUT}  
    "               <option value='DOSAGE' SELECTED>DOSAGE</option> " SKIP.
    ELSE
    {&OUT}  
    "               <option value='DOSAGE' >DOSAGE</option> " SKIP.

IF uomtype = "PURCHACE" THEN   
   {&OUT} 
    "               <option value='PURCHACE' SELECTED>PURCHACE</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='PURCHACE'>PURCHACE</option> " SKIP.
 
IF uomtype = "SALE" THEN   
    {&OUT} 
"               <option value='SALE' SELECTED>SALE</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='SALE'>SALE</option> " SKIP.  

IF uomtype = "CONSUMPTION" THEN   
    {&OUT} 
"               <option value='CONSUMPTION' SELECTED>CONSUMPTION</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='CONSUMPTION'>CONSUMPTION</option> " SKIP.

IF uomtype = "STORAGE" THEN   
    {&OUT} 
"               <option value='STORAGE' SELECTED>STORAGE</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='STORAGE'>STORAGE</option> " SKIP.

IF uomtype = "REORDER" THEN   
    {&OUT} 
"               <option value='REORDER' SELECTED>REORDER</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='REORDER'>REORDER</option> " SKIP.

IF uomtype = "HEIGHT" THEN   
    {&OUT} 
"               <option value='HEIGHT' SELECTED>HEIGHT</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='HEIGHT'>HEIGHT</option> " SKIP.

IF uomtype = "LENGTH" THEN   
    {&OUT} 
"               <option value='LENGTH' SELECTED>LENGTH</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='LENGTH'>LENGTH</option> " SKIP.

IF uomtype = "WIDTH" THEN   
    {&OUT} 
"               <option value='WIDTH' SELECTED>WIDTH</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='WIDTH'>WIDTH</option> " SKIP.
    
IF uomtype = "VOLUME" THEN   
    {&OUT} 
"               <option value='VOLUME' SELECTED>VOLUME</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='VOLUME'>VOLUME</option> " SKIP.

IF uomtype = "NET_WEIGHT" THEN   
    {&OUT} 
"               <option value='NET_WEIGHT' SELECTED>NET WEIGHT</option> " SKIP.
    
    ELSE 
    {&OUT}
    "               <option value='NET_WEIGHT'>NET WEIGHT</option> " SKIP.

{&OUT} 
    "         </SELECT>" SKIP               
    "       </TD>" SKIP 
    "   </TR>" SKIP
    "   <TR>" SKIP
    "       <TD>Unit of Measure Description</TD>" SKIP
    "       <TD>" SKIP 
            "             <input type='text' name='h-uomdesc' value='" uomdesc "' size=24 {3} />" SKIP
    "       </TD>" SKIP
    "   </TR>" SKIP
    "     <TR>" SKIP
/*    "         <TD>Unit of Measure Value</TD>" SKIP                                                */
/*    "         <TD>" SKIP                                                                          */
/*    "       <TD>" SKIP                                                                            */
/*    "             <input type='decimal' name='h-uomvalue' value='" uomvalue "' size=8 {3} />" SKIP*/
/*    "       </TD>" SKIP                                                                           */
/*    "   </TR>" SKIP                                                                               */
/*    "         <TD>Unit of Measure Destination</TD>" SKIP                                          */
/*    "         <TD>" SKIP                                                                          */
/*    "       <TD>" SKIP                                                                            */
/*    "             <input type='decimal' name='h-uomdest' value='" uomdest "' size=8 {3} />" SKIP  */
/*    "       </TD>" SKIP                                                                           */
/*    "   </TR>" SKIP                                                                               */
    "</TABLE>" SKIP
    "</DIV>" SKIP.
    
                                                                                IF ITshowmsg = YES THEN 
                                                                                    {&OUT}
                                                                                        "uom = " uomuom SKIP.
        
{&OUT}         
    "<center>" SKIP
    "</DIV>         <!-- end of grid_8 -->" SKIP
    "<DIV class='grid_2'> </DIV>" SKIP  
    "</DIV>     <!-- end of row -->" SKIP
    "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP. 
   
   IF "{5}" = "NO_BUTTON" THEN 
   {&OUT}
    "<div class='row'>" SKIP
/*            "<INPUT type='hidden' name='whattorun' value='" get-value('whattorun') "' />" SKIP                  /* 1dot2 - bonus fix */*/
            "   <div class='grid_5'> </DIV>" SKIP
            "   <div class='grid_2'><button type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP
            "   <div class='grid_5'> </DIV>" SKIP
            "</div>" SKIP.
   ELSE
   {&OUT} 
   "<div class='row'>" SKIP
"   <div class='grid_3'> </DIV>" SKIP
"   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{1}' class='btn'>{1}</BUTTON></div>" SKIP
"   <div class='grid_2'> </DIV>" SKIP
"   <div class='grid_2'><BUTTON type='submit' name='h-act' value='{5}' class='btn'>{5}</BUTTON></div>" SKIP
"   <div class='grid_3'> </DIV>" SKIP
"</div>" SKIP.
    
{&OUT}
    "</center>" SKIP
    "</DIV>" SKIP
    "</FORM>" SKIP.
    
    
    
/*****************************  End of File  *********************************/    
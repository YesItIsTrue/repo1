
/*------------------------------------------------------------------------
    File        : TRH-Hist-Dates.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Doug and Harold Luttrell
    Created     : Wed Oct 07 21:34:31 CDT 2015
  
    Version History:
        1dot1 - Written by Jacob Luttrell on 25/Nov/15.
                Removed disabled functions form paid by cust input.
                Marked by 1dot1.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
        {&OUT}
                "<DIV class='table_3col'>" SKIP
                "   <TABLE>" SKIP
                "       <TR>" SKIP
                "           <TH colspan=6>Transaction History Information</TH>" SKIP
                "       </TR>" SKIP

    /****************** trh_hist Row 1 ***************************/
                "       <TR>" SKIP                                                          
                "           <TD>Created</TD>" SKIP.
                
IF  x-loop = 0 THEN DO:                              /* Harold */   /* Convert i/p dates to html5 formats. */                              
    DO WHILE x-loop < 17:
        ASSIGN x-loop = (x-loop + 1).
                RUN VALUE(SEARCH("subr_YY_to_CCYY.r")) (datelist[x-loop], OUTPUT CCYY-Date).
     
        ASSIGN html5-datelist[x-loop] = SUBSTRING (CCYY-Date, 6, 2) + "/" +
                                        SUBSTRING (CCYY-Date, 9, 2) + "/" + 
                                        SUBSTRING (CCYY-Date, 1, 4).                                            
                                         
/*            {&OUT}   "datelist[x-loop] = " datelist[x-loop] SKIP.*/
/*            {&OUT}   "CCYY-Date = " CCYY-Date SKIP.*/
/*    {&OUT}   "html5-datelist[x-loop] = " html5-datelist[x-loop] SKIP.*/

    END.  /* DO WHILE x-loop < 17 */        
    
END.  /* IF  x-loop = 0   */             /* Convert i/p dates to html5 formats. */

IF datelist[14] <> ? THEN                                                                                                           /* 2dot4 */
    RUN VALUE(SEARCH("subr_YY_to_CCYY.r")) (datelist[14], OUTPUT disp-custdate).                                                    /* 2dot4 */
   
   
                                
            IF datelist[1] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-CREATED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[1] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-CREATED' value =" html5-datelist[1] " disabled /></TD>" SKIP.
                                         
            {&OUT} "           <TD>Lab Processed</TD>" SKIP.
                
            IF datelist[7] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-LAB_PROCESS' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[7] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-LAB_PROCESS' value =" html5-datelist[7] " disabled /></TD>" SKIP.                    

            {&OUT} "           <TD>Complete</TD>" SKIP.
                
            IF datelist[13] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-COMPLETE' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[13] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-COMPLETE' value =" html5-datelist[13] " disabled /></TD>" SKIP.                    
                 
            {&OUT}                      
                "       </TR>" SKIP
                "       <TR>" SKIP                                                          
                "           <TD>In Stock</TD>" SKIP.


    /****************** trh_hist Row 2 ***************************/        
         
            IF datelist[2] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-IN_STOCK' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[2] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-IN_STOCK' value =" html5-datelist[2] " disabled /></TD>" SKIP.                    
                
            {&OUT} "           <TD>HHI Received</TD>" SKIP.         

                
            IF datelist[8] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-HHI_RCVD' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[8] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-HHI_RCVD' value =" html5-datelist[8] " disabled /></TD>" SKIP.                    
                     
            {&OUT} "           <TD>Customer Paid</TD>" SKIP.
 
/* 2dot4 */
            IF "{2}" = "REVIEW"  THEN DO:                                                                                                        /* 3dot0 */
                    IF datelist[14] = ? THEN                                                                                                     /* 3dot0 */
                            {&OUT} "           <TD><input type='date' name='h-PAID_BY_CUST' {1} /></TD>" SKIP.                                   /* 3dot0 */           
                    ELSE                                                                                                                         /* 3dot0 */
                        {&OUT} "           <TD><input type='text' name='h-PAID_BY_CUST' value=" html5-datelist[14] " disabled /></TD>" SKIP.     /* 3dot0 */
            END.                                                                                                                                 /* 3dot0 */
            ELSE                                                                                                                                 /* 3dot0 */
                {&OUT} "           <TD><input type='date' name='h-PAID_BY_CUST' value=" disp-custdate " {1} />" SKIP                             /* 3dot0 */
                       "               <input type='hidden' name='h-origcustdate' value=" htmlcustdate " />" SKIP                                /* 3dot0 */
                       "           </TD>" SKIP.                                              /* 1dot1 */                                         /* 3dot0 */

/* 2dot4 */            
            {&OUT}                      
                "       </TR>" SKIP        
                "       <TR>" SKIP                                                          
                "           <TD>Sold</TD>" SKIP.
            

    /****************** trh_hist Row 3 ***************************/         
            
            IF datelist[3] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-SOLD' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[3] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-SOLD' value =" html5-datelist[3] " disabled /></TD>" SKIP.                    
                
            {&OUT} "           <TD>HHI Loaded</TD>" SKIP.         

                
            IF datelist[9] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-LOADED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[9] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-LOADED' value =" html5-datelist[9] " disabled /></TD>" SKIP.                    
                    
            {&OUT} "           <TD>Vendor Paid</TD>" SKIP.
                
            IF datelist[15] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-VEND_PAID' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[15] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-VEND_PAID' value =" html5-datelist[15] " disabled /></TD>" SKIP.                    
                   
            {&OUT}                      
                "       </TR>" SKIP        
                "       <TR>" SKIP                                                            
                "           <TD>Shipped</TD>" SKIP.         

    /****************** trh_hist Row 4 ***************************/         
            
            IF datelist[4] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-SHIPPED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[4] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-SHIPPED' value =" html5-datelist[4] " disabled /></TD>" SKIP.                    

                
            {&OUT} "           <TD>HHI Processed</TD>" SKIP.         

                
            IF datelist[10] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-PROCESSED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[10] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-PROCESSED' value =" html5-datelist[10] " disabled /></TD>" SKIP.                    
                    
            {&OUT} "           <TD colspan=2></TD>" SKIP
                "       </TR>" SKIP        
                "       <TR>" SKIP                                                            
                "           <TD>Collected</TD>" SKIP.         

    /****************** trh_hist Row 5 ***************************/         
            
            IF datelist[5] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-COLLECTED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[5] "</TD>" SKIP.*/                
                {&OUT} "           <TD><input type='text' name='h-COLLECTED' value =" html5-datelist[5] " disabled /></TD>" SKIP.                    

            {&OUT} "           <TD>Printed</TD>" SKIP.         

                
            IF datelist[11] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-PRINTED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[11] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-PRINTED' value =" html5-datelist[11] " disabled /></TD>" SKIP.                    
                    
            {&OUT} "           <TD>Deleted</TD>" SKIP.
                
            IF datelist[16] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-DELETED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[16] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-DELETED' value =" html5-datelist[16] " disabled /></TD>" SKIP.                    
                    
            {&OUT}                      
                "       </TR>" SKIP        
                "       <TR>" SKIP                                                           
                "           <TD>Lab Rcvd</TD>" SKIP.  

    /****************** trh_hist Row 6 ***************************/         
            
            IF datelist[6] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-LAB_RCVD' {1}/></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[6] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-LAB_RCVD' value =" html5-datelist[6] " disabled /></TD>" SKIP.                    
                
            {&OUT} "           <TD>Emailed</TD>" SKIP.         

                
            IF datelist[12] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-CD_EMAILED' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[12] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-CD_EMAILED' value =" html5-datelist[12] " disabled /></TD>" SKIP.                    
                    
            {&OUT} "           <TD>VOID</TD>" SKIP.
                
            IF datelist[17] = ? THEN 
                {&OUT} "           <TD><input type='date' name='h-VOID' {1} /></TD>" SKIP.
            ELSE 
/*                {&OUT} "           <TD>" datelist[17] "</TD>" SKIP.*/
                {&OUT} "           <TD><input type='text' name='h-VOID' value =" html5-datelist[17] " disabled /></TD>" SKIP.                    
                    
            {&OUT}                      
                "       </TR>" SKIP     
                "   </TABLE>" SKIP
                "</DIV>             <!-- end of table_3col -->" SKIP.                                                 

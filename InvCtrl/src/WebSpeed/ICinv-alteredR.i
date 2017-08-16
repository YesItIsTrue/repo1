
/*------------------------------------------------------------------------
    File        : ICinv-alteredR.i

    Description : This is the report parts of the QOH report and the TRH report 
        specifically of the things you just altered.

    Author(s)   : Trae Luttrell
    Created     : Tue Sep 06 16:44:33 EDT 2016
    Notes       : 
        
        {1} = the trh_hist.trh_id of the thing you just did.
        {2} = the qoh_det.qoh_id of the thing you just did.
  ----------------------------------------------------------------------*/
        
/********************************************* qoh_det SECTION ************************************************/

FIND QOH_det WHERE  
    qoh_det.qoh_site = {2} AND 
    qoh_det.qoh_warehouse = {3} AND 
    qoh_det.qoh_loc = {4} AND 
    qoh_det.qoh_item_nbr = {5} AND 
    qoh_det.qoh_lot = {6} AND 
    qoh_det.qoh_serial = {7} AND 
    qoh_det.qoh_deleted = ?
    NO-LOCK NO-ERROR.
    
IF AVAILABLE (qoh_det) THEN DO:

    {&OUT}
        "<DIV class='row'>" SKIP
        "<DIV class='grid_1'></div>" SKIP
        "<DIV class='grid_10'>" SKIP
        "<DIV class='table_report'>" SKIP
        "    <TABLE>" SKIP
        "        <THEAD>" SKIP
        "            <TR>" SKIP
        "                <TH colspan='11'>Altered Quantity on Hand</TH>" SKIP    
        "            </TR>" SKIP
        "            <TR>" SKIP
        "               <td>Site</td>" SKIP
        "               <td>Warehouse</td>" SKIP
        "               <td>Location</td>" SKIP
        "               <td>Item Number</td>" SKIP
        "               <td>Lot Name</td>" SKIP
        "               <td>Serial</td>" SKIP
        "               <td>Last Count</td>" SKIP
        "               <td>Status</td>" SKIP
        "               <td>Quantity</td>" SKIP
        "               <td>Available</td>" SKIP
        "               <td>Expiration Date</td>" SKIP
        "            </TR>" SKIP
        "        </THEAD>" SKIP(1)
        "        <tr>" SKIP
        "           <td>" qoh_det.qoh_site "</td>" SKIP
        "           <td>" qoh_det.qoh_warehouse "</td>" SKIP
        "           <td>" qoh_det.qoh_loc "</td>" SKIP
        "           <td>" qoh_det.qoh_item_nbr "</td>" SKIP
        "           <td>" qoh_det.qoh_lot "</td>" SKIP
        "           <td>" qoh_det.qoh_serial "</td>" SKIP
        "           <td>" qoh_det.qoh_last_count "</td>" SKIP
        "           <td>" qoh_det.qoh_status "</td>" SKIP
        "           <td>" qoh_det.qoh_quantity "</td>" SKIP
        "           <td>" qoh_det.qoh_avail "</td>" SKIP
        "           <td>" qoh_det.qoh_expire_date "</td>" SKIP
        "       </tr>" SKIP
        "   </table>" SKIP
        "</div>" SKIP
        "</div>" SKIP
        "<DIV class='grid_1'></div>" SKIP
        "</div>" SKIP 
        "<br></br>" SKIP.

END. /* find qoh_det. */

/* *******************************************  TRH_hist Block  ************************************************* */
FIND trh_hist WHERE trh_hist.trh_ID = {1}        
    NO-LOCK NO-ERROR.  
    
IF AVAILABLE (trh_hist) THEN DO:

    {&OUT}
        "<div class='row'>"                                     SKIP
        "<div class='grid_1'></div>"                            SKIP
        "<div class='grid_10'>"                                 SKIP
/*        "<form>"                                                SKIP*/
        "<div class='table_2col'>"                               SKIP
        "   <table>"                                            SKIP
        "       <thead>"                                        SKIP
        "           <tr>"                                       SKIP
        "               <th colspan=4>Transaction History Detail</th>"  SKIP
        "           </tr>"                                      SKIP
        "       </thead>"                                       SKIP         
        "           <tr>"                                       SKIP
        "               <td>Transation ID               </td>"  SKIP
        "               <td colspan=3>" trh_hist.trh_ID           "</td>" SKIP
        "           </tr>"                                      SKIP 
        "           <tr>"                                       SKIP
        "               <td>Item                        </td>"  SKIP
        "               <td>" trh_hist.trh_item         "</td>" SKIP
        "               <td>Action                      </td>"  SKIP
        "               <td>" trh_hist.trh_action       "</td>" SKIP
        "           </tr>"                                      SKIP

        "           <tr>"                                       SKIP
        "               <td>Quantity                    </td>"  SKIP
        "               <td>" trh_hist.trh_qty          "</td>" SKIP
        "               <td>Location                    </td>"  SKIP
        "               <td>" trh_hist.trh_loc          "</td>" SKIP
        "           </tr>"              

        "           <tr>"                                       SKIP
        "               <td>Lot                         </td>"  SKIP
        "               <td>" trh_hist.trh_lot          "</td>" SKIP
        "               <td>Serial                  </td>"  SKIP
        "               <td>" trh_hist.trh_serial       "</td>" SKIP
        "           </tr>" 

        "           <tr>"                                       SKIP 
        "               <td>Date                        </td>"  SKIP    
        "               <td>" trh_hist.trh_date         "</td>" SKIP 
        "               <td>Order Number                </td>"  SKIP
        "               <td>" trh_hist.trh_other_ID     "</td>" SKIP 
        "           </tr>"  SKIP

        "           <tr>"                                       SKIP
        "               <td>Created by                  </td>"  SKIP
        "               <td>" trh_hist.trh_created_by   "</td>" SKIP
        "               <td>Date Created                </td>"  SKIP
        "               <td>" trh_hist.trh_create_date  "</td>" SKIP
        "           </tr>"

        "           <tr>"                                       SKIP
        "               <td>Modified by                 </td>"  SKIP
        "               <td>" trh_hist.trh_modified_by  "</td>" SKIP
        "               <td>Date Modified               </td>"  SKIP
        "               <td>" trh_hist.trh_modified_date "</td>" SKIP
        "           </tr>"
         
        "           <tr>"                                       SKIP
        "               <td >Transaction Comments        </td>"  SKIP
        "               <td colspan=3>" trh_hist.trh_comments     "</td>" SKIP
        "           </tr>"
        "           <tr>"                                       SKIP
        
        "           </tr>"  SKIP          
        "   </table>"       SKIP
        "</div> "           SKIP
                "</div><!-- of grid_10 -->" SKIP
        "<div class='grid_1'></div>" SKIP
        "</DIV>     <!-- of row -->" SKIP
        "<br></BR>"             SKIP.
       
    
END. /** IF Available **/
    
ELSE 
    {&OUT} 
        "<DIV class='row'>" SKIP
        "<DIV class='grid_4'> </DIV>" SKIP
        "<DIV class='grid_4'>" SKIP
        "<CENTER><h1> Not a valid Transaction ID number. </h1></CENTER>" SKIP
        "</DIV>     <!-- end of grid_4 -->" SKIP
        "<DIV class='grid_4'> </DIV>" SKIP
        "</DIV>     <!-- end of row -->" SKIP  
        "<br>" SKIP.
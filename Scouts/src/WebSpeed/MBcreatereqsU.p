/************
 *
 *  MBcreatereqsU.p - Doug Luttrell - 19/Sep/15 - Version 1.0
 *
 ************/

def var MBname like MB_Name format "x(30)" no-undo.

main-loop:
repeat:

   update MBname
        with frame a width 80 side-labels.
   
   find MB_mstr where MB_name = MBname no-lock no-error.
   
   if not avail (MB_mstr) then do:
    
        message "MB = " MBname " not found in database.  Please re-enter."
            view-as alert-box warning buttons ok.
            
        next main-loop.
   
   end.  /** of if not avail MB_mstr **/
        
   else do:
        
        det-loop:
        repeat:
        
            create MBR_reqs.
            assign
                 MBR_BSA_ID = MB_BSA_ID.
                       
            update MBR_reqs except MBR_BSA_ID
                 with frame b 1 col width 80 side-labels
                     title MBname.
        
        end.  /** of repeat -- det-loop **/
        
   end.  /** of else do --- MB_mstr avail **/     
        
end.    /** of repeat --- main-loop **/


/****************  End of File.  ***************/


def var MBname like MBD_Name format "x(30)" no-undo.

repeat:

   update MBname
        with frame a width 80 side-labels.
   
   create MBD_Det.
   assign
        MBD_name = MBname.
        
   update MBD_Det except MBD_name
        with frame b 1 col width 80 side-labels
            title MBname.
        
        
end.


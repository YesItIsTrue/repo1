/* Utility to export an entire menu section */

DEFINE VARIABLE v-menuroot LIKE menu_num NO-UNDO.
DEFINE VARIABLE outfile AS CHARACTER FORMAT "x(50)" LABEL "Full Filename" 
     INITIAL "C:\progress\wrk\" NO-UNDO.

UPDATE skip(1)
     v-menuroot COLON 20
     outfile COLON 20 skip(1)
          WITH FRAME a WIDTH 80 SIDE-LABELS TITLE "--> Menu Exporter <--".

OUTPUT TO value(outfile).

FOR EACH menu_mstr WHERE menu_num = v-menuroot NO-LOCK:
    
    EXPORT DELIMITER ";" menu_mstr.
    
END.

OUTPUT CLOSE.
DEFINE TEMP-TABLE regdata
    FIELD ln AS CHARACTER FORMAT "x(24)"
    FIELD fn AS CHARACTER FORMAT "x(24)"
    FIELD dob AS DATE
    FIELD provunit AS CHARACTER FORMAT "x(20)"
    FIELD augunit AS CHARACTER FORMAT "x(20)"
    FIELD classlist AS CHARACTER EXTENT 20
        INDEX main-reg-idx AS PRIMARY UNIQUE ln fn.
        
DEFINE VARIABLE stake AS CHARACTER FORMAT "x(20)" NO-UNDO.
DEFINE VARIABLE quorum AS CHARACTER NO-UNDO.
DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE y AS INTEGER NO-UNDO.

PAUSE 0 BEFORE-HIDE.

INPUT from "C:\progress\wrk\imports\YM-Unit-Classes-5.csv".

import-loop:
REPEAT:

   CREATE regdata.
   IMPORT DELIMITER ";" regdata.
   
   IF ln = "" THEN DO:
        DELETE regdata.
        LEAVE import-loop.
   END.
   
END.  /** of repeat -- import loop **/

INPUT close.

maine-loop:
FOR EACH regdata WHERE ln <> "" NO-LOCK:

    y = y + 1.
    
   DISPLAY SKIP(1)
        ln COLON 15 
        fn COLON 15
        dob COLON 15
        provunit COLON 15 augunit COLON 50 SKIP(1)
            WITH FRAME peopdet WIDTH 80 SIDE-LABELS.
      
   DISPLAY classlist[1] COLON 20 classlist[2] COLON 60 SKIP 
        classlist[3] COLON 20 classlist[4] COLON 60 SKIP
        classlist[5] COLON 20 classlist[6] COLON 60 SKIP 
        classlist[7] COLON 20 classlist[8] COLON 60 SKIP
        classlist[9] COLON 20 classlist[10] COLON 60 SKIP 
        classlist[11] COLON 20 classlist[12] COLON 60 SKIP
        classlist[13] COLON 20 classlist[14] COLON 60 SKIP 
        classlist[15] COLON 20 classlist[16] COLON 60 SKIP
        classlist[17] COLON 20 classlist[18] COLON 60 SKIP
        classlist[19] COLON 20 classlist[20] COLON 60 SKIP(1)
        
            WITH FRAME dets SIDE-LABELS WIDTH 80.
        
    IF provunit <> "" THEN 
        stake = "Providence".
    ELSE IF augunit <> "" THEN
        stake = "August".
        
    
    IF dob < (TODAY - (16 * 365)) THEN
        quorum = "Priest".
    ELSE IF dob < (TODAY - (14 * 365)) THEN 
        quorum = "Teacher".
    ELSE IF dob <> ? THEN
        quorum = "Deacon".   
    
    DISPLAY stake quorum WITH FRAME peopldet.            
    
    FIND people_mstr WHERE people_lastname = ln AND 
        people_firstname = fn
            EXCLUSIVE-LOCK NO-ERROR.
            
    IF NOT avail (people_mstr) THEN DO:
        
        NEXT maine-loop.
        
/*         create people_mstr. */
/*         assign */
/*             people_ID           = next-value(seq-people) */
/*             people_lastname     = ln */
/*             people_firstname    = fn. */
            
    END.  /** of if not avail people_mstr **/
    
    ASSIGN
        people_DOB          = IF dob <> ? THEN dob ELSE people_DOB
        people_stake        = stake
        people_ward         = IF stake = "Providence" THEN
                                    provunit
                              ELSE IF stake = "August" THEN 
                                    augunit
                              ELSE 
                                    ""
        people_quorum       = quorum.
        
        
    DO x = 1 TO 20:
    
        IF classlist[x] <> "" THEN DO:
        
            CASE X:
            
                WHEN 1 THEN DO:     /** BSA ID = 123 **/
                
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Rifle Shooting"}.
                    
                END.  /** of 1 **/
            
                WHEN 2 THEN DO:      /** BSA ID = 019 **/
  
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Archery"}.  
                    
                END.  /** of 2 **/            
                    
                WHEN 3 THEN DO:      /** BSA ID = 033 **/
               
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Canoeing"}.  
                    
                    
                END.  /** of 3 **/           
                
                WHEN 4 THEN DO:      /** BSA ID = 900 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Beginning Swimming"}. 
                    
                END.  /** of 4 **/     
                
                WHEN 5 THEN DO:      /** BSA ID = 038 **/
                
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Cooking"}. 
                    
                END.  /** of 5 **/         
                
                WHEN 6 THEN DO:      /** BSA ID = 008 **/
                
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "First Aid"}. 
                    
                END.  /** of 6 **/                
                                           
                WHEN 7 THEN DO:      /** BSA ID = 007 **/
               
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Environmental Science"}. 
                    
                END.  /** of 7 **/   
                
                WHEN 8 THEN DO:      /** BSA ID = 058 **/
               
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Geology"}.  
                    
                END.  /** of 8 **/              
                
                WHEN 9 THEN DO:      /** BSA ID = 800 **/
               
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Sports & Games"}. 
                    
                END.  /** of 9 **/                   
                
                WHEN 10 THEN DO:      /** BSA ID = 098 **/
               
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Rowing"}.   
                    
                END.  /** of 10 **/                  
                
                WHEN 11 THEN DO:      /** BSA ID = 014 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Swimming"}.  
                    
                END.  /** of 11 **/                  
                
                WHEN 12 THEN DO:      /** BSA ID = 003 **/
               
  {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Citizenship in the Nation"}. 
                    
                END.  /** of 12 **/                    
                      
                WHEN 13 THEN DO:      /** BSA ID = 004 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Citizenship in the World"}.  
                    
                END.  /** of 13 **/                         
                      
                WHEN 14 THEN DO:      /** BSA ID = 090 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Public Speaking"}. 
                    
                END.  /** of 14 **/                         
                        
                WHEN 15 THEN DO:      /** BSA ID = 069 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Leatherwork"}.  
                    
                END.  /** of 15 **/                           
                        
                WHEN 16 THEN DO:      /** BSA ID = 027 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Basketry"}.   
                    
                END.  /** of 16 **/                           
                        
                WHEN 17 THEN DO:      /** BSA ID = 052 **/
                
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Fishing"}.   
                    
                END.  /** of 17 **/                          
                
                WHEN 18 THEN DO:      /** BSA ID = 049 **/
               
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Fingerprinting"}. 
                    
                END.  /** of 18 **/                    
                        
                WHEN 19 THEN DO:      /** BSA ID = 147 **/

   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Chess"}.  
                    
                END.  /** of 19 **/                           
                        
                WHEN 20 THEN DO:      /** BSA ID = 901 **/
 
   {c:\openedge\workspace\Scouts\src\create_MB_reqs_detail.i "Trail to 1st Class"}.  
                    
                END.  /** of 20 **/             
                
            END.  /** of CASE x **/                  
                        
        END.  /* of if classlist <> "" */
    
    END. /* x = 1 to 20 */
                
END.  /** of 4ea regdata **/

MESSAGE y VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.

        

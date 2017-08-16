
/*------------------------------------------------------------------------
    File        : DV-DAW-moveDwight-U.i
    Purpose     : To shorten my code.

    Description : The TRANSACTION that has the move and delete for actually updateing the attached files folder. 
                It also contains the export for Dwight's report that is to fix the SQL side of HHI's mess.

    Author(s)   : Trae Luttrell
    Created     : Thu Aug 13 19:04:49 EDT 2015

  ----------------------------------------------------------------------*/
DO TRANSACTION ON ERROR UNDO:  
    
    ASSIGN bigchar = SUBSTRING(v-filelocation,1, (R-INDEX (v-filelocation,"."))) + "pdf".
    
    v-pdf-fl = SEARCH(bigchar).
            
    IF updatemode = YES THEN DO:
    
        OS-COPY VALUE(v-filelocation) VALUE("C:\APPS\BioMed\holding_bin").

        OS-DELETE VALUE(v-filelocation).
        
        IF (v-pdf-fl <> "" AND v-pdf-fl <> "?") THEN DO:
        
            OS-COPY VALUE(v-pdf-fl) VALUE("C:\APPS\BioMed\holding_bin").
        
            OS-DELETE VALUE(v-pdf-fl).
        
        END. /*** of pdf <> "" ***/
        
    END. /*** of the updatemode = yes ***/
    
    IF v-attpeopleID = "" THEN 
        ASSIGN v-attIDint = 0. 
    ELSE ASSIGN v-attIDint = INTEGER(v-attpeopleID).
    
    IF v-fullpath-ID = "" THEN 
        ASSIGN v-fullIDint = 0. 
    ELSE ASSIGN v-fullIDint = INTEGER(v-fullpath-ID).
    
    EXPORT STREAM dwight DELIMITER ";"
        v-peopleID
        v-attIDint
        v-fullIDint 
        v-lab-sampleID 
        x  
        v-testkitID 
        v-testtype. 
    
    IF v-testtype = "UTM / UEE" AND x = 2 THEN 
    
        EXPORT STREAM dwight DELIMITER ";"
        v-peopleID
        v-attIDint
        v-fullIDint 
        v-lab-sampleID 
        1  
        v-testkitID  
        v-testtype.

    IF v-testtype = "UTM / UEE" AND x = 1 THEN

        EXPORT STREAM dwight DELIMITER ";"
        v-peopleID
        v-attIDint
        v-fullIDint
        v-lab-sampleID
        2
        v-testkitID
        v-testtype.

END. /* of Transaction */
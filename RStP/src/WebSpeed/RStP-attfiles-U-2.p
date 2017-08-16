
/*------------------------------------------------------------------------
    File        : RStP-attfiles-U.p
    Purpose     : 

    Syntax      :

    Description : Migrate the attached files data from the PATIENT_RCD table to the att_files table.
                    Designed to be run repeatedly in batch.

    Author(s)   : Doug Luttrell
    Created     : Thu Dec 11 20:19:30 EST 2014
    Notes       :
 
  ----------------------------------------------------------------------
  Revision History:        
  -----------------
  1.0 - written by DOUG LUTTRELL on 11/Dec/14.  Original version.
  1.1 - By Harold Luttrell on 25/Jul/15.
        a.  Added more output data displays for the error log report.  
        b.  Added the THIS-PROCEDURE:FILE-NAME assign to BHE_mstr.BHE_prog_name.
        c.  Added total count for each ERROR! message.
        d.  Removed the preprocessor references to 
            {&this-table}, which was pointing at PATIENT_FILES.
            I did NOT marked this change because there was so many of them I
            didn't want to make the code look junkie.
            Marked by 1dot1. 
  Version 1.2 by Harold Luttrell, Sr  on 22/Nov/15
        Set the progress_flag to 'DL' on ERROR-3! condition.
        Identified by /* 1dot2 */
        
  ----------------------------------------------------------------------
  
  
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/** specific to this program **/   
DEFINE VARIABLE testorpat AS LOGICAL FORMAT "Test/Patient" NO-UNDO.

DEFINE VARIABLE fileroot AS CHARACTER 
    INITIAL "C:\APPS\BioMed\AttachedFiles\" NO-UNDO.


/** useful for all RStP code **/
DEFINE VARIABLE firstrun AS LOGICAL INITIAL YES NO-UNDO.                         /* change to YES for very first run only */

DEFINE VARIABLE loadedlist AS CHARACTER 
    INITIAL "DL,AL,UL,IL" NO-UNDO.
DEFINE VARIABLE recordsprocessed AS INTEGER NO-UNDO.    

DEFINE VARIABLE ERROR-count AS INTEGER EXTENT 6 NO-UNDO.                        /* 1dot1 */  

        /* these are 5 settings to control the emailing of the output file */
DEFINE VARIABLE cmdname         AS CHARACTER INITIAL "C:\APPS\BioMed\batch-files\errormail.exe"         NO-UNDO.
DEFINE VARIABLE emailaddr       AS CHARACTER INITIAL "-r hhi.techsupport@mysolsource.com"               NO-UNDO.
DEFINE VARIABLE messagetxt      AS CHARACTER INITIAL "-m Error Report attached from "                   NO-UNDO.
DEFINE VARIABLE subjtxt         AS CHARACTER INITIAL "-s Error Report from "                            NO-UNDO.
DEFINE VARIABLE cmdparams       AS CHARACTER INITIAL "-a"                                               NO-UNDO.

messagetxt = messagetxt + THIS-PROCEDURE:FILE-NAME.
subjtxt  = subjtxt + THIS-PROCEDURE:FILE-NAME.
    
DEFINE STREAM outward.
DEFINE VARIABLE errlog AS CHARACTER 
    INITIAL "C:\PROGRESS\WRK\RStP-PATIENT_FILES-attfiles-log-2.txt" NO-UNDO.            /* change this to be a filename specific to your program */

OUTPUT STREAM outward TO value(errlog).
EXPORT STREAM outward DELIMITER ";"
    "Program Name" THIS-PROCEDURE:FILE-NAME.
EXPORT STREAM outward DELIMITER ";"
    "Start Run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"                                             /* These are column headers. You need one for each field    */
    "PATIENT_FILES.fileid"                                                      /* that is required for uniqueness in the SOURCE record.    */
    "Error Message".                                                            /* And then this one for the error message column.          */


/* ********************  Preprocessor Definitions  ******************** */

DEFINE VARIABLE drive_letter AS CHARACTER FORMAT "x(01)" NO-UNDO.               

ASSIGN drive_letter = SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1, 1).            
   
{emailaddr-USERID.i}.

/* ***************************  Main Block  *************************** */
FOR EACH PATIENT_FILES WHERE LOOKUP(PATIENT_FILES.Progress_Flag,loadedlist) = 0: 

    recordsprocessed = recordsprocessed + 1.

    IF PATIENT_FILES.Progress_Flag = "" OR 
        PATIENT_FILES.Progress_Flag = "A" OR
        (firstrun = YES AND PATIENT_FILES.Progress_Flag = "U")                                  /* this line is for the initial load only */
    THEN DO:                           /** Begin ADD section **/

        FIND att_files WHERE att_files.att_file_id = PATIENT_FILES.fileid AND                   /* finding the DESTINATION table */
            att_files.att_deleted = ? NO-LOCK NO-ERROR.
 
        IF AVAILABLE (att_files) THEN DO:  
            
            EXPORT STREAM outward DELIMITER ";"
                PATIENT_FILES.fileid                                                    /* fields required for uniqueness in SOURCE record */
                "ERROR-1! PATIENT_FILES.fileid already exists in att_files.".
            ASSIGN ERROR-count[1] = ERROR-count[1]  + 1.                            /* 1dot1 */
            ASSIGN PATIENT_FILES.Progress_Flag = "AL".                              /* 1dot2 */   
        END.  /** of if avail att_files --- error, already exists **/
        
        ELSE DO:        /** normal condition for a blank or A record --- Add the record **/
 
            IF PATIENT_FILES.lab_sampleid = "" AND PATIENT_FILES.patientid <> 0 THEN 
                testorpat = NO.
            ELSE IF PATIENT_FILES.lab_sampleid <> "" THEN 
                testorpat = YES.
            ELSE 
                testorpat = ?.
        
            IF testorpat = YES THEN DO:     /** attached TO test **/
            
                CREATE att_files.
                
                ASSIGN 
                    att_files.att_file_id       = PATIENT_FILES.fileid 
                    att_files.att_table         = "TK_mstr"
                    att_files.att_field1        = "TK_mstr.TK_lab_sample_ID"
                    att_files.att_value1        = PATIENT_FILES.lab_sampleid 
                    att_files.att_field2        = "TK_mstr.TK_lab_seq"
                    att_files.att_value2        = STRING(PATIENT_FILES.lab_sampleid_seqnbr)
                    att_files.att_field5        = "RS Patient ID"
                    att_files.att_value5        = STRING(PATIENT_FILES.patientid)
                    att_files.att_category      = IF PATIENT_FILES.filedesc = "Import PDF file" OR PATIENT_FILES.filedesc = "Import PDF file." THEN 
                                                        "SOURCE TEST"
                                                  ELSE IF PATIENT_FILES.filedesc = "Import TXT file." THEN 
                                                        "SOURCE CSV"
                                                  ELSE 
                                                        "UNKNOWN"
                    att_files.att_filepath      = fileroot + STRING(PATIENT_FILES.patientid) + "\"
                    att_files.att_filename      = PATIENT_FILES.filename
                    att_files.att_filedesc      = PATIENT_FILES.filedesc
                    att_files.att_major_version = "1"
                    att_files.att_minor_version = "0"
                    att_files.att_created_by    = USERID("General")
                    att_files.att_create_date   = TODAY
                    att_files.att_modified_by   = USERID("General")
                    att_files.att_modified_date = TODAY
                    att_files.att_prog_name     = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */
                    PATIENT_FILES.Progress_Flag = IF PATIENT_FILES.Progress_Flag = "A" THEN  
                                                    "AL"      /** update the RS database so we don't re-pull --- stands for Add Loaded **/
                                                  ELSE IF PATIENT_FILES.Progress_Flag = "U" THEN
                                                    "UL"
                                                  ELSE 
                                                    "IL".     /** update the RS database so we don't re-pull --- stands for Import Loaded **/
            
            END.  /*** OF IF testorpat = YES ***/
            
            ELSE IF testorpat = NO THEN DO:     /** attached TO patient **/
            
                CREATE att_files.
                
                ASSIGN 
                    att_files.att_file_id       = PATIENT_FILES.fileid 
                    att_files.att_table         = "patient_mstr"
                    att_files.att_field1        = "patient_mstr.patient_ID"
                    att_files.att_value1        = STRING(PATIENT_FILES.patientid) 
                    att_files.att_category      = IF PATIENT_FILES.filedesc = "Import PDF file" THEN 
                                                        "SOURCE TEST"
                                                  ELSE IF PATIENT_FILES.filedesc = "Import TXT file." THEN 
                                                        "SOURCE CSV"
                                                  ELSE 
                                                        "UNKNOWN"
                    att_files.att_filepath      = fileroot + STRING(PATIENT_FILES.patientid) + "\"
                    att_files.att_filename      = PATIENT_FILES.filename
                    att_files.att_filedesc      = PATIENT_FILES.filedesc
                    att_files.att_major_version = "1"
                    att_files.att_minor_version = "0"
                    att_files.att_created_by    = USERID("General")
                    att_files.att_create_date   = TODAY
                    att_files.att_modified_by   = USERID("General")
                    att_files.att_modified_date = TODAY  
                    att_files.att_prog_name     = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */                  
                    PATIENT_FILES.Progress_Flag = IF PATIENT_FILES.Progress_Flag = "A" THEN  
                                                    "AL"      /** update the RS database so we don't re-pull --- stands for Add Loaded **/
                                                  ELSE 
                                                    "IL".     /** update the RS database so we don't re-pull --- stands for Import Loaded **/
            
            END.  /*** OF ELSE IF testorpat = NO ***/
            
            ELSE DO:    /** ERROR TYPE **/
            
                EXPORT STREAM outward DELIMITER ";"
                    PATIENT_FILES.fileid                                                    /* fields required for uniqueness in SOURCE record */
                    "ERROR-2!  Unable to determine Test or Patient.".
                ASSIGN ERROR-count[2] = ERROR-count[2]  + 1.                            /* 1dot1 */
  
            END.  /*** OF ELSE DO --- testorpat = ? --- ERROR TYPE ***/
        
        END.  /** of else do --- not avail att_files --- normal condition **/
        
    END.  /*** of progress_flag = blank or A --- create a record ***/
    
    ELSE IF PATIENT_FILES.Progress_Flag = "D" THEN DO:                                                          /** Begin DELETE section */

        FIND att_files WHERE att_files.att_file_id = PATIENT_FILES.fileid AND                   /* finding the DESTINATION table */
            att_files.att_deleted = ? EXCLUSIVE-LOCK NO-ERROR.
 
        IF NOT AVAILABLE (att_files) THEN DO:  
            
            EXPORT STREAM outward DELIMITER ";"
                PATIENT_FILES.fileid                                                    /* fields required for uniqueness in SOURCE record */
                "ERROR-3! PATIENT_FILES.fileid already deleted from att_files.".
            ASSIGN ERROR-count[3] = ERROR-count[3]  + 1.                            /* 1dot1 */
            ASSIGN PATIENT_FILES.Progress_Flag = "DL".                              /* 1dot2 */        
        END.  /** of if not avail att_files --- error, already missing **/
        
        ELSE DO:        /** normal condition for a D record --- Delete the record **/
    
            /** DELETE att_files. ******  just kidding, we don't delete this way ****/
            
            ASSIGN
                att_files.att_deleted       = TODAY 
                att_files.att_modified_by   = USERID("General")
                att_files.att_modified_date = TODAY 
                att_files.att_prog_name     = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */
                PATIENT_FILES.Progress_Flag = "DL".     /** update the RS database so we don't re-pull --- stands for Delete Loaded **/

        END.  /*** of else do --- avail att_files --- normal condition ***/
    
    END.  /**** of else if progress_flag = D --- Delete a record ****/
           
    ELSE IF (PATIENT_FILES.Progress_Flag = "U" AND firstrun = NO) THEN DO:                         /*** Begin UPDATE section ***/

        FIND att_files WHERE att_files.att_file_id = PATIENT_FILES.fileid AND                      /* finding the DESTINATION table */             
            att_files.att_deleted = ? EXCLUSIVE-LOCK NO-ERROR.
 
        IF NOT AVAILABLE (att_files) THEN DO:  
            
            EXPORT STREAM outward DELIMITER ";"
                PATIENT_FILES.fileid                                                    /* fields required for uniqueness in SOURCE record */ 
                "ERROR-4! PATIENT_FILES.fileid not found in att_files to update.".
            ASSIGN ERROR-count[4] = ERROR-count[4]  + 1.                            /* 1dot1 */
       
        END.  /** of if not avail att_files --- error, record missing **/
        
        ELSE DO:        /** normal condition for a U record --- Update the record **/
    
            IF PATIENT_FILES.lab_sampleid = "" AND PATIENT_FILES.patientid <> 0 THEN 
                testorpat = NO.
            ELSE IF PATIENT_FILES.lab_sampleid <> "" THEN 
                testorpat = YES.
            ELSE 
                testorpat = ?.
        
            IF testorpat = YES THEN DO:     /** attached TO test **/
            
                ASSIGN 
                    att_files.att_table         = "TK_mstr"
                    att_files.att_field1        = "TK_mstr.TK_lab_sample_ID"
                    att_files.att_value1        = PATIENT_FILES.lab_sampleid 
                    att_files.att_field2        = "TK_mstr.TK_lab_seq"
                    att_files.att_value2        = STRING(PATIENT_FILES.lab_sampleid_seqnbr)
                    att_files.att_field5        = "RS Patient ID"
                    att_files.att_value5        = STRING(PATIENT_FILES.patientid)
                    att_files.att_category      = IF PATIENT_FILES.filedesc = "Import PDF file" OR PATIENT_FILES.filedesc = "Import PDF file." THEN 
                                                        "SOURCE TEST"
                                                  ELSE IF PATIENT_FILES.filedesc = "Import TXT file." THEN 
                                                        "SOURCE CSV"
                                                  ELSE 
                                                        "UNKNOWN"
                    att_files.att_filepath      = fileroot + STRING(PATIENT_FILES.patientid) + "\"
                    att_files.att_filename      = PATIENT_FILES.filename
                    att_files.att_filedesc      = PATIENT_FILES.filedesc
                    att_files.att_major_version = "1"
                    att_files.att_minor_version = "0"
                    att_files.att_modified_by   = USERID("General")
                    att_files.att_modified_date = TODAY 
                    att_files.att_prog_name     = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */                   
                    PATIENT_FILES.Progress_Flag = "UL".      /** update the RS database so we don't re-pull --- stands for Update Loaded **/
                    
            
            END.  /*** OF IF testorpat = YES ***/
            
            ELSE IF testorpat = NO THEN DO:     /** attached TO patient **/
            
                ASSIGN 
                    att_files.att_table         = "patient_mstr"
                    att_files.att_field1        = "patient_mstr.patient_ID"
                    att_files.att_value1        = STRING(PATIENT_FILES.patientid) 
                    att_files.att_category      = IF PATIENT_FILES.filedesc = "Import PDF file" THEN 
                                                        "SOURCE TEST"
                                                  ELSE IF PATIENT_FILES.filedesc = "Import TXT file." THEN 
                                                        "SOURCE CSV"
                                                  ELSE 
                                                        "UNKNOWN"
                    att_files.att_filepath      = fileroot + STRING(PATIENT_FILES.patientid) + "\"
                    att_files.att_filename      = PATIENT_FILES.filename
                    att_files.att_filedesc      = PATIENT_FILES.filedesc
                    att_files.att_major_version = "1"
                    att_files.att_minor_version = "0"
                    att_files.att_modified_by   = USERID("General")
                    att_files.att_modified_date = TODAY  
                    att_files.att_prog_name     = THIS-PROCEDURE:FILE-NAME         /* 1dot1 */                  
                    PATIENT_FILES.Progress_Flag = "UL".      /** update the RS database so we don't re-pull --- stands for Update Loaded **/
                        
            
            END.  /*** OF ELSE IF testorpat = NO ***/
            
            ELSE DO:    /** ERROR TYPE **/
            
                EXPORT STREAM outward DELIMITER ";"
                    PATIENT_FILES.fileid                                                    /* fields required for uniqueness in SOURCE record */ 
                    PATIENT_FILES.patientid
                    PATIENT_FILES.lab_sampleid
                    PATIENT_FILES.lab_sampleid_seqnbr
                    PATIENT_FILES.filename
                    PATIENT_FILES.Progress_Flag
                    "ERROR-5!  Unable to determine Test or Patient.".
                ASSIGN ERROR-count[5] = ERROR-count[5]  + 1.                            /* 1dot1 */
  
            END.  /*** OF ELSE DO --- testorpat = ? --- ERROR TYPE ***/            
    
        END. /** of else do --- avail att_files --- normal condition ***/
        
    END.  /*** of else if progress_flag = U --- Update a record ***/
        
    ELSE DO: 
        
        EXPORT STREAM outward DELIMITER ";"
            PATIENT_FILES.fileid                                                    /* fields required for uniqueness in SOURCE record */ 
            PATIENT_FILES.patientid
            PATIENT_FILES.lab_sampleid
            PATIENT_FILES.lab_sampleid_seqnbr
            PATIENT_FILES.filename
            PATIENT_FILES.Progress_Flag
            "ERROR-6!  Something UNEXPECTED happened.".      /* yet ironically I coded for it */
        ASSIGN ERROR-count[6] = ERROR-count[6]  + 1.                            /* 1dot1 */
   
            /* if this condition occured you should check the loadlist variable and also the Progress_Flag field */
    
    END.  /*** of else do --- unexpected error! ***/
   
END.  /** of 4ea. patient_files **/

/** closing off the output file **/
EXPORT STREAM outward DELIMITER ";"
    999999999 "END OF LINE".
EXPORT STREAM outward DELIMITER ";"
    "End Run at " TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM outward DELIMITER ";"
    recordsprocessed "Records Processed".
    
EXPORT STREAM outward DELIMITER ";"                                                                 /* 1dot1 */
    ERROR-count[1] "ERROR-1! PATIENT_FILES.fileid already exists in att_files.".         /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"                                                                 /* 1dot1 */
    ERROR-count[2] "ERROR-2!  Unable to determine Test or Patient.".                                /* 1dot1 */
EXPORT STREAM outward DELIMITER ";"                                                                 /* 1dot1 */
    ERROR-count[3] "ERROR-3! PATIENT_FILES.fileid already deleted from att_files.".      /* 1dot1 */   
EXPORT STREAM outward DELIMITER ";"                                                                 /* 1dot1 */
    ERROR-count[4] "ERROR-4! PATIENT_FILES.fileid not found in att_files to update.".    /* 1dot1 */ 
EXPORT STREAM outward DELIMITER ";"                                                                 /* 1dot1 */
    ERROR-count[5] "ERROR-5!  Unable to determine Test or Patient.".                                /* 1dot1 */ 
EXPORT STREAM outward DELIMITER ";"                                                                 /* 1dot1 */
    ERROR-count[6] "ERROR-6!  Something UNEXPECTED happened.".                                      /* 1dot1 */    
    
OUTPUT STREAM outward CLOSE.

/* emailing the output file */
OS-COMMAND SILENT 
    VALUE(cmdname)  
    VALUE(emailaddr)
    VALUE(messagetxt) 
    VALUE(subjtxt) 
    VALUE(cmdparams) 
    VALUE(errlog).
    
/*************************  END OF FILE  **************************/

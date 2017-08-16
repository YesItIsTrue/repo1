
/*------------------------------------------------------------------------
    File        : DVcsv-importerU.p
    Purpose     : 

    Syntax      :

    Description : This is a program that reads in the exportSamlesump csv and the exportDatadump csv. 

    Author(s)   : Trae Luttrell
    Created     : Thu Sep 17 12:46:23 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/*** Everytimers ***/
DEFINE VARIABLE starttime AS DATETIME NO-UNDO.
DEFINE VARIABLE endtime AS DATETIME NO-UNDO.

starttime = NOW.

DEFINE VARIABLE x AS INTEGER NO-UNDO.
DEFINE VARIABLE y AS INTEGER NO-UNDO.
DEFINE VARIABLE z AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ITmessages AS LOGICAL INITIAL NO NO-UNDO.

DEFINE VARIABLE p AS DECIMAL FORMAT "->>9.9<%" NO-UNDO. 

DEFINE VARIABLE v-filelocation AS CHARACTER INITIAL "C:\PROGRESS\WRK\imports\Old_MPAs\expSamp-fixed.csv" NO-UNDO.
DEFINE VARIABLE v-filelocation2 AS CHARACTER INITIAL "C:\PROGRESS\WRK\imports\Old_MPAs\expData-fixed.csv" NO-UNDO.
DEFINE VARIABLE c-import AS INTEGER NO-UNDO.
DEFINE VARIABLE c-deleted AS INTEGER NO-UNDO.

DEFINE VARIABLE v-Sample-id-holder AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-gps-id-holder AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-batch-id-holder AS CHARACTER NO-UNDO.

/* ***********************  Stream Definitions  *********************** */
DEFINE STREAM error-log.
DEFINE VARIABLE errorlocation AS CHARACTER INITIAL "C:\PROGRESS\WRK\imports\Old_MPAs\dumps-error-log.txt" NO-UNDO.
OUTPUT STREAM error-log TO VALUE (errorlocation).
EXPORT STREAM error-log DELIMITER ";" "Start run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM error-log DELIMITER ";" /* column headers */
    "eD_HoldID--DataRowID"
    "Data_sample_ID"
    "Data_snp_ID"
    "Data_display_call"
    "Data_call"
    "Progress_Flag--A".
   

DEFINE STREAM success-log.
DEFINE VARIABLE successlocation AS CHARACTER INITIAL "C:\PROGRESS\WRK\imports\Old_MPAs\dumps-success-log.txt" NO-UNDO.
OUTPUT STREAM success-log TO VALUE (successlocation).
EXPORT STREAM success-log DELIMITER ";" "Start run at" TODAY STRING(TIME, "HH:MM:SS").
EXPORT STREAM success-log DELIMITER ";" /* column headers */
    "Sample_ID"
    "Sample_gps_ID"
    "Sample_batch_ID"
    "Data_sample_ID"
    "Data_snp_ID"
    "Data_display_call"
    "Data_call".


/* ********************  Preprocessor Definitions  ******************** */

DEFINE TEMP-TABLE SampleCatch
    FIELD sample_id AS CHARACTER 
    FIELD gps_id AS CHARACTER 
    FIELD batch_id AS CHARACTER
        INDEX SampleCatch-idx AS PRIMARY UNIQUE sample_id.
        
DEFINE TEMP-TABLE DataCatch
    FIELD data_sample_id AS CHARACTER FORMAT "x(5)"
    FIELD snpid AS CHARACTER
    FIELD display_call AS CHARACTER
    FIELD data_call AS CHARACTER FORMAT "x(5)"
        INDEX DataCatch-idx AS PRIMARY UNIQUE data_sample_id snpid.

/* ***************************  Main Block  *************************** */

/*MESSAGE v-filelocation VIEW-AS ALERT-BOX BUTTONS OK.*/

INPUT FROM VALUE (v-filelocation).

    StraightImport: 
    REPEAT:
        
        CREATE SampleCatch.
        
        IMPORT DELIMITER "," SampleCatch.
        
/*        FIND SampleCatch WHERE                            */
/*            SampleCatch.sample_id = v-sample-id-holder AND*/
/*            samplecatch.gps_id = v-gps-id-holder AND      */
/*            SampleCatch.batch_id = v-batch-id-holder      */
/*            NO-LOCK NO-ERROR.                             */
/*                                                          */
/*        IF AVAILABLE (SampleCatch) THEN DO:               */
/*                                                          */
/*            ASSIGN z = z + 1.                             */
/*                                                          */
/*        END. /** of if available **/                      */
/*                                                          */
/*        ASSIGN                                            */
        
        ASSIGN 
            c-import = c-import + 1.

        CREATE exportSampleMMDDYYYY.
        ASSIGN 
            exportSampleMMDDYYYY.eS_HoldID          = c-import
            exportSampleMMDDYYYY.sample_ID          = SampleCatch.sample_id
            exportSampleMMDDYYYY.gps_id             = SampleCatch.gps_id
            exportSampleMMDDYYYY.batch_id           = SampleCatch.batch_id
            exportSampleMMDDYYYY.Progress_Flag      = "A".


/*        DISPLAY SampleCatch WITH 3 COL TITLE "Imported Sample Data".*/
        
    END. /** StraightImport **/
    
INPUT CLOSE. 

/*DEFINE BUFFER buff-SampleCatch FOR SampleCatch.       */
/*                                                      */
/*FOR EACH SampleCatch NO-LOCK:                         */
/*                                                      */
/*    ASSIGN                                            */
/*        v-sample-id-holder = SampleCatch.sample_id    */
/*        v-gps-id-holder = samplecatch.gps_id          */
/*        v-batch-id-holder = SampleCatch.batch_id .    */
/*                                                      */
/*    FOR EACH buff-SampleCatch WHERE                   */
/*        SampleCatch.sample_id = v-sample-id-holder AND*/
/*        samplecatch.gps_id = v-gps-id-holder AND      */
/*        SampleCatch.batch_id = v-batch-id-holder      */
/*        NO-LOCK:                                      */
/*                                                      */
/*        ASSIGN                                        */
/*            z = z + 1                                 */
/*            c-deleted = c-deleted + 1.                */
/*                                                      */
/*                                                      */
/*    END. /*** of the buff 4ea ***/                    */
/*                                                      */
/*    IF z > 1 THEN DO:                                 */
/*                                                      */
/*    END.                                              */
/*                                                      */
/*END. /** of for each **/                              */
 
IF c-import = 0 THEN DO: 
 
    MESSAGE "Nothing came in from the Sample csv." VIEW-AS ALERT-BOX BUTTONS OK.

END. 

ELSE DO: /** stuff came in, so keep going **/

    INPUT FROM VALUE (v-filelocation2).
    
        StraightImport2: 
        REPEAT:
            
            CREATE DataCatch.
            
            IMPORT DELIMITER "," DataCatch.
            
            ASSIGN x = x + 1.
            
            CREATE exportDataMMDDYYYY.
            ASSIGN 
                exportDataMMDDYYYY.eD_HoldID                = x
                exportDataMMDDYYYY.data_sample_id           = DataCatch.data_sample_id
                exportDataMMDDYYYY.data_snp_id              = DataCatch.snpid
                exportDataMMDDYYYY.data_display_call        = DataCatch.display_call
                exportDataMMDDYYYY.data_call                = DataCatch.data_call
                exportDataMMDDYYYY.Progress_Flag            = "A".
                
            
            FIND SampleCatch WHERE 
                samplecatch.sample_id = datacatch.data_sample_id
                NO-LOCK NO-ERROR.
                
            IF AVAILABLE (SampleCatch) THEN DO:
                
                ASSIGN y = y + 1.
                
/*                DISPLAY DataCatch WITH 4 COL TITLE "Imported Data Data" WITH FRAME wide WIDTH 80 DOWN.*/
           
            END. /*** available SampleCatch ***/
            
            ELSE DO: 
            
                EXPORT STREAM error-log DELIMITER ";"
                    exportdataMMDDYYYY.
                    
                IF NOT CAN-FIND(FIRST SNP_mstr WHERE SNP_mstr.SNP_ID = exportDataMMDDYYYY.data_snp_id NO-LOCK) THEN 
                    EXPORT STREAM error-log DELIMITER ";"
                         exportDataMMDDYYYY.eD_HoldID
                         exportDataMMDDYYYY.data_sample_id
                         exportDataMMDDYYYY.data_snp_id
                         exportDataMMDDYYYY.data_display_call
                         exportDataMMDDYYYY.data_call
                         exportDataMMDDYYYY.Progress_Flag
                         "Further Details - No SNP Found".
                         
                    
                    
            END.  /** of else do --- not avail samplecatch **/ 
            
        END. /** StraightImport2 **/
        
    INPUT CLOSE. 
     
    IF x = 0 THEN DO: 
        
        MESSAGE "Nothing came in from the Data csv." VIEW-AS ALERT-BOX BUTTONS OK.
    
    END.  /*** x = 0 ***/  

    p = (( y / x ) * 100).

    IF (x <> 0) AND (y <> 0) AND (x = y) THEN 
        
        MESSAGE " 100% percent of the lines matched a Sample ID" VIEW-AS ALERT-BOX BUTTONS OK. 

    ELSE 

        MESSAGE "Data Lines:" x SKIP "Matched  :" y SKIP 
            "Percent  :" p
                VIEW-AS ALERT-BOX BUTTONS OK.

    MESSAGE "Here are the total z's :" c-deleted 
        VIEW-AS ALERT-BOX BUTTONS OK.

END. 

OUTPUT STREAM error-log CLOSE. 
OUTPUT STREAM success-log CLOSE.

endtime = NOW.

DISPLAY starttime endtime ((endtime - starttime) / 1000).


/***********  EOF **************/


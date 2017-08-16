USE HHI_DB_BioMed;
 
DECLARE @Extract_DateTime	AS DATETIME	;

PRINT ' ';  
SELECT 'Begin Set-SQL-Export_Progress-Date-Flag Pgm. '
PRINT 'Begin Set-SQL-Export_Progress-Date-Flag Pgm. '

set @Extract_DateTime = CURRENT_TIMESTAMP;
    
SELECT @Extract_DateTime ;

UPDATE  PATIENT_RCD		
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;

UPDATE  PATIENT_FILES	
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;

UPDATE  PATIENT_DELETED_RCD	
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;


UPDATE  MPA_RCD			
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;
UPDATE  MPA_TEST_DETAILS_RCD 
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;


UPDATE  TESTS_RESULT_RCD 
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;
UPDATE  TESTS_DETAIL_RCD 
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;
UPDATE  TESTS_FM_SPECIMEN_RCD 
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;
UPDATE  TESTS_HE_SPECIMEN_RATIOS_RCD 
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;
UPDATE  TESTS_UTM_UEE_SPECIMEN_RCD 
	set progress_datetime = @Extract_DateTime, progress_flag = 'P'  where progress_DateTime is null ;

SELECT 'End Set-SQL-Live-Export_Progress-Date-Flag Pgm. '
PRINT 'End Set-SQL-Live-Export_Progress-Date-Flag Pgm. '
PRINT ' ';

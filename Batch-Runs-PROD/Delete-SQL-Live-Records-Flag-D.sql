USE HHI_DB_BioMed;
  
SELECT 'Begin Delete-SQL-Live-Records-Flag-D Pgm. ';
PRINT 'Begin Delete-SQL-Live-Records-Flag-D Pgm. ';

select patientid as 'Patient ID', patlastname as 'Last Name', patfirstname as 'First Name', patDOB as 'DOB' 
	from patient_rcd 		where progress_flag = 'D' ; 

DELETE  PATIENT_RCD			where progress_flag = 'D' ; 

DELETE  PATIENT_FILES			where progress_flag = 'D' ; 

DELETE  PATIENT_DELETED_RCD		where progress_flag = 'D' ; 	


DELETE  MPA_RCD				where progress_flag = 'D' ; 			
DELETE  MPA_TEST_DETAILS_RCD		where progress_flag = 'D' ;


DELETE  TESTS_RESULT_RCD		where progress_flag = 'D' ; 
DELETE  TESTS_DETAIL_RCD		where progress_flag = 'D' ; 
DELETE  TESTS_FM_SPECIMEN_RCD		where progress_flag = 'D' ; 
DELETE  TESTS_HE_SPECIMEN_RATIOS_RCD	where progress_flag = 'D' ; 
DELETE  TESTS_UTM_UEE_SPECIMEN_RCD	where progress_flag = 'D' ; 

SELECT 'End Delete-SQL-Live-Records-Flag-D Pgm. ';
PRINT 'End Delete-SQL-Live-Records-Flag-D Pgm. ';
PRINT ' ';

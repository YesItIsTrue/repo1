/*------------------------------------------------------------------------
    File        : DL-DDIverifierPDFexport.i
    Created     : Tue Oct 27 14:23:50 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/
  
ASSIGN 
    err-number = {1}.
    
ASSIGN 
    err-message = "{2}".

EXPORT STREAM to-error DELIMITER ";"
    i-filelocation   
    i-TXTvsPDF
    i-lastname
    i-firstname
    i-PDF-lastname 
    i-PDF-firstname
    i-testkitID
    i-test_seq
    i-test_type 
    i-DOB-progress
    i-lab-sampleID
    i-lab-seq /*** actually the lab seq ***/
    i-createdate
    "{3}"
    err-number
    err-message.


/*------------------------------------------------------------------------
    File        : DL-DDIverifierExport.i
    Author(s)   : Trae Luttrell
    Created     : Wed Oct 14 10:31:19 EDT 2015
    Updated     : Wed Oct 21 07:52:00 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/
 
ASSIGN err-number = {1}.   

ASSIGN err-message = "{2}".  

EXPORT STREAM to-error DELIMITER ";"
    i-filelocation 
    i-TXTvsPDF
    i-lastname
    i-firstname
    "" 
    ""
    i-testkitID
    i-test_seq
    i-test_type 
    i-DOB-progress
    i-lab-sampleID
    x /*** actually the lab seq ***/
    i-createdate
    "{3}"
    err-number
    err-message.

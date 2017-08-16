
/*------------------------------------------------------------------------
    File        : DL-DDIwalkExport.i=
    Author(s)   : Trae Luttrell
    Created     : Fri Oct 09 10:31:19 EDT 2015
    Notes       :
  ----------------------------------------------------------------------*/

ASSIGN err-number = {1}.

ASSIGN err-message = "{2}".

EXPORT STREAM to-error DELIMITER ";" 
    i-filelocation   
    i-TXTvsPDF
    i-pat-lastname  
    i-pat-firstname 
    o-lastname
    o-firstname
    v-testkitID
    v-test_seq  
    i-test_type 
    v-DOB-progress
    v-lab-sampleID
    x /*** actually the lab seq ***/
    i-createdate
    "{3}"
    err-number
    err-message.

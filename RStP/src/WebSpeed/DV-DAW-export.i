
/*------------------------------------------------------------------------
    File        : DV-DAW-export.i
    Created     : Thu Aug 13 19:12:10 EDT 2015
  ----------------------------------------------------------------------*/

ASSIGN err-number = {1}.

EXPORT STREAM to-error DELIMITER ";"
    v-filelocation
    v-lab-sampleID 
    x /*** actually the lab seq ***/
    v-last-lab-seq
    v-peopleID
    v-attpeopleID
    v-fullpath-ID
    v-tk_patient_id
    o-lastname 
    o-firstname
    v-testkitID
    v-test_seq
    v-testtype
    v-DOB-progress
    err-number
    "{2}".
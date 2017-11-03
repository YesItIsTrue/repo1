
/*------------------------------------------------------------------------
    File        : hhi-discrepancy-records.i
    Purpose     : Allows user to specify which databases to use for merging.

    Syntax      :

    Description : 

    Author(s)   : Andrew Garver
    Created     : Fri May 26 10:14:51 EDT 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */    
IF NOT AVAILABLE (people_mstr) AND NOT AVAILABLE ({1}) THEN 
DO:
    {&OUT}
        "<br/><br/><br/>" SKIP 
        "<h2 class='center'>All finished!</h2>" SKIP
        "<h3 class='center'>You have reconciled all flagged discrepancies</h3>" SKIP.    
END.
ELSE 
DO:         
    {&OUT}
        "<div class='center'>" SKIP.
        
    IF (mergePeople = YES) THEN
        {&OUT}    
            "<button class='btn btn-warning action' onclick='resetPage()'>Back to Discrepancies</button>" SKIP
            "<button class='btn w3-theme-d3 action' onclick='mergePatientRecords()'>Merge Selected Changes</button>" SKIP.
    ELSE
        {&OUT}    
            "<button class='btn btn-warning action' data-toggle='modal' data-target='#createRecordModal'>Create New Record</button>" SKIP
            "<button class='btn w3-theme-d3 action' onclick='mergeDiscrepancies()'>Merge Selected Changes</button>" SKIP.
   
   {&OUT}     
        "</div>" SKIP
        "<br>" SKIP.
    
    IF AVAILABLE (people_mstr) OR AVAILABLE ({1}) THEN 
    DO:
        {&OUT} 
            "<div class='center bold header'>Person ID: " people_mstr.people_id "</div>" SKIP.
    END.
    
    {&OUT}
        "<form id='descrepancy_form' action='hhi-discrepancy-controller.html' method='GET'>" SKIP
        "<div class='w3-card var-width w3-theme-l5'>" SKIP
        "<div class='container dec-table'>" SKIP
        "<div class='row bold'>" SKIP
        "<div class='col-sm-4'>Field</div>" SKIP
        "<div class='col-sm-4'><a href='PATpickerR.r?h-prevproc=hhi-discrepancy.r&h-pp-act=onRecord&h-pp-whattorun=3.37&h-pp-passBack-integer=" discrepancyPersonID "&h-pp-passBack-char=" mergePeople "&h-cust=NO&whattorun=3.37'>On Record</a></div>" SKIP
        "<div class='col-sm-4'><a href='PATpickerR.r?h-prevproc=hhi-discrepancy.r&h-pp-act=discrepancy&h-pp-whattorun=3.37&h-pp-passBack-integer=" recordPersonID "&h-pp-passBack-char=yes&h-cust=NO&whattorun=3.37'>Discrepancy</a></div>" SKIP
        "</div>" SKIP.
         
    /*
    *   Person
    */
    
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "prefix" "Prefix" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "firstname" "First Name" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "midname" "Middle Name" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "lastname" "Last Name" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "suffix" "Suffix" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "title" "Title" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "prefname" "Preferred Name" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "dob" "Birthdate" "?"}
    
    IF (AVAILABLE(people_mstr) AND people_mstr.people_gender <> ?) OR (AVAILABLE({1}) AND {1}.{2}_gender <> ?) THEN 
    DO:
        {&OUT}
            "<div class='row'>" SKIP
            "<div class='col-sm-4'>Gender</div>" SKIP
            "<div class='col-sm-4'>".
        IF AVAILABLE(people_mstr) AND people_mstr.people_gender <> ? THEN 
        DO: 
            {&OUT} 
                "<input type ='text' readonly checked='true' class='btn option' value='" IF AVAILABLE(people_mstr) AND people_mstr.people_gender = TRUE THEN "Male" ELSE "Female" "' name='gender'/>".
        END.
        
        {&OUT}
            "</div>" SKIP
            "<div class='col-sm-4'>".
            
        IF AVAILABLE({1}) AND {1}.{2}_gender <> ? THEN 
        DO:
            {&OUT} 
                "<input type ='text' readonly class='btn option' value='" IF AVAILABLE({1}) AND {1}.{2}_gender = TRUE THEN "Male" ELSE "Female" "' name='gender'/>".
        END.
        
        {&OUT}    
            "</div>" SKIP
            "</div>" SKIP.
    END.
     
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "company" "Company" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "homephone" "Home Phone" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "workphone" "Work Phone" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "cellphone" "Cellphone" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "fax" "Fax" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "email" "Email" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "email2" "Second Email" """"}
    {hhi-discrepancy-peopledata.i "people_mstr" "{1}" "people" "{2}" "contact" "Contact" """"}   
   
    /*
     *   Address 1
     */
               
    IF AVAILABLE (addr_mstr) OR AVAILABLE ({3}) THEN 
    DO:    
        {&OUT} 
            "<div class='center bold row header'>Address</div>".
            
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "addr1" "Address Line 1" """"}
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "addr2" "Address Line 2" """"}
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "addr3" "Address Line 3" """"}
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "city" "City" """"}
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "stateprov" "State/Province" """"}
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "zip" "Zip" """"}
        {hhi-discrepancy-peopledata.i "addr_mstr" "{3}" "addr" "{4}" "country" "Country" """"}
        
    END.
    
    IF AVAILABLE (people_mstr) THEN 
    DO:
        {&OUT} 
            "<input type='hidden' name='people_id' checked='true' value='" people_mstr.people_id "'/>" SKIP.
    END.
    IF AVAILABLE (addr_mstr) THEN 
    DO:
        {&OUT} 
            "<input type='hidden' name='addr_id' checked='true' value='" addr_mstr.addr_id "'/>" SKIP.
    END.
    IF AVAILABLE ({1}) THEN 
    DO:
        {&OUT} 
            "<input type='hidden' name='people_id2' checked='true' value='" {1}.{2}_id "'/>" SKIP.
    END.
    IF AVAILABLE ({3}) THEN 
    DO:
        {&OUT} 
            "<input type='hidden' name='addr_id2' checked='true' value='" {3}.{4}_id "'/>" SKIP.
    END.
    
    {&OUT}
        "</div>" SKIP
        "</div>" SKIP
        "<input type='hidden' name='action' checked='true' id='action'/>" SKIP
        "</form>" SKIP.

    {&OUT}
        "<br>" SKIP
        "<div class='center'>" SKIP.
        
    IF (mergePeople = YES) THEN
        {&OUT}    
            "<button class='btn btn-warning action' onclick='resetPage()'>Back to Discrepancies</button>" SKIP
            "<button class='btn w3-theme-d3 action' onclick='mergePatientRecords()'>Merge Selected Changes</button>" SKIP.
    ELSE
        {&OUT}    
            "<button class='btn btn-warning action' data-toggle='modal' data-target='#createRecordModal'>Create New Record</button>" SKIP
            "<button class='btn w3-theme-d3 action' onclick='mergeDiscrepancies()'>Merge Selected Changes</button>" SKIP.
       
    {&OUT}     
        "</div>" SKIP
        "<br>" SKIP.
END.

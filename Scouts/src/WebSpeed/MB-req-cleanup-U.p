/***************************************************************
 *
 *  Verify that people's individual requirements are set to y or n.
 *
 ***************************************************************


def var mbid like mb_bsa_id no-undo.

update skip(1)
    mbid colon 20 skip(1)
        with frame a width 80 side-labels.
        
for each sched_mstr where sched_bsa_id = mbid no-lock,
    first mb_mstr where mb_bsa_id = sched_bsa_id no-lock,
    each mbc_det where mbc_class_id = sched_class_id no-lock,
    first people_mstr where people_id = mbc_people_id no-lock
        break by mb_bsa_id by sched_class_id by mbc_people_id by mbc_req_nbr:
        
    display mbc_req_nbr mbc_completed 
        mbc_people_id 
        string(people_lastname + ", " + people_firstname) format "x(33)" label "Name"
        /* 
        mb_bsa_id
        */
        mbc_class_id format ">>9" column-label "Class"
            with frame resultslist width 80 down
                title mb_name.
    down with frame resultslist.
    
    if last-of(mbc_people_id) then 
        down 1 with frame resultslist.
.
        
    if last-of(sched_class_id) then 
        down 1 with frame resultslist.
.
        
    
end.        /** of 4ea. sched_mstr, etc. **/

***/

/***************************************************************
 *
 *  Deletes sched_mstr records for a specific individual.
 *
 ***************************************************************
 
def var mbid like mb_bsa_id no-undo.
def var peopleid like people_id no-undo.
def var oktogo as logical no-undo.

update skip(1)
    mbid colon 20
   /*  peopleid colon 20 skip(1) */
        with frame a width 80 side-labels.
        
for each sched_mstr where sched_bsa_id = mbid,
    first mb_mstr where mb_bsa_id = sched_bsa_id no-lock,
    each mbc_det where mbc_class_id = sched_class_id,
        /**
        and
        mbc_people_id = peopleid no-lock,
        ***/
    first people_mstr where people_id = mbc_people_id no-lock
        break by mb_bsa_id by sched_class_id by mbc_people_id by mbc_req_nbr:
        
    if first-of(mbc_people_id) then     
        message "Delete " people_lastname ", " people_firstname
            " from " mb_name "?"
                view-as alert-box question buttons yes-no
                update oktogo.
            
    if oktogo = YES then 
        delete mbc_det.
        
    if last-of(mbc_people_id) then do: 
        find regis_mstr where regis_people_id = mbc_people_id and
            regis_class_id = sched_class_id exclusive-lock no-error.
        if avail (regis_mstr) then
            delete regis_mstr.
        oktogo = NO. 
    end.    
    
end.  /** of 4ea. sched_mstr, etc. **/

***/



/***
 *
 *  Checks a specific MB for all it's requirements.  Compare to mb.org
 *
 ***

def var mbid like mb_bsa_id no-undo.

update skip(1)
    mbid colon 20 skip(1)
        with frame a width 80 side-labels.
    

for each mbr_reqs where mbr_bsa_id = mbid no-lock,
    first mb_mstr where mb_bsa_id = mbr_bsa_id no-lock
    break by mbr_bsa_id by mbr_req_nbr:

   display mbr_req_nbr mb_name mbr_orgroup mbr_orqty.
   
   if last-of(mbr_bsa_id) then 
    down 1.
    
end.

***/

/***
 *
 *  Sets MBC_det Completed records to NO for specific requirements
 *
 ***

def var mbid like mb_bsa_id no-undo.
def var nolist as char format "x(50)" label "NO List" no-undo.

update skip(1)
    mbid colon 20
    nolist colon 20 skip(1)
        with frame a width 80 side-labels.
        

for each sched_mstr where sched_bsa_id = mbid no-lock,
    each mbr_reqs where mbr_bsa_id = sched_bsa_id no-lock,
    each mbc_det where mbc_class_id = sched_class_id and
        mbc_req_nbr = mbr_req_nbr:
        
    if lookup(mbc_req_nbr,nolist) > 0 then        
        mbc_completed = NO.
        
end.
   
***/   
    

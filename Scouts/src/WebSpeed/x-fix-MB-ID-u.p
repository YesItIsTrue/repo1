def var mbname as char format "x(30)" label "MB Name" no-undo.
def var mbid like MBR_BSA_ID label "BSA ID" no-undo.
def var whatyear like MBR_year label "Req Year" no-undo.


form skip(1)
    mbname colon 20 skip(1)
    mbid colon 20
    whatyear colon 20 skip(1)
        with frame a width 80 side-labels.
        
main-loop:
repeat:

    update mbname mbid whatyear
        with frame a.
        
    for each mbr_mstr where mbr_name = mbname:
    
        assign
            mbr_bsa_id  = mbid
            mbr_year    = whatyear.

        display MBR_Req_Nbr MBR_ORgroup MBR_ORqty mbr_bsa_id mbr_year
            with frame maindet width 80 title mbname down.
        down with frame maindet.
        
    end.
    
end.

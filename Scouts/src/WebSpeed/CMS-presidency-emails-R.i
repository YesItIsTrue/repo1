
/*------------------------------------------------------------------------
    File        : CMS-presidency-emails-R.i
    Purpose     : 1.0 - written by DOUG LUTTRELL on 05/Oct/17.  Original version.


    Syntax      :

    Description : Bounces through the plink_mstr to find people who are serving 
                    in a particular calling / organization and outputs their email addresses.
                    
                Backed off of this plan in the interests of time.  It seems like we need an
                extra field or two and I don't have time to do that right now.  Just hardcoding.

    Author(s)   : DOUG LUTTRELL
    Created     : Thu Oct 05 08:34:15 EDT 2017
    Notes       :
        
        Usage = {CMS-presidency-emails-R.i "SYMP"}.
                    OR
                {CMS-presidency-emails-R.i "SYWP"}.
                
                
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

IF "SYMP" = "{1}" THEN 
    {&OUT}    
        "       <a href='mailto:doug.luttrell@gmail.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Doug</a>, " SKIP
        "       <a href='mailto:drmerryman@gmail.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Dave</a>, " SKIP
        "       <a href='mailto:rpcamire@maine.rr.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Roland</a>, " SKIP
        "       <a href='mailto:trae.luttrell@gmail.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Trae</a>" SKIP
        .
        
 ELSE IF "SYWP" = "{1}" THEN  
     {&OUT}
        "       <a href='mailto:leslie.crowley@gmail.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Leslie</a>, " SKIP
        "       <a href='mailto:rwheele1@maine.rr.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Kim</a>, " SKIP
        "       <a href='mailto:kskroski@hotmail.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Kadie</a>, or " SKIP
        "       <a href='mailto:sara.diai23@gmail.com?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>Sara</a> " SKIP.    
        
ELSE 
    {&OUT}
        "       <a href='mailto:solsource.techsupport@mysolsource.com?Subject=Event%20Missing%20Group%20Type' target='_top'>Solsource Techsupport</a> " SKIP.
    

/*FOR EACH plink_mstr WHERE plink_mstr.plink_rel_subtype = "{1}" AND                        */
/*        plink_mstr.plink_deleted = ? NO-LOCK,                                             */
/*    FIRST people_mstr WHERE people_mstr.people_id = plink_mstr.plink_people_ID AND        */
/*        people_mstr.people_deleted = ? NO-LOCK                                            */
/*            BREAK BY plink_mstr.plink_rel_type BY people_mstr.people_prefname:            */
/*                                                                                          */
/*    {&OUT}                                                                                */
/*        "       <a href='mailto:"                                                         */
/*        people_mstr.people_email                                                          */
/*        "?Subject=Augusta%20Maine%20Stake%20Activities%20Question/Comment' target='_top'>"*/
/*        people_mstr.people_prefname                                                       */
/*        "</a>".                                                                           */
/*                                                                                          */
/*     IF LAST-OF(plink_mstr.plink_rel_type) THEN                                           */
/*        {&OUT}                                                                            */
/*            " " SKIP.                                                                     */
/*     ELSE                                                                                 */
/*        {&OUT}                                                                            */
/*            ", " SKIP.                                                                    */
/*                                                                                          */
/*END.  /** of 4ea. plink_mstr, etc. **/                                                    */
        
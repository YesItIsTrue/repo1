/*************************************************************************************
 *
 *  UTIL-age-fixer-U.p - Doug Luttrell - summer of 2015 - Version 1.0
 *
 *  -----------------------------------------------------------------
 *
 *  Utility manually sorts people into Quorums by age.  Needs lots of work to 
 *  become a real utility.
 *
 *  -----------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL in the Summer of 2015.  Original version.
 *  1.1 - written by DOUG LUTTRELL on 14/Aug/17.  Changed to work with new CMC
 *          structure (Version 12).  Not fixing any of the other obvious issues.
 *          Not sure if this code is intended for use.  Marked by 1dot1.
 *
 *************************************************************************************/

DEFINE VARIABLE deaconmark AS DATE INITIAL "08/08/03" NO-UNDO.
DEFINE VARIABLE teachermark AS DATE INITIAL "08/08/01" NO-UNDO.
DEFINE VARIABLE priestmark AS DATE INITIAL "08/08/99" NO-UNDO.
DEFINE VARIABLE eldermark AS DATE INITIAL "08/03/96" NO-UNDO.

DEFINE VARIABLE calcquorum AS CHARACTER NO-UNDO.


FOR EACH people_mstr NO-LOCK,
    FIRST speop_shadow WHERE speop_shadow.speop_ID = people_mstr.people_id EXCLUSIVE-LOCK:                  /* 1dot1 */

   IF (people_DOB <= deaconmark AND 
            people_DOB > teachermark) THEN
        calcquorum = "Deacon".        
   ELSE IF (people_DOB <= teachermark AND 
           people_DOB > priestmark) THEN
        calcquorum = "Teacher".
   ELSE IF (people_DOB <= priestmark AND 
            people_DOB > eldermark) THEN
        calcquorum = "Priest".
   ELSE
        calcquorum = "Error".

   DISPLAY people_mstr.people_lastname 
        people_mstr.people_firstname
        people_mstr.people_DOB 
        speop_shadow.speop_quorum                                                                           /* 1dot1 */ 
        calcquorum
            WITH WIDTH 132.
        
   IF people_DOB <> ? THEN 
        speop_shadow.speop_quorum = calcquorum.                                                             /* 1dot1 */

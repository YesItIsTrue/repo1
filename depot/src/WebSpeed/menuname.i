/***********************************************************************************************
 *
 *  menuname.i - 12/Jan/15 - Doug Luttrell - Version 1.1
 *
 *  -----------------------------------------------------------------------------------------
 * 
 *  This code snippet should be all you need to use at the start of each of your programs
 *  to enable the dynamic naming / title to appear.  This code should be INSIDE the <body>
 *  tag, and the initial <SCRIPT> tag that calls Speedscript.  It works in combination with
 *  the menu.html code.  
 *
 *  -----------------------------------------------------------------------------------------
 *
 *  Revision History:
 *  -----------------
 *  1.0 - written by DOUG LUTTRELL on 09/May/14.  Original Version.
 *  1.1 - written by DOUG LUTTRELL on 12/Jan/15.  Apparently we need to pass the whattorun 
 *          variable around.  Also making changes to display the menu number in front of the
 *          title.
 *  1.11 - written by DOUG LUTTRELL on 11/Aug/17.  Working on the update to CMC (Version 12).
 *          Tried to fix the long-standing "error" that was in this include of the menu_mstr 
 *          table being unknown or ambiguous.  Finally used the voodoo approach that makes 
 *          Trae happy.  Re-typed (character for character) about a half dozen lines of code
 *          and the error finally went away.  Ooga booga.  Not marked.  Nope, looks like it came
 *          back again when I did a mass clean.  Perhaps there is a temp-table in another program
 *          that is being defined as menu_mstr?
 *
 *  -----------------------------------------------------------------------------------------
 *
 *  Usage Instructions:
 *  -------------------
 *  1) Make sure this file is in the WebSpeed folder of your depot project.
 *  2) Add the following code to your program:
 *
 *          {../depot/src/WebSpeed/menuname.i}.
 *
 *  3) Enjoy.
 *
 ***********************************************************************************************/ 

     /*********  Use the proper name on a program  **************/   
     DEFINE VARIABLE whatshouldrun AS CHARACTER NO-UNDO. 
     DEFINE VARIABLE menuprefix AS CHARACTER NO-UNDO.
     DEFINE VARIABLE menusuffix AS INTEGER NO-UNDO.      
     DEFINE VARIABLE menuheadername AS CHARACTER NO-UNDO.  
            
     ASSIGN
        whatshouldrun  = get-value('whattorun')
        menusuffix     = INTEGER(SUBSTRING(whatshouldrun,R-INDEX(whatshouldrun,".") + 1))
        menuprefix     = SUBSTRING(whatshouldrun,1,R-INDEX(whatshouldrun,".") - 1).
        
    FIND menu_mstr WHERE menu_mstr.menu_num = "0" AND 
        menu_mstr.menu_select = INTEGER(menuprefix)
            NO-LOCK NO-ERROR.
    
    IF AVAILABLE (menu_mstr) THEN 
        menuheadername = menu_mstr.menu_title.
        
                    
/*    FIND menu_mstr WHERE menu_mstr.menu_num = "0" AND menu_mstr.menu_select = INTEGER(menuprefix) NO-LOCK NO-ERROR.*/
/*                                              */
/*    IF AVAILABLE (menu_mstr) THEN             */
/*        menuheadername = menu_mstr.menu_title.*/
/*                                              */
     FIND menu_mstr WHERE menu_mstr.menu_num = menuprefix AND   
        menu_mstr.menu_select = menusuffix
            NO-LOCK NO-ERROR.
       
     IF AVAILABLE (menu_mstr) THEN DO:   
         
        {&OUT} 
            "<H1 class='webpagetitle'>" SKIP
            menu_mstr.menu_num + "." + STRING(menu_mstr.menu_select) + " - " SKIP
            menu_mstr.menu_title SKIP
            "</H1> " SKIP(1).
        
        
            
     END.  /** of if avail menu_mstr **/
     
     ELSE DO: 
          
        {&OUT} 
            "<H1 class='webpagetitle'> Unknown Menu Function </H1> " SKIP.
            
     END.  /** of else do --- not avail menu_mstr **/
        
     /************  End of program naming code  *****************/
     
    /*     Back button     */
    {&OUT}
        "<a href='http://localhost:3333/DataHub/rcode/menupager.html?c-usr=" get-value('c-usr') "&whattorun=" ENTRY(1, whatshouldrun, '.') "&h-menuheadername=" menuheadername "'><img src='/depot/src/HTMLContent/images/back-arrow.png' style='width: 2.5%; position: absolute; right: 1%; top: 2%;'/></a>".
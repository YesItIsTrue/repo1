/***********************************************************************************************
 *
 *  menuname.i - 11/Aug/17 - Doug Luttrell - Version 1.21
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
 *  1.2 - written by ANDREW GARVER in August of 2017.  Added the Back button.  Not marked.
 *  1.21 - written by DOUG LUTTRELL on 11/Aug/17.  Working on the update to CMC (Version 12).
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
 *  Add the following code to your program:
 *
 *          {../depot/src/WebSpeed/menuname.i}.
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
            "<div>" SKIP
            "   <h1 class='webpagetitle' style='float:left'>" SKIP
                    menu_mstr.menu_num + "." + STRING(menu_mstr.menu_select) + " - " SKIP
                    menu_mstr.menu_title SKIP
            "   </h1>" SKIP
            "   <div class='search-bar' style='text-align:right; padding-right:16px; padding-top:20px;'>" SKIP
            "       <form id='quickNavForm' action='menu-quick-nav.r' onsubmit='return validateQuickNav()'>" SKIP
            "           QuickNav &nbsp;&nbsp;<input type='text' id='quickNavInput' name='h-menu-num'/>" SKIP
            "       </form>" SKIP
            "   </div>" SKIP
            "</div> " SKIP.
            
     END.  /** of if avail menu_mstr **/
     
     ELSE DO: 
          
        {&OUT} 
            "<div>" SKIP
            "   <h1 class='webpagetitle' style='float:left'>Unknown Menu Function</h1>" SKIP
            "   <div class='search-bar' style='text-align:right; padding-right:16px; padding-top:20px;'>" SKIP
            "       <form id='quickNavForm' action='menu-quick-nav.r' onsubmit='return validateQuickNav()'>" SKIP
            "           QuickNav &nbsp;&nbsp;<input type='text' id='quickNavInput' name='h-menu-num'/>" SKIP
            "       </form>" SKIP
            "   </div>" SKIP
            "</div> " SKIP.
            
     END.  /** of else do --- not avail menu_mstr **/
     
     {&OUT}
        "<script>" SKIP
        "   function validateQuickNav() ~{" SKIP
        "       var quickNavValue = document.getElementById('quickNavInput').value;" SKIP
        "       var isValid = /^[0-9.]*$/.test(quickNavValue);" SKIP(1)

        "       if (!isValid) ~{" SKIP
        "           return false;" SKIP
        "       ~}" SKIP
        "   ~}" SKIP
        "</script>" SKIP.
        
     /************  End of program naming code  *****************/
     
        /*     Back button     */
    /*
    {&OUT}
        "<a href='http://localhost:3333/DataHub/rcode/menupager.html?c-usr=" 
        IF get-value('c-usr') THEN 
          get-value('c-usr') 
        ELSE 
          get-value('h-empid') 
        "&whattorun=" ENTRY(1, whatshouldrun, '.') 
        "&h-menuheadername=" menuheadername "'>"
        "<img src='/depot/src/HTMLContent/images/back-arrow.png' style='width: 2.5%; position: absolute; right: 1%; top: 2%;'/></a>".
    */
    
    
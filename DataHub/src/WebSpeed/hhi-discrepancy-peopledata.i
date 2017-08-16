IF (AVAILABLE({1}) AND {1}.{3}_{5} <> {7}) OR (AVAILABLE({2}) AND {2}.{4}_{5} <> {7}) THEN 
DO:
    {&OUT}
        "<div class='row'>" SKIP
        "<div class='col-sm-4'>{6}</div>" SKIP
        "<div class='col-sm-4'>".
    
    IF AVAILABLE({1}) AND {1}.{3}_{5} <> {7} THEN 
    DO:
        {&OUT} 
            "<input type='text' readonly checked='true' class='btn option' value='" {1}.{3}_{5} "' name='{5}'/>".
    END.
                    
    {&OUT}
        "</div>" SKIP
        "<div class='col-sm-4'>".
                        
    IF AVAILABLE({2}) AND {2}.{4}_{5} <> {7} THEN 
    DO: 
        {&OUT} 
            "<input type='text' readonly class='btn option' value='" {2}.{4}_{5} "' name='{5}'/>".
    END.
                    
    {&OUT}    
        "</div>" SKIP
        "</div>" SKIP.
END.
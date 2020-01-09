xquery version "3.1";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare variable $sanjin-A := doc('三进南京城.xml');

declare function local:choice_reg($input as text()) {
    let $kurz := analyze-string($input, '(\w)（kurzzeichen(\w)）')
    for $fanti in $kurz/*
    return
        if ($fanti instance of element(fn:match)) then
            element choice
            {
                element orig {$fanti/*[1]/string()},
                element reg {$fanti/*[2]/string()}
            }
        else
            local:choice_corr($fanti/text())

};

declare function local:choice_corr($input as text()) {
    let $Korr := analyze-string($input, '(\w)（Korrektur(\w)）')
    for $result in $Korr/*
    return
        if ($result instance of element(fn:match)) then
            element choice
            {
                element sic {$result/*[1]/string()},
                element corr {$result/*[2]/string()}
            }
        else
            local:add_pb($result/text())
};

declare function local:add_pb($input as text()) {
    let $analysis := analyze-string($input, "（第(\d+)页）")
    for $result in $analysis/*
    return
        if ($result instance of element(fn:match)) then
            element pb {attribute n {$result/*[1]/string()}}
        else
            $result/string()

};

(:~ A skeleton function for recursively transforming the xml data :)
declare function local:transform($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            (: delete anchor :)
            case element(tei:anchor)
                return
                    ()
                    (: leave other elements intact, including attributes :)
            case element()
                return
                    element
                    {node-name($node)}
                    {$node/@*, local:transform($node/node())}
            case text()
                return
                    local:choice_reg($node)
            default
                return
                    local:transform($node/node())
};


local:transform($sanjin-A)



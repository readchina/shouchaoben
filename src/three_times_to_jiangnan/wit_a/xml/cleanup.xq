xquery version "3.1";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare variable $sanjin-A := doc('三进南京城.xml');

(: NOTE do NER first then add choices:)

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
declare function local:docx_transform($nodes as node()*) {
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
                    {$node/@*, local:docx_transform($node/node())}
            case text()
                return
                    local:choice_reg($node)
            default
                return
                    local:docx_transform($node/node())
};



(:~ A skeleton function for recursively transforming the ner output to tei :)
declare function local:ner_transform($nodes as node()*) as item()* {
    for $node in $nodes
    return
        typeswitch ($node)
            case text()
                return
                    $node
            case comment()
                return
                    $node
                    (: date and time :)
                    (: too bad we can't cask chinese numbbers as integers :)
            case element(DATE)
                return
                    element date {local:ner_transform($node/node())}
            case element(TIME)
                return
                    element time {local:ner_transform($node/node())}
                    (: people :)
            case element(PERSON)
                return
                    element persName {local:ner_transform($node/node())}
            case element(ORGANIZATION)
                return
                    element orgName {local:ner_transform($node/node())}
                    (: places :)
            case element(COUNTRY)
                return
                    element placeName {attribute type {'country'}, local:ner_transform($node/node())}
            case element(FACILITY)
                return
                    element placeName {attribute type {'facility'}, local:ner_transform($node/node())}
            case element(STATE_OR_PROVINCE)
                return
                    element placeName {attribute type {'province'}, local:ner_transform($node/node())}
            case element(CITY)
                return
                    element placeName {attribute type {'city'}, local:ner_transform($node/node())}
            case element(LOCATION)
                return
                    element placeName {attribute type {'location'}, local:ner_transform($node/node())}
                    (: keep :)
            case element(wrap)
                return
                    element body {local:ner_transform($node/node())}
            case element(ner)
                return
                    element p {local:ner_transform($node/node())}
            default
                return
                    local:ner_transform($node/node())
};
(:local:ner_transform(.):)

local:docx_transform($sanjin-A)



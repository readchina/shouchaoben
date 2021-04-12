xquery version "3.1";

import module namespace so = "http://readchina.eu/scb/so/ns" at "standoff.xqm";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $wit_a := doc('../wit_a/xml/processed/三进南京城_ner.xml');
declare variable $wit_b := doc('../wit_b/xml/processed/三下江南_ner.xml');
declare variable $wit_c := doc('../wit_c/xml/processed/余飞三下南京_ner.xml');

(:~ A set of three helper functions to process project annotations into TEI conventions
 : @param $input the inline annotation as string
 : @see local:docx_transform
 : @return a tei element
 ~:)

(:~ Normalize character choices to fantizi ~:)
declare function local:choice_reg($input as text()) as item()* {
    let $kurz := analyze-string($input, '(\w)（[Kk]urzzeichen(\w)）')
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

(:~ Mark editorial corrections ~:)
declare function local:choice_corr($input as text()) as item()* {
    let $Korr := analyze-string($input, '(\w)（[Kk]orrektur(\w)）')
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

(:~ Insert pagebreaks ~:)
declare function local:add_pb($input as text()) as item()* {
    let $analysis := analyze-string($input, "（第(\d+)页）")
    for $result in $analysis/*
    return
        if ($result instance of element(fn:match)) then
            element pb {attribute n {$result/*[1]/string()}}
        else
            $result/string()

};

(:~ Cleanup and collapse whitespace character from transcription body 
: @para $wit the initial tei conversion from docx
: @return a transformed copy of the body/p of the orignal document
:)
declare function local:trim-space($wit as node()*) as element(body) {
<body>{
for $n in $wit//body/p
let $normalized := normalize-space($n)
return 
<p>
{replace($normalized, '\s', '')}
</p>
}</body>
};

(:~ A skeleton function for recursively transforming inline project annotatons from the converted docx files. 
: @para $nodes the initial tei conversion from docx
: @return a transformed copy of the tei document
:)
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
                    $node 
                      => local:choice_reg()

            default
                return
                    local:docx_transform($node/node())
};



(:~ A skeleton function for recursively transforming the ner output to tei 
 : @param $node the annotated ner ouput, usually processed/*_ner.xml
 : @return a hopefully valid transformed TEI version of the NER annotations
:)
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
                    (: too bad we can't cast chinese numbbers as integers :)
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
            case element(body)
                return
                    element body {local:ner_transform($node/node())}   
            case element(p)
                return
                    element p {local:ner_transform($node/node())}        
            default
                return
                    local:ner_transform($node/node())
};


declare function local:one-pass($items as item()*) as item()* {
$items 
=> local:ner_transform()
=> local:docx_transform()
};

(:for $wit in ($wit_a, $wit_b, $wit_c)
let $test := <body><p>（第1页）</p>
            <p>余飞三下<CITY>南京</CITY></p>
            <p>一九七0（Korrektur零）人看手錶（Kurzzeichen表）：“咦！停了，</p>
            </body>
return
local:one-pass($wit//body) :)




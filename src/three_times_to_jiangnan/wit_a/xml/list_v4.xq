xquery version "3.1";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $sanjin-A := doc('三进南京城.xml');
declare variable $sanjin-B := doc('三下江南.xml');
declare variable $sanjin-C := doc('余飞三下南京.xml');
declare variable $listPlace := doc("https://raw.githubusercontent.com/readchina/ReadAct/master/xml/listPlace.xml")/listPlace;
declare variable $listPerson := doc("https://raw.githubusercontent.com/readchina/ReadAct/master/xml/listPerson.xml")/listPerson;
declare variable $listOrg := doc("https://raw.githubusercontent.com/readchina/ReadAct/master/xml/listOrg.xml")/listOrg;


declare function local:lookup-place($input as node()*)
{
    <listPlace>
        {
            for $p in $input
            let $path := $listPlace/place/placeName[. = $p/placeName]/..
            return
                if ($p/placeName[. = $listPlace/place/placeName])
                then
                    <place>
                        {
                            $path/*,
                            <idno type='ReadAct'>{data($path/@*:id)}</idno>
                        }
                    </place>
                else
                    $p
        }
    </listPlace>
};


declare function local:lookup-person($input as node()*)
{
    <listPerson>{
            for $p in $input
            let $match := $listPerson//persName[concat(./surname, ./forename) = $p]
            return
                if ($match)
                then
                    (
                    <person
                        sex="{data($match/../@*:sex)}">
                        {
                            $match/../*,
                            <idno type='ReadAct'>{data($match/../@*:id)}</idno>
                        }
                    
                    </person>
                    )
                else
                    $p/..
        }
    </listPerson>
};


declare function local:lookup-org($input as node()*)
{
    <listOrg>{
            for $o in $input
            let $path := $listOrg/org/orgName[. = $o/orgName]/..
            return
                if ($o/orgName[. = $listOrg/org/orgName])
                then
                    <org>
                        {
                            $path/*,
                            <idno type='ReadAct'>{data($path/@*:id)}</idno>
                        }
                    </org>
                else
                    $o
        }</listOrg>
};


declare function local:generate-standoff($input as node()*)
{
    <standOff
        xml:lang="zh">
        {
            local:lookup-place($input//listPlace/place),
            local:lookup-person($input//listPerson//persName),
            local:lookup-org($input//listOrg/org)
        }
    </standOff>
};
local:generate-standoff($sanjin-A)
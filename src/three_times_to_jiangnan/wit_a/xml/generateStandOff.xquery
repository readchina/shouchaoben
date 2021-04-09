xquery version "3.1";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $SCB := doc("三进南京城.xml");
declare variable $listPlace := doc("listPlace.xml")/listPlace;
declare variable $listPerson := doc("listPerson.xml");
declare variable $listOrg := doc("listOrg.xml")/listOrg;

<standOff
    xml:lang="zh">
    
    <listPlace>
        {
            for $p in $SCB//listPlace/place
            let $path := $listPlace/place/placeName[. = $p/placeName]/..
            return
                if ($p/placeName[. = $listPlace/place/placeName])
                then
                    <place>
                        {
                            $path/child::node(),
                            <idno type='ReadAct'>{data($path/@*:id)}</idno>
                            
                            
                        }
                    </place>
                else
                    $p
        }
    </listPlace>
    
    
    <listPerson>{
            for $p in $SCB//listPerson//persName
            let $match := $listPerson//persName[concat(./surname, ./forename) = $p]
            return
                if ($match)
                then
                    (
                    <person
                        sex="{data($match/../@*:sex)}">
                        {
                            <idno type='ReadAct'>{data($match/../@*:id)}</idno>,
                            $match/../child::node()
                        }
                    
                    </person>
                    )
                else
                    ($p/..)
        }
    </listPerson>
    
    
    <listOrg>{
            for $o in $SCB//listOrg/org
            let $path := $listOrg/org/orgName[. = $o/orgName]/..
            return
                if ($o/orgName[. = $listOrg/org/orgName])
                then
                    <org>
                        {
                            <idno type='ReadAct'>{data($path/@*:id)}</idno>,
                            $path/child::node()
                        }
                    </org>
                else
                    $o
        }</listOrg>
</standOff>
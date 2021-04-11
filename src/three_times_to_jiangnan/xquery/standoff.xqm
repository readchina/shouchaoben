xquery version "3.1";

module namespace so = "http://readchina.eu/scb/so/ns";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";


(:~ Local Transcripts ~:)
declare variable $so:sanjin-A := doc('../wit_a/xml/三进南京城.xml');
declare variable $so:sanjin-B := doc('../wit_b/xml/三下江南.xml');
declare variable $so:sanjin-C := doc('../wit_c/xml/余飞三下南京.xml');

(:~ ReadAct authority files ~:)
declare variable $so:listPlace := doc("https://raw.githubusercontent.com/readchina/ReadAct/master/xml/listPlace.xml")/listPlace;
declare variable $so:listPerson := doc("https://raw.githubusercontent.com/readchina/ReadAct/master/xml/listPerson.xml")/listPerson;
declare variable $so:listOrg := doc("https://raw.githubusercontent.com/readchina/ReadAct/master/xml/listOrg.xml")/listOrg;

(:~ A set of three functions to process named entities from TEI, by cross-referencing with ReadAct data. 
 : Each function will return the original node in case of non-matches, or a reconstructed node with merged data 
 : and an <idno> element referencing ReadAct
 : @param $input  tei-xml document, or one of its nodes (such as body)
 ~:)
declare function so:lookup-place($input as node()*) as element(listPlace)
{
    <listPlace>
        {
            for $p in $input
            let $path := $so:listPlace/place/placeName[. = $p/placeName]/..
            return
                if ($p/placeName[. = $so:listPlace/place/placeName])
                then
                    <place>
                        {
                            $path/*,
                            <idno
                                type='ReadAct'>{data($path/@*:id)}</idno>
                        }
                    </place>
                else
                    $p
        }
    </listPlace>
};


declare function so:lookup-person($input as node()*) as element(listPerson)
{
    <listPerson>{
            for $p in $input
            let $match := $so:listPerson//persName[concat(./surname, ./forename) = $p]
            return
                if ($match)
                then
                    (
                    <person
                        sex="{data($match/../@*:sex)}">
                        {
                            $match/../*,
                            <idno
                                type='ReadAct'>{data($match/../@*:id)}</idno>
                        }
                    
                    </person>
                    )
                else
                    $p/..
        }
    </listPerson>
};


declare function so:lookup-org($input as node()*) as element(listOrg)
{
    <listOrg>{
            for $o in $input
            let $path := $so:listOrg/org/orgName[. = $o/orgName]/..
            return
                if ($o/orgName[. = $so:listOrg/org/orgName])
                then
                    <org>
                        {
                            $path/*,
                            <idno
                                type='ReadAct'>{data($path/@*:id)}</idno>
                        }
                    </org>
                else
                    $o
        }</listOrg>
};

(:~ Generate standOff xml element by extracting named entities in a given tei-xml node and looking up ReadAct authority files.
 : @see https://github.com/readchina/ReadAct
 : @param $input  tei-xml document, or one of its nodes (such as body)
 : @return standoff element with xml:lang zh containing either original names from the document.  
 ~:)
declare function so:standoff-merged($input as node()*) as element(standOff) {
    <standOff
        xml:lang="zh">
        {
            so:lookup-place($input//listPlace/place),
            so:lookup-person($input//listPerson//persName),
            so:lookup-org($input//listOrg/org)
        }
    </standOff>
};

(:~ Get the distinct named entities from a TEI transcription.
 : @param $nodes a common ancestor for all entities, e.g. body
 : @return standoff element with xml:lang zh containing distinct names for further processing.  
 ~:)
declare function so:standOff-distinct($nodes as node()*) as element(standOff) {
    <standOff
        xml:lang="zh">
        <listPlace>{
                for $p in distinct-values($nodes//placeName)
                return
                    <place><placeName>{$p}</placeName></place>
            }
        </listPlace>
        <listPerson>{
                for $p in distinct-values($nodes//persName)
                return
                    <person><persName>{$p}</persName></person>
            }</listPerson>
        <listOrg>{
                for $p in distinct-values($nodes//orgName)
                return
                    <org><orgName>{$p}</orgName></org>
            }</listOrg>
    </standOff>
};
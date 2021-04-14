xquery version "3.1";

import module namespace so = "http://readchina.eu/scb/so/ns" at "standoff.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:Todo: Problem which needs to be fixed: because there're empty elements like "<placeName ref="#SP0436"/>" exists in  "listPerson.xml" and "listOrg.xml",
so the result of place ids in the standOff starts at 2. :)
declare function local:add-place-id($input as node()*)
{
    <listPlace>{
            for $c at $pos in (1 to count($input//place))
            return
                if (fn:string-length($input//place[$pos]) > 0)
                then
                    <place
                        xml:id="{"P" || fn:format-integer(data($c), '0000')}">
                        {
                            for $childnode in $input//place[$pos]/*
                            return
                                if (local-name($childnode) = "placeName")
                                then
                                    <placeName>{fn:normalize-space($childnode)}</placeName>
                                else
                                    $childnode
                        }</place>
                else
                    ()
        }
    </listPlace>
};


declare function local:add-person-id($input as node()*)
{
    <listPerson>{
            for $c at $pos in (1 to count($input//person))
            return
                <person
                    xml:id="{"PE" || fn:format-integer(data($c), '0000')}">
                    {
                        for $childnode in $input//person[$pos]/*
                        return
                            if (local-name($childnode) = "persName")
                            then
                                <persName>{
                                        fn:normalize-space($childnode)
                                    }</persName>
                            else
                                $childnode
                    }
                </person>
        }
    </listPerson>
};

declare function local:add-org-id($input as node()*)
{
    <listOrg>{
            for $c at $pos in (1 to count($input//org))
            return
                <org
                    xml:id="{"O" || fn:format-integer(data($c), '0000')}">
                    {
                        for $childnode in $input//org[$pos]/*
                        return
                            if (local-name($childnode) = "orgName")
                            then
                                <orgName>{fn:normalize-space($childnode)}</orgName>
                            else
                                $childnode
                    }
                </org>
        }
    </listOrg>
};


declare function local:all-ids($input as node()*)
{
    <standOff
        xml:lang="zh">
        {
            local:add-place-id(so:standoff-merged(so:standOff-distinct($input))),
            local:add-person-id(so:standoff-merged(so:standOff-distinct($input))),
            local:add-org-id(so:standoff-merged(so:standOff-distinct($input)))
            
        }
    </standOff>
};


local:all-ids($so:sanjin-A | $so:sanjin-B | $so:sanjin-C)
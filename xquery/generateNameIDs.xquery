xquery version "3.1";

import module namespace so = "http://readchina.eu/scb/so/ns" at "standoff.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $standOff := doc("../standOff.xml");

declare function local:change-place-id($input as node()*)
{
    <listPlace>{
            for $c at $pos in (1 to count($input//place))
            return
                <place
                    xml:id="{"P" || fn:format-integer(data($c), '0000')}">
                    {
                        for $childnode in $input//place[$pos]/*
                        return
                                $childnode
                                
                    }</place>
        }</listPlace>
};


declare function local:change-person-id($input as node()*)
{
    <listPerson>{
            for $c at $pos in (1 to count($input//person))
            return
                <person
                    xml:id="{"PE" || fn:format-integer(data($c), '0000')}">
                    {
                        for $childnode in $input//person[$pos]/*
                        return
                                $childnode
                    }
                </person>
        }</listPerson>
};


declare function local:change-org-id($input as node()*)
{
    <listOrg>{
            for $c at $pos in (1 to count($input//org))
            return
                <org
                    xml:id="{"O" || fn:format-integer(data($c), '0000')}">
                    {
                        for $childnode in $input//org[$pos]/*
                        return
                                $childnode
                    }
                </org>
        }</listOrg>
};



declare function local:change-all-ids($input as node()*)
{
    <standOff
        xml:lang="zh">
        {
            local:change-place-id($input),
            local:change-person-id($input),
            local:change-org-id($input)
        }
    </standOff>
};


local:change-all-ids($standOff)


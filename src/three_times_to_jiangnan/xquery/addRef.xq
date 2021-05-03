xquery version "3.1";

(:~ Local Transcripts ~:)
declare variable $sanjin-A := doc('../wit_a/xml/三进南京城.xml');
declare variable $sanjin-B := doc('../wit_b/xml/三下江南.xml');
declare variable $sanjin-C := doc('../wit_c/xml/余飞三下南京.xml');
declare variable $standOff := doc("../standOff.xml");

declare function local:add-place-ref($input as node()*)
{
for $n in $input//*:text//*:placeName
return if($standOff//*:placeName[./string() = $n/string()])
then update insert  attribute ref{"#"||data($standOff//*:placeName[./string() = $n/string()]/../@*:id)} into $n
else ()
};


declare function local:add-person-ref($input as node()*)
{
for $n in $input//*:text//*:persName
return if($standOff//*:persName[./string() = $n/string()])
then update insert  attribute ref{"#"||data($standOff//*:persName[./string() = $n/string()]/../@*:id)} into $n
else ()
};


declare function local:add-org-ref($input as node()*)
{
for $n in $input//*:text//*:orgName
return if($standOff//*:orgName[./string() = $n/string()])
then update insert  attribute ref{"#"||data($standOff//*:orgName[./string() = $n/string()]/../@*:id)} into $n
else ()
};

local:add-place-ref($sanjin-A|$sanjin-B|$sanjin-C),
local:add-person-ref($sanjin-A|$sanjin-B|$sanjin-C),
local:add-org-ref($sanjin-A|$sanjin-B|$sanjin-C)
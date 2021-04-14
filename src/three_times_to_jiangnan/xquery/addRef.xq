declare namespace fun = "http://www.functx.com";
declare function fun:add-attributes
  ( $elements as element()* ,
    $attrNames as xs:QName* ,
    $attrValues as xs:anyAtomicType* )  as element()? {

   for $element in $elements
   return element { node-name($element)}
                  { for $attrName at $seq in $attrNames
                    return if ($element/@*[node-name(.) = $attrName])
                           then ()
                           else attribute {$attrName}
                                          {$attrValues[$seq]},
                    $element/@*,
                    $element/node() }
 } ;

declare variable $sanjin-A := db:open("three_times_to_jiangnan","wit_a/xml/三进南京城.xml");
declare variable $sanjin-B :=  db:open("three_times_to_jiangnan","wit_b/xml/三下江南.xml");
declare variable $sanjin-C :=  db:open("three_times_to_jiangnan","wit_c/xml/余飞三下南京.xml");


declare function local:add-place-ref($input as node()*)
{
let $standOff :=  db:open("three_times_to_jiangnan","standOff.xml")
for $node in $input//*:text//*:placeName
return fun:add-attributes($node, xs:QName('ref'), "#"||data($standOff//*:placeName[./string() = $node/string()]/../@*:id))
};


declare function local:add-person-ref($input as node()*)
{
let $standOff :=  db:open("three_times_to_jiangnan","standOff.xml")
for $node in $input//*:text//*:persName
return fun:add-attributes($node, xs:QName('ref'), "#"||data($standOff//*:persName[./string() = $node/string()]/../@*:id))
};


declare function local:add-org-ref($input as node()*)
{
let $standOff :=  db:open("three_times_to_jiangnan","standOff.xml")
for $node in $input//*:text//*:orgName
return fun:add-attributes($node, xs:QName('ref'), "#"||data($standOff//*:orgName[./string() = $node/string()]/../@*:id))
};

local:add-place-ref($sanjin-A|$sanjin-B|$sanjin-C),
local:add-person-ref($sanjin-A|$sanjin-B|$sanjin-C),
local:add-org-ref($sanjin-A|$sanjin-B|$sanjin-C)
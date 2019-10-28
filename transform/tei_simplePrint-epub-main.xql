import module namespace m='http://www.tei-c.org/pm/models/tei_simplePrint/epub' at '/db/apps/SNNJ/transform/tei_simplePrint-epub.xql';

declare variable $xml external;

declare variable $parameters external;

let $options := map {
    "styles": ["../transform/tei_simplePrint.css"],
    "collection": "/db/apps/SNNJ/transform",
    "parameters": if (exists($parameters)) then $parameters else map {}
}
return m:transform($options, $xml)
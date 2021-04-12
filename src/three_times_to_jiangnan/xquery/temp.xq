xquery version "3.1";

declare default element namespace "http://www.tei-c.org/ns/1.0";

import module namespace so = "http://readchina.eu/scb/so/ns" at "standoff.xqm";



for $e in $so:sanjin-B//*
return
 typeswitch ($e)
 case element ()
  return element {node-name($e)}
 {$e/@*, normalize-space($e)}
 default return ()

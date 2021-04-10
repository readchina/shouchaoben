xquery version "3.1";

import module namespace so = "http://readchina.eu/scb/so/ns" at "standoff.xqm";

declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

so:standoff-merged($so:sanjin-A)
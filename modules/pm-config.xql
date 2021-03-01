
xquery version "3.1";

module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config";

import module namespace pm-dantiscus2-web="http://www.tei-c.org/pm/models/dantiscus2/web/module" at "../transform/dantiscus2-web-module.xql";
import module namespace pm-dantiscus2-print="http://www.tei-c.org/pm/models/dantiscus2/fo/module" at "../transform/dantiscus2-print-module.xql";
import module namespace pm-dantiscus2-latex="http://www.tei-c.org/pm/models/dantiscus2/latex/module" at "../transform/dantiscus2-latex-module.xql";
import module namespace pm-dantiscus2-epub="http://www.tei-c.org/pm/models/dantiscus2/epub/module" at "../transform/dantiscus2-epub-module.xql";
import module namespace pm-docx-tei="http://www.tei-c.org/pm/models/docx/tei/module" at "../transform/docx-tei-module.xql";

declare variable $pm-config:web-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "dantiscus2.odd" return pm-dantiscus2-web:transform($xml, $parameters)
    default return pm-dantiscus2-web:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:print-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "dantiscus2.odd" return pm-dantiscus2-print:transform($xml, $parameters)
    default return pm-dantiscus2-print:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:latex-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "dantiscus2.odd" return pm-dantiscus2-latex:transform($xml, $parameters)
    default return pm-dantiscus2-latex:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:epub-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "dantiscus2.odd" return pm-dantiscus2-epub:transform($xml, $parameters)
    default return pm-dantiscus2-epub:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:tei-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "docx.odd" return pm-docx-tei:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode tei")
            
    
};
            
    
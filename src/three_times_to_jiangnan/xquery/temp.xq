xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace ner = "http://exist-db.org/xquery/stanford-nlp/ner";
import module namespace so = "http://readchina.eu/scb/so/ns" at "standoff.xqm";
import module namespace xmldb = "http://exist-db.org/xquery/xmldb";

for $n in ($so:sanjin-B, $so:sanjin-C, $so:sanjin-A)
let $col := document-uri($n) => tokenize('/')
let $name := $n//tei:titleStmt/tei:title[1]
let $path := '/db/three_times_to_jiangnan/' || $col[4] || '/xml/processed'
let $ner := ner:query-text-as-xml($n//tei:body, "zh" )

return
    xmldb:store($path, $name || '_ner2.xml', 
    <tei:TEI>
      {$n//tei:teiHeader}
      <tei:text>
          {$ner}
      </tei:text>
    </tei:TEI>
    )
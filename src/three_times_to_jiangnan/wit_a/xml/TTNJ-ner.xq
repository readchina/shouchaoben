xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace ner = "http://exist-db.org/xquery/stanford-nlp/ner";

declare variable $sanjin-A := doc('三进南京城.xml');
declare variable $sanjin-B := doc('三下江南.xml');
declare variable $sanjin-C := doc('余飞三下南京.xml');

for $n in ($sanjin-A, $sanjin-B, $sanjin-C)
let $name := $n//tei:titleStmt/tei:title[1]
let $ner := ner:classify-node($n//tei:body, "zh" )

return
    xmldb:store('/db/NER_scb', $name || '_ner.xml', 
    <tei:TEI>
      {$n//tei:teiHeader}
      <tei:text>
          {$ner}
      </tei:text>
    </tei:TEI>)
    
    

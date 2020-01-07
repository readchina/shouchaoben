xquery version "3.1";

declare default element namespace "http://www.tei-c.org/ns/1.0";


for $n in doc('三进南京城.xml')//tei:g
return
   replace node $n with  <choice><orig>{data($n/@ref)}</orig><reg>{$n/text()}</reg></choice>
xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace ner = "http://exist-db.org/xquery/stanford-nlp/ner";

declare variable $sanjin-A := doc('三进南京城.xml');

let $test := '克林顿说，华盛顿将逐步落实对韩国的经济援助。金大中对克林顿的讲话报以掌声：克林顿总统在会谈中重申，他坚定地支持韩国摆脱经济危机。'

let $tei := <p> 一九七〇年初春，阿尔巴尼亚代表团来我国<choice>
                    <orig>訪</orig>
                    <reg>访</reg>
                </choice>问，临结束<choice>
                    <orig>時</orig>
                    <reg>时</reg>
                </choice>，向中央要求参观南京长江大桥，中央经过讨论同意了客人的要求，<choice>
                    <orig>並</orig>
                    <reg>并</reg>
                </choice>通知南京市着手组织做好接待和保卫工作。</p>
                
let $text := $sanjin-A//tei:body/tei:p     
return
     xmldb:store('/db/', 'sanjin_ner.xml',
<wrap> {
for $p in $text
let $t := normalize-space($p)
    
return

 ner:query-text($t, "zh")
    }
    </wrap>)

(:$t:)
    
(:    xmldb:store('/db/', 'sanjin_ner.xml', ner:query-text($text, "zh")):)
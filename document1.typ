#import "src/tools/pageframe.typ": page-frame-sequence, document-data
#import "src/tools/numbering.typ": heading-numbering-ru, enum-numbering
#import "src/tools/table-tools.typ": table-multi-page
#import "src/style.typ": style-ver-1
#import "src/tools/outlines.typ": outline-break-by-enum

#show: style-ver-1


#set page(background: page-frame-sequence())
#show outline.entry: it => outline-break-by-enum(30, it)
#outline()


= Введение
= Feature

== Feature
= Feature
== Feature
= #lorem(18)
= Блок
= #lorem(18)
= #lorem(18)
= Feature
Дополнение
== Feature
= Заключение


This is a simple template for testing.

Here's a simple equation:

$ E = m c^2 $


#lorem(50)

#lorem(50)


Описание представлено в таблице @ttt


#[
  #show figure: set block(breakable: true)
  #figure(
    kind: table,
    caption: [Какое-то очень длинное название таблицы, которое не должно помещаться в одну строку текст текст],
    table-multi-page(
      continue-header-label: [Продолжение таблицы @ttt],
      continue-footer-label: [Продолжение таблицы @ttt],
      table(
        columns: (2cm, 3cm, 4cm, 1fr),
        row-gutter: (0.6mm, auto),
        inset: (top: 2mm, bottom: 2mm),
        table.header([cell1], [cell2], [cell3], [cell4]),
        ..for value in range(0, 150) {
          ([cell value], [#(150 - value)])
        }
      ),
    ),
  )
  <ttt>
]

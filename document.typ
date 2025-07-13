#import "src/tools/pageframe.typ": (
  page-frame-outline,
  page-frame-sequence,
  document-data,
  page-footer-sequence,
  page-layout-sequence,
)
#import "src/tools/numbering.typ": heading-numbering-ru, _enum-numbering
#import "src/tools/annexes.typ": *
#import "src/tools/table-tools.typ": table-multi-page
#import "src/tools/headings.typ": headings
#import "src/style.typ": style-ver-1
#import "src/tools/outlines.typ": outline-trim-by-prefix

// #set heading(numbering: "1.1")
#set par(
  first-line-indent: (
    amount: 1.25cm,
    all: true,
  ),
)
// #show:body=> style-ver-1(body)
#show: style-ver-1

// #set page(margin: (left: 3cm, right: 1.5cm, bottom: 2.5cm, top: 1.5cm))
// #show: page-frame-sequence.with(document-data:document-data)
// #set page(background: page-frame-sequence())
// #set page(footer:  page-footer-sequence())
// #set page(background: page-frame-sequence())
// #show:body=>context page-layout-sequence(body)

#set text(
  font: "Times new roman",
  size: 13pt,
  lang: "ru",
)

#show figure: it => block(if it.has("caption") {
  set figure.caption(position: top)
  show figure.caption: caption => {
    set align(left)
    set par(first-line-indent: (amount: 0cm))
    if caption.numbering != none {
      caption.supplement + [ ]
      numbering(caption.numbering, ..counter(figure).at(it.location())) + [ \- ] + caption.body
      v(-2mm)
    }
  }
  it
})
// #context place(
//   top,
//   dy: -page.header-ascent,
//   {
//     // Pretend stuff inside the header has as much height as our concept of margin allows
//     block(height: 70mm, [text])
//     // block(height: margin-for(here().page()), body)
//   },
// )
#let is-odd-page() = calc.rem(counter(page).get().first(), 2) == 1
#set page(
  header: context if is-odd-page() [odd] else [even] + " header",
  footer: context if is-odd-page() [odd] else [even] + " footer",
  footer-descent: -3cm,
)

#show outline.entry: it => outline-trim-by-prefix(it, direction: 0, prefix-number: 10)
#show outline: it => {
  show pagebreak: [text]
  show heading: []
  it
}

#outline()


#show outline.entry: it => outline-trim-by-prefix(direction: 1, prefix-number: 10, it)
#page(margin: (bottom: 6cm))[#outline()]



#pagebreak()
#let a = text("1.1")
#a
// #let is-split = repr(a).replace(regex("[\[\]]"), "")

#let is-split = int(repr(a).replace(regex("[\[\]]"), "").split(".").first())

#is-split
= Feature

= Заключение
== Feature
= Feature
== Feature
== Feature
== Feature
== Feature
== Feature
== Feature
== Feature
== Feature
= Feature
= Feature
= Feature
= Feature
== Feature
== Feature
== Feature
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= #lorem(18)
= Feature
= Feature
= Feature
= Feature
= Feature
= Feature
// #show: annexes
Дополнение
= Feature
= Feature
= Feature
= Feature
= Feature
= Заключение
== Feature
#pagebreak()
This is a simple template for testing.

Here's a simple equation:

$ E = m c^2 $


#lorem(50)

#lorem(50)

#let tbl = table(
  columns: (2cm, 3cm, 4cm, 1fr),
  row-gutter: (0.6mm, auto),
  inset: (top: 2mm, bottom: 2mm),
  table.header([cell1], [cell2], [cell3], [cell4]),
  ..for value in range(0, 150) {
    ([cell value], [#(150 - value)])
  }
)
Описание представлено в таблице @ttt2[]


#[
  #show figure: set block(breakable: true)
  #figure(
    kind: table,
    caption: [Какое-то очень длинное название таблицы, которое не должно помещаться в одну строку текст текст],
    table-multi-page(
      continue-header-label: [Продолжение таблицы @ttt2[]],
      continue-footer-label: [Продолжение таблицы @ttt2[]],
      tbl,
    ),
  )
  <ttt2>
]

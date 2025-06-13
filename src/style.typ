#import "tools/headings.typ": headings, structural-heading-titles
#import "tools/annexes.typ": is-heading-in-annex
#import "tools/pageframe.typ": page-frame-sequence

#let style-ver-1(
  body,
) = {
  show outline.entry: it => {
    if is-heading-in-annex(it.element) {
      link(
        it.element.location(),
        it.indented(
          none,
          [Приложение #it.prefix() #it.element.body]
            + sym.space
            + box(width: 1fr, it.fill)
            + sym.space
            + sym.wj
            + text(fill: red, it.page()),
        ),
      )
    } else {
      it
    }
  }

  set par(
    first-line-indent: (
      amount: 1.25cm,
      all: true,
    ),
  )
 
  set text(lang: "ru", font: "Times New Roman")
 let is-odd-page() = context {
    return calc.rem(counter(page).get().first(), 2) == 1
  }
  show: headings
  set ref(supplement: none)
  set math.equation(numbering: "(1)")
  show image: set align(center)
  set figure.caption(separator: " — ")
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  show figure: it => block(if it.has("caption") {
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

  set list(marker: [–], spacing: 1em)

  body
}

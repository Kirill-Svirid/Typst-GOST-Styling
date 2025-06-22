
#let set-base-style(doc) = {
  set text(lang: "ru", font: "Times New Roman", size: 13pt)
  // set text(lang: "ru",region: "RU", font: "newr", size: 13pt)

  set heading(numbering: "1.1.1")
  show heading: set text(hyphenate: false)
  show outline.entry: set par(justify: true)
  set par(
    first-line-indent: (
      amount: 1.25cm,
      all: true,
    ),
    justify: true,
  )


  set ref(supplement: none)

  show image: set align(center)

  set figure.caption(separator: " — ")

  show figure.where(kind: image): set figure(supplement: [Рисунок])

  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }

  // show heading.where(level: 1): it => {
  //   // pagebreak(weak: true)
  //   colbreak(weak: true)
  //   it
  // }

  show figure: it => block(if it.has("caption") {
    // set it.caption(separator: " — ")
    show figure.caption: caption => {
      set align(left)
      set par(first-line-indent: (amount: 0cm))
      if caption.numbering != none {
        caption.supplement + [ ]
        numbering(caption.numbering, ..counter(figure).at(it.location())) + [ \- ] + caption.body
      }
    }
    it
  })

  set list(marker: [–])

  doc
}

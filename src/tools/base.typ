
#let set-base-style(doc) = {
  set text(lang: "ru", font: "Times New Roman", size: 13pt)
  // set heading(numbering: "1.1.1")
  show heading: set text(hyphenate: false)

  set ref(supplement: none)

  show image: set align(center)

  set figure.caption(separator: " — ")

  show figure.where(kind: image): set figure(supplement: [Рисунок])

  show figure.where(kind: table): it => {
    set figure.caption(position: top)
    it
  }


  set list(marker: [–])

  doc
}

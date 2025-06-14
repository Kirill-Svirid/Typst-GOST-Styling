#import "tools/headings.typ": headings, structural-heading-titles
#import "tools/annexes.typ": is-heading-in-annex
#import "tools/pageframe.typ": page-frame-sequence
#import "tools/utils.typ": is-empty
#import "tools/base.typ": *


#let enum-set-heading-numbering(doc) = {
  set enum(
    numbering: (..n) => context {
      let headings = query(selector(heading).before(here()))
      let last = headings.at(-1)
      counter(heading).step(level: last.level + n.pos().len())
      context { counter(heading).display() }
    },
  )
  doc
}

#let enum-drop-heading-numbering(doc) = {
  set enum(numbering: "1")
  doc
}

#let correctly-indent-list-and-enum-items(doc) = {
  let first-line-indent() = if type(par.first-line-indent) == dictionary {
    par.first-line-indent.amount
  } else {
    par.first-line-indent
  }

  show list: li => {
    for (i, it) in li.children.enumerate() {
      let nesting = state("list-nesting", 0)
      let indent = context h((nesting.get() + 1) * li.indent)
      let marker = context {
        let n = nesting.get()
        if type(li.marker) == array {
          li.marker.at(calc.rem-euclid(n, li.marker.len()))
        } else if type(li.marker) == content {
          li.marker
        } else {
          li.marker(n)
        }
      }
      let body = {
        nesting.update(x => x + 1)
        it.body + parbreak()
        nesting.update(x => x - 1)
      }
      let content = {
        marker
        h(li.body-indent)
        body
      }
      context pad(left: int(nesting.get() != 0) * li.indent, content)
    }
  }

  show enum: en => {
    let start = if en.start == auto {
      if en.children.first().has("number") {
        if en.reversed { en.children.first().number } else { 1 }
      } else {
        if en.reversed { en.children.len() } else { 1 }
      }
    } else {
      en.start
    }
    let number = start
    for (i, it) in en.children.enumerate() {
      number = if it.has("number") { it.number } else { number }
      if en.reversed { number = start - i }
      let parents = state("enum-parents", ())
      let indent = context h((parents.get().len() + 1) * en.indent)
      let num = if en.full {
        context numbering(en.numbering, ..parents.get(), number)
      } else {
        numbering(en.numbering, number)
      }
      let max-num = if en.full {
        context numbering(en.numbering, ..parents.get(), en.children.len())
      } else {
        numbering(en.numbering, en.children.len())
      }
      num = context box(
        width: measure(max-num).width,
        align(right, text(overhang: false, num)),
      )
      let body = {
        parents.update(arr => arr + (number,))
        it.body + parbreak()
        parents.update(arr => arr.slice(0, -1))
      }
      if not en.reversed { number += 1 }
      let content = {
        num
        h(en.body-indent)
        body
      }
      context pad(left: int(parents.get().len() != 0) * en.indent, content)
    }
  }
  doc
}

#let style-ver-1(doc) = {
  set text(lang: "ru", font: "Times New Roman", size: 13pt)
  show: set-base-style.with()

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
            + it.page(),
        ),
      )
    } else {
      it
    }
  }

  set heading(numbering: "1.1.1")

  let header-counter = counter("header-all")

  show: correctly-indent-list-and-enum-items

  set page(margin: (left: 3cm, rest: 2cm))

  set par(
    first-line-indent: (
      amount: 1.25cm,
      all: true,
    ),
    justify: true,
    // spacing: 1.5em,
  )

  show heading: it => block(width: 100%)[
    #if not is-empty(it.numbering) {
      counter(heading).display(it.numbering) + [ ] + [#it.body]
    } else { it }
    #v(1cm)

  ]

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

  // show heading.where(level: 1): it => {
  //   // pagebreak(weak: true)
  //   it
  // }


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

  set list(marker: [–])

  show heading: it => {
    if it.level == 1 {
      (
        pagebreak(weak: true)
          + block(
            it,
            fill: color.hsl(200deg, 15%, 75%, 30%),
            above: 12pt,
            below: 18pt,
            inset: 1mm,
            radius: 2mm,
          )
      )
    } else { it }
    // it
    header-counter.step()
  }

  doc
}

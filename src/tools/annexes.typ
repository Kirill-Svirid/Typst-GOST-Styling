#import "numbering.typ": heading-numbering-ru

#let is-heading-in-annex(heading) = state("annexes", false).at(heading.location())

#let get-element-numbering(current-heading-numbering-ru, element-numbering) = {
  if (current-heading-numbering-ru.first() <= 0 or element-numbering <= 0) {
    return
  }
  let current-numbering = heading-numbering-ru(current-heading-numbering-ru.first())
  (current-numbering, numbering("1.1", element-numbering)).join(".")
}

#let annex-heading(status, level: 1, body) = {
  heading(level: level)[(#status)\ #body]
}

#let annexes(doc) = context {
  set heading(
    numbering: heading-numbering-ru,
    supplement: [Приложение],
  )

  show heading: it => {
    if is-heading-in-annex(it) {
      set align(center)
      set heading(supplement: [Приложение])
      assert(
        it.numbering != none,
        message: "В приложениях не может быть структурных заголовков или заголовков без нумерации",
      )
      pagebreak()
      counter("annex").step()

      block[#it.supplement #numbering(it.numbering, ..counter(heading).at(it.location())) \ #text(
          weight: "thin",
        )[#it.body]]

      show heading.where(level: 1): it => context {
        counter(figure.where(kind: image)).update(0)
        counter(figure.where(kind: table)).update(0)
        counter(figure.where(kind: raw)).update(0)
        counter(math.equation).update(0)
        it
      }

      set figure(
        numbering: it => {
          let current-heading = context counter(heading).get()
          get-element-numbering(current-heading, it)
        },
      )


      set math.equation(
        numbering: it => {
          let current-heading = counter(heading).get()
          [(#get-element-numbering(current-heading, it))]
        },
      )
    } else {
      it
    }
  }

  state("annexes").update(true)
  counter(heading).update(0)
  doc
}

#let annexes-enable(doc) = context {
  set heading(
    numbering: heading-numbering-ru,
    supplement: [Приложение],
  )

  show heading: it => {
    if is-heading-in-annex(it) {
      set block(width:100%, fill: color.hsl(203deg, 30%, 83%,50%), radius: 1mm,inset: 3mm)

      set align(center)
      assert(
        it.numbering != none,
        message: "В приложениях не может быть структурных заголовков или заголовков без нумерации" + repr(it.body),
      )
      pagebreak()
      // counter("annex").step()

      block(
        [#it.supplement #numbering(
            it.numbering,
            ..counter(heading).at(it.location()),
          ) \ #it.body],
      )
    } else { it }
  }

  state("annexes").update(true)
  counter(heading).update(0)
  doc
}

#let annexes-disable(doc) = {
  set heading(supplement: none)
  state("annexes").update(false)
  doc
}

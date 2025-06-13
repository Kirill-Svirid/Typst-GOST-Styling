#set heading(numbering: "1.1")
#set page(numbering: "1")
#let lab-counter = counter("lab")
#let header-counter = counter("header-all")

#let lab-slide(title) = {
  lab-counter.step()
  context { heading(level: 2, [Lab #lab-counter.display(): #title]) }
}

#show heading.where(level: 1): it => {
  header-counter.step()
  [ #metadata(("counter": header-counter.get(), "header": it))<lbl-header> ]
  it.body + [#header-counter.display()]
}

// #outline()
#context {
  let chapters = query(heading.where(level: 1).or(heading.where(level: 2)))

  for chapter in chapters {
    let loc = chapter.location()
    let nr = numbering(
      loc.page-numbering(),
      ..counter(page).at(loc),
    )
    link(
      loc,
      [#chapter.body #h(1fr) #nr \ ],
    )
  }
}

// #outline(target:context query(<lbl-header>))
#context query(<lbl-header>).at(2).value.at("header")

#context {
  let lbls = query(<lbl-header>)

  for it in lbls {
    // it.value.at(1)
    // it
  }
}


#pagebreak()
= foo
#lab-slide("fizz")
#lab-slide("buzz")
#pagebreak()
#lab-slide("fizzbuzz")

= bar
#lab-slide("blafoo")
#lab-slide("foobla")
= All header

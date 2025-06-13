#set heading(numbering: "1.1")
#set page(numbering: "1")
#let header-counter = counter("header-all")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}
#show heading: it => {
  header-counter.step()
  it
  [ #metadata(("counter": header-counter.get(), "header": it))<lbl-header> ]
}


#let outline-break(num) = context {
  let headings = query(<lbl-header>)
  for meta-header in headings {
    let head = meta-header.value.at("header")
    let loc = meta-header.location()
    let sel=selector(heading).after(here())
    let num=counter(sel).display(head.numbering)
    let n=numbering(head.numbering,..counter(heading).at(loc))
    let nr = numbering(
      loc.page-numbering(),
      ..counter(page).at(loc),
    )
    link(
      head.location(),
      // h.body + [\ ]
      [#n]+[#head.body ] + sym.space + box(width: 1fr, repeat[.]) + sym.space + sym.wj + [ #nr \ ],
    )
  }
}
#outline-break(2)

#context query(<lbl-header>)
#context {
  let lbls = query(<lbl-header>)

  for it in lbls {
    // it.value.at(1)
    // it
  }
}


= foo
== foofoo

= bar
== barbar

= fizbazz

= header

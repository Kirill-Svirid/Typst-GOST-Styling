
// Trim outline either forward(0) or backward(1) by prefix number
// #let outline-trim-by-prefix(prefix-number: 0, direction: 0, it) = {
//   let pref = repr(it.prefix()).replace(regex("[\[\]]"), "").split(".").first()
//   let show-item = {
//     if pref == "none" { it } else if direction == 0 and int(pref) < prefix-number {
//       it
//     } else if direction == 1 and int(pref) >= prefix-number { it } else { [] }
//   }
//   show-item
// }
#let outline-trim-by-prefix(prefix-number: 0, direction: 0, it) = {
  let pref = repr(it.prefix()).replace(regex("[\[\]]"), "").split(".").first()
  // let count = context(counter(heading).display(it))

  pref = if pref == "none" { 0 } else { int(pref) }
  let to-show = {
    (prefix-number > pref and pref != 0 and direction == 0) or (prefix-number <= pref and pref != 0 and direction == 1)
  }
  it
  // [#pref<#prefix-number = #{pref < prefix-number} ] + [#to-show] + [\ ]
  // let to-show = if prefix-number < pref and pref!=0 and direction == 0 { true } else { true }
  // if to-show { it } else { [#{ ( prefix-number <= pref and pref!=0 )}] + [\ ]}

  // link(
  //   it.element.location(),
  //   it.indented(
  //     it.prefix() + [],
  //     text(
  //       fill: blue,
  //       it.body() + box(width: 1fr, it.fill) + sym.wj + it.page() + [ ] + str(pref) + [ #to-show, ],
  //     ),
  //   ),
  // )
}
#let header-counter = counter("header-all")


#show heading: it => {
  header-counter.step()
  it
}

// Break outline feed by specified break-points (array or int).
// Before usage counter header-all must be applied to headers.
#let outline-break-by-enum(break-points, entry) = {
  let loc = entry.element.location()
  let c = counter("header-all").at(loc).at(0)
  if type(break-points) == int { break-points = (break-points,) }
  if break-points.contains(c) { pagebreak(weak: true) + entry } else { entry }
}

#let outline-break-by-header-body(break-heading, entry) = {
  let loc = entry.element.location()
  // assert(type(break-heading)==heading,"Wrong argument type")
  assert(type(break-heading) == label, message: "Type of argument must be label")
  let show-break = { entry.element.body == query(break-heading).at(0).body }
  if show-break { pagebreak() + entry } else { entry }
  // query( break-heading ).at(0).body

  // [#entry.fields()] + [#show-break]+ [\ ]
  // [#context query(break-heading).at(0).fields()]
}

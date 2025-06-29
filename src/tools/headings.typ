#let structural-heading-titles = (
  intro: [Введение],
  abstract: [Реферат],
  conclusion: [Заключение],
  content-list-ver-1: [Содержание],
  content-list-ver-2: [Оглавление],
  term-list-var-1: [Термины и определения],
  term-list-var-2: [Обозначения и сокращения],
  abbreviation-list-ver-1: [Перечень сокращений и обозначений],
  abbreviation-list-ver-2: [Обозначения и сокращения],
  performer-list: [Список исполнителей],
  reference-list-gen: [Список использованных источников],
  reference-list-docs: [Ссылочные документы],
  reference-list-legislation-docs: [Ссылочные нормативные документы],
  reference-list-bibliography: [Библиография],
)

// Selects headings of level 1 and body of special list of content to disable enumeration for them (GOST requirements)
#let set-heading-titles = body => {
  let folder-func(sel, item) = sel.or(heading.where(body: item, level: 1))
  let selector-structural-heading = structural-heading-titles.values().fold(selector, folder-func)
  show selector-structural-heading: set heading(numbering: none)
  show selector-structural-heading: set align(center)

  body
}

#let is-heading-in-structural(body) = {
  if structural-heading-titles.values().contain(it.body) and it.level == 1 {
    return true
  } else {
    return false
  }
}

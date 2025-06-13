#let structural-heading-titles = (
  intro: [Введение],
  abstract: [Реферат],
  conclusion: [Заключение],
  content-list: [Содержание],
  term-list-var-1: [Термины и определения],
  term-list-var-2: [Обозначения и сокращения],
  abbreviation-list: [Перечень сокращений и обозначений],
  performer-list: [Список исполнителей],
  reference-list: [Список использованных источников],
  reference-list-docs:[Ссылочные документы],
  reference-list-normative-docs:[Ссылочные нормативные документы],
  reference-list-bibliography:[Библиография]
)

#let headings = body => {
  set heading(numbering: "1.1.1")

  let structural-heading = structural-heading-titles
    .values()
    .fold(selector, (acc, heading-body) => acc.or(heading.where(body: heading-body, level: 1)))

  show structural-heading: set heading(numbering: none)

  body
}

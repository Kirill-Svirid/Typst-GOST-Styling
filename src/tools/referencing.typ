#import "@preview/t4t:0.4.3"
#import "@local/oxifmt:1.0.0"
#import "utils.typ": is-empty, to-string, string-convert-quote-marks
#import "bit-math.typ": *

#let flg-half-date = 1
#let flg-smart-quotes = 2
#let flg-trim-extra-spaces = 3
#let flg-trim-newline = 4
#let flg-name-nobreak = 5


/* Все загруженные документы в виде ключ-ключ для упрощения обращения к документам по тексту*/
#let document-labels = state("document-labels", (:))
// Все загруженные документы
#let document-base = state("document-base", (:))
// Все документы, на которые даны ссылки по тексту документа
#let document-mentions = state("document-mentions", (:))
// Ссылки(label), на которые документ может обращаться документ
#let document-backlinks = state("document-backlinks", (:))
// Типы документов, на которые уже приведены библиографии. Второй раз привести эти типы нельзя
#let document-referenced-types = state("document-referenced-types", ())
// Документы, которые приведены в библиографии
#let document-referenced-in-bibliography = state("document-referenced-in-bibliography", ())


#let header-legislation = (
  [Обозначение, наименование документа, на который дана ссылка],
  [Номер раздела, подраздела, приложения документа, в котором дана ссылка],
)

#let header-reference = (
  [Наименование организации, обозначение документа, наименование изделия, вид и инвентарный номер документа, на который дана ссылка],
  [Номер раздела, подраздела, приложения документа, в котором дана ссылка],
)


#let document-validate-base(doc) = {
  assert(
    (doc.at("title"), doc.at("name"), doc.at("type")).all(it => type(it) == str),
    message: "Поля (title, name, type) должны иметь тип str",
  )

  // assert(
  //   doc.at("type") in document-type-list,
  //   message: "Неподдерживаемый тип документа. Поддерживаемые типы:" + repr(document-type-list),
  // )

  assert(
    type(doc.at("repr-func")) == function,
    message: "Тип поля должен быть функцией",
  )
  assert(
    type(doc.at("flags")) in (int, type(none)),
    message: "Тип поля должен быть целым" + repr(type(doc.at("flags"))),
  )
}


#let document-sort-prefix(key) = {
  key = lower(key)
  let case = (
    (key.match(regex("^гост.*")), "000"),
    (key.match(regex("^нп.*")), "010"),
    (key.match(regex("^санпин.*")), "020"),
    (key.match(regex("^сп.*")), "025"),
    (key.match(regex("^ост.*")), "030"),
    (key.match(regex("^стк.*")), "040"),
    (key.match(regex("^сто.*")), "050"),
    (key.match(regex("^ту.*")), "060"),
    (true, "100"),
  )
  return case.find(it => it.at(0) != none).at(1)
}


// Предназначена для определения схемы представления документа в таблице ссылок или в списке литературы
#let document-default-repr(document) = {
  let lbl = document.at("label")
  let type = document.at("type")
  let title = document.at("title")
  let name = document.at("name")
  let date = document.at("date")
  let organization = document.at("organization", default: none)
  let headings = document.at("headings")
  let flags = document.at("flags")
  let document-ref-label = label("_link_" + lbl)
  if flags != none and bit-check(flags, flg-half-date) {
    date = date.display("[year repr:last_two]")
  } else {
    date = date.display("[year]")
  }
  (
    if organization != none [#organization. ] + [#name] + [\-#date ] + [#title] + [#metadata(lbl)#document-ref-label]
  )

  document-backlinks.update(s => {
    assert(
      label not in s.keys(),
      message: "Функция не может быть вызвана дважды для одного документа",
    )
    s.insert(lbl, document-ref-label)
    return s
  })
}

#let document-read-definition(
  lbl,
  entity,
  repr-func: none,
  flags: bits-opt(flg-smart-quotes, flg-trim-newline, flg-trim-extra-spaces, flg-name-nobreak),
) = {
  let doc = (:)
  doc.insert("label", lbl)
  doc.insert("type", entity.at("type", default: none))
  doc.insert("name", entity.at("name", default: none))
  doc.insert("title", entity.at("title", default: none))
  doc.insert("organization", entity.at("organization", default: none))
  doc.insert("repr-func", if repr-func != none { repr-func } else { document-default-repr })
  doc.insert("headings", ())
  doc.insert("flags", flags)
  document-validate-base(doc)

  for (k, v) in doc {
    // doc.at(k) = v.replace(regex("^[\r\n\s]|[\r\n\s]+$"), "")
    if type(v) == str {
      // При парсинге к строковым значениями может быть добавлен NewLine.
      // Это мешает при формировании элементов списков и конкатенации. По дефолту это лучше убрать

      if bit-check(flags, flg-trim-newline) {
        v = v.replace(regex("^[\r\n\s]|[\r\n\s]+$"), "")
      }

      if bit-check(flags, flg-trim-extra-spaces) == true {
        v = v.replace(regex("\s\s+"), " ").replace(regex("^[ \t]+|[ \t]+$"), "")
      }

      if bit-check(flags, flg-smart-quotes) == true {
        v = string-convert-quote-marks(v)
      }

      doc.at(k) = v
    }
  }

  if bit-check(flags, flg-name-nobreak) {
    doc.at("name") = doc.at("name").replace(" ", sym.space.nobreak.narrow)
  }

  let date = entity.at("date", default: none)
  assert(
    type(date) in (int, datetime, none),
    message: "Дата должна или целым числом или выражением типа (datetime)",
  )
  if type(date) == int {
    if date > 0 and date < 50 { date += 2000 } else if date >= 50 and date < 100 { date += 1900 }
  }
  assert(date > 1800, message: "Дата для документа не может быть менее 1800")
  date = datetime(year: date, month: 1, day: 1)

  doc.insert("date", date)

  return doc
}

#let document-append-defs(..paths, repr-func: none) = context {
  let document-dict-def
  let docs = (:)
  for path in paths.pos() {
    path = lower(path)
    if path.ends-with("yaml") or path.ends-with("yml") {
      document-dict-def = yaml(path)
    } else if path.ends-with("toml") {
      document-dict-def = toml(path)
    } else if path.ends-with("json") { document-dict-def = json(path) } else {
      panic("Объявлен неподдерживаемый тип файла. Поддерживаемые форматы: [YAML, TOML, JSON]")
    }

    for (k, v) in document-dict-def {
      docs.insert(k, document-read-definition(k, v, repr-func: repr-func))
      document-labels.update(s => {
        s.insert(k, k)
        return s
      })
      [#metadata(k)#label(k)]
    }
  }

  document-base.update(s => {
    s = t4t.get.dict-merge(s, docs)
    return s
  })
}


// Предназначена для определения схемы сортировки документа
#let document-get-sort-key(document-name) = {
  let item = document-base.final().at(document-name, default: none)
  assert(item != none, message: "Документ не обнаружен:" + document-name)
  let type = item.at("type")
  let name = item.at("name")
  let prefix = document-sort-prefix(name)
  return prefix + name
}


// Предназначена для объявления документа по тексту
#let document-ref(document-item, repr-func: none, flags: none) = context {
  let headings = query(heading.where(level: 2).or(heading.where(level: 1)).before(here()))
  headings = headings.filter(it => it.numbering != none)

  let docs-base = document-base.final()

  assert(
    headings.len() > 0,
    message: "Ссылка на документ не может быть использована без нумерованных заголовков уровня 1 или 2, если тип документа находится в ссылочных таблицах",
  )

  assert(
    type(document-item) in (str, content, dictionary, label),
    message: "Тип поля (document-item) должно быть строкой, контентом, словарем или label",
  )
  let document-label
  if type(document-item) == str {
    document-label = document-item
  } else if type(document-item) == label {
    document-label = query(document-item).first().value
  }

  if headings.len() > 0 and headings.last().numbering != none {
    document-base.update(s => {
      s.at(document-label).at("headings").push(headings.last())
      return s
    })
  }
  let header-parent = headings.last()


  // Update individual document options
  if repr-func != none {
    document-base.update(s => {
      s.at(document-label).at("repr-func") = repr-func
      return s
    })
  }

  if flags != none {
    let flag-array
    if type(flags) != array { flag-array = (flags,) }
    document-base.update(s => {
      s.at(document-label).at("flags") = bits-opt(..flag-array)
      return s
    })
  }

  let doc-bib-number = document-referenced-in-bibliography.final().position(it => it == document-label)

  document-mentions.update(s => {
    let headers-mentioned = s.at(document-label, default: ())
    assert(
      type(headers-mentioned) == array,
      message: "Ссылки должны быть в виде массива локаций",
    )
    if header-parent not in headers-mentioned {
      headers-mentioned.push(header-parent)
    }
    s.insert(document-label, headers-mentioned)
    return s
  })

  let backlink-item = document-backlinks.final().at(document-label, default: none)

  let document-inline-value

  let v = document-base.final().at(document-label, default: none)
  if v != none { document-inline-value = v.name }

  if doc-bib-number != none {
    document-inline-value = "[" + str(doc-bib-number + 1) + "]"
  }

  if backlink-item != none {
    link(backlink-item, [ #document-inline-value])
  } else {
    [#document-inline-value]
  }
}


// Позволяет получить массив данных для отображения в финальной таблице ссылок
#let document-get-as-array(document-types, sort-by-type: true) = {
  let mentions = document-mentions.final()
  assert(
    mentions.len() > 0,
    message: "Таблица не может быть сформирована, так в тексте отсутствуют ссылки на документы",
  )

  assert(type(document-types) == array)

  assert(
    document-types.all(it => { not document-referenced-types.get().contains(it) }),
    message: "Не допускается создавать ссылки на один тип документа больше одного раза",
  )

  let label-array = mentions.keys()
  let sort-array = mentions.keys().map(document-get-sort-key)
  let item-array = label-array.map(it => document-base.final().at(it))
  let header-array = mentions.values()

  for (i, item) in header-array.enumerate() {
    header-array.at(i) = item
      .dedup()
      .map(it => {
        let value = [#numbering(it.numbering, ..counter(heading).at(it.location()))]
        if not is-empty(it.supplement) { value = [#it.supplement] + [~] + value }
        link(
          it.location(),
          value,
        )
      })
      .join([, ])
  }

  let table-data = label-array.zip(header-array, sort-array, item-array)
  table-data = table-data.filter(it => { it.at(3).at("type") in document-types })
  if sort-by-type { table-data = table-data.sorted(key: it => it.at(2)) }
  return table-data
}


#let document-display-table(documents: "legislation", header: header-legislation, ..table-args) = context {
  show table.cell: it => {
    set text(hyphenate: false)
    if it.x == 1 {
      set par(justify: false)
      it
    } else {
      it
    }
  }
  let document-types
  if type(documents) in (str, content) {
    document-types = (documents,)
  } else { document-types = documents }

  let table-data = document-get-as-array(document-types)

  document-referenced-types.update(s => {
    for v in document-types {
      s.push(v)
    }
    return s
  })

  table(
    columns: (13.0cm, 1fr),
    inset: (top: 2mm, bottom: 2mm, rest: 1.5mm),
    align: (x, y) => {
      if y == 0 { center + horizon } else if y > 0 and x == 0 { left + top } else { center + horizon }
    },
    table.header(..header),
    ..table-args,
    ..for (lbl, link, sort, item) in table-data {
      (
        [#document-default-repr(item)],
        [#link],
      )
    }
  )
}


#let document-display-list(..list-args) = context {
  let docs-mentions = document-mentions.final().keys()
  let docs-base = document-base.final()

  let types-referenced = document-referenced-types.final()
  docs-mentions = docs-mentions.filter(it => { docs-base.at(it).at("type") not in (types-referenced) })
  document-referenced-in-bibliography.update(docs-mentions)
  set text(hyphenate: false)
  set enum(numbering: "1)", full: true)
  for doc in docs-mentions {
    enum.item(document-default-repr(docs-base.at(doc)) + [.])
  }
}

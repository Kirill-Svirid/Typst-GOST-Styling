#import "@preview/t4t:0.4.3"
#import "@local/oxifmt:1.0.0"
#import "utils.typ": is-empty

#let flg-half-date = 1.bit-rshift(1)

// #let document-type-list = ("legislation", "reference", "test")

/* Все загруженные документы в виде ключ-ключ для упрощения обращения к документам по тексту*/
#let document-labels = state("document-labels", (:))
// Все загруженные документы
#let document-base = state("document-base", (:))
// Все документы, на которые даны ссылки по тексту документа
#let document-mentions = state("document-mentions", (:))
// Ссылки(label), на которые документ может обращаться документ
#let document-backlinks = state("document-backlinks", (:))
// Типы документов, на которые уже приведены библиографии, ссылки. Второй раз привести эти типы нельзя
#let document-referenced-types = state("document-referenced-types", ())


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
  // title = "text string"
  let document-label = label("_link_" + lbl)
  (
    if organization != none [#organization. ]
      + [#name.replace(" ", sym.space.punct)]
      + [\-#date ]
      + [#title]
      + [#metadata(lbl)#document-label]
      + [.]
  )

  document-backlinks.update(s => {
    assert(
      label not in s.keys(),
      message: "Функция не может быть вызвана дважды для одного документа",
    )
    s.insert(lbl, document-label)
    return s
  })
}

#let document-read-definition(lbl, entity, repr-func: none, flags: none) = {
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

  // При парсинге к строковым значениями может быть добавлен NewLine. Это мешает при формировании элементов списков
  for (k, v) in doc.pairs() {
    if type(v) == str { doc.at(k) = v.replace(regex("^[\r\n]+|\.|[\r\n]+$"), "") }
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

  doc.insert("date", entity.at("date", default: none))

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
  if item == none { panic("Документ не обнаружен:" + document-name) }
  let type = item.at("type")
  let name = item.at("name")
  let prefix = document-sort-prefix(name)
  return prefix + name
}


// Предназначена для объявления документа по тексту
#let document-ref(document-item, repr-func: none, flags: none) = context {
  let headings = query(heading.where(level: 2).or(heading.where(level: 1)).before(here()))
  headings = headings.filter(it => it.numbering != none)

  assert(
    headings.len() > 0,
    message: "Ссылка на документ не может быть использована без нумерованных заголовков уровня 1 или 2",
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
  // assert(type(document-label) == str, message: repr(type(document-label)))

  if headings.len() > 0 and headings.last().numbering != none {
    document-base.update(s => {
      s.at(document-label).at("headings").push(headings.last())
      return s
    })
  }

  if repr-func != none {
    document-base.update(s => {
      s.at(document-label).at("repr-func") = repr-func
      return s
    })
  }

  if flags != none {
    document-base.update(s => {
      s.at(document-label).at("flags") = flags
      return s
    })
  }

  let header-parent = headings.last()

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

  if type(document-types) in (str, content) {
    document-types = (document-types,)
  }

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


#let document-display-table(document-type: "legislation", header: header-legislation, ..table-args) = context {
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
  if type(document-type) in (str, content) {
    document-types = (document-type,)
  }
  let table-data = document-get-as-array(document-types)

  document-referenced-types.update(s => {
    for v in document-types {
      s.push(v)
    }
    return s
  })

  table(
    columns: (13.0cm, 1fr),
    inset: (top: 2mm, bottom: 2mm, rest: 0.8mm),
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

#let to-string(content) = {
  if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let document-display-list(..list-args) = context {
  let docs-mentions = document-mentions.final().keys()
  let docs-base = document-base.final()

  let types-referenced = document-referenced-types.final()
  docs-mentions = docs-mentions.filter(it => { docs-base.at(it).at("type") not in (types-referenced) })
  // set enum(numbering: "1)")
  let item = [Content]
  for doc in docs-mentions {
    enum.item(document-default-repr(docs-base.at(doc)) + [.])
  }
  // to-string(document-default-repr-c(docs-base.at(docs-mentions.first())))
  // let c = document-default-repr-c(docs-base.at(docs-mentions.first())).children
  // c.push([.])
  // text(c)
  // repr(c)
}

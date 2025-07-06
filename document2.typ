#import "src/tools/pageframe.typ": *
#import "src/style.typ": *
#import "src/tools/outlines.typ": outline-break-by-enum
#import "src/tools/enums.typ": *
#import "src/tools/annexes.typ" as an
#import "src/tools/referencing.typ": *

#show: style-ver-1.with()
#show: enable-referenceable-enums.with()
#show outline.entry: outline-break-by-enum.with(0)

#set page(background: page-frame-title(), margin: (top: 5cm))

#pagebreak()

#set page(background: page-frame-sequence(), margin: (top: 2cm, right: 1.5cm))

#document-append-defs("/bibliography/references dev.yml", "/bibliography/references nor.yml")

#set text(lang: "ru")

#outline()

= Введение


#show: enum-set-heading-numbering

= Feature

Простой текст со ссылкой на документ #document-ref(<ГОСТ_Р_ИСО_9001>), #document-ref("СТО_95_12076") и #document-ref(<СТО_95_12077>)


== Требования к обеспечению безопасности при выполнении работ

+ На всех этапах работ должно быть #document-ref("ГОСТ_Р_8_563") обеспечено соблюдение норм и правил, регламентирующих безопасность в области использования атомной энергии с учётом конструктивных и физических особенностей РУ и АЭС. Документ #document-ref("test_pz_0001")

+ Эксперименты на стендах должны проводиться в соответствии с правилами ядерной и технической безопасности #document-ref("ГОСТ_Р_8_563")

== Требования по обеспечению государственной тайны при выполнении НИР и ОКР

#set enum(numbering: wrapped-enum-numbering("1.a"), full: true)

+ #enum-label[reaf] Разработка ТВС должна выполняться #document-ref(<ГОСТ_Р_15_011>, flags: flg-half-date) с учётом обеспечения технологичности конструкций составных частей, обеспеченности сырьём и исходными материалами, а также с максимально возможным уровнем унификации.

+ Изготовление и сборка элементов а.з. должна проводиться в соответствии с #document-ref("СТО_95_12076"),#document-ref("ГОСТ_Р_8_563"), #document-ref("ГОСТ_Р_15_011")

#show: enum-drop-heading-numbering

= Feature

#show: enum-set-heading-numbering
+ Технология изготовления, правила и методы приёмки и контроля ТВС должны обеспечивать:

// #show:enum-drop-heading-numbering

#set enum(numbering: "a.1")
+ сохранение герметичности в течение назначенного срока службы и назначенного срока хранения твэлов в составе ТВС.

#show: enum-set-heading-numbering
+ Порядок контроля должен быть определён на этапе разработки ТП.

+ На готовом изделии должны контролироваться параметры, указанные в 4.6.8.

+ Требования к составным частям и комплектующим деталям, к их приёмке и входному контролю устанавливает разработчик ТВС.

+ Оценка соответствия должна осуществляться в форме испытаний, контроля и приёмки согласно требованиям НП-071. Результаты оценки соответствия в форме приёмки должны оформляться заключением о приёмке в порядке, установленном ГОСТ Р 50.06.01.

Дополнение #document-ref("test_pz_0001")

= Feature

This is a simple template for testing. #document-ref("СТК-5")

#lorem(25) #document-ref("test_tz_0000")

#let doc = context document-base.final().at("ГОСТ_Р_8_563")


= Заключение
#figure(image("/assets/abstract.jpg", width: 60%), caption: "Изображение")


#show: an.annexes-enable

= Схема 1

#lorem(50)

+ Тест ссылок на документы в разделе приложения #document-ref("СТО_95_12076"),#document-ref("ГОСТ_Р_8_563"), #document-ref("ГОСТ_Р_15_011")

Текст


#figure(image("/assets/abstract.jpg"), caption: "Изображение")

= (справочное) \ Схема 2 \ #lorem(50)


#figure(image("/assets/abstract.jpg", width: 60%), caption: "Изображение")<p>

Ссылка на рис.#ref(<p>)


#figure(
  table(
    columns: (3cm, 4cm, 1fr),
    [], [], [text],
    [], [], [text],
  ),
  caption: "Изображение",
)


#show: an.annexes-disable

= Ссылочные нормативные документы
#document-display-table(documents: ("legislation",), header: header-legislation)

= Ссылочные документы
#document-display-table(documents: ("ПЗ", "ТЗ"), header: header-reference)

#show: enum-drop-heading-numbering

= Библиография

#document-display-list()


// #context document-base.final()

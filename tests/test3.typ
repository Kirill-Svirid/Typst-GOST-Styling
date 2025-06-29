#let arr2 = range(0, 100, step: 5)
#let arr1 = range(0, -10, step: -1)
#let arr4 = range(0, -20, step: -2)

#let keysort(a, b) = {
  return calc.pow(a, 3) + b
}

#let keysort2(..args) = {
  let arg-arr = args.pos()
  arg-arr.remove(0)
  // return calc.pow(args.pos().at(0), 2)  // + calc.min(args.pos())
  return arg-arr.sum()
}

#let arr3 = arr2.zip(arr1, arr4)
#arr3

// #arr3.map((a) => keysort(a.at(0), a.at(1)))

// #arr3.map((a) => keysort(..a))


// #range(1, 20).fold(0, (a, b) => a + b)
#arr3.sorted(key: key => keysort2(..key))

#let f(a) = { return a * a }


// #let s = "\"АО \"рога\"\""
#let s = "'АО \"рога''"


#s

#s.matches(regex("^?(?:[\s]?)([\"])[^\s\"]"))

#s.matches(regex("^?[^\s\"]([\"])(?:[\s]?)"))


#pagebreak()

#s.matches(regex("[\S]([\"])[\s$]?"))

#let string-convert-dumb-quotes(s) = {
  let m = s.matches(regex("^?(?:[\s]?)([\"\'])[^\s\"\']"))
  for v in m {
    s = s.replace(v.text, v.text.replace(v.captures.first(), "«"))
  }
  s = s.replace(regex("[\"\']"), "»")

  return s
}

sgdfg


#string-convert-dumb-quotes(s)


#let s1 = s.replace(
  regex("[^\s]?([\"])[\S]"),
  m => {
    let g = m.captures.first()
    return m.text.replace(g, "«")
  },
)

#s1

#let s1 = s.replace(
  regex("[^\s]?([\"])[\S]"),
  m => {
    let g = m.captures.first()
    return m.text.replace(g, "«")
  },
)



// #let s2=s1.replace(
//   regex("[\S]([\"])[$\s]?"),
//   m => {
//     let g=m.captures.first()
//     return m.text.replace(g,"»")
//   },
// )



// #s2


#let f=1.bit-lshift(3)

#f

#if f.bit-and(8)==8 {}
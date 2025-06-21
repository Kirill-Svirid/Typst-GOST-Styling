#let arr2 = range(0, 100,step:5)
#let arr1 = range(0, -10, step: -1)
#let arr4 = range(0, -20, step: -2)

#let keysort(a, b) = {
  return calc.pow(a, 3) + b
}

#let keysort2(..args) = {
  let arg-arr=args.pos()
  arg-arr.remove(0)
  // return calc.pow(args.pos().at(0), 2)  // + calc.min(args.pos())
  return  arg-arr.sum()

}

#let arr3 = arr2.zip(arr1, arr4)
#arr3

// #arr3.map((a) => keysort(a.at(0), a.at(1)))

// #arr3.map((a) => keysort(..a))


// #range(1, 20).fold(0, (a, b) => a + b)
#arr3.sorted(key:key=>keysort2(..key))

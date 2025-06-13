#let get-numbering-alphabet-ru(number) = {
  let alphabet = (
    "а",
    "б",
    "в",
    "г",
    "д",
    "е",
    "ж",
    "з",
    "и",
    "к",
    "л",
    "м",
    "н",
    "о",
    "п",
    "р",
    "с",
    "т",
    "у",
    "ф",
    "х",
    "ц",
    "ч",
    "ш",
    "щ",
    "э",
    "ю",
    "я",
  )

  let result = ""
  while number > 0 {
    result = alphabet.at(calc.rem(number - 1, 28)) + result
    number = calc.floor(number / 28)
  }
  return result
}


#let heading-numbering-ru(..nums) = {
  nums = nums.pos()
  let letter = upper(get-numbering-alphabet-ru(nums.first()))
  let rest = nums.slice(1).map(elem => str(elem))
  if rest != none {
    return (letter, rest).flatten().join(".")
  }
  return letter
}


#let enum-numbering(number) = { return [#get-numbering-alphabet-ru(number))] }

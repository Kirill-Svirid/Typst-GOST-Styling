// Implementation of bitwise flags operations

#let bit-opt(bit) = {
  return 1.bit-lshift(bit)
}


#let bit-set(num, bit) = {
  return num.bit-or(bit-opt(bit))
}

#let bits-opt(..bits) = {
  let v = 0
  for bit in bits.pos() {
    v = bit-set(v, bit)
  }
  return v
}

#let bit-toggle(num, bit) = {
  return num.bit-xor(bit-opt(bit))
}


#let bit-clear(num, bit) = {
  return num.bit-and(bit-opt(bit).bit-not())
}


#let bit-check(num, bit) = {
  return num.bit-rshift(bit).bit-and(1) == 1
}

// TODO: For implementation
#let bits-check(num, ..bits) = {
  assert(
    bits.at("all", default: none) != bits.at("any", default: none),
    message: "Only one option (all or any) is available",
  )

  if type(bits.at("all", default: none)) in (array,) {
    let opts
    return bits.at("all")
  } else if type(bits.at("any", default: none)) in (array,) {
    return
  }
}

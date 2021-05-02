let maybeRender = elemM => switch elemM {
  | None => React.null
  | Some(elem) => elem
}

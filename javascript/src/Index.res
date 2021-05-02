%raw("require('@patternfly/react-core/dist/styles/base.css')")
switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<React.StrictMode> <App.Main /> </React.StrictMode>, root)
| None => ()
}

let client = WebApi.newServiceClient("http://localhost:8080")

Js.log(client)

@react.component
let make = () => {
  let (username, setUsername) = React.useState(_ => "")
  React.useEffect0(() => {
    WebApi.register(client, WebApi.newRegisterRequest("TristanCacqueray"))->ignore
    None
  })
  <p> {"Hello!"->React.string} </p>
}

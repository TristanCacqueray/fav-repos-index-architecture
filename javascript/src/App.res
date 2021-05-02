module FriTypes = MessagesTypes
module FriBs = MessagesBs

module Repo = {
  @react.component
  let make = (~repo: FriTypes.repo) => <div> {repo.name->React.string} </div>
}

module Message = {
  @react.component
  let make = (~message: string) => {
    <div> {message->React.string} </div>
  }
}

module SearchBar = {
  @react.component
  let make = (~value, ~onChange, ~onSearch) => {
    // Debounch update
    React.useEffect1(() => {
      let handler = Js.Global.setTimeout(() => onSearch(value), 500)
      Some(() => Js.Global.clearTimeout(handler))
    }, [value])

    <Patternfly.TextInput id="fri-search" value _type=#Text iconVariant=#Search onChange />
  }
}

module RegisterBar = {
  @react.component
  let make = (~value, ~onChange, ~onRegister, ~onCancel) =>
    <Patternfly.Layout.Bullseye>
      <Patternfly.Form isHorizontal=true>
        <Patternfly.FormGroup
          label="Name"
          fieldId="horizontal-form-name"
          helperText="Please provide your GitHub username"
          isRequired=true>
          <Patternfly.TextInput value _type=#Text id="horizontal-form-name" onChange />
        </Patternfly.FormGroup>
        <Patternfly.ActionGroup>
          <Patternfly.Button onClick={_ => onRegister(value)} variant=#Primary>
            {"Submit form"->React.string}
          </Patternfly.Button>
          <Patternfly.Button onClick={_ => onCancel()} variant=#Link>
            {"Cancel"->React.string}
          </Patternfly.Button>
        </Patternfly.ActionGroup>
      </Patternfly.Form>
    </Patternfly.Layout.Bullseye>
}

module Main = {
  let client = WebApi.newServiceClient("http://localhost:8080")

  type visitor_status = Anon | Registering | Registered(string)

  @react.component
  let make = () => {
    let (reposCount, setReposCount) = React.useState(_ => 0)
    let (message, setMessage) = React.useState(_ => None)
    let repos = React.useRef([])

    let (searchText, setSearchText) = React.useState(_ => "")
    let (userName, setUserName) = React.useState(_ => "")

    let (visitorStatus, setVisitorStatus) = React.useState(_ => Anon)
    let registerButton = switch visitorStatus {
    | Anon => "Register"
    | Registering => "Cancel"
    | Registered(_) => "Logout"
    }
    let nextVisitorStatus = current =>
      switch current {
      | Anon => Registering
      | Registering => Anon
      | Registered(_) => Anon
      }

    let onCancel = () => {
      setVisitorStatus(_ => Anon)
    }

    let onRegisterData = resp =>
      switch resp {
      | FriTypes.Msg(msg) => {
          setVisitorStatus(_ => Registered(userName))
          setMessage(_ => Some(msg))
        }
      | FriTypes.Repo(repo) => {
          let count = repos.current->Js.Array2.push(<Repo repo />)
          setReposCount(_ => count)
        }
      }

    let onSearchData = (resp: FriTypes.search_response) => {
      switch resp.repo {
      | Some(repo) => {
          let count = repos.current->Js.Array2.push(<Repo repo />)
          setReposCount(_ => count)
        }
      }
    }

    let onRegister = v =>
      switch v->Js.String.length > 2 {
      | true => {
          Js.log3("registering!", v, WebApi.registerRequest(v))
          WebApi.register(client, WebApi.registerRequest(v), onRegisterData)->ignore
        }
      | false => ignore()
      }

    let onSearch = v => {
      switch v->Js.String.length > 2 {
      | true => {
          Js.log3("searching!", v, WebApi.searchRequest(v))
          Js.Array.removeCountInPlace(~pos=0, ~count=reposCount, repos.current)->ignore
          WebApi.search(client, WebApi.searchRequest(v), onSearchData)->ignore
        }
      | false => ignore()
      }
    }

    // Uncomment to trigger a default search
    React.useEffect0(_ => {
      setSearchText(_ => "haskell")
      onSearch("haskell")
      None
    })

    let header =
      <Patternfly.PageHeader
        logo="Fav Repo Index"
        headerTools={<Patternfly.PageHeaderTools>
          <Patternfly.Button
            variant=#Secondary onClick={_ => setVisitorStatus(v => v->nextVisitorStatus)}>
            {registerButton->React.string}
          </Patternfly.Button>
        </Patternfly.PageHeaderTools>}
      />
    <Patternfly.Page header>
      <Patternfly.PageSection>
        {switch visitorStatus {
        | Anon | Registered(_) =>
          <SearchBar value={searchText} onChange={(v, _) => setSearchText(_ => v)} onSearch />
        | Registering =>
          <RegisterBar
            value={userName} onChange={(v, _) => setUserName(_ => v)} onRegister onCancel
          />
        }}
      </Patternfly.PageSection>
      {switch message {
      | None => React.null
      | Some(message) => <Message message />
      }}
      <Patternfly.PageSection>
        <ul>
          {repos.current
          ->Belt.Array.mapWithIndex((i, repo) => <li key={string_of_int(i)}> {repo} </li>)
          ->React.array}
        </ul>
      </Patternfly.PageSection>
    </Patternfly.Page>
  }
}

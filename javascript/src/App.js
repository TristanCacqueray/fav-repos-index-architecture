import React, { useState, useEffect } from 'react'

import { RegisterRequest } from "./fri_pb.js"
import { ServiceClient } from "./fri_grpc_web_pb.js"

const client = new ServiceClient('http://localhost:8080')

export const App = () => {
    const [username, setUsername] = useState("")
    const register = () => {
        console.log("Registering...")
        var registerRequest = new RegisterRequest("guest-user")
        var stream = client.register(registerRequest,{})

        stream.on('data', response => {
            console.log("onData:", response)
        })
        stream.on('status', status => {
            console.log("onStatus:", status)
        })
    }
    useEffect(() => register())
    return <p>"Hello!"</p>
}

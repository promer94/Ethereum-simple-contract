import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import App from './App'
import configureStore from './configStore'

const initialState = {
  paper: { paperAddresses: [], isPending: false, paperList: [] },
  user: { address: [] }
}
const store = configureStore(initialState) //eslint-disable-line
ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)

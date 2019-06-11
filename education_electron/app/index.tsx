import * as React from "react";
import * as ReactDOM from "react-dom";
import 'antd/dist/antd.css';
import dotenv from 'dotenv';

import "./app.global.css";
import App from "./routes/App";
import ErrorBoundary from './components/ErrorBoundary'
import RoomControlStore from "./store/RoomControl";

dotenv.config()

ReactDOM.render(
  <RoomControlStore.Provider>
    <ErrorBoundary>
      <App />
    </ErrorBoundary>
  </RoomControlStore.Provider>,
  document.getElementById("root")
);

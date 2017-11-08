import { TrialSearchPage } from '../components/TrialSearch/TrialSearchPage';
import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { Route, Switch, Link } from 'react-router-dom'

import { createApplicationStore, RootState, bindActionCreators, RootDispatch } from '../store';
import { Provider } from 'react-redux';

const connectedStore = createApplicationStore('CancerMatch');

const rootEl = document.getElementById("react-root");
ReactDOM.render(
      <Provider store={connectedStore.store}>
        <TrialSearchPage />
      </Provider>
  , rootEl
)
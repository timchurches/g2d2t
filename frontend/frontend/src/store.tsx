import { createStore, combineReducers, applyMiddleware, compose } from 'redux';
import { bindActionCreators as reduxBindActionCreators } from 'redux';
import { Dispatch } from 'redux';

import createHistory from 'history/createBrowserHistory'
import { routerReducer, routerMiddleware } from 'react-router-redux'
export { returnType }

import { Action, ActionType, ActionCreator, ActionCreatorMap, ActionTypeMap, ActionHandler, TypedActionHandler, returnType } from './utils/redux';
// import ReduxThunk from 'redux-thunk'
import thunk from 'redux-thunk';

export interface RootState {
    search: SearchState,
};

import { searchReducer, SearchState } from './reducers/searchReducer';

declare namespace window {
  let __REDUX_DEVTOOLS_EXTENSION__: any;
  let __REDUX_DEVTOOLS_EXTENSION_COMPOSE__: any;
}

export function createApplicationStore(storeName: string, initialState?: any) {

  const reducers = 
    combineReducers<RootState>({
      search: searchReducer,
    });

  const devtoolsMiddleware = (typeof window.__REDUX_DEVTOOLS_EXTENSION__ !== 'undefined') ? window.__REDUX_DEVTOOLS_EXTENSION__() : (f:any) => f;

  const composeEnhancers = (storeName:string) =>
    // process.env.NODE_ENV !== 'production' &&
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ ?   
      window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__({
        name: storeName, actionsBlacklist: []
      }) : compose;

  const enhancers = (storeName:string) =>
    composeEnhancers(storeName)(applyMiddleware(thunk));

  const store = createStore<RootState>(
    reducers,
    (initialState || {}) as RootState, // initial state in reducers
    // applyMiddleware(thunk),
    enhancers(storeName)
  );

  return { history, store };
}

export interface RootDispatch extends Dispatch<RootState> {
  (action: Action<any>): RootState;
}
export interface SelectorWithoutProps<TResults> {
  (state: RootState): TResults;
}
export function bindActionCreators<T extends ActionCreatorMap>(actionCreators: T, dispatch: RootDispatch): T {
  return reduxBindActionCreators(actionCreators, dispatch);
}
export function createStateSelector<TResults>(selector: SelectorWithoutProps<TResults>): SelectorWithoutProps<TResults> {
  return selector;
}

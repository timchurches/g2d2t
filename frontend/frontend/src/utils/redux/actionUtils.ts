import { bindActionCreators as reduxBindActionCreators } from 'redux';
import { Action, ActionType, ActionCreator, ActionCreatorMap, ActionTypeMap, ActionHandler, TypedActionHandler } from './reduxTypes';

// export function createActionCreator<TPayload>(actionType: ActionType<TPayload>): ActionCreator<TPayload>;
export function createActionCreator<TPayload>(actionType: ActionType<TPayload>): ActionCreator<TPayload> {
  const type = actionType.toString();
  return Object.assign((payload: TPayload): Action<TPayload> => ({ type, payload }), { type });
}

export function actionType<TPayload>() {
  return {} as ActionType<TPayload>;
}

export function createActionConstantsMap<T extends ActionTypeMap>(prefix: string, input: T): T {
  prefix = prefix.toUpperCase() + '_';

  const map = Object.keys(input).reduce((acc, key) => {
    const namespacedActionType = prefix + key;
    return Object.assign(acc, { [key]: namespacedActionType });
  }, {}) as T;
  return map;
}

export function createActionHandler<TState>() {
  return <TPayload>(actionType: ActionType<TPayload>, handler: ActionHandler<TState, TPayload>): TypedActionHandler<TState, TPayload> => {
    return Object.assign(handler, { actionType: actionType.toString() });
  };
}
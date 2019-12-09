import React from 'react';
import {useRootContext} from '../store';
import { ActionType, LoginInfo } from '../reducers/types';

export interface IGlobal {
  showDialog: (val: {type: string, desc: string}) => void
  removeDialog: () => void
  addMe: (login: LoginInfo) => void
}

const GlobalContext: React.Context<IGlobal> = React.createContext({} as IGlobal);

export const useGlobalContext = () => React.useContext(GlobalContext);

export const GlobalContainer: React.FC<any> = ({children}: React.ComponentProps<any>) => {

  const {dispatch} = useRootContext();

  const showDialog = (val: { type: string, desc: string }) =>
    dispatch({
      type: ActionType.ADD_DIALOG, dialog: {
        visible: true,
        ...val
      }
    });

  const removeDialog = () => dispatch({ type: ActionType.REMOVE_DIALOG })
  const addMe = (login: LoginInfo) => dispatch({ type: ActionType.ADD_ME, payload: login });

  const methods = {
    showDialog,
    removeDialog,
    addMe,
  }

  return (
    <GlobalContext.Provider value={methods}>
      {children}
    </GlobalContext.Provider>
  )
}
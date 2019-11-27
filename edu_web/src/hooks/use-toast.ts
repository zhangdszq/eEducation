import {useRootContext} from '../store';
import { ActionType } from '../reducers/types';
import { ToastProps } from '../reducers/initialize-state';

export default function useToast() {
  const {dispatch} = useRootContext();

  return {
    showError: (errMessage: string) => dispatch({type: ActionType.ADD_TOAST, toast: {
      message: errMessage,
      type: 'error'
    }}),
    showToast: (toast: ToastProps) => dispatch({type: ActionType.ADD_TOAST, toast})
  }
}
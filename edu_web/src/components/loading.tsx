import React, { useMemo } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import CircularProgress from '@material-ui/core/CircularProgress';
import { useRootContext } from '../store';

const useStyles = makeStyles(theme => ({
  progress: {
    margin: theme.spacing(2),
    color: '#44A2FC'
  },
  container: {
    position: 'absolute',
    top: '0px',
    left: '0px',
    height: '100%',
    width: '100%',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    background: '#ffffff',
    opacity: 0.8,
    zIndex: 10
  }
}));

export const Loading: React.FC<{}> = () => {
  const classes = useStyles();
  return (
    <div className={classes.container}>
      <CircularProgress className={classes.progress} />
    </div>
  );
}

export default function LoadContainer () {

  const {store} = useRootContext();

  const loading = useMemo(() => store.global.loading, [store.global.loading]);

  return (
    loading ? <Loading /> : null
  )
}
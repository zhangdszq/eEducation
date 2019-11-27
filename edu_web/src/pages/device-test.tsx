import React from 'react';
import {useHistory} from 'react-router-dom';
import SettingCard from '../components/setting-card';
import { isElectron } from '../utils/platform';

export default function () {
  const history = useHistory();

  const handleClick = (evt: any) => {
    history.goBack();
  }

  return (
    <div className={`flex-container ${isElectron ? null : 'home-cover-web'}`}>
      <SettingCard handleFinish={handleClick} />
    </div>
  )
}
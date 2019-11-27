import React from 'react';
import { Theme, FormControl } from '@material-ui/core';
import {makeStyles} from '@material-ui/core/styles';
import Button from '../components/custom-button';
import RoleRadio from '../components/role-radio';
import Icon from '../components/icon';
import FormInput from '../components/form-input';
import FormSelect from '../components/form-select';
import { isElectron } from '../utils/platform';
import {roomTypes} from '../hooks/use-room-control';
import useHomePage from '../hooks/use-homepage';

const useStyles = makeStyles ((theme: Theme) => ({
  formControl: {
    minWidth: '240px',
    maxWidth: '240px',
  }
}));

export default function HomePage() {
  const classes = useStyles();
  const {
    handleClose,
    required,
    handleClick,
    role,
    setRoomName,
    setRole,
    roomName,
    setRoomType,
    roomType,
    yourName,
    setYourName,
  } = useHomePage();

  return (
    <div className={`flex-container ${isElectron ? null : 'home-cover-web' }`}>
      {isElectron ? null : 
      <div className="web-menu">
        <div className="web-menu-container">
          <div className="short-title">
            <span className="title">Agora Education</span>
            <span className="subtitle">Powered by agora.io</span>
          </div>
          <Icon className="icon-setting" onClick={handleClose}/>
        </div>
      </div>
      }
      <div className="custom-card">
        <div className="flex-item cover">
          {isElectron ? 
          <>
          <div className="short-title">
            <span className="title">Agora Education</span>
            <span className="subtitle">Powered by agora.io</span>
          </div>
          <div className="cover-placeholder"></div>
          </>
          : <div className="cover-placeholder-web"></div>
          }
        </div>
        <div className="flex-item card">
          <div className="position-top card-menu">
          {isElectron ? 
            <>
              <Icon className="icon-setting" onClick={handleClose}/>
              <div className="icon-container">
                <Icon className="icon-minimum" icon />
                <Icon className="icon-close" icon/>
              </div>
            </> : null}
          </div>
          <div className="position-content flex-direction-column">
            <FormControl className={classes.formControl}>
              <FormInput Label={"Room Name"} value={roomName} onChange={(val: string) => {
                  setRoomName(val);
                }}
                requiredText={required.roomName}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormInput Label={"Your Name"} value={yourName} onChange={(val: string) => {
                  setYourName(val);
                }}
                requiredText={required.yourName}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={"Room Type"}
                value={roomType}
                onChange={(evt: any) => {
                  setRoomType(evt.target.value)
                }}
                menus={roomTypes}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <RoleRadio value={role} onChange={(evt: any) => {
                 setRole(evt.target.value);
              }} requiredText={required.role}></RoleRadio>
            </FormControl>
            <Button name={"Join"} onClick={handleClick}/>
          </div>
        </div>
      </div>
    </div>
  )
}
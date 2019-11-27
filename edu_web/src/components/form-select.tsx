import React from 'react';
import {makeStyles} from '@material-ui/core/styles';
import { Select, FormControl, InputLabel, MenuItem } from '@material-ui/core';

export default function (props: any) {
  return (
    <>
      <InputLabel>{props.Label}</InputLabel>
      <Select
        value={props.value}
        onChange={props.onChange}
      >
        {props.menus.map((item: any, key: number) => 
          <MenuItem key={key} value={key}>{item.text}</MenuItem>
        )}
      </Select>
    </>
  );
}
import React from 'react';
import {makeStyles} from '@material-ui/core/styles';
import { Select, FormControl, InputLabel, MenuItem } from '@material-ui/core';

export interface FormSelectItems {
  text: string
}

export interface FormSelect {
  items: FormSelectItems[]
  Label: string
  value: any
  onChange: (evt: any) => any,
}

const FormSelect: React.FC<FormSelect> = ({
  Label,
  value,
  onChange,
  items
}) => {
  return (
    <>
      <InputLabel>{Label}</InputLabel>
      <Select
        value={value}
        onChange={onChange}
      >
        {items.map((item: any, key: number) => 
          <MenuItem key={key} value={key}>{item.text}</MenuItem>
        )}
      </Select>
    </>
  );
}

export default React.memo(FormSelect);
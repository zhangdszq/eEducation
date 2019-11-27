import React, {useState} from 'react';
import Button from '../custom-button';
import Dialog from '@material-ui/core/Dialog';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';

import './dialog.scss';

interface RoomProps {
  visible: boolean
  onConfirm: (type: string) => void
  onClose: (type: string) => void
  desc: string
  type: string
}

export default function RoomDialog(
{
  visible = false,
  onConfirm,
  onClose,
  desc,
  type
}: RoomProps) {

  const [open, setOpen] = useState<boolean>(visible);

  const handleClose = () => {
    onClose(type)
  };

  const handleConfirm = () => {
    onConfirm(type)
  }

  return (
    <div>
      <Dialog
        disableBackdropClick
        open={true}
        onClose={handleClose}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
      >
        <DialogContent
          className="modal-container"
        >
          <DialogContentText className="dialog-title">
            {desc}
          </DialogContentText>
          <div className="button-group">
            <Button name="Confirm" className="confirm" onClick={handleConfirm} color="primary" />
            <Button name="Cancel" className="cancel" onClick={handleClose} color="primary" />
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

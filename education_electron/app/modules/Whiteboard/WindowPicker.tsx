import React, { FunctionComponent, useState, useMemo, CSSProperties } from 'react';
import { Col, Row } from 'antd';
import './WindowPicker.scss';

export interface WindowItemProps {
  windowId: number,
  name: string,
  ownerName: string,
  active: boolean,
  image: string
}

export const WindowItem: FunctionComponent<WindowItemProps> = props => {
  const {name = 'No Title', active} = props
  const actualName = name.length > 15 ? `${name.substring(0, 15)}...` : name;
  const className = active ? 'screen-item active' : 'screen-item';

  return (
    <div className={className}>
      <div className="screen-image">
        <div className="content" style={{backgroundImage: `url(data:image/png;base64,${props.image})`}}>
        </div>
      </div>
      <div className="screen-meta">{actualName}</div>
    </div>
  )
}

export interface WindowPickerProps {
  windowList: Array<WindowItemProps>,
  onCancel: () => void,
  onSubmit: (windowId: number) => void,
  style?: CSSProperties
}

const WindowPicker: FunctionComponent<WindowPickerProps> = props => {
  const [currentWindowId, setCurrentWindowId] = useState(-1)

  const handleSubmit = () => {
    props.onSubmit && props.onSubmit(currentWindowId);
  }

  const handleCancel = () => {
    props.onCancel && props.onCancel();
  }

  const WindowList = useMemo(() => {
    return props.windowList.map((item, index) => {
      return (
        <Row key={index} style={{marginBottom:'10px'}}>
          <Col
            style={{
              width: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}
            key={item.windowId}
            onClick={() => {setCurrentWindowId(item.windowId);}}
            span={8}>
            <WindowItem windowId={item.windowId} ownerName={item.ownerName} active={item.windowId === currentWindowId} name={item.name} image={item.image} />
          </Col>
        </Row>
      )
    })
  }, [props.windowList, currentWindowId]);

  return (
    <div className='window-picker' style={props.style || {}}>
      <div className='header'>
        <div className="title">Pick the window</div>
        <div className="cancelBtn" onClick={handleCancel}></div>
      </div>
      <div className='screen-container'>
        {WindowList}
      </div>
      <div className='footer'>
        <div className="confirmBtn" onClick={handleSubmit}>
          Start
        </div>
      </div>
    </div>
  )
}

export default WindowPicker;
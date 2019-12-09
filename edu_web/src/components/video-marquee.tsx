import React, { useRef, useEffect } from 'react';
import VideoPlayer from './video-player';
import './video-marquee.scss';
import useStream from '../hooks/use-streams';
import { AgoraMediaStream } from '../reducers/types';

export default function VideoMarquee() {

  const {teacher, students, onPlayerClick} = useStream();

  const marqueeEl = useRef(null);

  const scrollLeft = (current: any, offset: number) => {
    current.scrollLeft += (offset * current.childNodes[1].offsetWidth);
  }

  const handleScrollLeft = (evt: any) => {
    scrollLeft(marqueeEl.current, 1);
  }

  const handleScrollRight = (evt: any) => {
    scrollLeft(marqueeEl.current, -1);
  }

  useEffect(() => {
    // @ts-ignore
    window.ss = {
      students,
      teacher
    }
  }, [students, teacher]);

  return (
    <div className="video-marquee-container">
      <div className="main">
      {/* <TeacherPlayer></TeacherPlayer> */}
        {teacher ?
          <VideoPlayer
            role="teacher"
            domId={`dom-${teacher.id}`}
            id={`${teacher.id}`}
            streamID={teacher.streamID}
            stream={teacher.stream}
            account={teacher.account}
            audio={Boolean(teacher.audio)}
            video={Boolean(teacher.video)}
            local={Boolean(teacher.local)}
            handleClick={onPlayerClick}
          />
          :
          <VideoPlayer role="teacher" account={'teacher'} video audio streamID={0} />
          }
      </div>
      <div className="video-marquee-mask">
        <div className="video-marquee" ref={marqueeEl}>
        {students.length >= 7 ? <div className="scroll-btn-group">
            <div className="icon icon-left" onClick={handleScrollLeft}></div>
            <div className="icon icon-right" onClick={handleScrollRight}></div>
        </div> : null}
          {students.map((student: AgoraMediaStream, key: number) => (
            <VideoPlayer
              role="student"
              domId={`dom-${student.id}`}
              key={`${key}${student.stream.streamID}`}
              id={`${student.id}`}
              account={student.account}
              streamID={student.streamID}
              stream={student.stream}
              video={student.video}
              audio={student.audio}
              local={student.local}
              handleClick={onPlayerClick}
            />
          ))}
        </div>
      </div>
    </div>
  )
}
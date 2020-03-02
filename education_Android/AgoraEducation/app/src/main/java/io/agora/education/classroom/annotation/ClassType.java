package io.agora.education.classroom.annotation;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

@IntDef({ClassType.ONE2ONE, ClassType.SMALL, ClassType.LARGE})
@Retention(RetentionPolicy.SOURCE)
public @interface ClassType {

    int ONE2ONE = 0;
    int SMALL = 1;
    int LARGE = 2;

}

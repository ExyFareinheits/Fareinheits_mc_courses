import { free2CourseData } from './free-2-course-data';
import { free3CourseData } from './free-3-course-data';
import { free4CourseData } from './free-4-course-data';

export const freeCoursesContent = {
  'free-2': free2CourseData,
  'free-3': free3CourseData,
  'free-4': free4CourseData,
} as const;

export type FreeCourseId = keyof typeof freeCoursesContent;

export function getFreeCourseContent(courseId: string) {
  return freeCoursesContent[courseId as FreeCourseId];
}

export function hasFreeCourseContent(courseId: string): courseId is FreeCourseId {
  return courseId in freeCoursesContent;
}

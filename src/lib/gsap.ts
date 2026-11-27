import { gsap } from 'gsap';
import { MotionPathPlugin } from 'gsap/MotionPathPlugin';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

// Registered once, app-wide. MotionPathPlugin is unused until the story scenes land.
gsap.registerPlugin(ScrollTrigger, MotionPathPlugin);

export { gsap, MotionPathPlugin, ScrollTrigger };

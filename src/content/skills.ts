import type { SkillGroup } from './types';

/** Verbatim from legacy `skillGroups` (en_strings.dart / ar_strings.dart), in display order. */
export const skillGroups: SkillGroup[] = [
  {
    name: { en: 'Languages & Frameworks', ar: 'لغات البرمجة والأطر' },
    skills: {
      en: [
        'Python',
        'Django',
        'FastAPI',
        'PHP (Laravel)',
        'Dart (Flutter)',
        'C++',
        'C#',
        'Java',
        'TypeScript',
        'HTML',
      ],
      ar: [
        'Python',
        'Django',
        'FastAPI',
        'PHP (Laravel)',
        'Dart (Flutter)',
        'C++',
        'C#',
        'Java',
        'TypeScript',
        'HTML',
      ],
    },
  },
  {
    name: { en: 'Web & Data', ar: 'الويب والبيانات' },
    skills: {
      en: ['React', 'REST API Development', 'PostgreSQL', 'MySQL', 'SQLite', 'TensorFlow'],
      ar: ['React', 'تطوير REST API', 'PostgreSQL', 'MySQL', 'SQLite', 'TensorFlow'],
    },
  },
  {
    name: { en: 'Tools & Platforms', ar: 'الأدوات والمنصات' },
    skills: {
      en: [
        'Git',
        'GitHub',
        'Microsoft Azure',
        'Linux',
        'Kali Linux',
        'Figma',
        'Unity',
        'Odoo ERP',
        'UltraVNC',
      ],
      ar: [
        'Git',
        'GitHub',
        'Microsoft Azure',
        'Linux',
        'Kali Linux',
        'Figma',
        'Unity',
        'Odoo ERP',
        'UltraVNC',
      ],
    },
  },
  {
    name: { en: 'Soft Skills', ar: 'المهارات الشخصية' },
    skills: {
      en: [
        'Leadership',
        'Cross-functional Communication',
        'Problem Solving',
        'Critical Thinking',
        'Time Management',
        'Teamwork',
      ],
      ar: ['القيادة', 'التواصل بين الفرق', 'حل المشكلات', 'التفكير النقدي', 'إدارة الوقت', 'العمل الجماعي'],
    },
  },
];

/** Legacy route slug: lowercase, spaces → `-`, `&` → `and` (applied to the localized name). */
export function skillRoute(groupName: string): string {
  return `/${groupName.toLowerCase().replaceAll(' ', '-').replaceAll('&', 'and')}`;
}

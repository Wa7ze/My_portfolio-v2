import type { EducationEntry, LanguageEntry, Localized } from './types';

/** Verbatim from legacy lib/core/strings/{en,ar}_strings.dart. */

export const summary: Localized<string> = {
  en: 'Software Engineer with hands-on experience in full-stack development (Python/FastAPI, React, TypeScript, PostgreSQL) and IT support/ERP administration. Built and deployed a production helpdesk and inventory system used daily by ~300 users. Experienced with Odoo ERP customization, REST API development, and end-to-end project delivery from data modeling to UI. Fluent in English and Arabic; advanced Turkish.',
  ar: 'مهندس برمجيات يتمتع بخبرة عملية في تطوير البرمجيات المتكاملة (Full-Stack) باستخدام Python/FastAPI وReact وTypeScript وPostgreSQL، إضافة إلى الدعم الفني وإدارة أنظمة تخطيط موارد المؤسسات (ERP). قام ببناء ونشر نظام إنتاجي لإدارة طلبات الدعم الفني والمخزون يُستخدم يوميًا من قبل نحو 300 مستخدم. لديه خبرة في تخصيص نظام Odoo ERP، وتطوير واجهات REST API، وتسليم المشاريع من مرحلة نمذجة البيانات وحتى واجهة المستخدم. يجيد اللغتين الإنجليزية والعربية بطلاقة، ولديه مستوى متقدم في اللغة التركية.',
};

/** The "open to opportunities" teaser (rendered by the pre-redesign home page). */
export const aboutTeaser: Localized<string> = {
  en: "I'm a software engineer specializing in full-stack development and IT/ERP systems — currently building production tools used by hundreds of people every day. I'm open to full-time, part-time, or traineeship opportunities in web, app, or game development.",
  ar: 'أنا مهندس برمجيات متخصص في تطوير البرمجيات المتكاملة (Full-Stack) وأنظمة تقنية المعلومات وERP، أعمل حاليًا على بناء أدوات إنتاجية يستخدمها المئات يوميًا. أنا منفتح على فرص العمل بدوام كامل أو جزئي أو التدريب في مجالات تطوير الويب والتطبيقات وتطوير الألعاب.',
};

export interface Experience {
  role: string;
  company: string;
  period: string;
  bullets: string[];
}

export const experience: Localized<Experience[]> = {
  en: [
    {
      role: 'IT Support Specialist',
      company: 'Alessa Industries — Riyadh, Saudi Arabia',
      period: '2025 – Present',
      bullets: [
        'Provided first-line IT support to employees using UltraVNC Viewer, resolving hardware, software, and system issues.',
        'Handled Helpdesk requests, troubleshooting Windows OS, applications, network connectivity, and printers.',
        'Participated in ERP system setup and migration activities, including master data preparation, validation, and testing across Sales, Purchase, Inventory, and Accounting modules.',
        'Developed and maintained custom Odoo modules, handling end-to-end implementation including business logic, data models, and UI views to extend core ERP functionality.',
      ],
    },
  ],
  ar: [
    {
      role: 'أخصائي دعم فني',
      company: 'شركة Alessa Industries — الرياض، المملكة العربية السعودية',
      period: '2025 – حتى الآن',
      bullets: [
        'تقديم الدعم الفني المباشر للموظفين باستخدام برنامج UltraVNC Viewer، وحل مشكلات الأجهزة والبرمجيات والأنظمة.',
        'التعامل مع طلبات الدعم الفني، واستكشاف أخطاء نظام Windows والتطبيقات والاتصال بالشبكة والطابعات وإصلاحها.',
        'المشاركة في إعداد وترحيل نظام ERP، بما في ذلك تجهيز البيانات الأساسية والتحقق منها واختبارها عبر وحدات المبيعات والمشتريات والمخزون والمحاسبة.',
        'تطوير وصيانة وحدات Odoo المخصصة، والإشراف على التنفيذ الكامل بدءًا من منطق الأعمال ونماذج البيانات وحتى واجهات المستخدم لتوسيع وظائف نظام ERP الأساسية.',
      ],
    },
  ],
};

export const education: Localized<EducationEntry[]> = {
  en: [
    {
      degree: "Bachelor's Degree",
      field: 'Software Engineering',
      school: 'Üsküdar University — Istanbul, Turkey',
      gpa: 'GPA: 3.65 / 4.0',
      period: '2021 – 2025',
    },
    {
      degree: 'Minor Degree',
      field: 'Computer Engineering',
      school: 'Üsküdar University — Istanbul, Turkey',
      gpa: 'GPA: 3.00 / 4.0',
      period: '2022 – 2025',
    },
  ],
  ar: [
    {
      degree: 'درجة البكالوريوس',
      field: 'هندسة البرمجيات',
      school: 'جامعة أسكودار — إسطنبول، تركيا',
      gpa: 'المعدل التراكمي: 3.65 / 4.0',
      period: '2021 – 2025',
    },
    {
      degree: 'تخصص فرعي',
      field: 'هندسة الحاسوب',
      school: 'جامعة أسكودار — إسطنبول، تركيا',
      gpa: 'المعدل التراكمي: 3.00 / 4.0',
      period: '2022 – 2025',
    },
  ],
};

export const languages: Localized<LanguageEntry[]> = {
  en: [
    { name: 'English', level: 'Fluent' },
    { name: 'Arabic', level: 'Fluent' },
    { name: 'Turkish', level: 'Advanced' },
  ],
  ar: [
    { name: 'الإنجليزية', level: 'طلاقة' },
    { name: 'العربية', level: 'طلاقة' },
    { name: 'التركية', level: 'متقدم' },
  ],
};

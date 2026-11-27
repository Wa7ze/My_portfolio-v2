/** Hidden terminal copy, verbatim from legacy lib/widgets/terminal_overlay.dart (English only). */
export const terminalText = {
  welcome: 'type help to list commands',
  prompt: 'guest@portfolio:~$ ',
  help: [
    'help, whoami, ls, ls projects, cat <slug>, cd <section>, curl /<section>,',
    'open github|linkedin|cv, history, clear, sudo hire <anything>, exit',
  ],
  noSuchProject: (slug: string) => `cat: ${slug}: no such project`,
  repo: (url: string) => `repo: ${url}`,
  routing: (name: string) => `→ routing to /${name}`,
  noRoute: (cmd: string, name: string) => `${cmd}: ${name}: no route to host`,
  opening: (target: string) => `→ opening ${target}`,
  unknownTarget: (target: string) => `open: ${target}: unknown target`,
  sudoGranted: '[sudo] permission granted.',
  sudoOpeningContact: '→ opening /contact',
  sudoNotFound: (rest: string) => `sudo: ${rest}: command not found`,
  notFound: (cmd: string) => `command not found: ${cmd}. try help`,
} as const;

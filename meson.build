project(
  'com.paysonwallach.portico',
  'vala', 'c',
  version: '5.0.4',
  meson_version: '>= 0.49.0'
)

gnome = import('gnome')
i18n = import('i18n')

vapi_dir = join_paths(meson.current_source_dir(), 'vapi')

greeter_resources = gnome.compile_resources(
  'greeter-resources',
  'data/greeter.gresource.xml',
  source_dir: 'data'
)

compositor_resources = gnome.compile_resources(
  'compositor-resources',
  'data/compositor.gresource.xml',
  source_dir: 'data'
)

add_project_arguments([
    '-DG_LOG_DOMAIN="@0@"'.format(meson.project_name()),
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
  ],
  language:'c'
)

add_project_arguments(
  ['--vapidir', vapi_dir],
  language: 'vala'
)

subdir('src')
subdir('compositor')
subdir('data')
subdir('po')

vapigen = find_program('vapigen', required: false)
if vapigen.found()
  subdir('vapi')
endif

meson.add_install_script('meson/post_install.py')

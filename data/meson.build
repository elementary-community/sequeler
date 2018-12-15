icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('assets/icons', i + 'x' + i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons/hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('assets/icons', i + 'x' + i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons/hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

install_data(
    'assets/icons/128x128/' + meson.project_name() + '.svg',
    install_dir: join_paths(get_option('datadir'), 'icons/hicolor/scalable/apps')
)

# Desktop file
desktop_file = i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

# Validate desktop file
desktop_file_validate = find_program('desktop-file-validate', required: false)
if desktop_file_validate.found()
  test(
    'validate-desktop',
    desktop_file_validate,
    args: [
      desktop_file.full_path()
    ]
  )
endif

appdata_file = i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

# Validate AppData file
appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test(
    'validate-appdata', appstream_util,
    args: [
      'validate-relax', appdata_file.full_path()
    ]
  )
endif

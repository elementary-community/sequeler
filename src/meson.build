conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('PKGDATADIR', get_option('datadir') + '/' + meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('RELEASE_NAME', 'Sequeler')
conf_data.set('VERSION', '0.6.5')
conf_data.set('VERSION_INFO', 'Friendly SQL Client')
conf_data.set('PREFIX', get_option('prefix'))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'Main.vala',
    'Application.vala',
    'Window.vala',

    'Layouts/HeaderBar.vala',
    'Layouts/Main.vala',
    'Layouts/Library.vala',
    'Layouts/Welcome.vala',
    'Layouts/DataBaseSchema.vala',
    'Layouts/DataBaseView.vala',

    'Layouts/Views/Structure.vala',
    'Layouts/Views/Content.vala',
    'Layouts/Views/Relations.vala',
    'Layouts/Views/Query.vala',

    'Partials/ButtonType.vala',
    'Partials/Helpers.vala',
    'Partials/LibraryItem.vala',
    'Partials/TreeBuilder.vala',

    'Services/Settings.vala',
    'Services/ActionManager.vala',
    'Services/DataManager.vala',
    'Services/ConnectionManager.vala',
    'Services/PasswordManager.vala',
    'Services/UpgradeManager.vala',

    'Services/Types/DataBaseType.vala',
    'Services/Types/MySQL.vala',
    'Services/Types/PostgreSQL.vala',
    'Services/Types/SQLite.vala',

    'Widgets/ConnectionDialog.vala',
    'Widgets/ModeSwitch.vala',
    asresources,
    config_header,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('granite'),
        dependency('glib-2.0'),
        dependency('gee-0.8'),
        dependency('gobject-2.0'),
        dependency('libxml-2.0'),
        dependency('libgda-5.0'),
        dependency('libsecret-1'),
        dependency('gtksourceview-3.0'),
        m_dep
    ],
    install: true
)

schema_conf = configuration_data()
schema_conf.set('appid', meson.project_name())
schema_conf.set('schema-path', '/com/github/alecaddd/sequeler/')

configure_file(
	input: '@0@.gschema.xml.in'.format(meson.project_name()),
	output: '@0@.gschema.xml'.format(meson.project_name()),
	install: true,
	install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas'),
	configuration:schema_conf
)

# project name and programming language
project ('com.github.stbsoft.sarge', 'vala', 'c')

# Include the translations module
i18n = import ('i18n')

# Set translation domain
add_global_arguments ('-DGETTEXT_PACKAGE="@0@"'
    .format(meson.project_name()), language: 'c')

subdir ('src')

# Translate and install desktop file
i18n.merge_file (
    input: join_paths ('data', 'sarge.desktop.in'),
    output: meson.project_name () + '.desktop',
    po_dir: join_paths (meson.source_root (), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'applications')
)

# Translate and install appdata file
i18n.merge_file (
    input: join_paths ('data', 'sarge.appdata.xml.in'),
    output: meson.project_name () + 'appdata.xml',
    po_dir: join_paths (meson.source_root (), 'po'),
    install: true,
    install_dir: join_paths (get_option ('datadir'), 'metainfo')
)

subdir ('po')

meson.add_install_script ('meson/post_install.py')

subdir ('data')

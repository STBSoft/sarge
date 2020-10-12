# List of source files
sarge_files = files (
    'SargeApp.vala',
    'components/Panel.vala'
)

# Create a new executable, list the files we want to compile, 
# list the dependencies we need, and install
executable (
    meson.project_name (),
    sarge_files,
    dependencies: [
        dependency ('gtk+-3.0')
    ],
    install: true
)
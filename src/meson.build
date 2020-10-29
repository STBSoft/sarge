# Create a new executable, list the files we want to compile, 
# list the dependencies we need, and install
executable (
    meson.project_name (), [
        'SargeApp.vala',
        'Components/PanelBox.vala',
        'Components/FileItem.vala',
        resources
    ],
    dependencies: [
        dependency ('gtk+-3.0')
    ],
    install: true
)
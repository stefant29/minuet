set(minuet_PLUGINS
    PianoView.json
    rect1.json
    rect2.json
    rect3.json
)

add_subdirectory(PianoView)
add_subdirectory(rect1)
add_subdirectory(rect2)
add_subdirectory(rect3)

install(FILES ${minuet_PLUGINS} DESTINATION ${KDE_INSTALL_DATADIR}/minuet/plugins)

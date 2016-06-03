set(minuetandroid_EXERCISES
    intervals-ascending-melodic.json
    intervals-descending-melodic.json
    chords-root-position.json
    scales-major-and-its-modes.json
    rhythm-easy.json
    rhythm-medium.json
)

install(FILES ${minuetandroid_EXERCISES} DESTINATION ${KDE_INSTALL_DATADIR}/minuetandroid/exercises)
install(DIRECTORY exercise-images DESTINATION ${KDE_INSTALL_DATADIR}/minuetandroid/qml)

set(minuetandroid_SRCS
    main.cpp
    exercisecontroller.cpp
    csengine.cpp
    csoundandroidsoundbackend.cpp
    isoundbackend.cpp
    iplugin.cpp
    iexercisecontroller.cpp
)
qt5_add_resources(minuetandroid_SRCS resources.qrc)

add_executable(minuetandroid ${minuetandroid_SRCS})

target_link_libraries (
    minuetandroid
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Qt5::Qml
    Qt5::XmlPatterns 
    Qt5::QuickControls2
)

#if (CMAKE_SYSTEM_NAME STREQUAL Android)
#    target_link_libraries (
#        minuetandroid
#        Qt5::Core
#        Qt5::Gui
#        Qt5::Quick
#        Qt5::Qml
#    )
#endif()

target_link_libraries(minuetandroid ${CSOUND_LIBS})

install(TARGETS minuetandroid RUNTIME DESTINATION bin)

set(minuetandroid_SRCS
    main.cpp
    exercisecontroller.cpp
)
qt5_add_resources(minuetandroid_SRCS resources.qrc)

add_executable(minuetandroid ${minuetandroid_SRCS})

target_link_libraries (
    minuetandroid
    Qt5::Core
    Qt5::Gui
    Qt5::Quick
    Qt5::Qml
)

if (CMAKE_SYSTEM_NAME STREQUAL Android)
    target_link_libraries (
        minuetandroid
        Qt5::Core
        Qt5::Gui
        Qt5::Quick
        Qt5::Qml
    )
endif()

install(TARGETS minuetandroid RUNTIME DESTINATION bin)

set (HICOLOR_DIR ${DATADIR}/icons/hicolor)
# Data
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/16/evalify.svg DESTINATION ${HICOLOR_DIR}/16x16/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/24/evalify.svg DESTINATION ${HICOLOR_DIR}/24x24/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/32/evalify.svg DESTINATION ${HICOLOR_DIR}/32x32/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/48/evalify.svg DESTINATION ${HICOLOR_DIR}/48x48/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/64/evalify.svg DESTINATION ${HICOLOR_DIR}/64x64/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/icons/128/evalify.svg DESTINATION ${HICOLOR_DIR}/128x128/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/evalify.desktop DESTINATION ${DATADIR}/applications/)


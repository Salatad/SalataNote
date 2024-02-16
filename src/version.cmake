# execute_process(COMMAND "${GIT}" describe --dirty --match "v${VERSION}" RESULT_VARIABLE RET OUTPUT_VARIABLE DESCRIPTION OUTPUT_STRIP_TRAILING_WHITESPACE)

# determine last git commit hash, to assign it to the VERSION constant
execute_process(COMMAND "${GIT}" log -1 --format=%h --no-abbrev-commit RESULT_VARIABLE RET OUTPUT_VARIABLE COMMIT OUTPUT_STRIP_TRAILING_WHITESPACE)
if(RET)
    # message(WARNING "Cannot determine current revision. Make sure that you are building either from a Git working tree or from a source archive.")
    message(WARNING "Cannot determine the current git version. Make sure that you have git installed and you are building from the git source.")
    # message(WARNING "VERSION will be set to ${COMMIT}")
    # set(VERSION "${COMMIT}")
    # configure_file("src/version.h.in" "${TO}")
else()
    # string(REGEX MATCH "([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])?(-dirty)? $" COMMIT "${DESCRIPTION} ")
    # string(STRIP "${COMMIT}" COMMIT)
    message(STATUS "Git version determined: ${COMMIT}")
    set(VERSION "${COMMIT}")
    configure_file("src/version.h.in" "${TO}")
endif()

# automatically increase build number
set(VERSION_H_IN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/src/version.h.in")
# Read the current build number from the version.h.in file
file(READ ${VERSION_H_IN_FILE} VERSION_H_CONTENTS)
# Define a regular expression pattern to match the entire line containing PROJECT_VERSION_BUILD_NO
set(VERSION_H_REGEX "#define PROJECT_VERSION_BUILD_NO \"([0-9]+)\"")
# Extract the current build number
string(REGEX MATCH "${VERSION_H_REGEX}" MATCHED_LINE "${VERSION_H_CONTENTS}")
if(MATCHED_LINE)
    # Extract the current build number
    string(REGEX REPLACE "${VERSION_H_REGEX}" "\\1" CURRENT_BUILD_NO "${MATCHED_LINE}")

    # Increment the build number
    math(EXPR NEXT_BUILD_NO "${CURRENT_BUILD_NO} + 1")

    # Generate the new line with the updated build number
    string(REGEX REPLACE "${VERSION_H_REGEX}" "#define PROJECT_VERSION_BUILD_NO \"${NEXT_BUILD_NO}\"" NEW_LINE "${MATCHED_LINE}")

    # Replace the old line with the new line
    string(REPLACE "${MATCHED_LINE}" "${NEW_LINE}" NEW_VERSION_H_CONTENTS "${VERSION_H_CONTENTS}")

    # Write the updated version.h.in file
    file(WRITE "${VERSION_H_IN_FILE}" "${NEW_VERSION_H_CONTENTS}")

    message(STATUS "Build number determined and increased: ${CURRENT_BUILD_NO}")
    message(STATUS "Next Build number: ${NEXT_BUILD_NO}")
else()
    message(WARNING "Cannot determine the build number.")
endif()

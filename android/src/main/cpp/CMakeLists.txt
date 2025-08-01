cmake_minimum_required(VERSION 3.18.1)

project("adhan")

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include directories
include_directories(
    ../../../cpp
)

# Source files
set(SOURCES
    ../../../cpp/AdhanCalculations.cpp
    ../../../cpp/AdhanJNI.cpp
)

# Create the shared library
add_library(adhan SHARED ${SOURCES})

# Find the log library
find_library(log-lib log)

# Link libraries
target_link_libraries(adhan ${log-lib})

# Compiler flags for optimization
target_compile_options(adhan PRIVATE 
    -O3 
    -ffast-math
    -Wall
    -Wextra
)

# Add math library
target_link_libraries(adhan m)
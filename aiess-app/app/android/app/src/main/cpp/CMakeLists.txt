cmake_minimum_required(VERSION 3.22.1)
project(aiess_llm CXX C)

set(CMAKE_CXX_STANDARD 17)
set(LLAMA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../third_party/llama.cpp)

# Solo la libreria llama + ggml (sin herramientas, servidor ni pruebas).
set(LLAMA_BUILD_COMMON OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(LLAMA_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(GGML_NATIVE OFF CACHE BOOL "" FORCE)
set(GGML_OPENMP OFF CACHE BOOL "" FORCE)
set(GGML_LLAMAFILE OFF CACHE BOOL "" FORCE)

add_subdirectory(${LLAMA_DIR} llama_build)

add_library(aiess_llm SHARED aiess_llm.cpp)
target_link_libraries(aiess_llm llama log android)
target_compile_options(aiess_llm PRIVATE -O3 -Wno-deprecated-declarations)

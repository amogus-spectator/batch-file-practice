#include <cstring>
#include <string>
#include <vector>
#include <iostream>
#include <algorithm>
#include <windows.h>
#include <fstream>
#include <cstdlib>

#include <openssl/evp.h>
#include <openssl/rand.h>
#include <stdexcept>

std::vector<std::string> file_reader(const std::string& file_name, std::vector<std::string>& lines) {
    std::ifstream file(file_name);
    if (!file.is_open()) {
        throw std::runtime_error("Could not open file");
    }
    std::string line;
    while (std::getline(file, line)) {
        lines.push_back(line);
    }
    return lines;
}

void file_writer(const std::string& file_name, const std::vector<std::string>& lines) {
    std::ofstream file(file_name);
    if (!file.is_open()) {
        throw std::runtime_error("Could not open file");
    }
    for (const auto& line : lines) {
        file << line << std::endl;
    }
}

void single_line_file_writer(const std::string& file_name, const std::string& datastream) {
    HANDLE hfile = CreateFile(
        file_name.c_str(), 
        GENERIC_WRITE, 
        0, 
        NULL, 
        CREATE_ALWAYS, 
        FILE_ATTRIBUTE_NORMAL, 
        NULL
    );
    if (hfile == INVALID_HANDLE_VALUE) {
        throw std::runtime_error("Could not open file");
    }
    DWORD totalBytesWritten = 0;
    DWORD bytesWritten;
    DWORD dataSize = strlen(datastream.c_str());
    while (totalBytesWritten < dataSize) {
        BOOL success = WriteFile(hfile, datastream.c_str() + totalBytesWritten, dataSize - totalBytesWritten, &bytesWritten, NULL);
        if (!success) {
            std::cout << "Write error: " << GetLastError() << std::endl;
            break;
        }
        totalBytesWritten += bytesWritten;
    }
}

std::vector<char> generate_gibberish(int size) {
    std::vector<char> gibberish(size);
    for (int i = 0; i < size; i++) {
        gibberish[i] = rand() % 256;
    }
    return gibberish;
}


bool is_valid_directory_path(const std::string& path) {
    DWORD attributes = GetFileAttributes(path.c_str());
    return (attributes != INVALID_FILE_ATTRIBUTES && (attributes & FILE_ATTRIBUTE_DIRECTORY));
}
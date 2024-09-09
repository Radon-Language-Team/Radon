# Function to handle platform-specific path conversion
convert_path() {
    if [ "$USER_OS" = "MINGW" ] || [ "$USER_OS" = "CYGWIN" ]; then
        # Convert Unix paths to Windows format in Git Bash/Cygwin
        echo $(cygpath -w "$1")
    else
        echo "$1"
    fi
}

# Set paths for both Windows and Linux
SRC_DIR="src/cmd/radon.v"
OUTPUT_DIR="radon"
EXECUTABLE_NAME="radon"
USER_OS=$(uname)

mkdir -p $OUTPUT_DIR

if [ "$USER_OS" = "Darwin" ]; then 
    echo "Building for Mac is not supported."
    read -p "Press any key to continue... " -n1 -s
    exit 1
fi

if [ "$USER_OS" = "Linux" ]; then

    echo "Building for Linux..."
    v -os linux -o $(convert_path $OUTPUT_DIR/$EXECUTABLE_NAME) $(convert_path $SRC_DIR) 2> error.log

    if [ $? -eq 0 ]; then
        echo "Linux build successful: $(convert_path $OUTPUT_DIR/$EXECUTABLE_NAME)"
    else
        echo "Linux build failed."
        echo "Check error.log for any warnings or errors."
        read -p "Press any key to continue... " -n1 -s
    fi

else 

    echo "Building for Windows..."
    v -os windows -o $(convert_path $OUTPUT_DIR/$EXECUTABLE_NAME.exe) $(convert_path $SRC_DIR) 2> error.log

    if [ $? -eq 0 ]; then
        echo "Windows build successful: $(convert_path $OUTPUT_DIR/$EXECUTABLE_NAME.exe)"
    else
        echo "Windows build failed."
        echo "Check error.log for any warnings or errors."
        read -p "Press any key to continue... " -n1 -s
    fi

fi

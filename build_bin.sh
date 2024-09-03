SRC_DIR="src/cmd/radon.v"
OUTPUT_DIR="radon"
EXECUTABLE_NAME="radon"
USER_OS=$(uname)

mkdir -p $OUTPUT_DIR

if [ "$USER_OS" = "Darwin" ]; then
    echo "Building for Mac is not supported."
    exit 1
fi

if [ "$USER_OS" = "Linux" ]; then

    echo "Building for Linux..."
    v -os linux -o $OUTPUT_DIR/$EXECUTABLE_NAME $SRC_DIR

    if [ $? -eq 0 ]; then
        echo "Linux build successful: $OUTPUT_DIR/$EXECUTABLE_NAME"
    else
        echo "Linux build failed."
    fi

else 

    echo "Building for Windows..."
    v -os windows -o $OUTPUT_DIR/$EXECUTABLE_NAME.exe $SRC_DIR

    if [ $? -eq 0 ]; then
        echo "Windows build successful: $OUTPUT_DIR/$EXECUTABLE_NAME.exe"
    else
        echo "Windows build failed."
    fi

fi

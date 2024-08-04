SRC_DIR="src/cmd/radon.v"
OUTPUT_DIR="radon"
EXECUTABLE_NAME="radon"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Build for Windows
echo "Building for Windows..."
v -os windows -o $OUTPUT_DIR/${EXECUTABLE_NAME}.exe $SRC_DIR

if [ $? -eq 0 ]; then
    echo "Windows build successful: $OUTPUT_DIR/${EXECUTABLE_NAME}.exe"
else
    echo "Windows build failed."
fi

echo "Building for Linux..."
v -os linux -o $OUTPUT_DIR/$EXECUTABLE_NAME $SRC_DIR

if [ $? -eq 0 ]; then
    echo "Linux build successful: $OUTPUT_DIR/$EXECUTABLE_NAME"
else
    echo "Linux build failed."
fi

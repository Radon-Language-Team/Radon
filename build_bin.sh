# Define the source and output directories
SRC_DIR="src/cmd/radon.v"  # The radon V source file path
OUTPUT_DIR="radon"          # Directory to place the built executables
EXECUTABLE_NAME="radon"   # The base name of the executable

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

# Build for Linux
echo "Building for Linux..."
v -os linux -o $OUTPUT_DIR/$EXECUTABLE_NAME $SRC_DIR

if [ $? -eq 0 ]; then
    echo "Linux build successful: $OUTPUT_DIR/$EXECUTABLE_NAME"
else
    echo "Linux build failed."
fi

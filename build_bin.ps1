$SRC_DIR = "src/cmd/radon.v"
$OUT_DIR = "radon"
$EXE_NAME = "radon.exe"

# Create the output directory if it doesn't exist
mkdir $OUT_DIR -ErrorAction SilentlyContinue

# Build the binary
v -os windows -prod -o "$OUT_DIR\$EXE_NAME" $SRC_DIR

# Check if the build was successful
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed"
    Read-Host -Prompt "Press Enter to exit"
    exit 1
}

Write-Host "Build successful"
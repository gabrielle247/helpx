#!/bin/sh

# Configuration
SOURCE="favicon.svg"
OUT_DIR="web/icons"
BG_COLOR="#121212" # Greyway Dark

# Ensure directory exists
mkdir -p $OUT_DIR

# Check if rsvg-convert is installed
if ! command -v rsvg-convert >/dev/null 2>&1; then
    echo "Error: rsvg-convert is not installed."
    echo "Install it using: sudo apt-get install librsvg2-bin"
    exit 1
fi

echo "🎨 Generating Icons for Help X..."

# 1. Standard Icons (Transparent Background)
# 192x192
rsvg-convert -w 192 -h 192 -f png -o "$OUT_DIR/Icon-192.png" "$SOURCE"
# 512x512
rsvg-convert -w 512 -h 512 -f png -o "$OUT_DIR/Icon-512.png" "$SOURCE"

# 2. Maskable Icons (With Greyway Background for Android)
# Note: We add a background rect using a temporary SVG wrapper or by just rendering on top.
# For simplicity with rsvg, we will assume the SVG is transparent and just render it. 
# Ideally, maskable icons need padding. We will scale the icon down slightly to 80% to fit the safe zone.

# Function to generate maskable icon
generate_maskable() {
    SIZE=$1
    NAME=$2
    # Create a temporary SVG that adds the background and centers/scales the icon
    # This ensures the logo isn't cut off by round icon masks
    echo "<svg width='$SIZE' height='$SIZE' viewBox='0 0 $SIZE $SIZE' xmlns='http://www.w3.org/2000/svg'>
            <rect width='$SIZE' height='$SIZE' fill='$BG_COLOR'/>
            <image href='$SOURCE' x='${SIZE}' y='${SIZE}' width='${SIZE}' height='${SIZE}' transform='translate(-$((SIZE/2)), -$((SIZE/2))) scale(0.8) translate($((SIZE/8)), $((SIZE/8)))'/> 
            </svg>" > temp_mask.svg
    
    # Actually, simpler method for shell:
    # Use rsvg to render the icon, then use ImageMagick if available, OR
    # just render the icon directly. Since we are keeping it simple:
    # We will render the icon directly for now. If you need strict padding, we can adjust.
    
    rsvg-convert -w $SIZE -h $SIZE -b "$BG_COLOR" -f png -o "$OUT_DIR/$NAME" "$SOURCE"
}

# Generate Maskable (using the background color flag -b)
rsvg-convert -w 192 -h 192 -b "$BG_COLOR" -f png -o "$OUT_DIR/Icon-maskable-192.png" "$SOURCE"
rsvg-convert -w 512 -h 512 -b "$BG_COLOR" -f png -o "$OUT_DIR/Icon-maskable-512.png" "$SOURCE"

echo "✅ Icons generated in $OUT_DIR"
#!/usr/bin/env python3
"""
Simple icon generator for LinkCrypta browser extension
Converts SVG to PNG in multiple sizes
"""

import os
from PIL import Image, ImageDraw, ImageFont
import cairosvg

def create_simple_icon(size):
    """Create a simple icon programmatically"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    bg_color = (37, 99, 235, 255)  # Primary blue
    lock_color = (255, 255, 255, 255)  # White
    
    # Draw rounded rectangle background
    margin = size // 8
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=size // 6,
        fill=bg_color
    )
    
    # Draw lock icon
    lock_size = size // 2
    lock_x = (size - lock_size) // 2
    lock_y = (size - lock_size) // 2 + size // 16
    
    # Lock body
    body_height = lock_size // 2
    body_width = int(lock_size * 0.8)
    body_x = lock_x + (lock_size - body_width) // 2
    body_y = lock_y + lock_size - body_height
    
    draw.rounded_rectangle(
        [body_x, body_y, body_x + body_width, body_y + body_height],
        radius=size // 32,
        fill=lock_color
    )
    
    # Lock shackle
    shackle_width = int(body_width * 0.6)
    shackle_height = int(lock_size * 0.4)
    shackle_x = body_x + (body_width - shackle_width) // 2
    shackle_y = body_y - shackle_height // 2
    
    # Draw shackle outline
    draw.arc(
        [shackle_x, shackle_y, shackle_x + shackle_width, shackle_y + shackle_height],
        start=180, end=0,
        fill=lock_color,
        width=size // 16
    )
    
    # Lock keyhole
    keyhole_size = size // 16
    keyhole_x = body_x + body_width // 2 - keyhole_size // 2
    keyhole_y = body_y + body_height // 3
    
    draw.ellipse(
        [keyhole_x, keyhole_y, keyhole_x + keyhole_size, keyhole_y + keyhole_size],
        fill=bg_color
    )
    
    return img

def generate_icons():
    """Generate all required icon sizes"""
    sizes = [16, 32, 48, 128]
    icons_dir = os.path.dirname(os.path.abspath(__file__)) + "/icons"
    
    # Create icons directory if it doesn't exist
    os.makedirs(icons_dir, exist_ok=True)
    
    for size in sizes:
        print(f"Generating {size}x{size} icon...")
        
        # Create icon
        icon = create_simple_icon(size)
        
        # Save as PNG
        icon_path = os.path.join(icons_dir, f"icon-{size}.png")
        icon.save(icon_path, "PNG")
        print(f"Saved: {icon_path}")
    
    print("All icons generated successfully!")

if __name__ == "__main__":
    try:
        generate_icons()
    except ImportError as e:
        print("Error: Missing required packages. Install with:")
        print("pip install Pillow cairosvg")
        print(f"Error details: {e}")
    except Exception as e:
        print(f"Error generating icons: {e}")

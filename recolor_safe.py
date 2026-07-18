import sys
from PIL import Image
import os

def blue_to_gold(input_path, output_path):
    try:
        img = Image.open(input_path).convert("RGBA")
        datas = img.getdata()

        newData = []
        for item in datas:
            r, g, b, a = item
            # Identify blue-ish pixels (diamonds)
            # The diamonds are cyan/blue: high b, medium g, low r
            # Safe is neutral grey: r ≈ g ≈ b
            if b > r + 30 and b > 100:
                # Convert blue to gold/orange:
                # We want high R, medium G, low B
                # E.g., swap R and B, and boost R
                new_r = min(255, int(b * 1.2))
                new_g = min(255, int(g * 1.0))
                new_b = max(0, int(r * 0.5))
                newData.append((new_r, new_g, new_b, a))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(output_path, "PNG")
        print(f"Successfully created {output_path}")
    except Exception as e:
        print(f"Error processing {input_path}: {e}")

blue_to_gold(r"assets\images\diamond_safe.png", r"assets\images\joker_safe.png")

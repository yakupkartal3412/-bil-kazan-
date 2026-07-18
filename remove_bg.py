import sys
from PIL import Image
import os

def remove_green(input_path, output_path):
    try:
        img = Image.open(input_path)
        img = img.convert("RGBA")
        datas = img.getdata()

        newData = []
        for item in datas:
            r, g, b, a = item
            if g > 150 and g > r * 1.5 and g > b * 1.5:
                newData.append((255, 255, 255, 0))
            elif g > 100 and g > r * 1.2 and g > b * 1.2:
                newData.append((255, 255, 255, int(a * 0.5)))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(output_path, "PNG")
        print(f"Successfully processed {output_path}")
    except Exception as e:
        print(f"Error processing {input_path}: {e}")

bag_input = r"C:\Users\lenovo\.gemini\antigravity\brain\0661b7f5-a251-43a2-8831-d00c6d5b0aa7\joker_bag_green_1784369039258.png"
chest_input = r"C:\Users\lenovo\.gemini\antigravity\brain\0661b7f5-a251-43a2-8831-d00c6d5b0aa7\joker_chest_green_1784369049157.png"

remove_green(bag_input, r"assets\images\joker_bag.png")
remove_green(chest_input, r"assets\images\joker_chest.png")

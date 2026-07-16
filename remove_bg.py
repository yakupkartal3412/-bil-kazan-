from PIL import Image

def remove_white(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    data = img.getdata()
    
    new_data = []
    for item in data:
        r, g, b, a = item
        if r > 230 and g > 230 and b > 230:
            new_data.append((255, 255, 255, 0))
        elif r > 180 and g > 180 and b > 180:
             # Soft edge for anti-aliasing
             new_data.append((r, g, b, 100))
        else:
            new_data.append(item)
            
    img.putdata(new_data)
    img.save(output_path, "PNG")
    print("Background removed successfully!")

remove_white(r"C:\Users\lenovo\.gemini\antigravity\brain\0661b7f5-a251-43a2-8831-d00c6d5b0aa7\diamond_option_1_1782396308820.png", r"C:\Users\lenovo\ogrenkazan\bil_kazan\assets\images\diamond.png")

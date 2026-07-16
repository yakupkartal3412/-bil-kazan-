import os
from PIL import Image, ImageFilter

folder = "ekran_goruntuleri"
target_width = 1080
target_height = 1920

if not os.path.exists(folder):
    print("Klasör bulunamadı!")
    exit()

count = 1
for filename in os.listdir(folder):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')) and not filename.startswith('hazir_'):
        filepath = os.path.join(folder, filename)
        
        try:
            img = Image.open(filepath).convert("RGB")
        except:
            continue
            
        img_ratio = img.width / img.height
        target_ratio = target_width / target_height
        
        if img_ratio > target_ratio:
            new_width = target_width
            new_height = int(target_width / img_ratio)
        else:
            new_height = target_height
            new_width = int(target_height * img_ratio)
            
        resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Blur'lu arka plan
        bg_width = target_width
        bg_height = int(target_width / img_ratio)
        if bg_height < target_height:
            bg_height = target_height
            bg_width = int(target_height * img_ratio)
            
        bg = img.resize((bg_width, bg_height), Image.Resampling.LANCZOS)
        
        left = (bg.width - target_width) / 2
        top = (bg.height - target_height) / 2
        right = (bg.width + target_width) / 2
        bottom = (bg.height + target_height) / 2
        bg = bg.crop((left, top, right, bottom))
        
        bg = bg.filter(ImageFilter.GaussianBlur(radius=40))
        
        # Karartma filtresi (blur arkada daha şık dursun diye)
        dark_overlay = Image.new('RGB', (target_width, target_height), (0, 0, 0))
        bg = Image.blend(bg, dark_overlay, alpha=0.3)
        
        paste_x = (target_width - new_width) // 2
        paste_y = (target_height - new_height) // 2
        bg.paste(resized_img, (paste_x, paste_y))
        
        output_name = f"hazir_ekran_{count}.jpg"
        bg.save(os.path.join(folder, output_name), quality=95)
        print(f"{filename} başarıyla {output_name} olarak 1080x1920 formatına getirildi.")
        
        count += 1

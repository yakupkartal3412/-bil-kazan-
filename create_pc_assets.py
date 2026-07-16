import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import random

# 1. PC Logosu (600x400, Şeffaf PNG, Yazılı)
img_logo = Image.new('RGBA', (600, 400), (0, 0, 0, 0))
draw_logo = ImageDraw.Draw(img_logo)
try:
    font_logo1 = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 60)
    font_logo2 = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 45)
except:
    font_logo1 = ImageFont.load_default()
    font_logo2 = ImageFont.load_default()

t1 = "MİLYARDER"
t2 = "TRİVİA"
try:
    w1 = font_logo1.getbbox(t1)[2] - font_logo1.getbbox(t1)[0]
    w2 = font_logo2.getbbox(t2)[2] - font_logo2.getbbox(t2)[0]
except:
    w1, w2 = 400, 300

# Gölgeli Yazı
draw_logo.text(((600-w1)/2 + 4, 130 + 4), t1, fill=(0,0,0,200), font=font_logo1)
draw_logo.text(((600-w1)/2, 130), t1, fill="#ffcc00", font=font_logo1)

draw_logo.text(((600-w2)/2 + 3, 210 + 3), t2, fill=(0,0,0,200), font=font_logo2)
draw_logo.text(((600-w2)/2, 210), t2, fill="white", font=font_logo2)
img_logo.save("pc_logo.png")

# 2. PC Özellik Grafiği (1920x1080, Metinsiz, 16:9)
img_feat = Image.new('RGB', (1920, 1080))
draw_feat = ImageDraw.Draw(img_feat)
for y in range(1080):
    r = int(20 + (y / 1080) * 30)
    g = int(10 + (y / 1080) * 20)
    b = int(80 - (y / 1080) * 40)
    draw_feat.line([(0, y), (1920, y)], fill=(r, g, b))

random.seed(42)
for _ in range(800):
    x = random.randint(0, 1920)
    y = random.randint(0, 1080)
    draw_feat.point((x, y), fill=(255, 255, 255, 150))
    draw_feat.point((x+1, y), fill=(255, 255, 255, 80))
    draw_feat.point((x, y+1), fill=(255, 255, 255, 80))
img_feat.save("pc_ozellik_grafigi.jpg", quality=95)

# 3. PC Ekran Görüntüleri (16:9)
folder = "ekran_goruntuleri"
pc_folder = "pc_ekran_goruntuleri"
if not os.path.exists(pc_folder):
    os.makedirs(pc_folder)

target_w, target_h = 1920, 1080
count = 1
for filename in os.listdir(folder):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')) and not filename.startswith('hazir_') and not filename.startswith('pc_'):
        filepath = os.path.join(folder, filename)
        try:
            img = Image.open(filepath).convert("RGB")
        except:
            continue
            
        # Telefon resmi dik, bunu yatay bir arkaplana oturtacağız
        # Arkaplan için resmi çok büyütüp blur ekleyelim
        bg = img.resize((target_w, int(target_w * (img.height/img.width))), Image.Resampling.LANCZOS)
        
        # Ortadan kırp
        left = 0
        top = (bg.height - target_h) / 2
        right = target_w
        bottom = (bg.height + target_h) / 2
        bg = bg.crop((left, top, right, bottom))
        
        bg = bg.filter(ImageFilter.GaussianBlur(radius=50))
        dark_overlay = Image.new('RGB', (target_w, target_h), (0, 0, 0))
        bg = Image.blend(bg, dark_overlay, alpha=0.4)
        
        # Asıl resmi ortada olacak şekilde yeniden boyutlandır (yüksekliği 1000 yapıp biraz pay bırakalım)
        phone_h = 1000
        phone_w = int(phone_h * (img.width / img.height))
        phone_img = img.resize((phone_w, phone_h), Image.Resampling.LANCZOS)
        
        paste_x = (target_w - phone_w) // 2
        paste_y = (target_h - phone_h) // 2
        bg.paste(phone_img, (paste_x, paste_y))
        
        # Biraz gölge/çerçeve verelim asıl resme
        draw_bg = ImageDraw.Draw(bg)
        draw_bg.rectangle([paste_x-2, paste_y-2, paste_x+phone_w+1, paste_y+phone_h+1], outline="white", width=2)
        
        out_name = f"pc_ekran_{count}.jpg"
        bg.save(os.path.join(pc_folder, out_name), quality=95)
        count += 1

print("Tüm PC grafikleri oluşturuldu!")

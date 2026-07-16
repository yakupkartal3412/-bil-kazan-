from PIL import Image, ImageDraw, ImageFont
import random

width, height = 1024, 500
img = Image.new('RGB', (width, height))
draw = ImageDraw.Draw(img, 'RGBA')

# Hızlı dikey gradyan
for y in range(height):
    r = int(20 + (y / height) * 30)
    g = int(10 + (y / height) * 20)
    b = int(80 - (y / height) * 40)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Yıldız efekti
random.seed(42)
for _ in range(400):
    x = random.randint(0, width)
    y = random.randint(0, height)
    draw.point((x, y), fill=(255, 255, 255, 120))
    draw.point((x+1, y), fill=(255, 255, 255, 60))
    draw.point((x, y+1), fill=(255, 255, 255, 60))

try:
    font_main = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 80)
    font_sub = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 40)
except:
    font_main = ImageFont.load_default()
    font_sub = ImageFont.load_default()

main_text = "MİLYARDER TRİVİA"
sub_text = "Bilgini Sına, Zirveye Ulaş!"

try:
    tw_main = font_main.getbbox(main_text)[2] - font_main.getbbox(main_text)[0]
    tw_sub = font_sub.getbbox(sub_text)[2] - font_sub.getbbox(sub_text)[0]
except:
    tw_main = 750
    tw_sub = 450

# Metin gölgeleri ve kendileri
draw.text(((width - tw_main)/2 + 5, 170 + 5), main_text, fill="black", font=font_main)
draw.text(((width - tw_main)/2, 170), main_text, fill="#ffcc00", font=font_main)

draw.text(((width - tw_sub)/2 + 3, 270 + 3), sub_text, fill="black", font=font_sub)
draw.text(((width - tw_sub)/2, 270), sub_text, fill="white", font=font_sub)

# Şık bir neon çerçeve
draw.rectangle([3, 3, width-4, height-4], outline="#00ffff", width=5)
draw.rectangle([8, 8, width-9, height-9], outline="#cc66ff", width=2)

img.save('ozellik_grafigi.png')
print("Özellik Grafiği başarıyla oluşturuldu!")

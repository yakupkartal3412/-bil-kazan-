from PIL import Image, ImageDraw, ImageFont
import random

width, height = 512, 512
img = Image.new('RGB', (width, height))
draw = ImageDraw.Draw(img, 'RGBA')

# Daha parlak ve canlı bir arka plan gradyanı (Parlak Lacivertten Mor/Maviye)
for y in range(height):
    r = int(20 + (y / height) * 30)
    g = int(10 + (y / height) * 20)
    b = int(80 + (y / height) * 70)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Parlak yıldızlar
random.seed(42)
for _ in range(100):
    x = random.randint(0, width)
    y = random.randint(0, height)
    draw.point((x, y), fill=(255, 255, 255, 150))
    draw.point((x+1, y), fill=(255, 255, 255, 80))
    draw.point((x, y+1), fill=(255, 255, 255, 80))

# Ekstra ölçeklendirmeye gerek yok, çünkü elemanları merkeze toplayıp daraltacağız (Circle Mask'e sığacak)
try:
    # Çok daha büyük fontlar
    font_title = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 46)
    font_button_letter = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 44)
    font_button_text = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 42)
except:
    font_title = ImageFont.load_default()
    font_button_letter = ImageFont.load_default()
    font_button_text = ImageFont.load_default()

def draw_rounded_rect(draw, xy, radius, fill, outline, width):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)

# --- Üst Soru Kutusu ---
# X: 36 ile 476 arası (Genişlik 440)
# Y: 30 ile 140 arası
title_box_shadow = [40, 34, 480, 144]
draw_rounded_rect(draw, title_box_shadow, radius=20, fill=(0,0,0,180), outline=None, width=0)

title_box = [36, 30, 476, 140]
draw_rounded_rect(draw, title_box, radius=20, fill='#330066', outline='#00ffff', width=5)

title_box_inner = [42, 36, 470, 134]
draw_rounded_rect(draw, title_box_inner, radius=16, fill=None, outline='#cc66ff', width=2)

# Çok kısa soru
title_text = "En sert maden?"
try:
    bbox = font_title.getbbox(title_text)
    tw = bbox[2] - bbox[0]
except:
    tw = 300

# Yazıyı tam ortaya hizala
draw.text(((width - tw)/2 + 2, 55 + 2), title_text, fill="black", font=font_title)
draw.text(((width - tw)/2, 55), title_text, fill="white", font=font_title)

# --- Şıklar ---
# Buton genişliği 400 (X: 56 ile 456 arası). Yarıçapı yuvarlak maskeye tam sığar.
buttons = [
    ("A:", "Elmas", 170),
    ("B:", "Altın", 250),
    ("C:", "Demir", 330),
    ("D:", "Yakut", 410)
]

for letter, text, y in buttons:
    # Gölge
    btn_shadow = [60, y+4, 460, y + 69]
    draw_rounded_rect(draw, btn_shadow, radius=32, fill=(0,0,0,180), outline=None, width=0)
    
    # Asıl Buton
    btn_box = [56, y, 456, y + 65]
    draw_rounded_rect(draw, btn_box, radius=32, fill='#001a66', outline='#ffcc00', width=4)
    
    # İç Çerçeve (Parlaklık için)
    btn_box_inner = [62, y+5, 450, y + 60]
    draw_rounded_rect(draw, btn_box_inner, radius=28, fill=None, outline='#6699ff', width=2)
    
    # Harfler
    draw.text((92, y + 12), letter, fill="black", font=font_button_letter)
    draw.text((90, y + 10), letter, fill="#FFCC00", font=font_button_letter)
    
    # Metin
    draw.text((162, y + 12), text, fill="black", font=font_button_text)
    draw.text((160, y + 10), text, fill="white", font=font_button_text)

# Resmi direkt assets'in içine kaydediyoruz
img.save('assets/images/mukemmel_ikon.png')
print("Daha büyük ve parlak ikon başarıyla oluşturuldu!")

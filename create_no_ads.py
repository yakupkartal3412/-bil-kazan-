from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

size = 512
img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
draw = ImageDraw.Draw(img)

# Try to load a bold font
try:
    font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 200)
except Exception as e:
    print("Font not found:", e)
    font = ImageFont.load_default()

text = "ADS"
# Get text size
bbox = draw.textbbox((0, 0), text, font=font)
tw = bbox[2] - bbox[0]
th = bbox[3] - bbox[1]

text_x = (size - tw) / 2
text_y = (size - th) / 2 - 40

# Add a slight black drop shadow/stroke for visibility
shadow_color = (0, 0, 0, 255)
stroke_width = 8
for dx in range(-stroke_width, stroke_width+1, 2):
    for dy in range(-stroke_width, stroke_width+1, 2):
        draw.text((text_x + dx, text_y + dy), text, fill=shadow_color, font=font)

# Draw white text
draw.text((text_x, text_y), text, fill=(255, 255, 255, 255), font=font)

outline_width = 50
margin = 20

# Draw red circle outline
draw.ellipse((margin, margin, size-margin, size-margin), outline="#D31111", width=outline_width)

# Draw diagonal line (from top left to bottom right or top right to bottom left)
# Standard "no" sign is top left to bottom right
draw.line((margin + int(outline_width*0.8), margin + int(outline_width*0.8), size-margin - int(outline_width*0.8), size-margin - int(outline_width*0.8)), fill="#D31111", width=outline_width)

# Save as antialiased high quality
img = img.resize((256, 256), Image.Resampling.LANCZOS)
img.save("assets/images/no_ads_vip_icon.png")

# Also copy it to artifacts for user to see
img.save("C:/Users/lenovo/.gemini/antigravity/brain/0661b7f5-a251-43a2-8831-d00c6d5b0aa7/transparent_ads.png")

print("SUCCESS")

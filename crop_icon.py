from rembg import remove
from PIL import Image
import os

input_path = 'C:/Users/lenovo/.gemini/antigravity/brain/0661b7f5-a251-43a2-8831-d00c6d5b0aa7/no_ads_vip_icon_1784408383890.png'
output_path = 'assets/images/no_ads_vip_icon.png'
artifact_path = 'C:/Users/lenovo/.gemini/antigravity/brain/0661b7f5-a251-43a2-8831-d00c6d5b0aa7/transparent_ads.png'

print('Loading image...')
input_img = Image.open(input_path)

print('Removing background...')
output_img = remove(input_img)

# Crop to bounding box to fit the circle perfectly
bbox = output_img.getbbox()
if bbox:
    output_img = output_img.crop(bbox)
    # Ensure it is a square (optional, but good for CircleAvatar)
    w, h = output_img.size
    size = max(w, h)
    new_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    new_img.paste(output_img, ((size - w) // 2, (size - h) // 2))
    output_img = new_img

output_img.save(output_path)
output_img.save(artifact_path)
print('SUCCESS')

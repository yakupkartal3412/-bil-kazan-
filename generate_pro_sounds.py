import wave, struct, math, os

def make_wav(filename, duration, type='sine', vol=0.5):
    os.makedirs('assets/sounds', exist_ok=True)
    sample_rate = 44100
    with wave.open(f'assets/sounds/{filename}', 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sample_rate)
        
        for i in range(int(sample_rate * duration)):
            t = float(i) / sample_rate
            value = 0
            
            if type == 'pro_correct': 
                # Çok profesyonel TV yarışma zili (C5, E5, G5, C6 Akoru)
                # Yankılı ve zengin bir vibrafon sesi
                f1, f2, f3, f4 = 523.25, 659.25, 783.99, 1046.50
                env1 = math.exp(-2*t)
                env2 = math.exp(-4*t)
                
                v1 = math.sin(2 * math.pi * f1 * t) * env1
                v2 = math.sin(2 * math.pi * f2 * t) * env1
                v3 = math.sin(2 * math.pi * f3 * t) * env1
                v4 = math.sin(2 * math.pi * f4 * t) * env2
                
                # Ekstra parlaklık için harmonikler
                v5 = math.sin(2 * math.pi * (f1*2) * t) * env2 * 0.5
                
                value = (v1 + v2 + v3 + v4 + v5) / 4.5
                
            elif type == 'pro_wrong':
                # Profesyonel boğuk televizyon buzzer'ı
                env = 1.0 if t < 0.3 else math.exp(-8*(t-0.3))
                f_base = 110
                # Çift testere dişi dalga (Daha dolgun bir cızırtı/buzzer hissi verir)
                saw1 = 2 * (t * f_base - math.floor(t * f_base + 0.5))
                saw2 = 2 * (t * (f_base*1.02) - math.floor(t * (f_base*1.02) + 0.5))
                
                # Biraz kare dalga ile kaba bir distorsiyon ekleyelim
                sq = 1 if math.sin(2 * math.pi * 90 * t) > 0 else -1
                
                value = ((saw1 + saw2 + (sq*0.5)) / 2.5) * env
                
            elif type == 'pro_walk_away':
                # Oyundan çekilme (Yükselen arp glissandosu ve final akoru)
                notes = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99, 1046.50]
                total_notes = len(notes)
                time_per_note = duration / total_notes
                idx = int(t / time_per_note)
                if idx >= total_notes: idx = total_notes - 1
                
                freq = notes[idx]
                # Her nota kendi içinde hafif söner
                env = math.exp(-4*(t % time_per_note))
                
                # Final akorunu sona ekle
                if t > duration - 1.0:
                    env_final = math.exp(-2*(t - (duration - 1.0)))
                    v_f1 = math.sin(2 * math.pi * 523.25 * t) * env_final
                    v_f2 = math.sin(2 * math.pi * 659.25 * t) * env_final
                    value = (math.sin(2 * math.pi * freq * t) * env) + ((v_f1+v_f2)/2)
                else:
                    value = math.sin(2 * math.pi * freq * t) * env

            value *= vol
            
            # Kırpılmayı önleme
            if value > 1.0: value = 1.0
            if value < -1.0: value = -1.0
                
            data = struct.pack('<h', int(value * 32767.0))
            w.writeframesraw(data)

print("Profesyonel Telifsiz Sesler Sentezleniyor...")
make_wav('correct.wav', 2.0, type='pro_correct', vol=0.9)
make_wav('wrong.wav', 1.0, type='pro_wrong', vol=0.8)
make_wav('walk_away.wav', 3.0, type='pro_walk_away', vol=0.9)
print("Sentez Başarılı!")

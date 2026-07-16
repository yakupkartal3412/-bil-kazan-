import wave
import math
import struct
import random

sample_rate = 44100

def write_wav(filename, samples):
    with wave.open(filename, 'w') as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        for v in samples:
            # clamp to valid 16-bit PCM range
            v = max(-32767, min(32767, int(v)))
            f.writeframes(struct.pack('<h', v))

print("Generating premium click.wav...")
# 1. Premium Click: Soft percussion / bubble pop
duration_click = 0.1
samples_click = []
for i in range(int(sample_rate * duration_click)):
    t = i / sample_rate
    # pitch drops rapidly for a satisfying "pop" or "click"
    freq = 600 * math.exp(-t * 60) 
    env = math.exp(-t * 40)
    val = math.sin(2.0 * math.pi * freq * t)
    samples_click.append(val * env * 20000)
write_wav('assets/audio/click.wav', samples_click)

print("Generating premium correct.wav...")
# 2. Premium Correct: Major Chord Chime (C major: C5, E5, G5, C6) + Tremolo
duration_correct = 1.5
samples_correct = []
# C major chord frequencies
freqs = [523.25, 659.25, 783.99, 1046.50]
for i in range(int(sample_rate * duration_correct)):
    t = i / sample_rate
    # fast attack, slow smooth release (bell-like)
    env = (1.0 - math.exp(-t * 30)) * math.exp(-t * 2.5)
    val = 0
    for f in freqs:
        # fundamental + small harmonic
        val += math.sin(2.0 * math.pi * f * t) + 0.2 * math.sin(2.0 * math.pi * f * 2 * t)
    # add some shimmer/tremolo
    tremolo = 1.0 + 0.1 * math.sin(2.0 * math.pi * 10 * t)
    val = (val / (len(freqs) * 1.2)) * tremolo
    samples_correct.append(val * env * 28000)
write_wav('assets/audio/correct.wav', samples_correct)

print("Generating premium wrong.wav...")
# 3. Premium Wrong: Deep dissonant pitch-drop
duration_wrong = 0.8
samples_wrong = []
for i in range(int(sample_rate * duration_wrong)):
    t = i / sample_rate
    # Pitch drop
    freq1 = 250 * math.exp(-t * 4)
    freq2 = 265 * math.exp(-t * 4)
    env = (1.0 - math.exp(-t * 50)) * math.exp(-t * 5)
    val1 = math.sin(2.0 * math.pi * freq1 * t)
    val2 = math.sin(2.0 * math.pi * freq2 * t)
    val = (val1 + val2) / 2.0
    # Soft clipping/distortion to make it sound like a buzzer
    # polynomial approximation for smooth clipping
    val = max(-1.0, min(1.0, val * 3.0))
    val = val - (val ** 3) / 3.0
    samples_wrong.append(val * env * 28000)
write_wav('assets/audio/wrong.wav', samples_wrong)

print("Premium sounds generation complete!")

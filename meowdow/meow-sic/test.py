import librosa
print("test")
# import json

# audio_path = "C:/Users/Schezo/Desktop/Meowdow/meowdow/meow-sic/bossmusic.wav"

# # Load audio
# y, sr = librosa.load(audio_path)

# # Beat tracking
# tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)

# # Convert frames → time
# beat_times = librosa.frames_to_time(beat_frames, sr=sr)

# print(f"Detected BPM: {tempo}")
# print(beat_times)

# # Save to file for Godot
# with open("beats.json", "w") as f:
#     json.dump(beat_times.tolist(), f)
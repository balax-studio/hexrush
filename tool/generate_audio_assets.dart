import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() async {
  final audioDir = Directory('assets/audio');
  if (!audioDir.existsSync()) {
    audioDir.createSync(recursive: true);
  }

  print('Synthesizing HexRush Organic Audio Suite...');

  // 1. UI & Tactile SFX
  _generateWav('assets/audio/tap.wav', _generateTapSound());
  _generateWav('assets/audio/build.wav', _generateBuildSound());
  _generateWav('assets/audio/conquer.wav', _generateConquerSound());
  _generateWav('assets/audio/harvest.wav', _generateHarvestSound());
  _generateWav('assets/audio/upgrade.wav', _generateUpgradeSound());
  _generateWav('assets/audio/horn.wav', _generateHornSound());
  _generateWav('assets/audio/market.wav', _generateMarketSound());
  _generateWav('assets/audio/frenzy.wav', _generateFrenzySound());
  _generateWav('assets/audio/demolish.wav', _generateDemolishSound());
  _generateWav('assets/audio/reward.wav', _generateRewardSound());
  _generateWav('assets/audio/season_change.wav', _generateSeasonChangeSound());
  _generateWav('assets/audio/error.wav', _generateErrorSound());

  // 2. Relaxing Chill Steppe Background Music (Loopable 32-second track)
  _generateWav('assets/audio/steppe_chill_loop.wav', _generateSteppeChillMusic());

  print('Audio Suite Generation Complete! 13 assets generated in assets/audio/');
}

void _generateWav(String path, List<double> samples, {int sampleRate = 44100, int channels = 1}) {
  final byteData = _encodeWav(samples, sampleRate: sampleRate, channels: channels);
  File(path).writeAsBytesSync(byteData.buffer.asUint8List());
  print('Generated $path (${samples.length / sampleRate}s, ${byteData.lengthInBytes} bytes)');
}

ByteData _encodeWav(List<double> samples, {int sampleRate = 44100, int channels = 1}) {
  final int numSamples = samples.length;
  final int subChunk2Size = numSamples * channels * 2; // 16-bit
  final int chunkSize = 36 + subChunk2Size;
  final ByteData byteData = ByteData(44 + subChunk2Size);

  // RIFF header
  byteData.setUint8(0, 0x52); // 'R'
  byteData.setUint8(1, 0x49); // 'I'
  byteData.setUint8(2, 0x46); // 'F'
  byteData.setUint8(3, 0x46); // 'F'
  byteData.setUint32(4, chunkSize, Endian.little);
  byteData.setUint8(8, 0x57);  // 'W'
  byteData.setUint8(9, 0x41);  // 'A'
  byteData.setUint8(10, 0x56); // 'V'
  byteData.setUint8(11, 0x45); // 'E'

  // fmt subchunk
  byteData.setUint8(12, 0x66); // 'f'
  byteData.setUint8(13, 0x6D); // 'm'
  byteData.setUint8(14, 0x74); // 't'
  byteData.setUint8(15, 0x20); // ' '
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 = PCM)
  byteData.setUint16(22, channels, Endian.little);
  byteData.setUint32(24, sampleRate, Endian.little);
  byteData.setUint32(28, sampleRate * channels * 2, Endian.little); // ByteRate
  byteData.setUint16(32, channels * 2, Endian.little); // BlockAlign
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16)

  // data subchunk
  byteData.setUint8(36, 0x64); // 'd'
  byteData.setUint8(37, 0x61); // 'a'
  byteData.setUint8(38, 0x74); // 't'
  byteData.setUint8(39, 0x61); // 'a'
  byteData.setUint32(40, subChunk2Size, Endian.little);

  // PCM 16-bit signed samples
  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final double s = samples[i].clamp(-1.0, 1.0);
    final int intSample = (s * 32767.0).round().clamp(-32768, 32767);
    byteData.setInt16(offset, intSample, Endian.little);
    offset += 2;
  }

  return byteData;
}

// ---------------------------------------------------------------------------
// PROCEDURAL SOUND SYNTHESIS ENGINES (ORGANIC & TACTILE)
// ---------------------------------------------------------------------------

/// 1. Tap: Tactile acoustic wooden/stone click (45ms)
List<double> _generateTapSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.045).round();
  final List<double> s = List.filled(count, 0.0);
  final rand = math.Random(42);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double env = math.exp(-t * 90.0);
    final double freq = 1200.0 * math.exp(-t * 80.0) + 350.0;
    final double tone = math.sin(2.0 * math.pi * freq * t);
    final double click = (rand.nextDouble() * 2.0 - 1.0) * math.exp(-t * 220.0) * 0.5;
    s[i] = (tone * 0.7 + click) * env * 0.85;
  }
  return s;
}

/// 2. Build: Solid stone placement & wood settle (180ms)
List<double> _generateBuildSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.18).round();
  final List<double> s = List.filled(count, 0.0);
  final rand = math.Random(123);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double env1 = math.exp(-t * 28.0);
    final double thudFreq = 160.0 * math.exp(-t * 25.0) + 55.0;
    final double thud = math.sin(2.0 * math.pi * thudFreq * t);
    
    // Gravel/stone texture
    final double gravel = (rand.nextDouble() * 2.0 - 1.0) * math.exp(-t * 45.0) * 0.35;
    // Wood snap
    final double wood = math.sin(2.0 * math.pi * 480.0 * t) * math.exp(-t * 60.0) * 0.4;

    s[i] = (thud * 0.75 + gravel + wood) * env1 * 0.9;
  }
  return s;
}

/// 3. Conquer: Deep resonant steppe bass drum (Köz/Davul) + bronze bell (650ms)
List<double> _generateConquerSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.65).round();
  final List<double> s = List.filled(count, 0.0);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    // Low drum hit (75Hz -> 38Hz)
    final double drumFreq = 75.0 * math.exp(-t * 12.0) + 38.0;
    final double drumEnv = math.exp(-t * 7.5);
    final double drum = math.sin(2.0 * math.pi * drumFreq * t) + 0.3 * math.sin(4.0 * math.pi * drumFreq * t);

    // Resonant bronze gong overtone (330Hz, 664Hz, 992Hz)
    final double bellEnv = math.exp(-t * 4.2);
    final double bell = (math.sin(2.0 * math.pi * 330.0 * t) * 0.4 +
                         math.sin(2.0 * math.pi * 664.0 * t) * 0.25 +
                         math.sin(2.0 * math.pi * 992.0 * t) * 0.15) * bellEnv;

    s[i] = (drum * drumEnv * 0.7 + bell * 0.45) * 0.95;
  }
  return s;
}

/// 4. Harvest: Organic grain shaker / bamboo chime (140ms)
List<double> _generateHarvestSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.14).round();
  final List<double> s = List.filled(count, 0.0);
  final rand = math.Random(77);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double env = math.sin(math.pi * math.min(1.0, t / 0.02)) * math.exp(-t * 22.0);
    final double tone = math.sin(2.0 * math.pi * 880.0 * t) * 0.4 +
                        math.sin(2.0 * math.pi * 1320.0 * t) * 0.3;
    final double rustle = (rand.nextDouble() * 2.0 - 1.0) * 0.35;

    s[i] = (tone + rustle) * env * 0.8;
  }
  return s;
}

/// 5. Upgrade: Bronze forge anvil hammer strike with harmonic chime (480ms)
List<double> _generateUpgradeSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.48).round();
  final List<double> s = List.filled(count, 0.0);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double strikeEnv = math.exp(-t * 40.0);
    final double ringEnv = math.exp(-t * 6.5);

    // Anvil strike
    final double strike = math.sin(2.0 * math.pi * 1450.0 * t) * strikeEnv;
    // Harmonic bell chord (A5 = 880Hz, E6 = 1320Hz, A6 = 1760Hz)
    final double ring = (math.sin(2.0 * math.pi * 880.0 * t) * 0.5 +
                         math.sin(2.0 * math.pi * 1320.0 * t) * 0.35 +
                         math.sin(2.0 * math.pi * 1760.0 * t) * 0.2) * ringEnv;

    s[i] = (strike * 0.4 + ring * 0.75) * 0.9;
  }
  return s;
}

/// 6. Horn: Steppe Battle Horn / Kuray call (880ms)
List<double> _generateHornSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.88).round();
  final List<double> s = List.filled(count, 0.0);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double attack = math.min(1.0, t / 0.12);
    final double release = math.max(0.0, 1.0 - (t - 0.55) / 0.33);
    final double env = attack * release;

    // Horn pitch bend slightly upwards (220Hz -> 232Hz)
    final double f0 = 220.0 + 12.0 * math.sin(t * 3.0);
    final double vibrato = 1.0 + 0.02 * math.sin(2.0 * math.pi * 5.5 * t);
    final double f = f0 * vibrato;

    // Rich brassy harmonics (1f, 2f, 3f, 4f, 5f)
    final double brass = math.sin(2.0 * math.pi * f * t) * 0.6 +
                         math.sin(2.0 * math.pi * f * 2.0 * t) * 0.45 +
                         math.sin(2.0 * math.pi * f * 3.0 * t) * 0.35 +
                         math.sin(2.0 * math.pi * f * 4.0 * t) * 0.20 +
                         math.sin(2.0 * math.pi * f * 5.0 * t) * 0.10;

    s[i] = brass * env * 0.85;
  }
  return s;
}

/// 7. Market: Ancient bronze coins clink & barter settlement (320ms)
List<double> _generateMarketSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.32).round();
  final List<double> s = List.filled(count, 0.0);

  // Multi-coin impacts
  final coinTimes = [0.0, 0.06, 0.11];
  final coinPitches = [2400.0, 3100.0, 2750.0];

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    double sample = 0.0;

    for (int c = 0; c < 3; c++) {
      final double ct = t - coinTimes[c];
      if (ct >= 0) {
        final double cEnv = math.exp(-ct * 28.0);
        final double freq = coinPitches[c];
        sample += (math.sin(2.0 * math.pi * freq * ct) * 0.5 +
                   math.sin(2.0 * math.pi * (freq * 1.5) * ct) * 0.25) * cEnv;
      }
    }
    s[i] = sample * 0.5;
  }
  return s;
}

/// 8. Frenzy: 10x Toy Frenzy Sunburst & Rising Pentatonic Fanfare (650ms)
List<double> _generateFrenzySound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.65).round();
  final List<double> s = List.filled(count, 0.0);
  // Fast rising arpeggio: A4, C5, D5, E5, G5, A5
  final notes = [440.0, 523.25, 587.33, 659.25, 783.99, 880.0];

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final int noteIdx = (t / 0.09).floor().clamp(0, notes.length - 1);
    final double noteT = t - (noteIdx * 0.09);
    final double freq = notes[noteIdx];
    final double env = math.exp(-noteT * 14.0);

    final double tone = (math.sin(2.0 * math.pi * freq * noteT) * 0.6 +
                         math.sin(4.0 * math.pi * freq * noteT) * 0.3) * env;
    s[i] = tone * 0.8;
  }
  return s;
}

/// 9. Demolish: Stone crumbling & building deconstruction (360ms)
List<double> _generateDemolishSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.36).round();
  final List<double> s = List.filled(count, 0.0);
  final rand = math.Random(321);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double env = math.exp(-t * 9.5);
    final double lowRumble = math.sin(2.0 * math.pi * (80.0 * math.exp(-t * 6.0)) * t);
    final double debris = (rand.nextDouble() * 2.0 - 1.0) * 0.6;

    s[i] = (lowRumble * 0.55 + debris * 0.45) * env * 0.85;
  }
  return s;
}

/// 10. Reward: Ancient Tamga resonance & quest chime (580ms)
List<double> _generateRewardSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.58).round();
  final List<double> s = List.filled(count, 0.0);
  final pitches = [523.25, 659.25, 783.99, 1046.5]; // C major / A minor 7 chord

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    double sample = 0.0;

    for (int p = 0; p < pitches.length; p++) {
      final double pt = t - (p * 0.07);
      if (pt >= 0) {
        final double env = math.exp(-pt * 6.0);
        sample += math.sin(2.0 * math.pi * pitches[p] * pt) * env * 0.3;
      }
    }
    s[i] = sample * 0.85;
  }
  return s;
}

/// 11. Season Change: Whispering steppe wind & seasonal chime (950ms)
List<double> _generateSeasonChangeSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.95).round();
  final List<double> s = List.filled(count, 0.0);
  final rand = math.Random(999);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double env = math.sin(math.pi * (t / 0.95));
    // Wind noise
    final double wind = (rand.nextDouble() * 2.0 - 1.0) * 0.35;
    // Chime overtone
    final double chime = math.sin(2.0 * math.pi * 587.33 * t) * 0.3 * math.exp(-t * 3.5) +
                         math.sin(2.0 * math.pi * 880.0 * t) * 0.2 * math.exp(-t * 2.8);

    s[i] = (wind * 0.5 + chime * 0.5) * env * 0.85;
  }
  return s;
}

/// 12. Error: Low muffled wooden warning thump (130ms)
List<double> _generateErrorSound({int sampleRate = 44100}) {
  final int count = (sampleRate * 0.13).round();
  final List<double> s = List.filled(count, 0.0);

  for (int i = 0; i < count; i++) {
    final double t = i / sampleRate;
    final double env = math.exp(-t * 35.0);
    final double tone = math.sin(2.0 * math.pi * 110.0 * t) * 0.7 +
                        math.sin(2.0 * math.pi * 85.0 * t) * 0.3;
    s[i] = tone * env * 0.9;
  }
  return s;
}

// ---------------------------------------------------------------------------
// RELAXING CHILL STEPPE BACKGROUND MUSIC GENERATOR
// ---------------------------------------------------------------------------

/// Generates a peaceful, organic, meditative 32-second loopable Steppe Ambient track
/// Plucked acoustic Dombra/Kopuz notes (A-minor pentatonic), warm drone chord pad, gentle wind.
List<double> _generateSteppeChillMusic({int sampleRate = 44100}) {
  const double duration = 32.0; // 32 seconds seamless loop
  final int totalSamples = (sampleRate * duration).round();
  final List<double> mix = List.filled(totalSamples, 0.0);
  final rand = math.Random(1337);

  // A-Minor Pentatonic Frequencies (Hz)
  const double noteA2 = 110.0;
  const double noteE2 = 82.41;
  const double noteD2 = 73.42;

  // 1. Ambient Drone & Warm Steppe Wind Pad
  for (int i = 0; i < totalSamples; i++) {
    final double t = i / sampleRate;

    // Slow chord progression: A minor (0-8s) -> D minor (8-16s) -> E minor (16-24s) -> A minor (24-32s)
    double rootFreq = noteA2;
    double fifthFreq = 164.81; // E3
    if (t >= 8.0 && t < 16.0) {
      rootFreq = noteD2 * 2; // D3 = 146.83
      fifthFreq = 220.0; // A3
    } else if (t >= 16.0 && t < 24.0) {
      rootFreq = noteE2 * 2; // E3 = 164.81
      fifthFreq = 246.94; // B3
    }

    // Warm binaural sine pad
    final double padL = math.sin(2.0 * math.pi * rootFreq * t) * 0.12;
    final double padR = math.sin(2.0 * math.pi * fifthFreq * t) * 0.08;
    final double subDrone = math.sin(2.0 * math.pi * (rootFreq * 0.5) * t) * 0.14;

    // Gentle steppe breeze whisper (filtered pink-ish noise)
    final double windNoise = (rand.nextDouble() * 2.0 - 1.0) * 0.025;
    final double windSwell = (0.5 + 0.5 * math.sin(2.0 * math.pi * (1.0 / 16.0) * t));

    mix[i] += (padL + padR + subDrone + windNoise * windSwell);
  }

  // 2. Dombra / Plucked Harp Melody Sequence (Chill Pentatonic Phrasing)
  // Pair of (timeInSeconds, noteFrequency, velocity)
  final melodyNotes = <List<double>>[
    // Phrase 1 (A Minor)
    [0.5, 220.0, 0.45],  // A3
    [1.5, 261.63, 0.40], // C4
    [2.5, 293.66, 0.42], // D4
    [4.0, 329.63, 0.48], // E4
    [5.5, 293.66, 0.35], // D4
    [6.5, 220.0, 0.38],  // A3

    // Phrase 2 (D Minor exploration)
    [8.5, 293.66, 0.45], // D4
    [9.5, 349.23, 0.42], // F4
    [11.0, 392.0, 0.46], // G4
    [12.5, 440.0, 0.50], // A4
    [14.0, 392.0, 0.38], // G4
    [15.0, 293.66, 0.36], // D4

    // Phrase 3 (E Minor / Mystic Mountain)
    [16.5, 329.63, 0.46], // E4
    [17.5, 392.0, 0.42],  // G4
    [18.5, 440.0, 0.45],  // A4
    [20.0, 523.25, 0.52], // C5
    [21.5, 440.0, 0.40],  // A4
    [22.5, 329.63, 0.38], // E4

    // Phrase 4 (Resolution back to A Minor Steppe)
    [24.5, 440.0, 0.48],  // A4
    [25.5, 392.0, 0.40],  // G4
    [26.5, 329.63, 0.42], // E4
    [28.0, 293.66, 0.38], // D4
    [29.5, 261.63, 0.35], // C4
    [30.5, 220.0, 0.42],  // A3
  ];

  for (final note in melodyNotes) {
    final double startTime = note[0];
    final double freq = note[1];
    final double vel = note[2];

    final int startSample = (startTime * sampleRate).round();
    const double noteDuration = 3.5; // Long acoustic string decay
    final int noteSamples = (noteDuration * sampleRate).round();

    for (int j = 0; j < noteSamples; j++) {
      final int targetIdx = (startSample + j) % totalSamples;
      final double nt = j / sampleRate;

      // Acoustic string pluck envelope (sharp attack, exponential body decay)
      final double env = math.exp(-nt * 2.2);

      // Acoustic harmonics with slight inharmonicity (Dombra/Kopuz simulation)
      final double stringSound =
          math.sin(2.0 * math.pi * freq * nt) * 0.65 +
          math.sin(2.0 * math.pi * (freq * 2.01) * nt) * 0.30 +
          math.sin(2.0 * math.pi * (freq * 3.02) * nt) * 0.15 +
          math.sin(2.0 * math.pi * (freq * 4.04) * nt) * 0.08;

      mix[targetIdx] += stringSound * env * vel * 0.55;
    }
  }

  // Master Normalization and Soft Limiting
  double maxPeak = 0.0;
  for (final s in mix) {
    if (s.abs() > maxPeak) maxPeak = s.abs();
  }
  if (maxPeak > 0.0) {
    final double normFactor = 0.88 / maxPeak;
    for (int i = 0; i < totalSamples; i++) {
      mix[i] *= normFactor;
    }
  }

  return mix;
}

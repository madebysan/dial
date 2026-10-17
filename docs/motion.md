# Motion

Dial uses the calm, frequently used tool lane from apply-motion, implemented with native SwiftUI. There are no new dependencies. Motion confirms an action or connects two states; it does not delay playback, selection or search.

| Area | Motion | Reduced motion |
|---|---|---|
| Play/pause and grid/list icons | Fixed slot; 250 ms crossfade with up to 2 pt blur and 0.25 scale on the hidden glyph. Reversals retarget existing views. | Swap state without custom blur or scaling. |
| Bookmark activation | 150 ms fill change, 350 ms compression/settle, eight tiny particles up to 20 pt from the star over 600 ms. | State/fill update; no pop or particles. |
| Bookmark removal | Reverse fill; no new burst. | Direct state update. |
| Grid/list content | 160 ms opacity transition. | Immediate switch. |
| Profile and timer disclosures | 220 ms eased expansion/collapse. | Immediate custom disclosure changes. |
| Tuner | Existing 600 ms frequency motion retained. | Direct frequency update. |

System sheets, the trigger-anchored volume popover, segmented controls and switches retain their existing native behavior. Search and filtering remain immediate. As of 0.10.0, bookmark actions live in station details and list rows. Bookmark motion is triggered by changes rather than appearance, so opening an already-saved station does not replay a celebration. All custom bursts are finite and have no repeating timer or ambient loop.

`DialMotion.swift` owns the timing set, fixed-slot symbol swap, bookmark symbol and shared Reduce Motion reader. The reader respects the system preference. Debug UI tests may additionally force the custom reduced-motion path with `--ui-testing --reduce-motion`; this does not change simulator or device accessibility settings.

## Original 0.9.0 verification

The same standard interaction sequence was recorded before and after at normal speed on the dedicated iPhone 17 Pro simulator, with isolated test state and muted volume. Standard/reduced runs exercised repeated taps, bookmark activation/removal, play/pause, both disclosures, grid/list changes and failed playback. Use separate taps for reversal checks: XCTest's double-tap gesture was coalesced on these controls in the baseline and does not represent two independent activations.

Frame strips of bookmark changes, play/pause, grid/list and profile disclosure were visually inspected. Reduced-motion frames showed no bookmark particles or pop. The capture is visual evidence, not a frame-time benchmark; no Instruments or dropped-frame performance claim is made. The reduced-motion launch override verifies custom behavior, not every system-level animation or external keyboard interaction.

The ten-test UI regression run passed. After the station-identity refinement, all three motion tests passed again against final source, including restoring a saved station. See regression summary and final motion summary. All recordings and tests ran with silent simulator playback; the app closed after teardown.

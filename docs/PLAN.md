# overshoot — plan

## What this is

A photo-culling tool for Franklin's event/travel photography. He overshoots
(thousands of RAWs per shoot) and existing culling apps don't have automation
built in. overshoot ingests a folder of RAWs, groups them into bursts, and
provides a fast picking UI. Picks export as XMP sidecars so they round-trip
into the existing Photo Mechanic / Lightroom workflow.

Side project. Single user, local disk, one shoot at a time.

## Workflow this slots into

- Camera: Canon (CR3 RAWs)
- Dump memory card → folder on disk → point overshoot at it
- Cull in overshoot → export XMP sidecars
- Photo Mechanic reads the sidecars; final edits in Lightroom

## v1 scope (KISS)

Burst grouping and a usable picking UI. **Not** in v1: face detection,
dynamic-range scoring, any ML filter. Those come once v1 is solid.

## Data model

SQLite at `<shoot-folder>/.overshoot/db.sqlite`.

```
photos(id, filename, captured_at, file_size, burst_id, picked, preview_path)
bursts(id, started_at, ended_at, photo_count)
shoot(gap_seconds, ...)   -- single-row config table
```

## Layout on disk

```
<shoot-folder>/
  IMG_0001.CR3
  IMG_0002.CR3
  ...
  .overshoot/
    db.sqlite
    previews/
      IMG_0001.jpg     # embedded JPG preview extracted from CR3
      ...
```

## Ingest pipeline

CLI: `overshoot ingest <folder>`

1. Scan folder for `*.CR3`
2. For each new file: read EXIF timestamp, extract embedded JPG preview to
   `.overshoot/previews/<basename>.jpg`, insert `photos` row
3. Burst grouping: sort by `captured_at`, split where gap > `gap_seconds`,
   write `bursts` rows
4. Re-runnable: skip files already in DB. Changing `gap_seconds` only
   re-runs step 3, not preview extraction.

## Backend

CLI: `overshoot serve <folder>` — boots FastAPI pointed at one shoot.

Endpoints:
- `GET  /api/bursts` — list of bursts with photo summaries
- `GET  /api/bursts/{id}` — full burst detail
- `POST /api/photos/{id}/pick` — toggle pick
- `POST /api/bursts/regroup` — recompute bursts with new `gap_seconds`
- `POST /api/export` — write XMP sidecars next to CR3s
- Static mount of `.overshoot/previews/` for thumbnail serving

XMP export writes `photomechanic:Tagged=True` on picks (and maybe
`photomechanic:ColorClass=1`) so Photo Mechanic sees them as tagged.

## Frontend (v1)

- Vertical list of bursts. Each burst = horizontally-scrollable thumbnail
  strip with a header (timestamp, photo count).
- Click thumbnail → larger preview overlay.
- Spacebar / click toggles pick. Picked state visible at thumbnail size.
- Top bar: numeric control for burst gap (seconds), "Re-group" button,
  "Export" button.

## Build order

1. **Phase 1 — ingest (no UI).** SQLite schema + `overshoot ingest <folder>`
   command. Verify embedded-JPG extraction works on real Canon CR3s. Output:
   working DB + previews dir.
2. **Phase 2 — API.** Replace the `/api/hello` stub with the real endpoints
   above. Smoke-test with curl.
3. **Phase 3 — UI.** Burst list, pick toggle, gap control, export button.

## Dependencies to add

Python:
- `rawpy` — CR3 embedded JPG extraction (libraw). Fallback if rawpy can't
  read CR3 reliably: shell out to `exiftool`.
- `pyexiv2` — EXIF read + XMP sidecar write
- `Pillow` — thumbnail resize (preview JPG → grid-sized thumb)

Frontend: nothing new yet for v1.

## Parking lot — v2+ ideas

- **Smarter burst detection.** Treat photo timestamps as a 1D point process.
  KDE on timestamps → find local maxima of λ(t) → assign photos to nearest
  peak. Adaptive bandwidth so faster bursts get tighter windows. Smoother
  ramp-up/ramp-down handling than hard gap.
- **Face-in-focus filter.** MediaPipe (or InsightFace) face detection;
  Laplacian variance on the face crop as sharpness score. Toggle in UI.
- **Per-burst group stats.** "Top 25% by dynamic range within burst" to catch
  mid-burst exposure adjustments. Histogram-based DR score.
- **Same-subject burst refinement.** Beyond temporal grouping — embedding
  similarity on the previews to split bursts that span subjects.
- **Photo Mechanic color classes** beyond Tagged/Untagged for finer-grained
  triage.

## Open questions (still open as of writing)

- Will `rawpy` reliably extract the embedded JPG preview from this user's
  CR3s on this machine? Phase 1 verification step.
- Burst gap default — starting at 2s, exposed as a UI control so the user
  can tune per-shoot.

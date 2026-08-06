/**
 * scripts/import-places.ts
 *
 * Loads the merged master CSV into Supabase `places` as `unreviewed`.
 * Idempotent: re-running updates existing rows by apple_id rather than duplicating.
 *
 * Run:  npx tsx scripts/import-places.ts ./data/michaelin-map-master-import.csv
 *
 * Deliberately does NOT hydrate against Google Places — that is a separate,
 * rate-limited, billable step (see scripts/hydrate-places.ts). Import first,
 * verify the row count, then hydrate.
 */

import { createClient } from '@supabase/supabase-js';
import { parse } from 'csv-parse/sync';
import { readFileSync } from 'node:fs';

const SUPABASE_URL = process.env.SUPABASE_URL!;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!; // service role: bypasses RLS

if (!SUPABASE_URL || !SERVICE_KEY) {
  throw new Error('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
}

const db = createClient(SUPABASE_URL, SERVICE_KEY);

/** CSV column shape produced by the merge step. */
interface Row {
  Name: string;
  'Place Type': string;
  Tier: string;
  Star: string;
  Status: string;
  Tags: string;
  City: string;
  Country: string;
  Town: string;
  Address: string;
  Latitude: string;
  Longitude: string;
  'Apple ID': string;
  'Source Guides': string;
  Conflict: string;
}

/** Map the CSV's display labels to the DB's enum-ish values. */
const TYPE_MAP: Record<string, string> = {
  'Restaurant': 'restaurant',
  'Bar': 'bar',
  'Food truck': 'food_truck',
  'Dessert': 'dessert',
  'Winery': 'winery',
  'Hotel': 'hotel',
  'Grocery': 'grocery',
  'Shop': 'shop',
  'Outdoors & attraction': 'outdoors',
  'Unclassified': 'unclassified',
};

const TIER_MAP: Record<string, string> = {
  'Destination': 'destination',
  'Experience': 'experience',
  'Fair': 'fair',
  'Cool': 'cool',
};

function slugify(s: string): string {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

async function main() {
  const path = process.argv[2];
  if (!path) throw new Error('Usage: tsx scripts/import-places.ts <csv-path>');

  const rows: Row[] = parse(readFileSync(path, 'utf-8'), {
    columns: true,
    skip_empty_lines: true,
  });

  console.log(`Parsed ${rows.length} rows`);

  const conflicts: string[] = [];
  const seenSlugs = new Set<string>();

  const records = rows.map((r) => {
    const visited = r.Status !== 'Not visited';
    let tier: string | null = TIER_MAP[r.Tier] ?? null;

    // Constraint: an unvisited place cannot carry a tier.
    // Drop the tier and record the conflict rather than failing the insert.
    if (tier && !visited) {
      conflicts.push(r.Name);
      tier = null;
    }

    // Slugs must be unique; disambiguate branches of the same name.
    let slug = slugify(r.Name);
    let n = 2;
    while (seenSlugs.has(slug)) slug = `${slugify(r.Name)}-${n++}`;
    seenSlugs.add(slug);

    return {
      name: r.Name.trim(),
      slug,
      place_type: TYPE_MAP[r['Place Type']] ?? 'unclassified',
      tier,
      starred: r.Star === 'Yes' && visited,
      visited,
      status: 'unreviewed' as const,
      country: r.Country || null,
      city: r.City || null,
      area: null, // derived later, Austin only
      lat: r.Latitude ? Number(r.Latitude) : null,
      lng: r.Longitude ? Number(r.Longitude) : null,
      address: r.Address || null,
      apple_id: r['Apple ID'] || null,
      source_guides: r['Source Guides'] ? r['Source Guides'].split('; ') : [],
      source: 'apple_csv' as const,
    };
  });

  // Upsert on apple_id so re-running is safe.
  const CHUNK = 100;
  for (let i = 0; i < records.length; i += CHUNK) {
    const batch = records.slice(i, i + CHUNK);
    const { error } = await db
      .from('places')
      .upsert(batch, { onConflict: 'apple_id', ignoreDuplicates: false });

    if (error) {
      console.error(`Batch ${i / CHUNK + 1} failed:`, error.message);
      process.exit(1);
    }
    console.log(`  imported ${Math.min(i + CHUNK, records.length)}/${records.length}`);
  }

  console.log(`\nDone. ${records.length} places imported as 'unreviewed'.`);

  if (conflicts.length) {
    console.log(
      `\n${conflicts.length} places had a tier but were marked Not Visited.\n` +
        `Tier was dropped. These need curator review:\n`
    );
    conflicts.forEach((c) => console.log(`  - ${c}`));
  }

  const unclassified = records.filter((r) => r.place_type === 'unclassified');
  if (unclassified.length) {
    console.log(`\n${unclassified.length} places need a place_type assigned:\n`);
    unclassified.forEach((r) => console.log(`  - ${r.name}`));
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

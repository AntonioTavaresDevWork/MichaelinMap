import { formatNumber } from '@/lib/utils'
import type { FieldReportAggregate, Question } from '@/types'

/**
 * Field reports — which questions a visitor is asked, and the arithmetic the
 * guide is allowed to show back.
 *
 * The absurdity is structural, not decorative (bible §10). None of the 38
 * questions can be answered in a way that grades the place, which is exactly
 * what lets a visitor take part without their opinion competing with the
 * curator's verdict. So nothing in this file may ever derive a score: it deals
 * in counts, means and modes of ceiling heights measured in hands.
 */

/** RN-25 — an aggregate stays hidden until the fifth answer arrives. */
export const MIN_AGGREGATE_N = 5

/** Asked per visit. Never all 38: that is a survey, not a moment of play. */
const FEWEST_ASKED = 2
const MOST_ASKED = 3

/** RN-24 — the one bounded text input in the product. The server truncates too. */
export const TEXT_ANSWER_MAX = 40

/** FNV-1a. Small and stable across browsers; not a security boundary. */
function hashSeed(value: string): number {
  let hash = 0x811c9dc5
  for (let i = 0; i < value.length; i += 1) {
    hash ^= value.charCodeAt(i)
    hash = Math.imul(hash, 0x01000193)
  }
  return hash >>> 0
}

function mulberry32(seed: number): () => number {
  let a = seed
  return () => {
    a = (a + 0x6d2b79f5) | 0
    let t = Math.imul(a ^ (a >>> 15), 1 | a)
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

/**
 * The two or three questions this visitor gets for this place.
 *
 * Seeded rather than random, because `Math.random()` would reshuffle on every
 * render and the question would change under the visitor's thumb mid-answer.
 * Seeding on place + session also means two people standing at the same table
 * are asked different things, which is what makes an aggregate worth having.
 *
 * The pool is sorted by id first so the draw depends on the questions
 * themselves, never on the order the database happened to return them in.
 */
export function sampleQuestions(questions: Question[], seed: string): Question[] {
  const pool = questions
    .filter((question) => question.active && question.weight > 0)
    .sort((a, b) => a.id.localeCompare(b.id))

  if (!pool.length) return []

  const random = mulberry32(hashSeed(seed))
  const span = MOST_ASKED - FEWEST_ASKED + 1
  const count = Math.min(pool.length, FEWEST_ASKED + Math.floor(random() * span))

  const remaining = [...pool]
  const picked: Question[] = []

  // Weighted draw without replacement. `weight` is 1 across the seed today, so
  // this is a plain shuffle until the curator decides some question earns more.
  while (picked.length < count && remaining.length) {
    const total = remaining.reduce((sum, question) => sum + question.weight, 0)
    let ticket = random() * total
    let index = remaining.length - 1

    for (let i = 0; i < remaining.length; i += 1) {
      ticket -= remaining[i].weight
      if (ticket <= 0) {
        index = i
        break
      }
    }

    picked.push(remaining[index])
    remaining.splice(index, 1)
  }

  return picked
}

export type AnswerValue = string | number | boolean | null

/** Nothing is submittable half-filled; the submit button reads this. */
export function isAnswerComplete(question: Question, value: AnswerValue): boolean {
  switch (question.input_type) {
    case 'number':
    case 'slider':
    case 'compound':
      return typeof value === 'number' && Number.isFinite(value)
    case 'yes_no':
      return typeof value === 'boolean'
    case 'text_short':
      return typeof value === 'string' && value.trim().length > 0
    default:
      // color, single_choice
      return typeof value === 'string' && value.length > 0
  }
}

function capitalise(word: string): string {
  return word.charAt(0).toUpperCase() + word.slice(1)
}

/**
 * The two labels for a question's follow-up ("Was it worth it?", "Is that good
 * or bad?").
 *
 * WHY it is a choice and not a text box: `judgment` rides along with the answer
 * and is published immediately whenever the question itself does not require
 * review. RN-24 allows exactly one unbounded text input in the product — the
 * one that goes to the queue — so a free-text follow-up would be a second one,
 * live, unmoderated. The labels come off the prompt, which either offers them
 * ("good or bad") or is a plain yes/no question.
 */
export function judgmentOptions(prompt: string): [string, string] {
  const offered = /\b([a-z]+)\s+or\s+([a-z]+)\s*\?*\s*$/i.exec(prompt.trim())
  if (offered) return [capitalise(offered[1]), capitalise(offered[2])]
  return ['Yes', 'No']
}

/**
 * How a published aggregate reads.
 *
 * Mirrors the view rather than second-guessing it: `field_report_aggregates`
 * averages `number` and `slider` only, so everything else — including
 * `compound`, whose value is a number — reports its mode instead of a mean.
 */
export function formatAggregateValue(row: FieldReportAggregate): string {
  switch (row.input_type) {
    case 'number':
    case 'slider': {
      if (row.mean_value === null) return '—'
      return formatNumber(Math.round(row.mean_value * 10) / 10)
    }
    case 'yes_no': {
      if (row.modal_value === 'true') return 'Yes'
      if (row.modal_value === 'false') return 'No'
      return '—'
    }
    default:
      return row.modal_value ?? '—'
  }
}

/** The label under a mean, kept plain: "n = 7", not "7 people said". */
export function formatSampleSize(n: number): string {
  return `n = ${formatNumber(n)}`
}

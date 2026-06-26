import { ChecklistRuleResult } from "./checklistRules";

const impactWeight = {
  Low: 30,
  Medium: 60,
  High: 90,
};

const difficultyPenalty = {
  Easy: 5,
  Medium: 15,
  Hard: 25,
};

export function calculatePriorityScore(rule: ChecklistRuleResult): number {
  const impact = impactWeight[rule.impact];
  const confidence = rule.confidence * 100;
  const urgency = rule.urgency * 100;
  const penalty = difficultyPenalty[rule.difficulty];

  const score =
    impact * 0.4 +
    confidence * 0.3 +
    urgency * 0.3 -
    penalty;

  return Math.max(0, Math.min(100, Math.round(score)));
}

export function calculateRevenueLift(currentRevenue: number, liftPercent: number): number {
  if (!currentRevenue || currentRevenue <= 0) return 0;
  return Math.round(currentRevenue * liftPercent);
}
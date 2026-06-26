export type Difficulty = "Easy" | "Medium" | "Hard";
export type Impact = "Low" | "Medium" | "High";

export type ChecklistMetrics = {
  revenue: number;
  sessions: number;
  conversionRate: number;
  bounceRate: number;
  directTrafficRate: number;
  productViewSessions: number;
  addToCartSessions: number;
  checkoutSessions: number;
  purchaseSessions: number;
  avgSessionDuration: number;
  maxPageBounceRate: number;
};

export type ChecklistRuleResult = {
  ruleId: string;
  title: string;
  reason: string;
  difficulty: Difficulty;
  impact: Impact;
  confidence: number;
  urgency: number;
  revenueLiftPercent: number;
};

export function evaluateChecklistRules(metrics: ChecklistMetrics): ChecklistRuleResult[] {
  const rules: ChecklistRuleResult[] = [];

  if (metrics.bounceRate > 70) {
    rules.push({
      ruleId: "high_bounce_rate",
      title: "Improve landing page experience",
      reason: `Bounce rate is ${metrics.bounceRate.toFixed(1)}%, which means many users are leaving without engaging.`,
      difficulty: "Medium",
      impact: "High",
      confidence: 0.85,
      urgency: 0.8,
      revenueLiftPercent: 0.04,
    });
  }

  if (metrics.conversionRate < 2 && metrics.sessions > 0) {
    rules.push({
      ruleId: "low_conversion_rate",
      title: "Optimize checkout flow",
      reason: `Conversion rate is ${metrics.conversionRate.toFixed(1)}%, which is below the healthy benchmark of 2%.`,
      difficulty: "Medium",
      impact: "High",
      confidence: 0.9,
      urgency: 0.9,
      revenueLiftPercent: 0.06,
    });
  }

  if (metrics.productViewSessions > 0 && metrics.purchaseSessions / metrics.productViewSessions < 0.03) {
    rules.push({
      ruleId: "high_product_views_low_purchase",
      title: "Optimize product pages",
      reason: `Product views are high, but purchases are low. Improve product descriptions, images, pricing clarity, and reviews.`,
      difficulty: "Medium",
      impact: "High",
      confidence: 0.8,
      urgency: 0.75,
      revenueLiftPercent: 0.05,
    });
  }

  if (metrics.checkoutSessions > 0 && metrics.purchaseSessions / metrics.checkoutSessions < 0.6) {
    rules.push({
      ruleId: "checkout_dropoff",
      title: "Reduce checkout drop-off",
      reason: `Many users are reaching checkout but not completing purchase. Add UPI, COD, EMI, trust badges, and simplify payment steps.`,
      difficulty: "Hard",
      impact: "High",
      confidence: 0.88,
      urgency: 0.95,
      revenueLiftPercent: 0.08,
    });
  }

  if (metrics.directTrafficRate < 10 && metrics.sessions > 0) {
    rules.push({
      ruleId: "low_direct_traffic",
      title: "Increase brand awareness",
      reason: `Direct traffic is only ${metrics.directTrafficRate.toFixed(1)}%, which suggests weak brand recall.`,
      difficulty: "Medium",
      impact: "Medium",
      confidence: 0.7,
      urgency: 0.5,
      revenueLiftPercent: 0.025,
    });
  }

  if (metrics.maxPageBounceRate > 70) {
    rules.push({
      ruleId: "top_page_high_exit",
      title: "Add stronger CTAs on top pages",
      reason: `One or more top pages have high bounce rate. Add clearer CTAs, offers, forms, or product links.`,
      difficulty: "Easy",
      impact: "Medium",
      confidence: 0.75,
      urgency: 0.7,
      revenueLiftPercent: 0.03,
    });
  }

  return rules;
}
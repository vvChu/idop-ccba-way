# Opportunities Automation Flows (Pseudo-code)

<!-- Added reference to expressions documentation -->
> Detailed Power Automate expression snippets will be maintained (planned) in `docs/reporting/flow-expressions.md`.

## 1. Recalculate InfluenceScore & AdjustedProbability

Trigger: Item added/modified in OpportunityStakeholders OR change Stage/Probability in Opportunities.

```
FETCH stakeholders = all OpportunityStakeholders WHERE OpportunityId = current.OpportunityId
influenceScore = 0
FOR each s IN stakeholders:
  supportFactor = SWITCH(s.SupportLevel, {"Champion":1.2,"Supportive":1.0,"Neutral":0.7,"Concerned":0.4,"Opposed":0.1}, 0.7)
  engagementFactor = SWITCH(s.EngagementStatus,{"Active":1.0,"Passive":0.6,"Unresponsive":0.3},0.6)
  influenceScore += s.InfluenceWeight * supportFactor * engagementFactor
UPDATE Opportunities.InfluenceScore

baseProb = Opportunities.Probability (fallback default by Stage if null)
riskAdj = 1.0
IF influenceScore < 30 THEN riskAdj -= 0.15
IF EXISTS stakeholder with SupportLevel="Opposed" AND InfluenceWeight>=4 THEN riskAdj -= 0.1 (add RiskFlag StakeholderOpposition)
IF missing critical roles THEN riskAdj -= 0.1 (add RiskFlag MissingRoles)
AdjustedProbability = MAX(0, MIN(1, baseProb * riskAdj))
UPDATE Opportunities.AdjustedProbability
```

## 2. Update ServiceMixSummary

Trigger: Item added/updated/deleted in OpportunityServices.

```
FETCH services GROUP BY ServiceType: {count, wonCount}
summary = JOIN(each group => ServiceType+":"+count+"("+wonCount+"W)" , "; ")
UPDATE Opportunities.ServiceMixSummary
```

## 3. Cross-sell Suggestion Draft

Trigger: OpportunityService status changes to Won.

```
IF Opportunity has other ServiceTypes in catalog missing:
  SELECT top 1-2 complementary services (taxonomy relation rules - future)
  CREATE draft OpportunityServices rows with Status="Pending" Source="CrossSellSuggestion"
```

## 4. Stage Progress Validation

Trigger: Stage change in Opportunities.

```
required = MAP Stage -> required fields (eg Proposal: Probability, InfluenceScore; Negotiation: DecisionMaker present)
IF any missing -> revert Stage + add RiskFlag DataGap + notify Owner
```

## 5. Stakeholder Coverage Monitor (Scheduled Daily)

```
FOR each open Opportunity Stage IN {Proposal,Negotiation}:
  IF missing Decision Maker OR Finance OR Technical -> add/keep RiskFlag MissingRoles
  ELSE remove flag if previously set
```

## 6. Influence Alerting

Trigger: InfluenceScore recompute.

```
IF Stage >= Proposal AND InfluenceScore < 30 -> send advisory to Owner
IF InfluenceScore dropped >20% vs last snapshot -> escalate to Manager
```


## 7. Velocity Tracking & StageHistory Snapshot

```
Nightly: For each Active Opportunity, increment StageDayCounter++
On Stage change: write (OpportunityId, FromStage, ToStage, ChangedBy, ChangedDate, DaysInPrevStage) to OpportunityStageHistory list
Power BI and analytics use OpportunityStageHistory for velocity metrics
```

### StageHistory Snapshot Export

> Use script: `tools/scripts/snapshots/export-stagehistory-snapshot.ps1` to export the OpportunityStageHistory list to CSV for reporting/analytics.

**Fields:** OpportunityId, FromStage, ToStage, ChangedBy, ChangedDate, DaysInPrevStage

## 8. Data Completeness Flagging

```
Compute IsLifecycleCompliant per Opportunity nightly; expose as calculated column (or list field) for KPI DataCompleteness
```

## Implementation Notes
- Power Automate flows preferred (SharePoint triggers) for low-code; complex logic can be in an Azure Function later.
- Use batching where possible to reduce API call volume (Update summary + influence in single run if both triggered closely).

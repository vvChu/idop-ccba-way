# Opportunity KPI Model

## Fact & Dimension Tables
- FactOpportunityService (source: OpportunityServices list)
  - Keys: OpportunityId (lookup), ServiceCatalogId (lookup)
  - Measures base: EstimatedValue, Probability, AdjustedProbability
- DimOpportunity (Opportunities list)
  - Attributes: Stage, InfluenceScore, RiskFlags, ServiceMixSummary
- DimService (ServiceCatalog list)
- DimStakeholderRole (taxonomy: CCBA_VaiTroLienHe)
- BridgeOpportunityStakeholder (OpportunityStakeholders list)

## Core Measures (DAX)

```DAX
PipelineTotalValue := 
CALCULATE(
  SUM(FactOpportunityService[EstimatedValue]),
  NOT DimOpportunity[Stage] IN {"Won","Lost"}
)

AdjustedForecast := 
SUMX(
  FactOpportunityService,
  FactOpportunityService[EstimatedValue] * FactOpportunityService[AdjustedProbability]
)

WinRate := 
DIVIDE(
  CALCULATE(COUNTROWS(DimOpportunity), DimOpportunity[Stage] = "Won"),
  CALCULATE(COUNTROWS(DimOpportunity), DimOpportunity[Stage] IN {"Won","Lost"})
)

CrossSellIndex := 
VAR ServicePerOpp = 
  ADDCOLUMNS(
    SUMMARIZE(FactOpportunityService, FactOpportunityService[OpportunityId]),
    "ServiceCount", CALCULATE(DISTINCTCOUNT(FactOpportunityService[ServiceCatalogId]))
  )
VAR MultiServiceOpp = FILTER(ServicePerOpp, [ServiceCount] > 1)
RETURN
DIVIDE(
  COUNTROWS(MultiServiceOpp),
  CALCULATE(COUNTROWS(DimOpportunity), DimOpportunity[Stage] = "Won")
)

InfluenceCoverage := 
AVERAGEX(
  ADDCOLUMNS(
    SUMMARIZE(DimOpportunity, DimOpportunity[OpportunityId]),
    "HasAll", IF([HasDecisionMaker] = 1 && [HasFinance] = 1 && [HasTechnical] = 1, 1, 0)
  ),
  [HasAll]
)

StakeholderRiskCount := 
CALCULATE(
  COUNTROWS(BridgeOpportunityStakeholder),
  BridgeOpportunityStakeholder[SupportLevel] = "Opposed",
  BridgeOpportunityStakeholder[InfluenceWeight] >= 4
)

DataCompleteness := AVERAGE(DimOpportunity[IsLifecycleCompliant])
```

## Supporting Calculated Columns / Flags
- DimOpportunity[IsLifecycleCompliant]: evaluate stage-specific required fields
- OpportunityStakeholders derived booleans: HasDecisionMaker, HasFinance, HasTechnical via role pivot

## Suggested Visuals
1. Stage Funnel (Count & Value)
2. Service Mix Matrix (Category x Stage)
3. Influence vs AdjustedProbability Scatter
4. Stakeholder Risk Heatmap (Role vs SupportLevel weighted)
5. Cross-sell Candidate Table (Opportunities with >1 Pending service & InfluenceScore >= threshold)
6. Velocity by Stage (average days)

## Refresh & Data Flow
- Incremental pull via SharePoint list connectors
- Pre-calculation of InfluenceScore and AdjustedProbability in list reduces model complexity
- Optional: snapshot nightly to `OpportunityKpiSnapshot` (future)

## Alert Thresholds
- InfluenceScore < 30 at Proposal
- MissingDecisionMaker at Negotiation
- AdjustedProbability > 0.6 with InfluenceCoverage < 1

## Future Enhancements
- Add historical trending table
- A/B test Influence weight mappings
- Predictive scoring (regression) once 200+ won/lost records

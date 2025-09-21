# Power Automate Expressions — Opportunities Module

## 1. InfluenceScore Recalculation (Compose)
```
add(
  0,
  add(
    mul(items('Loop_Stakeholders')?['InfluenceWeight'],
        if(equals(items('Loop_Stakeholders')?['SupportLevel'],'Champion'),1.2,
        if(equals(items('Loop_Stakeholders')?['SupportLevel'],'Supportive'),1.0,
        if(equals(items('Loop_Stakeholders')?['SupportLevel'],'Neutral'),0.7,
        if(equals(items('Loop_Stakeholders')?['SupportLevel'],'Concerned'),0.4,
        if(equals(items('Loop_Stakeholders')?['SupportLevel'],'Opposed'),0.1,0.7))))),
    0)
)
```
> Wrap trong loop và cộng dồn: dùng biến số (Initialize variable InfluenceScore = 0; Set variable = add(variables('InfluenceScore'), <expression above>)).

### Engagement Factor (nếu tách):
```
if(equals(items('Loop_Stakeholders')?['EngagementStatus'],'Active'),1.0,
 if(equals(items('Loop_Stakeholders')?['EngagementStatus'],'Passive'),0.6,
 if(equals(items('Loop_Stakeholders')?['EngagementStatus'],'Unresponsive'),0.3,0.6)))
```

## 2. AdjustedProbability Calculation
```
// baseProb fallback theo Stage
if(empty(triggerOutputs()?['body/Probability']),
  if(equals(triggerOutputs()?['body/Stage'],'Lead'),0.1,
  if(equals(triggerOutputs()?['body/Stage'],'Qualified'),0.25,
  if(equals(triggerOutputs()?['body/Stage'],'Proposal'),0.5,
  if(equals(triggerOutputs()?['body/Stage'],'Negotiation'),0.65,0.1)))),
  div(triggerOutputs()?['body/Probability'],100)
)
```
Risk factor chuỗi:
```
float(mul(variables('BaseProb'),
  sub(1,
    add(
      if(less(variables('InfluenceScore'),30),0.15,0),
      if(and(equals(variables('HasOpposedHighInfluence'),true),greaterOrEquals(variables('OpposedInfluenceMax'),4)),0.1,0),
      if(equals(variables('MissingCriticalRoles'),true),0.1,0)
    )
  )
))
```

## 3. ServiceMixSummary Builder
- Initialize variable `ServiceMix` (Array)
- Append to array per service line:
```
json(concat('{"ServiceType":"', item()?['ServiceType']?['Label'], '","IsWon":', if(equals(item()?['Status'],'Won'),'true','false'),'}'))
```
- After loop Compose summary:
```
join(
  union(
    createArray(),
    select(variables('ServiceMix'),'ServiceType')
  ), '; ')
```
(Thay bằng logic nhóm nếu cần: dùng Power Fx trong Power Apps hoặc xử lý bằng Azure Function khi cần thống kê wonCount.)

## 4. Cross-sell Draft Creation Condition
```
and(
  equals(triggerOutputs()?['body/Status'],'Won'),
  greater(length(variables('ComplementaryCandidates')),0)
)
```
### Compose Draft Row (ví dụ HTTP to SharePoint API)
```
{
  "__metadata": {"type": "SP.Data.OpportunityServicesListItem"},
  "Title": concat('Draft ', variables('CandidateServiceCode')),
  "OpportunityId": triggerOutputs()?['body/ID'],
  "Status": "Pending",
  "Source": "CrossSellSuggestion"
}
```

## 5. Missing Critical Roles Detection
```
setVariable('MissingCriticalRoles', not(
  and(
    variables('HasDecisionMaker'),
    variables('HasFinance'),
    variables('HasTechnical')
  )
))
```

## 6. RiskFlags Aggregation (Text Multi)
```
join(
  union(
    createArray(),
    if(less(variables('InfluenceScore'),30),createArray('InfluenceLow'),createArray()),
    if(variables('MissingCriticalRoles'),createArray('MissingRoles'),createArray()),
    if(and(variables('HasOpposedHighInfluence'),greaterOrEquals(variables('OpposedInfluenceMax'),4)),createArray('StakeholderOpposition'),createArray())
  ),';')
```

## 7. Influence Drop Alert
```
and(
  greater(variables('PrevInfluenceScore'),0),
  greater(div(sub(variables('PrevInfluenceScore'),variables('InfluenceScore')),variables('PrevInfluenceScore')),0.2)
)
```

## 8. Velocity Stage Entry Timestamp (When Stage changes)
Store previous Stage timestamp in separate list or hidden field.
```
sub(ticks(utcNow()), ticks(triggerOutputs()?['body/StageEnteredAt']))
```
Convert ticks to days later in reporting: `div(div(sub(ticksNow, ticksEnter),10000000),86400)`.

## 9. Data Completeness Compliance Flag
```
and(
  if(equals(triggerOutputs()?['body/Stage'],'Proposal'),
     and(not(empty(body('Get_item')?['Probability'])), greater(variables('InfluenceScore'),0)), true),
  if(equals(triggerOutputs()?['body/Stage'],'Negotiation'),
     equals(variables('HasDecisionMaker'), true), true)
)
```

## Biến khởi tạo gợi ý
- `InfluenceScore` (Number = 0)
- `HasDecisionMaker` / `HasFinance` / `HasTechnical` (Boolean)
- `MissingCriticalRoles` (Boolean)
- `HasOpposedHighInfluence` (Boolean)
- `OpposedInfluenceMax` (Number = 0)
- `PrevInfluenceScore` (Number)
- `BaseProb` (Number)
- `ComplementaryCandidates` (Array)

## Ghi chú
- Giảm độ phức tạp flow bằng cách gom các phép toán trong 1 Compose rồi cập nhật 1 lần.
- Khi biểu thức quá dài, cân nhắc chuyển sang Azure Function HTTP endpoint.

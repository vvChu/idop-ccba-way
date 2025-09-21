# Checklist Bảo trì & Đồng bộ Hệ thống IDOP-CCBA-WAY

## 1. Checklist Kiểm thử Định kỳ

### 1.1 Kiểm thử Schema & Datamodel
- [ ] Chạy `node tools/scripts/validate-sp-schemas.js` để validate tất cả JSON schema
- [ ] Đối chiếu các trường trong JSON với spec.md của từng module
- [ ] Kiểm tra mapping taxonomy/termset với managed metadata fields
- [ ] Validate lookup relationships giữa các lists

### 1.2 Kiểm thử Triển khai Script
- [ ] Chạy dry-run deployment: `./tools/scripts/deploy-sp-lists-enhanced.ps1 -DryRun`
- [ ] Kiểm tra log output cho warnings/errors
- [ ] Verify default view setup cho tất cả lists
- [ ] Test list formatting application

### 1.3 Kiểm thử Tích hợp Nghiệp vụ
- [ ] Test Power Automate flows cho approval workflows
- [ ] Verify Power BI dashboards data sources
- [ ] Check Teams integration points
- [ ] Validate document management workflows

### 1.4 Kiểm thử Bảo mật & Phân quyền
- [ ] Review SharePoint permissions theo ma trận vai trò
- [ ] Test audit logging cho critical operations
- [ ] Verify data encryption cho sensitive fields
- [ ] Check compliance với internal policies

## 2. Quy trình Rà soát Đồng bộ

### 2.1 Rà soát Hàng tuần
- Kiểm tra git commits cho changes trong specs/ và datamodel/
- Review PRs theo checklist trong constitution.md
- Update tasks.md status cho completed/pending items
- Sync taxonomy changes với termstore

### 2.2 Rà soát Hàng tháng
- Full deployment test trên dev environment
- Performance testing cho critical lists
- User acceptance testing với sample data
- Documentation review và updates

### 2.3 Rà soát Hàng quý
- Security audit và penetration testing
- Compliance check với new regulations
- Technology stack updates (PnP.PowerShell, etc.)
- Backup/restore testing

## 3. Quy trình Duy trì Đồng bộ

### 3.1 Khi Thay đổi Spec
1. Update spec.md trong module tương ứng
2. Review impact trên datamodel và taxonomy
3. Update plan.md với technical changes
4. Test deployment script changes
5. Update documentation

### 3.2 Khi Thay đổi Datamodel
1. Validate JSON schema compliance
2. Update taxonomy nếu cần
3. Test lookup relationships
4. Update spec.md references
5. Run full deployment test

### 3.3 Khi Deploy Production
1. Dry-run trên staging environment
2. Backup current production state
3. Deploy with monitoring
4. Post-deployment validation
5. Update maintenance logs

## 4. Monitoring & Alerting

### 4.1 Automated Checks
- Daily schema validation via CI/CD
- Weekly deployment dry-run
- Monthly performance benchmarks
- Quarterly security scans

### 4.2 Manual Reviews
- PR reviews theo constitution checklist
- Monthly stakeholder meetings
- Quarterly architecture reviews
- Annual compliance audits

## 5. Rollback Procedures

### 5.1 Emergency Rollback
1. Identify issue và impact scope
2. Restore from backup (data + configuration)
3. Communicate với stakeholders
4. Root cause analysis
5. Preventive measures implementation

### 5.2 Gradual Rollback
1. Deploy previous version to staging
2. Test compatibility
3. Gradual user migration
4. Monitor for issues
5. Complete transition

---

*Checklist này được cập nhật định kỳ theo changes trong constitution và spec requirements.*
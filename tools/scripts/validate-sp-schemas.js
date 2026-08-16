
// Script kiểm thử schema JSON cho SharePoint Lists
const { execSync } = require('child_process');

try {
	execSync('npx -y ajv-cli validate -s datamodel/sharepoint/schemas/sp-list.schema.json -d "datamodel/sharepoint/lists/**/*.json"', { stdio: 'inherit' });
	console.log('✅ Schema validation PASSED for all lists');
} catch (e) {
	console.error('❌ Schema validation FAILED. Vui lòng kiểm tra lại các file JSON.');
	process.exit(1);
}

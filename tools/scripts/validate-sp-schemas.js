
// Script kiểm thử schema JSON cho SharePoint Lists
// Yêu cầu: npm install -g ajv-cli

const { execSync } = require('child_process');

try {
	execSync('ajv validate -s datamodel/sharepoint/schemas/sp-list.schema.json -d datamodel/sharepoint/lists/**/*.json', { stdio: 'inherit' });
	console.log('✅ Schema validation PASSED for all lists');
} catch (e) {
	console.error('❌ Schema validation FAILED. Vui lòng kiểm tra lại các file JSON.');
	process.exit(1);
}

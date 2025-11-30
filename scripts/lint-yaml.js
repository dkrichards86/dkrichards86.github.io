#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { glob } = require('glob');

async function lintYamlFiles() {
  const files = await glob('**/*.{yml,yaml}', {
    ignore: ['node_modules/**', 'vendor/**', '_site/**']
  });

  let hasErrors = false;

  for (const file of files) {
    try {
      const content = fs.readFileSync(file, 'utf8');
      yaml.load(content);
      console.log(`✓ ${file}`);
    } catch (error) {
      hasErrors = true;
      console.error(`✗ ${file}`);
      console.error(`  ${error.message}`);
    }
  }

  if (hasErrors) {
    process.exit(1);
  } else {
    console.log('\n✅ All YAML files are valid');
  }
}

lintYamlFiles().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});

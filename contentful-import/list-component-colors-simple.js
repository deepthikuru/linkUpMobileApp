/**
 * Contentful Component Colors List Script (Simple Version)
 * 
 * Lists all component colors currently in Contentful using Management API.
 * 
 * Usage:
 *   node list-component-colors-simple.js --space-id=YOUR_SPACE_ID --token=YOUR_MANAGEMENT_TOKEN
 */

const contentful = require('contentful-management');
const fs = require('fs');

// Get environment variables or command line arguments
function getConfig() {
  const args = process.argv.slice(2);
  let spaceId = process.env.CONTENTFUL_SPACE_ID;
  let token = process.env.CONTENTFUL_MANAGEMENT_TOKEN;

  args.forEach(arg => {
    if (arg.startsWith('--space-id=')) {
      spaceId = arg.split('=')[1];
    } else if (arg.startsWith('--token=')) {
      token = arg.split('=')[1];
    }
  });

  if (!spaceId || !token) {
    console.error('❌ Error: Missing required configuration');
    console.error('');
    console.error('Please provide:');
    console.error('  --space-id=YOUR_SPACE_ID --token=YOUR_MANAGEMENT_TOKEN');
    console.error('');
    console.error('Or set environment variables:');
    console.error('  CONTENTFUL_SPACE_ID=YOUR_SPACE_ID');
    console.error('  CONTENTFUL_MANAGEMENT_TOKEN=YOUR_TOKEN');
    console.error('');
    process.exit(1);
  }

  return { spaceId, token };
}

async function listComponentColors() {
  const { spaceId, token } = getConfig();

  console.log('🔍 Fetching Component Colors from Contentful...');
  console.log(`   Space ID: ${spaceId}`);
  console.log('');

  try {
    // Initialize Contentful client
    const client = contentful.createClient({
      accessToken: token,
    });

    // Get space and environment
    const space = await client.getSpace(spaceId);
    const environment = await space.getEnvironment('master');

    console.log('✅ Connected to Contentful');
    console.log('');

    // Fetch all component colors
    let allEntries = [];
    let skip = 0;
    const limit = 1000;
    let hasMore = true;

    while (hasMore) {
      const response = await environment.getEntries({
        content_type: 'componentColor',
        limit: limit,
        skip: skip,
      });

      allEntries = allEntries.concat(response.items);
      skip += limit;
      hasMore = response.items.length === limit;
    }

    if (allEntries.length === 0) {
      console.log('📭 No component colors found in Contentful');
      return;
    }

    console.log(`📦 Found ${allEntries.length} component color(s):`);
    console.log('');

    // Sort entries by componentId
    allEntries.sort((a, b) => {
      const idA = a.fields?.componentId?.['en-US'] || '';
      const idB = b.fields?.componentId?.['en-US'] || '';
      return idA.localeCompare(idB);
    });

    // Print table header
    console.log('┌────────────────────────────────────────────────────────────────────────────────────────────┐');
    console.log('│ Component ID                                    │ Colors                                    │');
    console.log('├────────────────────────────────────────────────────────────────────────────────────────────┤');

    // Print each entry
    allEntries.forEach(entry => {
      const componentId = entry.fields?.componentId?.['en-US'] || 'N/A';
      const colors = [];

      if (entry.fields?.backgroundColor?.['en-US']) {
        colors.push(`BG:${entry.fields.backgroundColor['en-US']}`);
      }
      if (entry.fields?.textColor?.['en-US']) {
        colors.push(`TXT:${entry.fields.textColor['en-US']}`);
      }
      if (entry.fields?.iconColor?.['en-US']) {
        colors.push(`ICON:${entry.fields.iconColor['en-US']}`);
      }
      if (entry.fields?.borderColor?.['en-US']) {
        colors.push(`BORDER:${entry.fields.borderColor['en-US']}`);
      }
      if (entry.fields?.shadowColor?.['en-US']) {
        colors.push(`SHADOW:${entry.fields.shadowColor['en-US']}`);
      }
      if (entry.fields?.gradientStartColor?.['en-US']) {
        colors.push(`GRAD-START:${entry.fields.gradientStartColor['en-US']}`);
      }
      if (entry.fields?.gradientEndColor?.['en-US']) {
        colors.push(`GRAD-END:${entry.fields.gradientEndColor['en-US']}`);
      }

      const colorsStr = colors.length > 0 ? colors.join(', ') : 'No colors set';
      const idPadded = componentId.padEnd(45);
      const colorsPadded = colorsStr.substring(0, 50).padEnd(50);
      console.log(`│ ${idPadded} │ ${colorsPadded} │`);
    });

    console.log('└────────────────────────────────────────────────────────────────────────────────────────────┘');
    console.log('');

    // Export to JSON
    const exportFile = 'component-colors-list.json';
    const exportData = allEntries.map(entry => {
      const componentId = entry.fields?.componentId?.['en-US'] || 'N/A';
      return {
        componentId,
        backgroundColor: entry.fields?.backgroundColor?.['en-US'] || null,
        textColor: entry.fields?.textColor?.['en-US'] || null,
        iconColor: entry.fields?.iconColor?.['en-US'] || null,
        borderColor: entry.fields?.borderColor?.['en-US'] || null,
        shadowColor: entry.fields?.shadowColor?.['en-US'] || null,
        gradientStartColor: entry.fields?.gradientStartColor?.['en-US'] || null,
        gradientEndColor: entry.fields?.gradientEndColor?.['en-US'] || null,
        entryId: entry.sys?.id || null,
        publishedAt: entry.sys?.publishedAt || null,
      };
    });

    fs.writeFileSync(exportFile, JSON.stringify(exportData, null, 2));
    console.log(`💾 Exported to: ${exportFile}`);
    console.log('');

    // Show summary by category
    const categories = {
      'screen-': 0,
      'text-': 0,
      'button-': 0,
      'icon-': 0,
      'snackbar-': 0,
      'input-': 0,
      'link-': 0,
      'tab-': 0,
      'menu-': 0,
      'overlay-': 0,
      'other': 0,
    };

    allEntries.forEach(entry => {
      const componentId = entry.fields?.componentId?.['en-US'] || '';
      let categorized = false;
      
      for (const [prefix, _] of Object.entries(categories)) {
        if (componentId.startsWith(prefix)) {
          categories[prefix]++;
          categorized = true;
          break;
        }
      }
      
      if (!categorized) {
        categories.other++;
      }
    });

    console.log('📊 Summary by Category:');
    Object.entries(categories).forEach(([category, count]) => {
      if (count > 0) {
        console.log(`   ${category.padEnd(15)}: ${count}`);
      }
    });
    console.log('');

  } catch (error) {
    console.error('');
    console.error('❌ Error fetching component colors:');
    console.error(error.message);
    if (error.response) {
      console.error('Response:', JSON.stringify(error.response.data, null, 2));
    }
    console.error('');
    process.exit(1);
  }
}

// Run the list command
listComponentColors();


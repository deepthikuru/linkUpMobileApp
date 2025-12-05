/**
 * Contentful Component Colors List Script
 * 
 * This script lists all component colors currently in Contentful.
 * 
 * Usage:
 *   node list-component-colors.js --space-id=YOUR_SPACE_ID --token=YOUR_TOKEN
 * 
 * Or use environment variables:
 *   CONTENTFUL_SPACE_ID=YOUR_SPACE_ID
 *   CONTENTFUL_ACCESS_TOKEN=YOUR_TOKEN (Delivery API token)
 *   node list-component-colors.js
 */

const contentful = require('contentful-management');
// Try to use contentful (Delivery API) if available, otherwise just use Management API
let contentfulDelivery;
try {
  contentfulDelivery = require('contentful');
} catch (e) {
  // contentful package not installed, will use Management API only
}

// Get environment variables or command line arguments
function getConfig() {
  const args = process.argv.slice(2);
  let spaceId = process.env.CONTENTFUL_SPACE_ID;
  let managementToken = process.env.CONTENTFUL_MANAGEMENT_TOKEN;
  let deliveryToken = process.env.CONTENTFUL_ACCESS_TOKEN;

  args.forEach(arg => {
    if (arg.startsWith('--space-id=')) {
      spaceId = arg.split('=')[1];
    } else if (arg.startsWith('--token=')) {
      managementToken = arg.split('=')[1];
      deliveryToken = arg.split('=')[1]; // Use same token for both if provided
    } else if (arg.startsWith('--management-token=')) {
      managementToken = arg.split('=')[1];
    } else if (arg.startsWith('--delivery-token=')) {
      deliveryToken = arg.split('=')[1];
    }
  });

  if (!spaceId) {
    console.error('❌ Error: Missing space ID');
    console.error('');
    console.error('Please provide:');
    console.error('  --space-id=YOUR_SPACE_ID');
    console.error('');
    process.exit(1);
  }

  // Try to use delivery token first (read-only, safer), fallback to management token
  const token = deliveryToken || managementToken;

  if (!token) {
    console.error('❌ Error: Missing access token');
    console.error('');
    console.error('Please provide:');
    console.error('  --token=YOUR_TOKEN (Delivery API token preferred)');
    console.error('  OR');
    console.error('  --management-token=YOUR_MANAGEMENT_TOKEN');
    console.error('');
    process.exit(1);
  }

  return { spaceId, token, managementToken };
}

async function listComponentColors() {
  const { spaceId, token, managementToken } = getConfig();

  console.log('🔍 Fetching Component Colors from Contentful...');
  console.log(`   Space ID: ${spaceId}`);
  console.log('');

  try {
    // Try using Delivery API first (read-only, safer)
    let useDeliveryAPI = true;
    let entries = [];

    if (token && !managementToken && contentfulDelivery) {
      // Use Delivery API
      try {
        const client = contentfulDelivery.createClient({
          space: spaceId,
          accessToken: token,
        });

        const response = await client.getEntries({
          content_type: 'componentColor',
          limit: 1000,
        });

        entries = response.items;
        console.log('✅ Using Content Delivery API');
      } catch (error) {
        console.log('⚠️  Delivery API failed, trying Management API...');
        useDeliveryAPI = false;
      }
    }

    // Fallback to Management API if Delivery API failed or management token provided
    if (!useDeliveryAPI || managementToken) {
      const client = contentful.createClient({
        accessToken: managementToken || token,
      });

      const space = await client.getSpace(spaceId);
      const environment = await space.getEnvironment('master');

      const response = await environment.getEntries({
        content_type: 'componentColor',
        limit: 1000,
      });

      entries = response.items;
      console.log('✅ Using Content Management API');
    }

    console.log('');

    if (entries.length === 0) {
      console.log('📭 No component colors found in Contentful');
      return;
    }

    console.log(`📦 Found ${entries.length} component color(s):`);
    console.log('');
    console.log('┌─────────────────────────────────────────────────────────────────────────────┐');
    console.log('│ Component ID                                    │ Colors                    │');
    console.log('├─────────────────────────────────────────────────────────────────────────────┤');

    // Sort entries by componentId
    entries.sort((a, b) => {
      const idA = a.fields?.componentId?.['en-US'] || a.sys?.id || '';
      const idB = b.fields?.componentId?.['en-US'] || b.sys?.id || '';
      return idA.localeCompare(idB);
    });

    // Group by category for better readability
    const categories = {
      'Screen Backgrounds': [],
      'Text Colors': [],
      'Button Colors': [],
      'Icon Colors': [],
      'Snackbar Colors': [],
      'Input Colors': [],
      'Link Colors': [],
      'Menu/Overlay': [],
      'Other': [],
    };

    entries.forEach(entry => {
      const componentId = entry.fields?.componentId?.['en-US'] || entry.sys?.id || 'N/A';
      const colors = [];

      if (entry.fields?.backgroundColor?.['en-US']) {
        colors.push(`BG: ${entry.fields.backgroundColor['en-US']}`);
      }
      if (entry.fields?.textColor?.['en-US']) {
        colors.push(`TXT: ${entry.fields.textColor['en-US']}`);
      }
      if (entry.fields?.iconColor?.['en-US']) {
        colors.push(`ICON: ${entry.fields.iconColor['en-US']}`);
      }
      if (entry.fields?.borderColor?.['en-US']) {
        colors.push(`BORDER: ${entry.fields.borderColor['en-US']}`);
      }
      if (entry.fields?.shadowColor?.['en-US']) {
        colors.push(`SHADOW: ${entry.fields.shadowColor['en-US']}`);
      }
      if (entry.fields?.gradientStartColor?.['en-US']) {
        colors.push(`GRAD-START: ${entry.fields.gradientStartColor['en-US']}`);
      }
      if (entry.fields?.gradientEndColor?.['en-US']) {
        colors.push(`GRAD-END: ${entry.fields.gradientEndColor['en-US']}`);
      }

      const colorsStr = colors.length > 0 ? colors.join(', ') : 'No colors set';

      // Categorize
      if (componentId.startsWith('screen-') || componentId.includes('_scaffold_background')) {
        categories['Screen Backgrounds'].push({ componentId, colorsStr });
      } else if (componentId.startsWith('text-') || componentId.includes('_text')) {
        categories['Text Colors'].push({ componentId, colorsStr });
      } else if (componentId.startsWith('button-') || componentId.includes('_button')) {
        categories['Button Colors'].push({ componentId, colorsStr });
      } else if (componentId.startsWith('icon-') || componentId.includes('_icon') || componentId.includes('_indicator')) {
        categories['Icon Colors'].push({ componentId, colorsStr });
      } else if (componentId.startsWith('snackbar-') || componentId.includes('_snackbar')) {
        categories['Snackbar Colors'].push({ componentId, colorsStr });
      } else if (componentId.startsWith('input-') || componentId.includes('_input')) {
        categories['Input Colors'].push({ componentId, colorsStr });
      } else if (componentId.startsWith('link-') || componentId.includes('_link')) {
        categories['Link Colors'].push({ componentId, colorsStr });
      } else if (componentId.includes('_menu') || componentId.includes('_barrier') || componentId.includes('_overlay')) {
        categories['Menu/Overlay'].push({ componentId, colorsStr });
      } else {
        categories['Other'].push({ componentId, colorsStr });
      }
    });

    // Print categorized list
    Object.keys(categories).forEach(category => {
      if (categories[category].length > 0) {
        console.log(`\n📁 ${category} (${categories[category].length}):`);
        categories[category].forEach(({ componentId, colorsStr }) => {
          const idPadded = componentId.padEnd(45);
          const colorsPadded = colorsStr.substring(0, 35).padEnd(35);
          console.log(`   ${idPadded} │ ${colorsPadded}`);
        });
      }
    });

    console.log('');
    console.log('└─────────────────────────────────────────────────────────────────────────────┘');
    console.log('');
    console.log(`📊 Summary: ${entries.length} total component color(s)`);

    // Export to JSON option
    const fs = require('fs');
    const exportFile = 'component-colors-list.json';
    const exportData = entries.map(entry => {
      const componentId = entry.fields?.componentId?.['en-US'] || entry.sys?.id || 'N/A';
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
      };
    });

    fs.writeFileSync(exportFile, JSON.stringify(exportData, null, 2));
    console.log(`💾 Exported to: ${exportFile}`);

  } catch (error) {
    console.error('');
    console.error('❌ Error fetching component colors:');
    console.error(error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
    console.error('');
    process.exit(1);
  }
}

// Run the list command
listComponentColors();


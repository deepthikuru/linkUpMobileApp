/**
 * Script to check what fields exist in content types
 * This helps diagnose why imports are failing
 */

const contentful = require('contentful-management');

const spaceId = 'w44htb0sb9sl';
const token = process.argv[2] || process.env.CONTENTFUL_MANAGEMENT_TOKEN;

if (!token) {
  console.error('❌ Error: Please provide token as argument or CONTENTFUL_MANAGEMENT_TOKEN env var');
  process.exit(1);
}

async function checkContentTypes() {
  try {
    console.log('🔍 Checking Content Types and Fields...');
    console.log(`   Space ID: ${spaceId}`);
    console.log('');

    const client = contentful.createClient({
      accessToken: token,
    });

    const space = await client.getSpace(spaceId);
    const environment = await space.getEnvironment('master');

    const contentTypes = await environment.getContentTypes();
    
    console.log('📋 Content Types Found:');
    console.log('');

    // Check componentColor
    const componentColorType = contentTypes.items.find(ct => ct.sys.id === 'componentColor');
    if (componentColorType) {
      console.log('✅ componentColor content type exists');
      console.log('   Fields:');
      componentColorType.fields.forEach(field => {
        console.log(`     - ${field.id} (${field.type}${field.required ? ', required' : ''})`);
      });
    } else {
      console.log('❌ componentColor content type NOT found');
    }
    console.log('');

    // Check componentText
    const componentTextType = contentTypes.items.find(ct => ct.sys.id === 'componentText');
    if (componentTextType) {
      console.log('✅ componentText content type exists');
      console.log('   Fields:');
      componentTextType.fields.forEach(field => {
        console.log(`     - ${field.id} (${field.type}${field.required ? ', required' : ''})`);
      });
      
      // Check if required fields exist
      const hasTextId = componentTextType.fields.some(f => f.id === 'textId');
      const hasText = componentTextType.fields.some(f => f.id === 'text');
      
      console.log('');
      console.log('🔍 Field Check:');
      console.log(`   textId field: ${hasTextId ? '✅ Exists' : '❌ MISSING'}`);
      console.log(`   text field: ${hasText ? '✅ Exists' : '❌ MISSING'}`);
      
      if (!hasTextId || !hasText) {
        console.log('');
        console.log('⚠️  ISSUE DETECTED: Missing required fields!');
        console.log('');
        console.log('📝 To fix this:');
        console.log('   1. Go to Contentful web interface');
        console.log('   2. Navigate to Content model');
        console.log('   3. Open "Component Text" content type');
        console.log('   4. Add missing fields:');
        if (!hasTextId) {
          console.log('      - textId (Short text, required, unique)');
        }
        if (!hasText) {
          console.log('      - text (Short text, required)');
        }
        console.log('   5. Save and publish the content type');
        console.log('   6. Run the import script again');
      }
    } else {
      console.log('❌ componentText content type NOT found');
      console.log('');
      console.log('📝 To create it:');
      console.log('   1. Go to Contentful web interface');
      console.log('   2. Navigate to Content model');
      console.log('   3. Click "Add content type"');
      console.log('   4. Name: Component Text');
      console.log('   5. API Identifier: componentText');
      console.log('   6. Add fields:');
      console.log('      - textId (Short text, required, unique)');
      console.log('      - text (Short text, required)');
      console.log('   7. Save and publish');
    }

  } catch (error) {
    console.error('');
    console.error('❌ Error checking content types:');
    console.error(`   ${error.message}`);
    if (error.response) {
      console.error(`   Status: ${error.response.status}`);
      console.error(`   Details: ${JSON.stringify(error.response.data, null, 2)}`);
    }
    process.exit(1);
  }
}

checkContentTypes();


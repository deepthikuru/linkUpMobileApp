/**
 * Simple script to test Contentful Management API token
 */

const contentful = require('contentful-management');

const spaceId = 'w44htb0sb9sl';
const token = process.argv[2] || process.env.CONTENTFUL_MANAGEMENT_TOKEN;

if (!token) {
  console.error('❌ Error: Please provide token as argument or CONTENTFUL_MANAGEMENT_TOKEN env var');
  process.exit(1);
}

async function testToken() {
  try {
    console.log('🔍 Testing token access...');
    console.log(`   Space ID: ${spaceId}`);
    console.log(`   Token: ${token.substring(0, 20)}...`);
    console.log('');

    const client = contentful.createClient({
      accessToken: token,
    });

    // Try to get the space
    const space = await client.getSpace(spaceId);
    console.log('✅ Successfully connected to Contentful!');
    console.log(`   Space Name: ${space.name}`);
    console.log('');

    // Try to get environment
    const environment = await space.getEnvironment('master');
    console.log('✅ Successfully accessed master environment');
    console.log('');

    // Try to list content types
    try {
      const contentTypes = await environment.getContentTypes();
      console.log(`✅ Successfully listed content types (${contentTypes.items.length} found)`);
      console.log('');
      
      // Check if our content types exist
      const componentColorType = contentTypes.items.find(ct => ct.sys.id === 'componentColor');
      const componentTextType = contentTypes.items.find(ct => ct.sys.id === 'componentText');
      
      console.log('📋 Content Type Status:');
      console.log(`   componentColor: ${componentColorType ? '✅ Exists' : '❌ Not found'}`);
      console.log(`   componentText: ${componentTextType ? '✅ Exists' : '❌ Not found'}`);
      console.log('');
      
      // Check componentText fields if it exists
      if (componentTextType) {
        const hasTextId = componentTextType.fields.some(f => f.id === 'textId');
        const hasText = componentTextType.fields.some(f => f.id === 'text');
        
        console.log('🔍 componentText Field Check:');
        console.log(`   textId field: ${hasTextId ? '✅ Exists' : '❌ MISSING'}`);
        console.log(`   text field: ${hasText ? '✅ Exists' : '❌ MISSING'}`);
        console.log('');
        
        if (!hasTextId || !hasText) {
          console.log('⚠️  ISSUE: componentText is missing required fields!');
          console.log('   This will cause import to fail.');
          console.log('   See FIX_COMPONENT_TEXT_TYPE.md for instructions to fix.');
          console.log('');
          console.log('   Current fields in componentText:');
          componentTextType.fields.forEach(field => {
            console.log(`     - ${field.id} (${field.type})`);
          });
          console.log('');
        }
      }
      
      if (!componentColorType || !componentTextType) {
        console.log('⚠️  Warning: Required content types are missing!');
        console.log('   Please create them before running the import.');
        console.log('   See CONTENTFUL_CONTENT_TYPES.md for instructions.');
      }
    } catch (error) {
      console.log('⚠️  Could not list content types:', error.message);
    }

    console.log('✅ Token is valid and has proper access!');
    console.log('   You can proceed with the import.');

  } catch (error) {
    console.error('');
    console.error('❌ Token test failed:');
    console.error(`   Error: ${error.message}`);
    if (error.response) {
      console.error(`   Status: ${error.response.status}`);
      console.error(`   Details: ${JSON.stringify(error.response.data, null, 2)}`);
    }
    console.error('');
    console.error('💡 Troubleshooting:');
    console.error('   1. Verify the token is correct');
    console.error('   2. Check that the token has access to space w44htb0sb9sl');
    console.error('   3. Ensure the token has not expired');
    console.error('   4. Wait a few moments if the token was just created');
    process.exit(1);
  }
}

testToken();

